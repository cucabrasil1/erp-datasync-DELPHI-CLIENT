unit uSyncOrchestrator;

interface

uses
  System.JSON, System.SysUtils, System.Classes, Data.DB,
  uEntityBase, uApiClient;

type
  TSyncOrchestrator = class
  public
    class function SyncEntity(AEntity: TEntityBase; AApiClient: TApiClient;
      const AType, ACodRecord, ACodFilial: string;
      const AEventApiId: string = ''): TSyncResult; static;

    class function SyncAllEntity(AEntity: TEntityBase; AApiClient: TApiClient;
      const AProgress: TEntityProgress = nil): TSyncResult; static;
  end;

implementation

{ TSyncOrchestrator.SyncEntity }

class function TSyncOrchestrator.SyncEntity(AEntity: TEntityBase;
  AApiClient: TApiClient; const AType, ACodRecord, ACodFilial: string;
  const AEventApiId: string): TSyncResult;
var
  DataSet: TDataSet;
  JsonBody: TJSONObject;
  Response: TJSONObject;
  ApiId: string;
  BodyStr, Resource: string;
begin
  Result.Success    := False;
  Result.ApiId      := '';
  Result.ErrorMessage := '';
  Result.NeedAuth   := False;
  Response := nil;

  try
    Resource := '/api' + AEntity.ResourceName;

    if AType <> 'DELETE' then
    begin
      // INSERT ou UPDATE: le registro, monta JSON, envia
      DataSet := AEntity.GetRecord(ACodRecord);
      try
        if DataSet.IsEmpty then
        begin
          Result.ErrorMessage := 'Registro nao encontrado: ' + ACodRecord;
          Exit;
        end;
        JsonBody := AEntity.MapToJson(DataSet);
        ApiId    := AEntity.GetApiId(DataSet);
      finally
        DataSet.Free;
      end;

      try
        BodyStr := TApiClient.Sanitize(JsonBody.ToString, AEntity.TableName + '.body');

        if ApiId <> '' then
        begin
          // UPDATE
          Response := AApiClient.Put(Resource, ApiId, BodyStr);

          // 404 → fallback POST (reativa na API)
          if Response.GetValue<string>('status') = '404' then
          begin
            FreeAndNil(Response);
            Response := AApiClient.Post(Resource, '[' + BodyStr + ']');
          end;
        end
        else
        begin
          // CREATE
          Response := AApiClient.Post(Resource, '[' + BodyStr + ']');
        end;
      finally
        FreeAndNil(JsonBody);
      end;
    end
    else
    begin
      // DELETE → SoftDelete (PUT com {"deleted":true})
      ApiId := AEventApiId;

      // Fallback: tenta ler ApiId do registro ERP (mas pode ja ter sido deletado)
      if ApiId = '' then
      begin
        DataSet := AEntity.GetRecord(ACodRecord);
        try
          ApiId := AEntity.GetApiId(DataSet);
        finally
          DataSet.Free;
        end;
      end;

      if ApiId = '' then
      begin
        Result.Success := True;
        Exit;
      end;

      AApiClient.SoftDelete(Resource, ApiId);
      Result.Success := True;
      Exit;
    end;

    // Trata resposta (INSERT/UPDATE)
    if (Response.GetValue<string>('status') = '200') or
       (Response.GetValue<string>('status') = '201') then
    begin
      if AApiClient.IsResponseOk(Response, Result.ErrorMessage) then
      begin
        Result.ApiId := AApiClient.ExtractApiId(Response);
        if Result.ApiId <> '' then
        begin
          AEntity.SetContextFlag('DATASYNC_IMPORTING', '1');
          try
            AEntity.StoreApiIdBack(ACodRecord, Result.ApiId);
          finally
            AEntity.SetContextFlag('DATASYNC_IMPORTING', '0');
          end;
        end;
        Result.Success := True;
      end;
    end
    else if Response.GetValue<string>('status') = '204' then
    begin
      Result.Success := True;
    end
    else
    begin
      if Response.GetValue<string>('status') = '401' then
      begin
        Result.NeedAuth := True;
        Result.ErrorMessage := 'Token expirado';
      end
      else
      begin
        if Assigned(Response.GetValue('erro')) then
          Result.ErrorMessage := Response.GetValue<string>('status') + ': ' +
            Response.GetValue('erro').ToString
        else
        begin
          Result.ErrorMessage := Response.GetValue<string>('status') + ': ';
          AApiClient.IsResponseOk(Response, Result.ErrorMessage);
        end;
      end;
    end;

    FreeAndNil(Response);
  except
    on E: Exception do
    begin
      FreeAndNil(Response);
      Result.ErrorMessage := E.Message;
    end;
  end;
end;

{ TSyncOrchestrator.SyncAllEntity }

class function TSyncOrchestrator.SyncAllEntity(AEntity: TEntityBase;
  AApiClient: TApiClient; const AProgress: TEntityProgress): TSyncResult;
var
  DataSet: TDataSet;
  Arr: TJSONArray;
  CodRecords: TStringList;
  Response: TJSONObject;
  DataArr: TJSONArray;
  i, idx, BatchPos, BatchSize: Integer;
  ApiId, ItemCod, BodyStr, Resource: string;
  InnerVal, ArrVal2: TJSONValue;
begin
  Result.Success      := False;
  Result.ApiId        := '';
  Result.ErrorMessage := '';
  Result.NeedAuth     := False;
  Response := nil;
  DataArr := nil;

  Resource   := '/api' + AEntity.ResourceName;
  BatchSize  := AEntity.GetBatchSize;
  BatchPos   := 0;

  DataSet := AEntity.GetUnsyncedRecords;
  try
    Result.RecordCount := DataSet.RecordCount;
    if DataSet.IsEmpty then
    begin
      Result.Success := True;
      Result.ErrorMessage := 'Nenhum registro pendente';
      Exit;
    end;

    DataSet.First;

    while not DataSet.Eof do
    begin
      Arr := TJSONArray.Create;
      CodRecords := TStringList.Create;
      try
        // Monta batch
        while (CodRecords.Count < BatchSize) and not DataSet.Eof do
        begin
          Arr.AddElement(AEntity.MapToJson(DataSet));
          CodRecords.Add(DataSet.FieldByName(AEntity.GetErpPKFieldName).AsString);
          DataSet.Next;
          Inc(BatchPos);
        end;

        if Arr.Count < 1 then
          Break;

        if Assigned(AProgress) then
          AProgress(Format(sLineBreak + '%s | Enviando lote com %d registro(s) (%d de %d)',
            [FormatDateTime('hh:nn:ss', Now), Arr.Count, BatchPos, Result.RecordCount]));

        BodyStr := TApiClient.Sanitize(Arr.ToString, AEntity.TableName + '.batch');
        Response := AApiClient.Post(Resource, BodyStr);

        // Valida status
        if (Response.GetValue<string>('status') <> '200') and
           (Response.GetValue<string>('status') <> '201') then
        begin
          if Response.GetValue<string>('status') = '401' then
            Result.NeedAuth := True
          else
          begin
            if Assigned(Response.GetValue('erro')) then
              Result.ErrorMessage := Response.GetValue<string>('status') + ': ' +
                Response.GetValue('erro').ToString
            else
            begin
              Result.ErrorMessage := Response.GetValue<string>('status') + ': ';
              AApiClient.IsResponseOk(Response, Result.ErrorMessage);
            end;
          end;
          if Assigned(AProgress) then
            AProgress(Format('%s | Lote falhou: %s',
              [FormatDateTime('hh:nn:ss', Now), Result.ErrorMessage]));
          Exit;
        end;

        if not AApiClient.IsResponseOk(Response, Result.ErrorMessage) then
          Exit;

        if Assigned(AProgress) then
          AProgress(Format('%s | Lote de %d registro(s) enviado com sucesso',
            [FormatDateTime('hh:nn:ss', Now), Arr.Count]));

        // Parse do array retornado
        DataArr := nil;
        InnerVal := Response.GetValue('data');
        if Assigned(InnerVal) and (InnerVal is TJSONObject) then
        begin
          ArrVal2 := TJSONObject(InnerVal).GetValue('data');
          if Assigned(ArrVal2) and (ArrVal2 is TJSONArray) then
            DataArr := TJSONArray(ArrVal2);
        end;

        if (not Assigned(DataArr)) or (DataArr.Count < CodRecords.Count) then
        begin
          Result.ErrorMessage := 'Resposta da API com quantidade inesperada de itens';
          Exit;
        end;

        // StoreApiIdBack para cada item
        AEntity.SetContextFlag('DATASYNC_IMPORTING', '1');
        try
          for i := 0 to DataArr.Count - 1 do
          begin
            if not (DataArr.Items[i] is TJSONObject) then Continue;
            ItemCod := '';
            TJSONObject(DataArr.Items[i]).TryGetValue<string>('codigoerp', ItemCod);
            if ItemCod = '' then Continue;
            ApiId := '';
            TJSONObject(DataArr.Items[i]).TryGetValue<string>('id', ApiId);
            if ApiId = '' then Continue;
            idx := CodRecords.IndexOf(ItemCod);
            if idx >= 0 then
              AEntity.StoreApiIdBack(CodRecords[idx], ApiId);
          end;
        finally
          AEntity.SetContextFlag('DATASYNC_IMPORTING', '0');
        end;

        FreeAndNil(Response);
      finally
        FreeAndNil(Response);
        FreeAndNil(CodRecords);
        FreeAndNil(Arr);
      end;
    end;

    if Result.ErrorMessage = '' then
      Result.Success := True;
  finally
    DataSet.Free;
  end;
end;

end.
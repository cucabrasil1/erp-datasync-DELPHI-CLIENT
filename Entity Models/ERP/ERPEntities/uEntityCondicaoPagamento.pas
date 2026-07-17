unit uEntityCondicaoPagamento;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uCondicaoPagamentoAPI;

type
  TEntityCondicaoPagamento = class(TEntityBase)
  protected
    class function GetTableNameClass: string; override;
    function GetResourceName: string; override;
    function GetRecord(ACodRecord: string): TDataSet; override;
    function MapToJson(ADataSet: TDataSet): TJSONObject; override;
    function GetApiId(ADataSet: TDataSet): string; override;
    function GetUnsyncedRecords: TDataSet; override;
    function GetBatchSize: Integer; override;
    function GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string; override;
    procedure StoreApiIdBack(ACodRecord, AApiId: string); override;
  end;

implementation

uses
  FireDAC.Stan.Param, uEntityFactory;

{ TEntityCondicaoPagamento }

class function TEntityCondicaoPagamento.GetTableNameClass: string;
begin
  Result := 'C000015';
end;

function TEntityCondicaoPagamento.GetResourceName: string;
begin
  Result := TCondicaoPagamentoAPI.ResourceName;
end;

function TEntityCondicaoPagamento.GetRecord(ACodRecord: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityCondicaoPagamento.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDFORMAPAGAMENTO').AsString
  else
    Result := ADataSet.FieldByName('IDFORMAPAGAMENTO').AsString;
end;

function TEntityCondicaoPagamento.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TCondicaoPagamentoAPI;
  QryDet: TFDQuery;
begin
  DTO := TCondicaoPagamentoAPI.Create;
  try
    DTO.codigoerp        := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao        := ADataSet.FieldByName('condpgto').AsString;
    DTO.codtipopagamento := ADataSet.FieldByName('codtipopagamento').AsString;
    DTO.qtdeparcelas     := ADataSet.FieldByName('parcelas').AsInteger;
    DTO.habilitado       := IfThen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);

    QryDet := TFDQuery.Create(nil);
    try
      QryDet.Connection := FConnection;
      QryDet.SQL.Add('select * from C000016');
      QryDet.SQL.Add('where codcondpgto = :cod');
      QryDet.SQL.Add('order by numero');
      QryDet.ParamByName('cod').AsString := ADataSet.FieldByName('codigo').AsString;
      QryDet.Open;

      while not QryDet.Eof do
      begin
        DTO.AddParcela(
          QryDet.FieldByName('codigo').AsString,
          QryDet.FieldByName('numero').AsInteger,
          QryDet.FieldByName('dias').AsInteger,
          QryDet.FieldByName('percentual').AsFloat,
          QryDet.FieldByName('juros').AsFloat
        );
        QryDet.Next;
      end;
    finally
      QryDet.Free;
    end;

    case FDatabaseType of
      dtIndustrial:
      begin
        // <<CHANGE_ME: campos especificos industrial>>
      end;

      dtCommercial:
      begin
        // <<CHANGE_ME: campos especificos comercial>>
      end;
    end;

    Result := DTO.ToJson;
  finally
    DTO.Free;
  end;
end;

function TEntityCondicaoPagamento.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDFORMAPAGAMENTO is null');
    Qry.SQL.Add('order by codigo');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityCondicaoPagamento.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityCondicaoPagamento.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Condicoes de Pagamento sincronizados com sucesso'
  else
    Result := 'Erro em Condicoes de Pagamento: ' + AErrorMsg;
end;

procedure TEntityCondicaoPagamento.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDFORMAPAGAMENTO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityCondicaoPagamento.GetTableNameClass, TEntityCondicaoPagamento);
end.







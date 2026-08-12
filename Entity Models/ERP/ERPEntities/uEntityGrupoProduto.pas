unit uEntityGrupoProduto;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uGrupoProdutoAPI;

type
  TEntityGrupoProduto = class(TEntityBase)
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

{ TEntityGrupoProduto }

class function TEntityGrupoProduto.GetTableNameClass: string;
begin
  Result := 'C000017';
end;

function TEntityGrupoProduto.GetResourceName: string;
begin
  Result := TGrupoProdutoAPI.ResourceName;
end;

function TEntityGrupoProduto.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityGrupoProduto.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDGRUPO').AsString
  else
    Result := ADataSet.FieldByName('IDGRUPO').AsString;
end;

function TEntityGrupoProduto.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TGrupoProdutoAPI;
begin
  DTO := TGrupoProdutoAPI.Create;
  try
    DTO.codigoerp  := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao  := ADataSet.FieldByName('grupo').AsString;
    DTO.comissao   := ADataSet.FieldByName('comissao').AsFloat;
    DTO.desconto   := ADataSet.FieldByName('desconto').AsFloat;
    DTO.habilitadoweb := IfThen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);

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

function TEntityGrupoProduto.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDGRUPO is null');
    if FDatabaseType = dtIndustrial then
    begin
      Qry.SQL.Add('and codigofilial = :filial');
      Qry.ParamByName('filial').AsString := FFilial;
    end;
    Qry.SQL.Add('order by codigo');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityGrupoProduto.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityGrupoProduto.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Grupos de Produto sincronizados com sucesso'
  else
    Result := 'Erro em Grupos de Produto: ' + AErrorMsg;
end;

procedure TEntityGrupoProduto.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDGRUPO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityGrupoProduto.GetTableNameClass, TEntityGrupoProduto);
end.







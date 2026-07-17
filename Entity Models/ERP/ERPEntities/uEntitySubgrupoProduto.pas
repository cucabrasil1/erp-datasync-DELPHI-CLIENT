unit uEntitySubgrupoProduto;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uSubgrupoProdutoAPI;

type
  TEntitySubgrupoProduto = class(TEntityBase)
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

{ TEntitySubgrupoProduto }

class function TEntitySubgrupoProduto.GetTableNameClass: string;
begin
  Result := 'C000018';
end;

function TEntitySubgrupoProduto.GetResourceName: string;
begin
  Result := TSubgrupoProdutoAPI.ResourceName;
end;

function TEntitySubgrupoProduto.GetRecord(ACodRecord: string): TDataSet;
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

function TEntitySubgrupoProduto.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDSUBGRUPO').AsString
  else
    Result := ADataSet.FieldByName('IDSUBGRUPO').AsString;
end;

function TEntitySubgrupoProduto.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TSubgrupoProdutoAPI;
begin
  DTO := TSubgrupoProdutoAPI.Create;
  try
    DTO.codigoerp  := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao  := ADataSet.FieldByName('subgrupo').AsString;
    DTO.codgrupo   := ADataSet.FieldByName('codgrupo').AsString;
    DTO.comissao   := ADataSet.FieldByName('comissao').AsFloat;
    DTO.desconto   := ADataSet.FieldByName('desconto').AsFloat;
    DTO.habilitado := IfThen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);

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

function TEntitySubgrupoProduto.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDSUBGRUPO is null');
    Qry.SQL.Add('order by codigo');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntitySubgrupoProduto.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntitySubgrupoProduto.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Subgrupos de Produto sincronizados com sucesso'
  else
    Result := 'Erro em Subgrupos de Produto: ' + AErrorMsg;
end;

procedure TEntitySubgrupoProduto.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDSUBGRUPO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntitySubgrupoProduto.GetTableNameClass, TEntitySubgrupoProduto);
end.







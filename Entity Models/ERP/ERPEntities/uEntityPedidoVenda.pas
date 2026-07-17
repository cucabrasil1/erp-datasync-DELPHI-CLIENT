unit uEntityPedidoVenda;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase;

type
  TEntityPedidoVenda = class(TEntityBase)
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

{ TEntityPedidoVenda }

class function TEntityPedidoVenda.GetTableNameClass: string;
begin
  Result := 'C000126';
end;

function TEntityPedidoVenda.GetResourceName: string;
begin
  Result := '/pedidos-venda';
end;

function TEntityPedidoVenda.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityPedidoVenda.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDPEDIDO').AsString
  else
    Result := ADataSet.FieldByName('IDPEDIDO').AsString;
end;

function TEntityPedidoVenda.MapToJson(ADataSet: TDataSet): TJSONObject;
begin
  Result := TJSONObject.Create;

  // <<CHANGE_ME: mapear campos do banco para JSON da API>>

  Result.AddPair('codigoerp', ADataSet.FieldByName('codigo').AsString);

  if ADataSet.FieldByName('situacao').AsInteger = 1 then
    Result.AddPair('ativo', 1)
  else
    Result.AddPair('ativo', 0);

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
end;

function TEntityPedidoVenda.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDPEDIDO is null');
    Qry.SQL.Add('order by codigo');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityPedidoVenda.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityPedidoVenda.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Pedidos de Venda sincronizados com sucesso'
  else
    Result := 'Erro em Pedidos de Venda: ' + AErrorMsg;
end;

procedure TEntityPedidoVenda.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDPEDIDO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityPedidoVenda.GetTableNameClass, TEntityPedidoVenda);
end.






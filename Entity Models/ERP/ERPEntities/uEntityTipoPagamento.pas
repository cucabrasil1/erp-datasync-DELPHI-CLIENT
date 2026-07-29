unit uEntityTipoPagamento;

interface

uses
  System.JSON, System.SysUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, System.StrUtils, system.Math, uTipoPagamentoAPI;

type
  TEntityTipoPagamento = class(TEntityBase)
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

{ TEntityTipoPagamento }

class function TEntityTipoPagamento.GetTableNameClass: string;
begin
  Result := 'C000014';
end;

function TEntityTipoPagamento.GetResourceName: string;
begin
  Result := TTipoPagamentoAPI.ResourceName;
end;

function TEntityTipoPagamento.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityTipoPagamento.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDTIPOPAGAMENTO').AsString
  else
    Result := ADataSet.FieldByName('IDTIPOPAGAMENTO').AsString;
end;

function TEntityTipoPagamento.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TTipoPagamentoAPI;
begin
  DTO := TTipoPagamentoAPI.Create;
  try
    DTO.codigoerp  := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao  := ADataSet.FieldByName('formapgto').AsString;
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

function TEntityTipoPagamento.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDTIPOPAGAMENTO is null');
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

function TEntityTipoPagamento.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityTipoPagamento.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Tipos de Pagamento sincronizados com sucesso'
  else
    Result := 'Erro em Tipos de Pagamento: ' + AErrorMsg;
end;

procedure TEntityTipoPagamento.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDTIPOPAGAMENTO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityTipoPagamento.GetTableNameClass, TEntityTipoPagamento);
end.







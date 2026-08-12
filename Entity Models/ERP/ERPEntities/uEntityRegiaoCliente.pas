unit uEntityRegiaoCliente;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uRegiaoClienteAPI;

type
  TEntityRegiao = class(TEntityBase)
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

{ TEntityRegiao }

class function TEntityRegiao.GetTableNameClass: string;
begin
  Result := 'C000005';
end;

function TEntityRegiao.GetResourceName: string;
begin
  Result := TRegiaoClienteAPI.ResourceName;
end;

function TEntityRegiao.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityRegiao.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDREGIAO').AsString
  else
    Result := ADataSet.FieldByName('IDREGIAO').AsString;
end;

function TEntityRegiao.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TRegiaoClienteAPI;
begin
  DTO := TRegiaoClienteAPI.Create;
  try
    DTO.codigoerp           := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao           := ADataSet.FieldByName('regiao').AsString;
    DTO.percentualfretecif  := ADataSet.FieldByName('percentualfretecif').AsFloat;
    DTO.habilitadoweb          := IfThen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);

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

function TEntityRegiao.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDREGIAO is null');
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

function TEntityRegiao.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityRegiao.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Regiao de Clientes sincronizados com sucesso'
  else
    Result := 'Erro em Regiao de Clientes: ' + AErrorMsg;
end;

procedure TEntityRegiao.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDREGIAO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityRegiao.GetTableNameClass, TEntityRegiao);
end.







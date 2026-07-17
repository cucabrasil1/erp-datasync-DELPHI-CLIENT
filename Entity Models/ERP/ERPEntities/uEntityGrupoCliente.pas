unit uEntityGrupoCliente;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uGrupoClienteAPI;

type
  TEntityGrupoCliente = class(TEntityBase)
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

{ TEntityGrupoCliente }

class function TEntityGrupoCliente.GetTableNameClass: string;
begin
  Result := 'C000144';
end;

function TEntityGrupoCliente.GetResourceName: string;
begin
  Result := TGrupoClienteAPI.ResourceName;
end;

function TEntityGrupoCliente.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityGrupoCliente.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDGRUPOCLIENTE').AsString
  else
    Result := ADataSet.FieldByName('IDGRUPOCLIENTE').AsString;
end;

function TEntityGrupoCliente.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TGrupoClienteAPI;
begin
  DTO := TGrupoClienteAPI.Create;
  try
    DTO.codigoerp  := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao  := ADataSet.FieldByName('nomegrupo').AsString;
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

function TEntityGrupoCliente.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDGRUPOCLIENTE is null');
    Qry.SQL.Add('order by codigo');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityGrupoCliente.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityGrupoCliente.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Grupos de Cliente sincronizados com sucesso'
  else
    Result := 'Erro em Grupos de Cliente: ' + AErrorMsg;
end;

procedure TEntityGrupoCliente.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDGRUPOCLIENTE = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityGrupoCliente.GetTableNameClass, TEntityGrupoCliente);
end.





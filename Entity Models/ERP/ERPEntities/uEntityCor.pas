unit uEntityCor;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uCorAPI;

type
  TEntityCor = class(TEntityBase)
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

{ TEntityCor }

class function TEntityCor.GetTableNameClass: string;
begin
  Result := 'C000129';
end;

function TEntityCor.GetResourceName: string;
begin
  Result := TCorAPI.ResourceName;
end;

function TEntityCor.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityCor.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDCOR').AsString
  else
    Result := ADataSet.FieldByName('IDCOR').AsString;
end;

function TEntityCor.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TCorAPI;
begin
  DTO := TCorAPI.Create;
  try
    DTO.codigoerp  := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao  := ADataSet.FieldByName('cor').AsString;
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

function TEntityCor.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDCOR is null');
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

function TEntityCor.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityCor.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Cores sincronizados com sucesso'
  else
    Result := 'Erro em Cores: ' + AErrorMsg;
end;

procedure TEntityCor.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDCOR = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityCor.GetTableNameClass, TEntityCor);
end.








unit uEntityCenarioFaturamento;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uCenarioFaturamentoAPI;

type
  TEntityCenarioFaturamento = class(TEntityBase)
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

{ TEntityCenarioFaturamento }

class function TEntityCenarioFaturamento.GetTableNameClass: string;
begin
  Result := 'C000233';
end;

function TEntityCenarioFaturamento.GetResourceName: string;
begin
  Result := TCenarioFaturamentoAPI.ResourceName;
end;

function TEntityCenarioFaturamento.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityCenarioFaturamento.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDCENARIO').AsString
  else
    Result := ADataSet.FieldByName('IDCENARIO').AsString;
end;

function TEntityCenarioFaturamento.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TCenarioFaturamentoAPI;
begin
  DTO := TCenarioFaturamentoAPI.Create;
  try
    DTO.codigoerp           := ADataSet.FieldByName('codigo').AsString;
    DTO.descricao           := ADataSet.FieldByName('descricao').AsString;
    DTO.percentual          := ADataSet.FieldByName('percentual').AsFloat;
    DTO.rateioparcelamento := ADataSet.FieldByName('rateioparcelamento').AsInteger;
    DTO.habilitadoweb         := IfThen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);

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

function TEntityCenarioFaturamento.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDCENARIO is null');
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

function TEntityCenarioFaturamento.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityCenarioFaturamento.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Cenarios de Faturamento sincronizados com sucesso'
  else
    Result := 'Erro em Cenarios de Faturamento: ' + AErrorMsg;
end;

procedure TEntityCenarioFaturamento.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDCENARIO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityCenarioFaturamento.GetTableNameClass, TEntityCenarioFaturamento);
end.








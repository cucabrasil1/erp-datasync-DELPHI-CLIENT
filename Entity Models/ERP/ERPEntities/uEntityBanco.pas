unit uEntityBanco;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uInstituicoesFinancirasAPI;

type
  TEntityBanco = class(TEntityBase)
  protected
    class function GetTableNameClass: string; override;
    function GetResourceName: string; override;
    function GetErpPKFieldName: string; override;
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

{ TEntityBanco }

class function TEntityBanco.GetTableNameClass: string;
begin
  Result := 'C000013';
end;

function TEntityBanco.GetResourceName: string;
begin
  Result := TInstituicoesFinancirasAPI.ResourceName;
end;

function TEntityBanco.GetErpPKFieldName: string;
begin
  Result := 'numero';
end;

function TEntityBanco.GetRecord(ACodRecord: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where numero = :cod');
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityBanco.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDBANCO').AsString
  else
    Result := ADataSet.FieldByName('IDBANCO').AsString;
end;

function TEntityBanco.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TInstituicoesFinancirasAPI;
begin
  DTO := TInstituicoesFinancirasAPI.Create;
  try
    DTO.descricao       := ADataSet.FieldByName('banco').AsString;
    DTO.numerobanco     := ADataSet.FieldByName('numero').AsString;
    DTO.tipo            := IfThen(ADataSet.FieldByName('financeira').AsInteger = 1, 'FINANCEIRA', 'BANCO');
    DTO.cartaocredito   := IfThen(ADataSet.FieldByName('cartao_credito').AsInteger = 1, 1, 0);
    DTO.creditocomissao := ADataSet.FieldByName('comissao_credito').AsCurrency;
    DTO.creditoprazo    := ADataSet.FieldByName('rec_credito').AsInteger;
    DTO.debitocomissao  := ADataSet.FieldByName('comissao_debito').AsCurrency;
    DTO.debitoprazo     := ADataSet.FieldByName('rec_debito').AsInteger;
    DTO.habilitadoweb      := IfThen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);

    case FDatabaseType of
      dtIndustrial:
      begin
      end;

      dtCommercial:
      begin
      end;
    end;

    Result := DTO.ToJson;
  finally
    DTO.Free;
  end;
end;

function TEntityBanco.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDBANCO is null');
    Qry.SQL.Add('order by numero');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityBanco.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityBanco.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Bancos sincronizados com sucesso'
  else
    Result := 'Erro em Bancos: ' + AErrorMsg;
end;

procedure TEntityBanco.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDBANCO = :apiid');
    Qry.SQL.Add('where numero = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityBanco.GetTableNameClass, TEntityBanco);
end.

unit uEntityVariacaoProduto;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uVariacaoProdutoAPI;

type
  TEntityVariacaoProduto = class(TEntityBase)
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

{ TEntityVariacaoProduto }

class function TEntityVariacaoProduto.GetTableNameClass: string;
begin
  Result := 'C000279';
end;

function TEntityVariacaoProduto.GetResourceName: string;
begin
  Result := TVariacaoProdutoAPI.ResourceName;
end;

function TEntityVariacaoProduto.GetRecord(ACodRecord: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where codigo = :cod');
    Qry.SQL.Add('and variacaobase = ''N''');
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityVariacaoProduto.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDVARIACAO').AsString
  else
    Result := ADataSet.FieldByName('IDVARIACAO').AsString;
end;

function TEntityVariacaoProduto.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  Variacao: TVariacaoProdutoAPI;
begin
  Variacao := TVariacaoProdutoAPI.Create;
  try
    case FDatabaseType of
      dtIndustrial:
      begin
        Variacao.codigoerp  := ADataSet.FieldByName('codigo').AsString;
        Variacao.codproduto := ADataSet.FieldByName('codproduto').AsString;
        Variacao.descricao  := ADataSet.FieldByName('descricao_variacao').AsString;
        Variacao.ativo      := IfThen(ADataSet.FieldByName('ativo').AsString = 'S', 1, 0);
        Variacao.variacaobase := IfThen(ADataSet.FieldByName('variacaobase').AsString = 'S', 1, 0);
        Variacao.precocusto := ADataSet.FieldByName('precocusto').AsCurrency;
        Variacao.habilitado := IfThen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);

        if ADataSet.FieldByName('datamodificacao').IsNull then
          Variacao.datamodificacao := ''
        else
          Variacao.datamodificacao := FormatDateTime('yyyy-mm-dd hh:nn:ss',
            ADataSet.FieldByName('datamodificacao').AsDateTime);
      end;

      dtCommercial:
      begin
      end;
    end;

    Result := Variacao.ToJson;
  finally
    Variacao.Free;
  end;
end;

function TEntityVariacaoProduto.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDVARIACAO is null');
    Qry.SQL.Add('and variacaobase = ''N''');
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

function TEntityVariacaoProduto.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityVariacaoProduto.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Variacoes de Produto sincronizados com sucesso'
  else
    Result := 'Erro em Variacoes de Produto: ' + AErrorMsg;
end;

procedure TEntityVariacaoProduto.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDVARIACAO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityVariacaoProduto.GetTableNameClass, TEntityVariacaoProduto);
end.






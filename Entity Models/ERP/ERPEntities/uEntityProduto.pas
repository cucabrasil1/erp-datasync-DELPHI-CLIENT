unit uEntityProduto;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uProdutoAPI;

type
  TEntityProduto = class(TEntityBase)
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

{ TEntityProduto }

class function TEntityProduto.GetTableNameClass: string;
begin
  Result := 'C000025';
end;

function TEntityProduto.GetResourceName: string;
begin
  Result := TProdutoAPI.ResourceName;
end;

function TEntityProduto.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityProduto.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDPRODUTO').AsString
  else
    Result := ADataSet.FieldByName('IDPRODUTO').AsString; // ajustar para comercial se diferente
end;

function TEntityProduto.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TProdutoAPI;
begin
  DTO := TProdutoAPI.Create;
  try
    DTO.codigoerp      := ADataSet.FieldByName('codigo').AsString;
    DTO.produto        := ADataSet.FieldByName('produto').AsString;
    DTO.referencia     := ADataSet.FieldByName('referencia').AsString;
    DTO.codbarras      := ADataSet.FieldByName('codbarra').AsString;
    DTO.unidade        := ADataSet.FieldByName('unidade').AsString;
    DTO.ncm            := ADataSet.FieldByName('ncm').AsString;
    DTO.cest           := ADataSet.FieldByName('codigocest').AsString;
    DTO.precocompra    := ADataSet.FieldByName('precocompra').AsFloat;
    DTO.precocusto     := ADataSet.FieldByName('precocusto').AsFloat;
    DTO.precovenda     := ADataSet.FieldByName('precovenda').AsFloat;
    DTO.tipo           := ADataSet.FieldByName('tipo').AsString;
    DTO.qtdevolume     := 1;
    DTO.m3             := 0;
    DTO.pesobruto      := 0;
    DTO.pesoliquido    := 0;
    DTO.ativo          := 'S';
    DTO.caminhoimagem1 := '';
    DTO.caminhoimagem2 := '';
    DTO.caminhoimagem3 := '';

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

function TEntityProduto.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where idproduto is null');
    Qry.SQL.Add('order by codigo');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityProduto.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityProduto.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Produtos sincronizados com sucesso'
  else
    Result := 'Erro em Produtos: ' + AErrorMsg;
end;

procedure TEntityProduto.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set idproduto = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityProduto.GetTableNameClass, TEntityProduto);
end.








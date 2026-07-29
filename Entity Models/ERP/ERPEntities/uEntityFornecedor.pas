unit uEntityFornecedor;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uPessoaAPI;

type
  TEntityFornecedor = class(TEntityBase)
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

{ TEntityFornecedor }

class function TEntityFornecedor.GetTableNameClass: string;
begin
  Result := 'C000009';
end;

function TEntityFornecedor.GetResourceName: string;
begin
  Result := TPessoaAPI.ResourceName;
end;

function TEntityFornecedor.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityFornecedor.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDFORNECEDOR').AsString
  else
    Result := ADataSet.FieldByName('IDFORNECEDOR').AsString;
end;

function TEntityFornecedor.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  Pessoa: TPessoaAPI;
begin
  Pessoa := TPessoaAPI.Create;
  try
    Pessoa.habilitado           := ifthen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);
    Pessoa.perfilfornecedor     := 1;
    Pessoa.codigoerp            := ADataSet.FieldByName('codigo').AsString;
    Pessoa.nome                 := ADataSet.FieldByName('nome').AsString;
    Pessoa.nomefantasia         := ADataSet.FieldByName('fantasia').AsString;
    Pessoa.logradouro           := ADataSet.FieldByName('endereco').AsString;
    Pessoa.cep                  := ADataSet.FieldByName('cep').AsString;
    Pessoa.bairro               := ADataSet.FieldByName('bairro').AsString;
    Pessoa.cidade               := ADataSet.FieldByName('cidade').AsString;
    Pessoa.uf                   := ADataSet.FieldByName('uf').AsString;
    Pessoa.ibge                 := ADataSet.FieldByName('cod_municipio_ibge').AsString;
    Pessoa.numero               := ADataSet.FieldByName('numero').AsString;
    Pessoa.complemento          := ADataSet.FieldByName('complemento').AsString;
    Pessoa.documentoprincipal   := ADataSet.FieldByName('cnpj').AsString;
    Pessoa.documentosecundario  := ADataSet.FieldByName('ie').AsString;
    Pessoa.telefone             := ADataSet.FieldByName('telefone1').AsString;
    Pessoa.celular              := ADataSet.FieldByName('telefone2').AsString;
    Pessoa.email                := ADataSet.FieldByName('email').AsString;
    Pessoa.observacoes          := ADataSet.FieldByName('obs1').AsString + sLineBreak + ADataSet.FieldByName('obs2').AsString + sLineBreak + ADataSet.FieldByName('obs3').AsString;
    Pessoa.ativo                := ifthen(ADataSet.FieldByName('situacao').AsInteger = 1, 1, 0);

    case ADataSet.FieldByName('tipo').asinteger of
      1: Pessoa.tipopessoa      := 'FISICA';
      2: Pessoa.tipopessoa      := 'JURIDICA';
      3: Pessoa.tipopessoa      := 'PRODUTORRURAL';
      else Pessoa.tipopessoa    := 'OUTRO';
    end;

    if ADataSet.FieldByName('data').IsNull then
      Pessoa.datacadastro := ''
    else
      Pessoa.datacadastro := FormatDateTime('yyyy-mm-dd', ADataSet.FieldByName('data_cadastro').AsDateTime);

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

    //Add contatos
    Pessoa.AddContato('Contato 1', ADataSet.FieldByName('celular1').AsString, '', '');
    Pessoa.AddContato('Contato 2', ADataSet.FieldByName('celular2').AsString, '', '');

    //Add dados bancarios
    Pessoa.AddDadosBancarios('', '', ADataSet.FieldByName('banco').AsString,
                            ADataSet.FieldByName('agencia').AsString,
                            ADataSet.FieldByName('conta').AsString,
                            '', '', '', ''
    );

    Result := Pessoa.ToJson;
  finally
    Pessoa.Free;
  end;
end;

function TEntityFornecedor.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDFORNECEDOR is null');
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

function TEntityFornecedor.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityFornecedor.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Fornecedores sincronizados com sucesso'
  else
    Result := 'Erro em Fornecedores: ' + AErrorMsg;
end;

procedure TEntityFornecedor.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDFORNECEDOR = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityFornecedor.GetTableNameClass, TEntityFornecedor);
end.

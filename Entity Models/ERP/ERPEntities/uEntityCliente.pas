unit uEntityCliente;

interface

uses
  System.JSON, System.SysUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, System.Math, system.StrUtils, uPessoaAPI;

type
  TEntityCliente = class(TEntityBase)
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
    procedure LoadFromDTO(const ADTO: TPessoaAPI);
    function GetContatosTabC000276(ACodCliente: string): TDataSet;
    function GetEnderecosTabC000183(ACodCliente: string): TDataSet;
  end;

implementation

uses
  FireDAC.Stan.Param, uEntityFactory;

{ TEntityCliente }

class function TEntityCliente.GetTableNameClass: string;
begin
  Result := 'C000007';
end;

function TEntityCliente.GetResourceName: string;
begin
  Result := TPessoaAPI.ResourceName;
end;

function TEntityCliente.GetRecord(ACodRecord: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select c.*, r.idregiao, g.idgrupocliente,');
    Qry.SQL.Add('case when exists (select 1 from C000183 e where e.codcliente = c.codigo)');
    Qry.SQL.Add('  then 1 else 0 end as possui_endereco');
    Qry.SQL.Add('from ' + GetTableNameClass + ' c');
    Qry.SQL.Add('left join C000005 r on r.codigo = c.codregiao');
    Qry.SQL.Add('left join C000144 g on g.codigo = c.codigogrupo');
    Qry.SQL.Add('where c.codigo = :cod');
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityCliente.GetContatosTabC000276(ACodCliente: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from C000276');
    Qry.SQL.Add('where codcliente = :cod');
    Qry.ParamByName('cod').AsString := ACodCliente;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityCliente.GetEnderecosTabC000183(ACodCliente: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from C000183');
    Qry.SQL.Add('where codcliente = :cod');
    Qry.SQL.Add('order by codigo');
    Qry.ParamByName('cod').AsString := ACodCliente;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityCliente.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDCLIENTE').AsString
  else
    Result := ADataSet.FieldByName('IDCLIENTE').AsString; // ajustar para comercial se diferente
end;

function TEntityCliente.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  Pessoa: TPessoaAPI;
  ContatosDs: TDataSet;
  EnderecosDs: TDataSet;
begin
  Pessoa := TPessoaAPI.Create;
  try
    Pessoa.habilitado          := ifthen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);
    Pessoa.perfilcliente       := 1;
    Pessoa.codigoerp           := ADataSet.FieldByName('codigo').AsString;;
    Pessoa.nome                := ADataSet.FieldByName('nome').AsString;
    Pessoa.nomefantasia        := ADataSet.FieldByName('apelido').AsString;
    Pessoa.logradouro          := ADataSet.FieldByName('endereco').AsString;
    Pessoa.cep                 := ADataSet.FieldByName('cep').AsString;
    Pessoa.bairro              := ADataSet.FieldByName('bairro').AsString;
    Pessoa.cidade              := ADataSet.FieldByName('cidade').AsString;
    Pessoa.uf                  := ADataSet.FieldByName('uf').AsString;
    Pessoa.ibge                := ADataSet.FieldByName('cod_municipio_ibge').AsString;
    Pessoa.numero              := ADataSet.FieldByName('numeroimovel').AsString;
    Pessoa.complemento         := ADataSet.FieldByName('complemento').AsString;
    Pessoa.documentoprincipal  := ADataSet.FieldByName('cpf').AsString;
    Pessoa.documentosecundario := ADataSet.FieldByName('rg').AsString;
    Pessoa.telefone            := ADataSet.FieldByName('telefone1').AsString;
    Pessoa.celular             := ADataSet.FieldByName('celular').AsString;
    Pessoa.email               := ADataSet.FieldByName('email').AsString;
    Pessoa.observacoes         := ADataSet.FieldByName('observacaogeral').AsString;
    Pessoa.sexo                := ADataSet.FieldByName('sexo').AsString;
    Pessoa.ativo               := ifthen(ADataSet.FieldByName('situacao').AsInteger = 1, 1, 0);
    Pessoa.tipopessoa          := IfThen(ADataSet.FieldByName('tipo').asinteger = 1, 'FISICA', 'JURIDICA');
    Pessoa.idclientegrupo      := ADataSet.FieldByName('IDGRUPOCLIENTE').AsString;
    Pessoa.idclienteregiao     := ADataSet.FieldByName('IDREGIAO').AsString;

    if ADataSet.FieldByName('nascimento').AsString.Trim.IsEmpty then
      Pessoa.datafundacaonascimento := ''
    else
      Pessoa.datafundacaonascimento := FormatDateTime('yyyy-mm-dd', StrToDateTime(ADataSet.FieldByName('nascimento').AsString));

    if ADataSet.FieldByName('data_cadastro').IsNull then
      Pessoa.datacadastro := ''
    else
      Pessoa.datacadastro := FormatDateTime('yyyy-mm-dd', ADataSet.FieldByName('data_cadastro').AsDateTime);

    if ADataSet.FieldByName('data_ultimacompra').IsNull then
      Pessoa.dataultimacompra := ''
    else
      Pessoa.dataultimacompra := FormatDateTime('yyyy-mm-dd', ADataSet.FieldByName('data_ultimacompra').AsDateTime);


    if ADataSet.FieldByName('telefone2').AsString <> '' then
      Pessoa.AddContato('Telefone 2', ADataSet.FieldByName('telefone2').AsString, '', '');
    if ADataSet.FieldByName('telefone3').AsString <> '' then
      Pessoa.AddContato('Telefone 3', ADataSet.FieldByName('telefone3').AsString, '', '');
    if ADataSet.FieldByName('contato').AsString <> '' then
      Pessoa.AddContato('Contato',    ADataSet.FieldByName('contato').AsString, '', '');

    case FDatabaseType of
      dtIndustrial:
      begin
        // <<CHANGE_ME: campos especificos industrial>>
        Pessoa.nomefantasia        := ADataSet.FieldByName('nomefantasia').AsString;

        // Contatos da tabela C000276
        ContatosDs := GetContatosTabC000276(ADataSet.FieldByName('codigo').AsString);
        try
          while not ContatosDs.Eof do
          begin
              Pessoa.AddContato(ContatosDs.FieldByName('identificador').AsString,
                                ContatosDs.FieldByName('telefone').AsString,
                                ContatosDs.FieldByName('email').AsString,
                                ContatosDs.FieldByName('setor').AsString);
            ContatosDs.Next;
          end;
        finally
          ContatosDs.Free;
        end;
      end;

      dtCommercial:
      begin
        // <<CHANGE_ME: campos especificos comercial>>
      end;
    end;

    // Enderecos adicionais do cliente (C000183)
    if ADataSet.FieldByName('possui_endereco').AsInteger > 0 then
    begin
      EnderecosDs := GetEnderecosTabC000183(ADataSet.FieldByName('codigo').AsString);
      try
        while not EnderecosDs.Eof do
        begin
          Pessoa.AddEndereco(
            EnderecosDs.FieldByName('ENDERECO').AsString,
            EnderecosDs.FieldByName('NUMERO').AsString,
            EnderecosDs.FieldByName('COMPLEMENTO').AsString,
            EnderecosDs.FieldByName('BAIRRO').AsString,
            EnderecosDs.FieldByName('CIDADE').AsString,
            EnderecosDs.FieldByName('UF').AsString,
            EnderecosDs.FieldByName('CEP').AsString,
            EnderecosDs.FieldByName('DESCRICAO').AsString,
            '',
            EnderecosDs.FieldByName('CODIGO').AsString,
            EnderecosDs.FieldByName('COD_MUNICIPIO_IBGE').AsString,
            EnderecosDs.FieldByName('CPFCNPJ').AsString,
            EnderecosDs.FieldByName('RGIE').AsString,
            IfThen(EnderecosDs.FieldByName('ATIVO').AsString = 'S', 1, 0)
          );
          EnderecosDs.Next;
        end;
      finally
        EnderecosDs.Free;
      end;
    end;

    Result := Pessoa.ToJson;
  finally
    Pessoa.Free;
  end;
end;

function TEntityCliente.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select c.*, r.idregiao, g.idgrupocliente,');
    Qry.SQL.Add('case when exists (select 1 from C000183 e where e.codcliente = c.codigo)');
    Qry.SQL.Add('  then 1 else 0 end as possui_endereco');
    Qry.SQL.Add('from ' + GetTableNameClass + ' c');
    Qry.SQL.Add('left join C000005 r on r.codigo = c.codregiao');
    Qry.SQL.Add('left join C000144 g on g.codigo = c.codigogrupo');
    Qry.SQL.Add('where c.idcliente is null');
    if FDatabaseType = dtIndustrial then
    begin
      Qry.SQL.Add('and c.codigofilial = :filial');
      Qry.ParamByName('filial').AsString := FFilial;
    end;
    Qry.SQL.Add('order by c.codigo');
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityCliente.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityCliente.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Clientes sincronizados com sucesso'
  else
    Result := 'Erro em Clientes: ' + AErrorMsg;
end;

procedure TEntityCliente.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set idcliente = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

procedure TEntityCliente.LoadFromDTO(const ADTO: TPessoaAPI);
var
  vTipo: Integer;
begin
  vTipo := 2; // JURIDICA
  if ADTO.tipopessoa = 'FISICA' then
    vTipo := 1;

  with TFDQuery.Create(nil) do
  try
    Connection := FConnection;
    SQL.Add('update ' + GetTableNameClass + ' set');
    SQL.Add('  nome = :nome,');
    SQL.Add('  apelido = :apelido,');
    SQL.Add('  endereco = :endereco,');
    SQL.Add('  cep = :cep,');
    SQL.Add('  bairro = :bairro,');
    SQL.Add('  cidade = :cidade,');
    SQL.Add('  uf = :uf,');
    SQL.Add('  ibge = :ibge,');
    SQL.Add('  numero = :numero,');
    SQL.Add('  complemento = :complemento,');
    SQL.Add('  cpf = :cpf,');
    SQL.Add('  rg = :rg,');
    SQL.Add('  telefone1 = :telefone1,');
    SQL.Add('  celular = :celular,');
    SQL.Add('  email = :email,');
    SQL.Add('  observacaogeral = :observacao,');
    SQL.Add('  sexo = :sexo,');
    SQL.Add('  situacao = :situacao,');
    SQL.Add('  tipo = :tipo,');
    SQL.Add('  habilitadoweb = :habilitadoweb,');
    SQL.Add('  idcliente = :idcliente');
    SQL.Add('where codigo = :codigo');

    ParamByName('codigo').AsString         := ADTO.codigoerp;
    ParamByName('nome').AsString           := ADTO.nome;
    ParamByName('apelido').AsString        := ADTO.nomefantasia;
    ParamByName('endereco').AsString       := ADTO.logradouro;
    ParamByName('cep').AsString            := ADTO.cep;
    ParamByName('bairro').AsString         := ADTO.bairro;
    ParamByName('cidade').AsString         := ADTO.cidade;
    ParamByName('uf').AsString             := ADTO.uf;
    ParamByName('ibge').AsString           := ADTO.ibge;
    ParamByName('numero').AsString         := ADTO.numero;
    ParamByName('complemento').AsString    := ADTO.complemento;
    ParamByName('cpf').AsString            := ADTO.documentoprincipal;
    ParamByName('rg').AsString             := ADTO.documentosecundario;
    ParamByName('telefone1').AsString      := ADTO.telefone;
    ParamByName('celular').AsString        := ADTO.celular;
    ParamByName('email').AsString          := ADTO.email;
    ParamByName('observacao').AsString     := ADTO.observacoes;
    ParamByName('sexo').AsString           := ADTO.sexo;
    ParamByName('situacao').AsInteger      := ADTO.ativo;
    ParamByName('tipo').AsInteger          := vTipo;
    ParamByName('habilitadoweb').AsString  := IfThen(ADTO.habilitado = 1, 'S', 'N');
    ParamByName('idcliente').AsString      := ADTO.id;
    ExecSQL;
  finally
    Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityCliente.GetTableNameClass, TEntityCliente);
end.




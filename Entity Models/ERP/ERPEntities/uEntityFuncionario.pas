unit uEntityFuncionario;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uPessoaAPI;

type
  TEntityFuncionario = class(TEntityBase)
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

{ TEntityFuncionario }

class function TEntityFuncionario.GetTableNameClass: string;
begin
  Result := 'C000008';
end;

function TEntityFuncionario.GetResourceName: string;
begin
  Result := TPessoaAPI.ResourceName;
end;

function TEntityFuncionario.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityFuncionario.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDFUNCIONARIO').AsString
  else
    Result := ADataSet.FieldByName('IDFUNCIONARIO').AsString;
end;

function TEntityFuncionario.MapToJson(ADataSet: TDataSet): TJSONObject;

  function SafeFlagInt(const AFieldName: string): Integer;
  var
    v: string;
  begin
    v := UpperCase(Trim(ADataSet.FieldByName(AFieldName).AsString));
    if (v = 'S') or (v = '1') then
      Exit(1);
    if (v = 'N') or (v = '0') or (v = '') then
      Exit(0);
    try
      Result := StrToInt(v);
    except
      on E: EConvertError do
        raise EConvertError.CreateFmt('C000008.%s invalid value: "%s"', [AFieldName, v]);
    end;
  end;

  function FormatDateField(const AFieldName: string): string;
  begin
    if ADataSet.FieldByName(AFieldName).IsNull then
      Exit('');
    Result := FormatDateTime('yyyy-mm-dd', ADataSet.FieldByName(AFieldName).AsDateTime);
  end;

var
  Pessoa: TPessoaAPI;
begin
  Pessoa := TPessoaAPI.Create;
  try
    Pessoa.habilitadoweb          := ifthen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);
    Pessoa.perfilfuncionario   := 1;
    Pessoa.perfilvendedor      := SafeFlagInt('f_vendedor');
    if ADataSet.FieldByName('situacao').AsInteger = 1 then
      Pessoa.ativo := 1
    else
      Pessoa.ativo := 0;

    Pessoa.codigoerp           := ADataSet.FieldByName('codigo').AsString;;
    Pessoa.nome                := ADataSet.FieldByName('nome').AsString;
    Pessoa.logradouro          := ADataSet.FieldByName('endereco').AsString;
    Pessoa.cep                 := ADataSet.FieldByName('cep').AsString;
    Pessoa.bairro              := ADataSet.FieldByName('bairro').AsString;
    Pessoa.cidade              := ADataSet.FieldByName('cidade').AsString;
    Pessoa.uf                  := ADataSet.FieldByName('uf').AsString;
//    Pessoa.ibge                := ADataSet.FieldByName('cod_municipio_ibge').AsString;
    Pessoa.numero              := ADataSet.FieldByName('numero').AsString;
//    Pessoa.complemento         := ADataSet.FieldByName('complemento').AsString;
    Pessoa.documentoprincipal  := ADataSet.FieldByName('cpf').AsString;
    Pessoa.documentosecundario := ADataSet.FieldByName('rg').AsString;
    Pessoa.telefone            := ADataSet.FieldByName('telefone').AsString;
    Pessoa.celular             := ADataSet.FieldByName('celular').AsString;
    Pessoa.email               := ADataSet.FieldByName('email').AsString;
    Pessoa.observacoes         := ADataSet.FieldByName('obs1').AsString + sLineBreak
                                  + ADataSet.FieldByName('obs2').AsString + sLineBreak
                                  + ADataSet.FieldByName('obs2').AsString + sLineBreak;

//    Pessoa.sexo                := ADataSet.FieldByName('sexo').AsString;
//    Pessoa.tipopessoa          := IfThen(ADataSet.FieldByName('tipo').asinteger = 1, 'FISICA', 'JURIDICA');

    Pessoa.datafundacaonascimento := FormatDateField('nascimento');

    case FDatabaseType of
      dtIndustrial:
      begin
        // <<CHANGE_ME: campos especificos industrial>>
        Pessoa.perfilsupervisor    := SafeFlagInt('f_supervisor');

         //Add dados bancarios
        Pessoa.AddDadosBancarios('', ADataSet.FieldByName('codbanco').AsString,
                                '',ADataSet.FieldByName('agencia').AsString,
                                ADataSet.FieldByName('conta').AsString,
                                '',
                                ADataSet.FieldByName('chavepix').AsString,
                                ADataSet.FieldByName('tipochavepix').AsString,
                                ''
        );
      end;

      dtCommercial:
      begin
        // <<CHANGE_ME: campos especificos comercial>>
      end;
    end;

    // complemento funcionario (mesma tabela C000008)
    Pessoa.AddComplementoFuncionario(
      ADataSet.FieldByName('codigo').AsString,
      ADataSet.FieldByName('ctps').AsString,
      ADataSet.FieldByName('seriectps').AsString,
      ADataSet.FieldByName('nis').AsString,
      ADataSet.FieldByName('tituloeleitor').AsString,
      ADataSet.FieldByName('secaoeleitorial').AsString,
      ADataSet.FieldByName('funcao').AsString,
      FormatDateField('data_admissao'),
      FormatDateField('data_demissao'),
      ADataSet.FieldByName('salario').AsFloat,
      ADataSet.FieldByName('comissao').AsFloat,
      SafeFlagInt('f_caixa'),
      SafeFlagInt('f_tecnico'),
      SafeFlagInt('f_mecanico'),
      SafeFlagInt('gerarfolhapagamento'),
      ADataSet.FieldByName('codfaixainss').AsString,
      ADataSet.FieldByName('codfornecedorctaspagar').AsString,
      SafeFlagInt('habilitadoplanilhacusto'),
      ADataSet.FieldByName('ajudacusto').AsFloat,
      ADataSet.FieldByName('insalubridade').AsFloat,
      ADataSet.FieldByName('periculosidade').AsFloat,
      ADataSet.FieldByName('adicionalnoturno').AsFloat,
      ADataSet.FieldByName('decimoterceiro').AsFloat,
      ADataSet.FieldByName('ferias').AsFloat,
      ADataSet.FieldByName('umtercoferias').AsFloat,
      ADataSet.FieldByName('fgts').AsFloat,
      ADataSet.FieldByName('indenizacoes').AsFloat,
      ADataSet.FieldByName('total').AsFloat,
      ADataSet.FieldByName('comissaovenda').AsFloat,
      ADataSet.FieldByName('premioprodutividade').AsFloat,
      ADataSet.FieldByName('codregiao').AsString,
      ADataSet.FieldByName('codsupervisor').AsString,
      ADataSet.FieldByName('estadocivil').AsString,
      ADataSet.FieldByName('conjuge').AsString,
      FormatDateField('dataentrada'),
      FormatDateField('datafimcontratoexperiencia'),
      ADataSet.FieldByName('codcargo').AsString
    );

    Result := Pessoa.ToJson;
  finally
    Pessoa.Free;
  end;
end;

function TEntityFuncionario.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDFUNCIONARIO is null');
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

function TEntityFuncionario.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityFuncionario.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Funcionarios sincronizados com sucesso'
  else
    Result := 'Erro em Funcionarios: ' + AErrorMsg;
end;

procedure TEntityFuncionario.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDFUNCIONARIO = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityFuncionario.GetTableNameClass, TEntityFuncionario);
end.

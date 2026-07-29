unit uEntityTransportador;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uPessoaAPI;

type
  TEntityTransportador = class(TEntityBase)
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

{ TEntityTransportador }

class function TEntityTransportador.GetTableNameClass: string;
begin
  Result := 'C000010';
end;

function TEntityTransportador.GetResourceName: string;
begin
  Result := TPessoaAPI.ResourceName;
end;

function TEntityTransportador.GetRecord(ACodRecord: string): TDataSet;
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

function TEntityTransportador.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDTRANSPORTADOR').AsString
  else
    Result := ADataSet.FieldByName('IDTRANSPORTADOR').AsString;
end;

function TEntityTransportador.MapToJson(ADataSet: TDataSet): TJSONObject;

  function ConcatObs: string;
  var
    s: string;
  begin
    Result := '';
    s := Trim(ADataSet.FieldByName('obs1').AsString);
    if s <> '' then
      Result := s;
    s := Trim(ADataSet.FieldByName('obs2').AsString);
    if s <> '' then
    begin
      if Result <> '' then Result := Result + sLineBreak;
      Result := Result + s;
    end;
    s := Trim(ADataSet.FieldByName('obs3').AsString);
    if s <> '' then
    begin
      if Result <> '' then Result := Result + sLineBreak;
      Result := Result + s;
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
    Pessoa.habilitado              := ifthen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);
    Pessoa.perfiltransportador     := 1;
    Pessoa.ativo                   := 1;  //cadastro de transportador nao implementa ativo/inativo. Logo sempre ativo

    Pessoa.codigoerp               := ADataSet.FieldByName('codigo').AsString;
    Pessoa.nome                    := ADataSet.FieldByName('nome').AsString;
    Pessoa.nomefantasia            := ADataSet.FieldByName('nomefantasia').AsString;
    Pessoa.logradouro              := ADataSet.FieldByName('endereco').AsString;
    Pessoa.cep                     := ADataSet.FieldByName('cep').AsString;
    Pessoa.bairro                  := ADataSet.FieldByName('bairro').AsString;
    Pessoa.cidade                  := ADataSet.FieldByName('cidade').AsString;
    Pessoa.uf                      := ADataSet.FieldByName('uf').AsString;
    Pessoa.numero                  := ADataSet.FieldByName('numero').AsString;
    Pessoa.documentoprincipal      := ADataSet.FieldByName('cpf').AsString;
    Pessoa.documentosecundario     := ADataSet.FieldByName('rg').AsString;
    Pessoa.telefone                := ADataSet.FieldByName('telefone').AsString;
    Pessoa.celular                 := ADataSet.FieldByName('celular').AsString;
    Pessoa.email                   := ADataSet.FieldByName('email').AsString;
    Pessoa.observacoes             := ConcatObs;
    Pessoa.rntrc_transportador     := ADataSet.FieldByName('rntrc').AsString;
    Pessoa.datacadastro            := FormatDateField('data');
    Pessoa.ibge                    := ADataSet.FieldByName('ibge').AsString;
    Pessoa.complemento             := ADataSet.FieldByName('complemento').AsString;

    if ADataSet.FieldByName('tipo').AsInteger = 1 then
      Pessoa.tipopessoa := 'FISICA'
    else
      Pessoa.tipopessoa := 'JURIDICA';

    //Add dados bancarios
    Pessoa.AddDadosBancarios('', ADataSet.FieldByName('codbanco').AsString,
                            '', ADataSet.FieldByName('agencia').AsString,
                            ADataSet.FieldByName('conta').AsString,
                            '',
                            ADataSet.FieldByName('chavepix').AsString,
                            '',
                            ADataSet.FieldByName('tipoconta').AsString
    );

    Result := Pessoa.ToJson;
  finally
    Pessoa.Free;
  end;
end;

function TEntityTransportador.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from ' + GetTableNameClass);
    Qry.SQL.Add('where IDTRANSPORTADOR is null');
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

function TEntityTransportador.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityTransportador.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Transportadores sincronizados com sucesso'
  else
    Result := 'Erro em Transportadores: ' + AErrorMsg;
end;

procedure TEntityTransportador.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set IDTRANSPORTADOR = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityTransportador.GetTableNameClass, TEntityTransportador);
end.






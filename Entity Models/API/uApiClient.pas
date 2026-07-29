unit uApiClient;

interface

uses
  System.JSON, System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  uMRestIntegracao, uLogger;

type
  TApiClient = class
  private
    FBaseURL: string;
    FToken: string;
    FAuthHeader: string;
    FAutenticar: Boolean;
    FConnection: TFDConnection;
    function Executar(const AMethod, AResource: string; const ABody: string = ''): TJSONObject;
  public
    constructor Create(const ABaseURL: string; AConnection: TFDConnection);
    procedure SetToken(const AToken: string);
    procedure LimparToken;
    function GetToken(const ARenovar: Boolean = False): string;
    procedure AutenticaApi(const ACodFilial: string = '');

    // Parse de response (movidos de TEntityBase)
    function ExtractApiId(const AResponse: TJSONObject): string;
    function IsResponseOk(const AResponse: TJSONObject; var AErrorMsg: string): Boolean;
    class function Sanitize(const AValue: string; const AContext: string = ''): string; static;

    // Metodos publicos
    function Get(const AResource: string; const AId: string = ''): TJSONObject;
    function Post(const AResource: string; const ABody: string): TJSONObject;
    function Put(const AResource, AId, ABody: string): TJSONObject;
    procedure SoftDelete(const AResource, AId: string);
  end;

implementation

{ TApiClient }

constructor TApiClient.Create(const ABaseURL: string; AConnection: TFDConnection);
begin
  inherited Create;
  FBaseURL := ABaseURL;
  FConnection := AConnection;
  FToken := '';
  FAuthHeader := 'Authorization';
  FAutenticar := True;
end;

procedure TApiClient.SetToken(const AToken: string);
begin
  FToken := AToken;
end;

procedure TApiClient.LimparToken;
begin
  FToken := '';
end;

function TApiClient.GetToken(const ARenovar: Boolean = False): string;
begin
  if ARenovar or (FToken = '') then
    AutenticaApi;
  Result := FToken;
end;

procedure TApiClient.AutenticaApi(const ACodFilial: string = '');
var
  qrIntegrador, qrParametrosIntegrador, qrToken: TFDQuery;
  Login: TRestIntegracao;
  content: TJSONObject;
  response: TJSONObject;
  vToken: string;
  vExpiresIn: Integer;
  vResource: string;
begin
  qrIntegrador := TFDQuery.Create(nil);
  qrParametrosIntegrador := TFDQuery.Create(nil);
  qrToken := nil;
  Login := nil;
  content := nil;
  response := nil;
  try
    qrIntegrador.Connection := FConnection;
    qrIntegrador.SQL.Add('select * from c000440');
    qrIntegrador.SQL.Add('where tipo = :pTipo');
    qrIntegrador.SQL.Add('and habilitado = :pHab');
    if ACodFilial <> '' then
    begin
      qrIntegrador.SQL.Add('and codigofilial = :pFilial');
      qrIntegrador.ParamByName('pFilial').AsString := ACodFilial;
    end;
    qrIntegrador.ParamByName('pTipo').Value := 'CUCABRASIL DATASYNC';
    qrIntegrador.ParamByName('pHab').Value := 'S';
    qrIntegrador.Open;

    if qrIntegrador.IsEmpty then
    begin
      TLogger.Log(llWarn, lcAuth, 'Nenhum integrador habilitado', ['filial=' + ACodFilial]);
      Exit;
    end;

    if (qrIntegrador.FieldByName('datatoken').AsDateTime > Now) and
       (qrIntegrador.FieldByName('token').AsString <> '') then
    begin
      FToken := 'Bearer ' + qrIntegrador.FieldByName('token').AsString;
      Exit;
    end;

    qrParametrosIntegrador.Connection := FConnection;
    qrParametrosIntegrador.SQL.Add('select * from c000441');
    qrParametrosIntegrador.SQL.Add('where codintegrador = :cod');
    qrParametrosIntegrador.ParamByName('cod').AsString := qrIntegrador.FieldByName('codigo').AsString;
    qrParametrosIntegrador.Open;

    content := TJSONObject.Create;
    qrParametrosIntegrador.First;
    while not qrParametrosIntegrador.Eof do
    begin
      content.AddPair(
        qrParametrosIntegrador.FieldByName('chave').AsString,
        qrParametrosIntegrador.FieldByName('valor').AsString
      );
      qrParametrosIntegrador.Next;
    end;

    vResource := '/auth/login-proxy';
    Login := TRestIntegracao.Create(qrIntegrador.FieldByName('url').AsString);

    if Assigned(content) then
      response := Login.Executar('POST', vResource, '', '', content.ToString)
    else
      response := Login.Executar('POST', vResource, '', '', '{}');

    if response.GetValue<string>('status') = '200' then
    begin
      vToken := response.GetValue<TJSONObject>('data')
        .GetValue<TJSONObject>('data')
        .GetValue<string>('access_token');

      FToken := 'Bearer ' + vToken;

      try
        vExpiresIn := response.GetValue<TJSONObject>('data')
          .GetValue<TJSONObject>('data')
          .GetValue<Integer>('expires_in');
      except
        vExpiresIn := 900;
      end;

      qrToken := TFDQuery.Create(nil);
      qrToken.Connection := FConnection;
      qrToken.SQL.Add('update c000440 set token = :token, datatoken = :datatoken');
      qrToken.SQL.Add('where codigo = :cod');
      qrToken.ParamByName('token').AsString := vToken;
      qrToken.ParamByName('datatoken').AsDateTime := Now + vExpiresIn / 86400;
      qrToken.ParamByName('cod').AsString := qrIntegrador.FieldByName('codigo').AsString;
      qrToken.ExecSQL;

      TLogger.Log(llInfo, lcAuth, 'Autenticado com sucesso', ['filial=' + ACodFilial]);
    end
    else
      raise Exception.Create('Falha na autenticacao. Status: ' + response.GetValue<string>('status'));
  finally
    qrToken.Free;
    response.Free;
    Login.Free;
    content.Free;
    qrParametrosIntegrador.Free;
    qrIntegrador.Free;
  end;
end;

function TApiClient.Executar(const AMethod, AResource: string; const ABody: string): TJSONObject;
var
  Rest: TRestIntegracao;
  FullURL: string;
begin
  FullURL := FBaseURL + AResource;

  if FAutenticar and (FToken = '') then
    AutenticaApi;

  Rest := TRestIntegracao.Create(FBaseURL);
  try
    if FToken <> '' then
      Result := Rest.Executar(AMethod, AResource, FAuthHeader, FToken, ABody)
    else
      Result := Rest.Executar(AMethod, AResource, '', '', ABody);
  finally
    Rest.Free;
  end;

  if Result.GetValue<string>('status') = '401' then
  begin
    TLogger.Log(llWarn, lcAuth, 'Token expirado, reautenticando...', []);
    LimparToken;
    AutenticaApi;
    Result.Free;
    Result := Executar(AMethod, AResource, ABody);
  end;
end;

function TApiClient.IsResponseOk(const AResponse: TJSONObject;
  var AErrorMsg: string): Boolean;
var
  InnerVal, OkVal, ErrVal: TJSONValue;
begin
  Result := False;
  InnerVal := AResponse.GetValue('data');
  if not (Assigned(InnerVal) and (InnerVal is TJSONObject)) then
    Exit;

  OkVal := TJSONObject(InnerVal).GetValue('ok');
  if Assigned(OkVal) and (OkVal.Value = 'true') then
    Result := True
  else
  begin
    ErrVal := TJSONObject(InnerVal).GetValue('erro');
    if Assigned(ErrVal) then
      AErrorMsg := AErrorMsg + ErrVal.Value;
  end;
end;

function TApiClient.ExtractApiId(const AResponse: TJSONObject): string;
var
  InnerVal, DataVal: TJSONValue;
  ArrVal: TJSONArray;
begin
  Result := '';

  // TApiClient.Executar retorna: {"status":"200","data":<resposta_original>}
  // resposta_original tem: {"ok":true,"data":[...]} ou {"ok":true,"data":{...}}
  // Portanto o id esta em response.data.data[0].id ou response.data.data.id

  InnerVal := AResponse.GetValue('data');
  if not (Assigned(InnerVal) and (InnerVal is TJSONObject)) then
    Exit;

  DataVal := TJSONObject(InnerVal).GetValue('data');
  if DataVal is TJSONArray then
  begin
    ArrVal := TJSONArray(DataVal);
    if (ArrVal.Count > 0) and (ArrVal.Items[0] is TJSONObject) then
      TJSONObject(ArrVal.Items[0]).TryGetValue<string>('id', Result);
  end
  else if DataVal is TJSONObject then
  begin
    if TJSONObject(DataVal).TryGetValue<string>('id', Result) then Exit;
    if TJSONObject(DataVal).TryGetValue<string>('_id', Result) then Exit;
  end
  else if DataVal is TJSONString then
    Result := TJSONString(DataVal).Value
  else if DataVal is TJSONNumber then
    Result := TJSONNumber(DataVal).ToString;
end;

class function TApiClient.Sanitize(const AValue: string;
  const AContext: string): string;
var
  i, removed: Integer;
  badChar: string;
begin
  Result := AValue;
  removed := 0;
  badChar := '';
  for i := Length(Result) downto 1 do
    if (Result[i] < #32) or (Result[i] = #127) then
    begin
      badChar := Result[i];
      Delete(Result, i, 1);
      Inc(removed);
    end;
  if (removed > 0) and (AContext <> '') then
    TLogger.Log(llWarn, lcSystem,
      Format('Sanitize removeu %d char(s) [%s] em %s', [removed, badChar, AContext]), []);
  // badChar fica como o ULTIMO char removido; era assim no original
end;

function TApiClient.Get(const AResource: string; const AId: string = ''): TJSONObject;
var
  FullResource: string;
begin
  if AId <> '' then
    FullResource := AResource + '/' + AId
  else
    FullResource := AResource;
  Result := Executar('GET', FullResource);
end;

function TApiClient.Post(const AResource: string; const ABody: string): TJSONObject;
begin
  Result := Executar('POST', AResource, ABody);
end;

function TApiClient.Put(const AResource, AId, ABody: string): TJSONObject;
begin
  Result := Executar('PUT', AResource + '/' + AId, ABody);
end;

procedure TApiClient.SoftDelete(const AResource, AId: string);
var
  Response: TJSONObject;
begin
  Response := Executar('PUT', AResource + '/' + AId, '{"deleted":true}');
  try
    if (Response.GetValue<string>('status') <> '200') and
       (Response.GetValue<string>('status') <> '201') and
       (Response.GetValue<string>('status') <> '204') then
      raise Exception.Create('Falha ao marcar como excluido. Status: ' + Response.GetValue<string>('status'));
  finally
    Response.Free;
  end;
end;

end.

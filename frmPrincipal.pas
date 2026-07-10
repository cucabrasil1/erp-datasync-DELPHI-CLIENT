unit frmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Phys.Intf, FireDAC.Stan.Option, FireDAC.Stan.Intf, FireDAC.Comp.Client,
  Vcl.StdCtrls, System.JSON, system.DateUtils, System.Generics.Collections,
  uEntityBase, cxGraphics, cxControls, cxCheckBox, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxGroupBox,
  cxCheckGroup, Vcl.ExtCtrls, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  dxBarBuiltInMenu, cxPC, System.ImageList, Vcl.ImgList, cxImageList,
  AdvGlowButton, JvExControls, JvNavigationPane;

type
  TTableSummary = record
    Sucessos: Integer;
    Erros: Integer;
  end;

  TForm2 = class(TForm)
    btnSincronizar: TButton;
    Memo1: TMemo;
    monitorEventos: TFDEventAlerter;
    pnSincronizar: TPanel;
    chkClientes: TcxCheckBox;
    chkProdutos: TcxCheckBox;
    cxGroupBox1: TcxGroupBox;
    cmbEmpresa: TcxComboBox;
    btnSettings: TAdvGlowButton;
    cxImageList1: TcxImageList;
    JvNavPanelHeader1: TJvNavPanelHeader;
    JvNavPanelHeader2: TJvNavPanelHeader;
    procedure monitorEventosAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSincronizarClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
  private
    FDatabaseType: TDatabaseType;
    FAutenticar: Boolean;
    FSummary: TDictionary<string, TTableSummary>;
    hMutex: THandle;
    function GetDatabaseType: TDatabaseType;
    function NomeTabela(const ATabela: string): string;
    procedure IncrementarContador(const ATabela: string; ASucesso: Boolean);
    procedure ExibirResumo;
    procedure EnviarRegistroApi(qrRecord, qrIntegrador, qrParametrosIntegrador: TFDQuery; thConnection: TFDConnection);
    procedure gerarLog(name, msg: string; query: TFDquery; codFilial: string);
    procedure BuscaIntegrador(qrIntegrador: TFDQuery; thConnection: TFDConnection; vWhereClauses: string = '');
    procedure AutenticaApi(codFilial: string; qrRecord, qrIntegrador, qrParametrosIntegrador: TFDQuery; thConnection: TFDConnection);
    procedure AtualizarEventoSync(qrEvento: TFDQuery; const ASyncResult: TSyncResult);
  end;

var
  Form2: TForm2;

implementation

uses
  uThreadCuca, dmModulo, uMRestIntegracao, uEntityFactory;

{$R *.dfm}



function TForm2.GetDatabaseType: TDatabaseType;
var
  vParam: string;
begin
  vParam := UpperCase(Trim(ParamStr(1)));

  Result := dtIndustrial; // default industrial

  if vParam = 'INDUSTRIAL' then       //comercial proloja
    Result := dtCommercial;

  Self.Memo1.Lines.Add('Modo banco: ' + vParam);
  pnSincronizar.Visible := False;

end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  hMutex := CreateMutex(nil, False, 'CucaBrasilDataSync_UnicaInstancia');
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    CloseHandle(hMutex);
    MessageBox(0, 'Aplicação já está em execução.', 'Aviso', MB_OK or MB_ICONINFORMATION);
    Halt;
  end;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  if hMutex <> 0 then
    CloseHandle(hMutex);
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  FDatabaseType := GetDatabaseType;
  FAutenticar := True;
  FSummary := TDictionary<string, TTableSummary>.Create;

  with TFDQuery.Create(nil) do
  try
    Connection := modulo.conexao;
    SQL.Add('select e.codigo, e.filial, e.cnpj from c000004 e');
    SQL.Add('where e.usarmodulointegracaomarketplace = ''S''');
    SQL.Add('and exists (select 1 from c000440 i where i.codigofilial = e.codigo');
    SQL.Add('  and i.tipo = ''CUCABRASIL DATASYNC'' and i.habilitado = ''S'')');
    SQL.Add('order by e.filial');
    Open;

    cmbEmpresa.Properties.Items.Clear;
    while not Eof do
    begin
      cmbEmpresa.Properties.Items.Add(FieldByName('codigo').AsString + ' - ' + FieldByName('filial').AsString + ' - ' + FieldByName('cnpj').AsString);
      Next;
    end;

    if cmbEmpresa.Properties.Items.Count > 0 then
      cmbEmpresa.ItemIndex := 0;
  finally
    Free;
  end;

  with TFDQuery.Create(nil) do
  try
    Connection := modulo.conexao;
    SQL.Add('update EVENTS_DATASYNC set THREADID = null');
    SQL.Add('where SINCRONIZADO = ''N''');
    SQL.Add('and THREADID is not null');
    ExecSQL;
  finally
    Free;
  end;

  monitorEventos.Active := True;
  Self.monitorEventosAlert(nil, 'Event_DB_CHANGE', null);
end;

procedure TForm2.gerarLog(name, msg: string; query: TFDquery; codFilial: string);
var
  auxText: string;
begin
  Self.Memo1.Lines.Add('');
  if name = 'auth_erro_busca_integrador' then
  begin

    if query.IsEmpty then
      auxText := 'Nenhum integrador cadastrado ou habilitado. Verifique.'
    else
      auxText := 'Integração para filial ''' + codFilial + ''' não cadastrada ou desabilitada. Verifique.';

    Self.Memo1.Lines.Add( '*******************  AUTENTICAÇÃO  *******************' + #13#10
                        + auxText + ': ' + DateTimeToStr(Now) + #13#10
                        + '*******************  AUTENTICAÇÃO  *******************');
  end
  else if name = 'auth_erro' then
  begin
    Self.Memo1.Lines.Add( '*******************  AUTENTICAÇÃO  *******************' + #13#10
                        + '- Autenticação NÃO efetuada: ' + DateTimeToStr(Now) + #13#10
                        + '- Empresa: ' + codFilial + #13#10
                        + '- Mensagem de Erro: ' + msg + #13#10
                        + '*******************  AUTENTICAÇÃO  *******************');
  end
  else if name = 'auth_sucesso' then
  begin
    Self.Memo1.Lines.Add( '###################  AUTENTICAÇÃO  ###################' + #13#10
                        + '- Autenticação efetuada com SUCESSO: ' + DateTimeToStr(Now) + #13#10
                        + '- Empresa: ' + codFilial + #13#10
                        + '###################  AUTENTICAÇÃO  ###################');
  end
  else if name = 'evt_erro' then
  begin
    Self.Memo1.Lines.Add('*** ERRO: Evento NÃO sincronizado: ' + DateTimeToStr(Now) + '                                 *** ERRO ***' + #13#10 + 'CÓDIGO DO EVENTO: ' + query.FieldByName('codseq').AsString + #13#10 + 'OPERAÇÃO: ' + query.FieldByName('type_db').AsString + #13#10 + 'TABELA: ' + Self.NomeTabela(query.FieldByName('tablename_db').AsString) + #13#10 + 'CÓDIGO DO REGISTRO: ' + query.FieldByName('coderecord_db').AsString + #13#10 + 'MENSAGEM ERRO: ' + msg);
  end
  else if name = 'evt_sucesso' then
  begin
    Self.Memo1.Lines.Add( '### Evento sincronizado com SUCESSO: ' + DateTimeToStr(Now) + #13#10
                        + 'CÓDIGO DO EVENTO: ' + query.FieldByName('codseq').AsString + #13#10
                        + 'OPERAÇÃO: ' + query.FieldByName('type_db').AsString + #13#10
                        + 'TABELA: ' + Self.NomeTabela(query.FieldByName('tablename_db').AsString) + #13#10
                        + 'CÓDIGO DO REGISTRO: ' + query.FieldByName('coderecord_db').AsString);
  end
  else if name = 'import_sucesso' then
  begin
    Self.Memo1.Lines.Add('### Importação realizada com SUCESSO: ' + DateTimeToStr(Now) + #13#10
                        + msg);
  end
  else if name = 'import_erro' then
  begin
    Self.Memo1.Lines.Add('### Erro na Importação de Dados: ' + DateTimeToStr(Now) + #13#10
                        + msg);
  end
  else if name = 'export_sucesso' then
  begin
    Self.Memo1.Lines.Add('### Exportação realizada com SUCESSO: ' + DateTimeToStr(Now) + #13#10
                        + msg);
  end
  else if name = 'export_msg' then
  begin
    Self.Memo1.Lines.Add(msg);
  end
  else if name = 'export_erro' then
  begin
    Self.Memo1.Lines.Add('### Erro na Exportação de Dados: ' + DateTimeToStr(Now) + #13#10 + msg);
  end;
  Self.Memo1.Lines.Add('');
end;

procedure TForm2.BuscaIntegrador(qrIntegrador: TFDQuery; thConnection: TFDConnection; vWhereClauses: string = '');
begin
  try
    with qrIntegrador do
    begin
      Connection := thConnection;
      Close;
      SQL.Clear;
      SQL.Add('select * from c000440');
      SQL.Add('where tipo = :pTipo');
      SQL.Add('and habilitado = :pHab');

      ParamByName('pTipo').value := 'CUCABRASIL DATASYNC';
      ParamByName('pHab').value := 'S';
      Open;
    end;

    if qrIntegrador.IsEmpty then
      raise Exception.Create('Nenhum integrador foi encontrado. Verifique.');
  except
    on E: Exception do
    begin
      Self.gerarLog('auth_erro_busca_integrador', 'Mensagem: ' + E.Message, nil, '');

      raise;
    end;
  end;
end;

procedure TForm2.btnSettingsClick(Sender: TObject);
var
  vParam, vPass: string;
begin
  if pnSincronizar.Visible then
  begin
    pnSincronizar.Visible := false;
    exit;
  end;

  vParam := ParamStr(2);
  if vParam <> 'DEV' then
  begin
    vPass := InputBox('Acesso Restrito', #31 + 'Digite sua senha:', '');
    if vPass <> 'ccb30211777uba' then
      Exit;
  end;

  pnSincronizar.Visible := true;
end;

procedure TForm2.btnSincronizarClick(Sender: TObject);
type
  TEntidadeSync = record
    CheckboxName: string;
    TableName: string;
  end;
const
  ENTIDADES: array[0..1] of TEntidadeSync = (
    (CheckboxName: 'chkClientes'; TableName: 'C000007'),
    (CheckboxName: 'chkProdutos'; TableName: 'C000025')
  );
var
  t: TThreadCuca;
  chk: TcxCheckBox;
  algumSelecionado: Boolean;
  i: Integer;
begin
  algumSelecionado := False;

  for i := Low(ENTIDADES) to High(ENTIDADES) do
  begin
    chk := FindComponent(ENTIDADES[i].CheckboxName) as TcxCheckBox;
    if Assigned(chk) and chk.Checked then
    begin
      algumSelecionado := True;
      Break;
    end;
  end;

  if not algumSelecionado then
  begin
    MessageDlg('Selecione ao menos uma entidade para sincronizar.', mtWarning, [mbOK], 0);
    Exit;
  end;

  t := TThreadCuca.Create(
    procedure
    var
      thConnection: TFDConnection;
      qrIntegrador, qrParametrosIntegrador: TFDQuery;
      Entity: TEntityBase;
      SyncResult: TSyncResult;
      vToken: string;
    var
      i: Integer;
      Checkbox: TComponent;
      StartTime: TDateTime;
      ElapsedSec: Double;
    begin
      try
        thConnection := TFDConnection.Create(nil);
        modulo.DoConnectionDatabase(thConnection);

        qrIntegrador := TFDQuery.Create(nil);
        qrIntegrador.Connection := thConnection;

        qrParametrosIntegrador := TFDQuery.Create(nil);
        qrParametrosIntegrador.Connection := thConnection;

        with qrIntegrador do
        begin
          Close;
          SQL.Clear;
          SQL.Add('select * from c000440');
          SQL.Add('where tipo = :pTipo');
          SQL.Add('and habilitado = :pHab');
          SQL.Add('and codigofilial = :pFilial');
          ParamByName('pTipo').Value := 'CUCABRASIL DATASYNC';
          ParamByName('pHab').Value := 'S';
          ParamByName('pFilial').Value := Copy(cmbEmpresa.Properties.Items[cmbEmpresa.ItemIndex], 1, Pos(' - ', cmbEmpresa.Properties.Items[cmbEmpresa.ItemIndex]) - 1);
          Open;
        end;

        if qrIntegrador.IsEmpty then
        begin
          Self.gerarLog('auth_erro_busca_integrador', 'Nenhum integrador para empresa selecionada', nil, '');
          Exit;
        end;

        Self.AutenticaApi(qrIntegrador.FieldByName('codigofilial').AsString, nil, qrIntegrador, qrParametrosIntegrador, thConnection);

        qrIntegrador.Close;
        qrIntegrador.Open;

        for i := Low(ENTIDADES) to High(ENTIDADES) do
        begin
          Checkbox := Self.FindComponent(ENTIDADES[i].CheckboxName);
          if not Assigned(Checkbox) then
            Continue;

          if not (Checkbox is TcxCheckBox) then
            Continue;

          if not TcxCheckBox(Checkbox).Checked then
            Continue;

          qrIntegrador.First;
          while not qrIntegrador.Eof do
          begin
            vToken := qrIntegrador.FieldByName('token').AsString;

            try
              Entity := TEntityFactory.GetEntity(thConnection, ENTIDADES[i].TableName, FDatabaseType);
              Entity.OnProgress := procedure(const AMsg: string)
                begin
                  Self.Memo1.Lines.Add(AMsg);
                end;
              try
                StartTime := Now;
                if vToken <> '' then
                  SyncResult := Entity.SyncAll(qrIntegrador.FieldByName('url').AsString, 'Bearer ' + vToken, 'Authorization')
                else
                  SyncResult := Entity.SyncAll(qrIntegrador.FieldByName('url').AsString, '', '');

                if SyncResult.NeedAuth then
                begin
                  Self.AutenticaApi(qrIntegrador.FieldByName('codigofilial').AsString, nil, qrIntegrador, qrParametrosIntegrador, thConnection);
                  qrIntegrador.Close;
                  qrIntegrador.Open;

                  vToken := qrIntegrador.FieldByName('token').AsString;
                  if vToken <> '' then
                    SyncResult := Entity.SyncAll(qrIntegrador.FieldByName('url').AsString, 'Bearer ' + vToken, 'Authorization')
                  else
                    SyncResult := Entity.SyncAll(qrIntegrador.FieldByName('url').AsString, '', '');
                end;

                ElapsedSec := (Now - StartTime) * 24 * 60 * 60;

                if SyncResult.Success then
                  Self.gerarLog('export_sucesso',
                    Format('%d registro(s) sincronizado(s) em %.1fs - %s',
                      [SyncResult.RecordCount, ElapsedSec, Entity.GetSyncAllMessage(True, '')]),
                    nil, '')
                else
                  Self.gerarLog('export_erro',
                    Format('%d registro(s) com erro em %.1fs - %s',
                      [SyncResult.RecordCount, ElapsedSec, Entity.GetSyncAllMessage(False, SyncResult.ErrorMessage)]),
                    nil, '');
              finally
                Entity.Free;
              end;
            except
              on E: Exception do
                Self.gerarLog('export_erro', Entity.GetSyncAllMessage(False, E.Message), nil, '');
            end;

            qrIntegrador.Next;
          end;

          qrIntegrador.First;
        end;

        FreeAndNil(qrIntegrador);
        FreeAndNil(qrParametrosIntegrador);
        FreeAndNil(thConnection);
      except
        on E: Exception do
          MessageDLG('Falha no SyncAll: ' + #13 + E.Message, mtError, [mbOK], 0);
      end;
    end, False);
end;

procedure TForm2.AutenticaApi(codFilial: string; qrRecord: TFDQuery; qrIntegrador: TFDQuery; qrParametrosIntegrador: TFDQuery; thConnection: TFDConnection);
var
  Login: TRestIntegracao;
  content, response: TJSONObject;
  qrToken: TFDQuery;
  vToken,   vResource: string;
  vExpiresIn: Integer;
begin
  Login := nil;
  content := nil;
  response := nil;
  qrToken := nil;
  vResource := '';
  vExpiresIn := 900;

  try
    if not FAutenticar then
      Exit;

    if (qrIntegrador.fieldbyname('datatoken').AsDateTime > Now) and (qrIntegrador.fieldbyname('token').AsString <> '') then
      Exit;

    Login := TRestIntegracao.Create(qrIntegrador.fieldbyname('url').asstring);

    with qrParametrosIntegrador do
    begin
      Connection := thConnection;
      Close;
      SQL.Clear;
      SQL.Add('select * from c000441');
      SQL.Add('where codintegrador = ' + QuotedStr(qrIntegrador.fieldbyname('codigo').AsString));
      Open;
    end;

    if qrParametrosIntegrador.RecordCount > 0 then
    begin
      content := TJSONObject.Create;

      qrParametrosIntegrador.first;
      while not qrParametrosIntegrador.eof do
      begin
        content.AddPair(qrParametrosIntegrador.fieldbyname('chave').AsString, qrParametrosIntegrador.fieldbyname('valor').AsString);

        qrParametrosIntegrador.Next;
      end;
    end;

    vResource := '/auth/login-proxy';

    if Assigned(content) then
      response := Login.Executar('POST', vResource, '', '', content.ToString)
    else
      response := Login.Executar('POST', vResource, '', '', '{}');

    if response.GetValue<string>('status') = '200' then
    begin
      vToken := response.GetValue<TJSONObject>('data').GetValue<TJSONObject>('data').GetValue<string>('access_token');

      try
        vExpiresIn := response.GetValue<TJSONObject>('data').GetValue<TJSONObject>('data').GetValue<Integer>('expires_in');
      except
        vExpiresIn := 900;
      end;

      qrToken := TFDQuery.Create(nil);
      qrToken.Connection := thConnection;

      qrToken.Close;
      qrToken.SQL.Clear;
      qrToken.SQL.Add('update c000440');
      qrToken.SQL.Add('set token = ' + QuotedStr(vToken) + ' ,');
      qrToken.SQL.Add('datatoken = ' + QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now + vExpiresIn / 86400)));
      qrToken.SQL.Add('where codigo = ' + QuotedStr(qrParametrosIntegrador.fieldbyname('codintegrador').AsString));
      qrToken.ExecSQL;

      Self.gerarLog('auth_sucesso', '', nil, codFilial);
    end
    else
      Self.gerarLog('auth_erro', 'API retornou: ' + response.GetValue<string>('status'), nil, codFilial);

    FreeAndNil(qrToken);
    FreeAndNil(Login);
    FreeAndNil(content);
    FreeAndNil(response);
  except
    on E: Exception do
    begin
      Self.gerarLog('auth_erro', 'Falha na autenticacao: ' + E.Message, nil, codFilial);

      FreeAndNil(qrToken);
      FreeAndNil(Login);
      FreeAndNil(content);
      FreeAndNil(response);
    end;
  end;
end;

procedure TForm2.AtualizarEventoSync(qrEvento: TFDQuery; const ASyncResult: TSyncResult);
var
  qrUpdate: TFDQuery;
begin
  qrUpdate := TFDQuery.Create(nil);
  try
    qrUpdate.Connection := qrEvento.Connection;
    if ASyncResult.Success then
    begin
      qrUpdate.SQL.Add('update EVENTS_DATASYNC');
      qrUpdate.SQL.Add('set sincronizado = ''S'',');
      qrUpdate.SQL.Add('    datasincronizacao = current_timestamp');
      qrUpdate.SQL.Add('where codseq = :codseq');
      qrUpdate.ParamByName('codseq').AsString := qrEvento.FieldByName('codseq').AsString;
    end
    else
    begin
      qrUpdate.SQL.Add('update EVENTS_DATASYNC');
      qrUpdate.SQL.Add('set observacoes = :erro,');
      qrUpdate.SQL.Add('    threadid = null');
      qrUpdate.SQL.Add('where codseq = :codseq');
      qrUpdate.ParamByName('codseq').AsString := qrEvento.FieldByName('codseq').AsString;

      qrUpdate.ParamByName('erro').AsString := '[' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + '] ' + ASyncResult.ErrorMessage;

      if qrEvento.FieldByName('observacoes').AsString <> '' then
        qrUpdate.ParamByName('erro').AsString := qrEvento.FieldByName('observacoes').AsString + #13#10 + qrUpdate.ParamByName('erro').AsString;
    end;
    qrUpdate.ExecSQL;
  finally
    qrUpdate.Free;
  end;
end;

function TForm2.NomeTabela(const ATabela: string): string;
begin
  Result := ATabela;
end;

procedure TForm2.IncrementarContador(const ATabela: string; ASucesso: Boolean);
var
  Sum: TTableSummary;
begin
  if not FSummary.TryGetValue(NomeTabela(ATabela), Sum) then
  begin
    Sum.Sucessos := 0;
    Sum.Erros := 0;
  end;

  if ASucesso then
    Inc(Sum.Sucessos)
  else
    Inc(Sum.Erros);

  FSummary.AddOrSetValue(NomeTabela(ATabela), Sum);
end;

procedure TForm2.ExibirResumo;
var
  Key: string;
  Sum: TTableSummary;
begin
  Self.Memo1.Lines.Add('');
  Self.Memo1.Lines.Add('========== RESUMO ==========');

  for Key in FSummary.Keys do
  begin
    Sum := FSummary[Key];
    Self.Memo1.Lines.Add(Format('Tabela %s - Sucesso: %d  Erro: %d', [Key, Sum.Sucessos, Sum.Erros]));
  end;

  Self.Memo1.Lines.Add('============================');
  Self.Memo1.Lines.Add('');

  FSummary.Clear;
end;

procedure TForm2.EnviarRegistroApi(qrRecord: TFDQuery; qrIntegrador: TFDQuery; qrParametrosIntegrador: TFDQuery; thConnection: TFDConnection);
var
  Entity: TEntityBase;
  SyncResult: TSyncResult;
  Rest: TRestIntegracao;
  vToken: string;
begin
  Entity := nil;
  Rest := nil;

  try
    if not qrIntegrador.Locate('CODIGOFILIAL', qrRecord.FieldByName('CODIGOFILIAL').AsString, []) then
    begin
      Self.gerarLog('auth_erro_busca_integrador', 'Integrador não cadastrado ou desabilitado para esta empresa. Verifique.', qrIntegrador, qrRecord.FieldByName('CODIGOFILIAL').AsString);
      Exit;
    end;

    try
      Entity := TEntityFactory.GetEntity(thConnection, qrRecord.FieldByName('tablename_db').AsString, FDatabaseType);
    except
      on E: Exception do
      begin
        SyncResult.Success := False;
        SyncResult.ApiId := '';
        SyncResult.ErrorMessage := 'Sem mapper para tabela ' + Self.NomeTabela(qrRecord.FieldByName('tablename_db').AsString) + ': ' + E.Message;
        Self.AtualizarEventoSync(qrRecord, SyncResult);
        Self.IncrementarContador(qrRecord.FieldByName('tablename_db').AsString, False);
        Self.gerarLog('evt_erro', SyncResult.ErrorMessage, qrRecord, '');
        Exit;
      end;
    end;

    try
      Self.AutenticaApi(qrRecord.FieldByName('codigofilial').AsString, qrRecord, qrIntegrador, qrParametrosIntegrador, thConnection);

      qrIntegrador.Close;
      qrIntegrador.Open;
      qrIntegrador.Locate('CODIGOFILIAL', qrRecord.FieldByName('CODIGOFILIAL').AsString, []);

      vToken := qrIntegrador.FieldByName('token').AsString;

      Rest := TRestIntegracao.Create(qrIntegrador.FieldByName('url').AsString);
      try
        if vToken <> '' then
          SyncResult := Entity.Sync(qrRecord.FieldByName('type_db').AsString, qrRecord.FieldByName('coderecord_db').AsString, qrRecord.FieldByName('codigofilial').AsString, Rest, 'Bearer ' + vToken, 'Authorization')
        else
          SyncResult := Entity.Sync(qrRecord.FieldByName('type_db').AsString, qrRecord.FieldByName('coderecord_db').AsString, qrRecord.FieldByName('codigofilial').AsString, Rest, '', '');

        // Retry se token expirou
        if SyncResult.NeedAuth then
        begin
          Self.AutenticaApi(qrRecord.FieldByName('codigofilial').AsString, qrRecord, qrIntegrador, qrParametrosIntegrador, thConnection);
          qrIntegrador.Close;
          qrIntegrador.Open;
          qrIntegrador.Locate('CODIGOFILIAL', qrRecord.FieldByName('CODIGOFILIAL').AsString, []);
          vToken := qrIntegrador.FieldByName('token').AsString;

          if vToken <> '' then
            SyncResult := Entity.Sync(qrRecord.FieldByName('type_db').AsString, qrRecord.FieldByName('coderecord_db').AsString, qrRecord.FieldByName('codigofilial').AsString, Rest, 'Bearer ' + vToken, 'Authorization')
          else
            SyncResult := Entity.Sync(qrRecord.FieldByName('type_db').AsString, qrRecord.FieldByName('coderecord_db').AsString, qrRecord.FieldByName('codigofilial').AsString, Rest, '', '');
        end;
      finally
        Rest.Free;
      end;

      Self.AtualizarEventoSync(qrRecord, SyncResult);

      if SyncResult.Success then
      begin
        Self.IncrementarContador(qrRecord.FieldByName('tablename_db').AsString, True);
        Self.gerarLog('evt_sucesso', '', qrRecord, '')
      end
      else
      begin
        Self.IncrementarContador(qrRecord.FieldByName('tablename_db').AsString, False);
        Self.gerarLog('evt_erro', SyncResult.ErrorMessage, qrRecord, '');
      end;

    except
      on E: Exception do
      begin
        SyncResult.Success := False;
        SyncResult.ApiId := '';
        SyncResult.ErrorMessage := 'Falha no sync: ' + E.Message;
        Self.AtualizarEventoSync(qrRecord, SyncResult);
        Self.IncrementarContador(qrRecord.FieldByName('tablename_db').AsString, False);
        Self.gerarLog('evt_erro', SyncResult.ErrorMessage, qrRecord, '');
      end;
    end;

    Entity.Free;
  except
    on E: Exception do
    begin
      Self.gerarLog('auth_erro_busca_integrador', 'Mensagem: ' + E.Message, qrIntegrador, qrRecord.FieldByName('CODIGOFILIAL').AsString);
    end;
  end;
end;

procedure TForm2.monitorEventosAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
var
  newThread: TThreadCuca;
begin
  Memo1.Lines.Add('### PROCESSANDO - ' + FormatDateTime('DD-MM-YYYY * HH:MM:SS', Now));

  if AEventName <> 'Event_DB_CHANGE' then
    Exit;

  newThread := TThreadCuca.Create(
    procedure
    var
      thConnection: TFDConnection;
      qrEventos: TFDQuery;
      qrIntegrador: TFDQuery;
      qrParametrosIntegrador: TFDQuery;
    begin
      try
        thConnection := TFDConnection.Create(nil);
        modulo.DoConnectionDatabase(thConnection);

        qrIntegrador := TFDQuery.Create(nil);
        qrIntegrador.Connection := thConnection;

        qrParametrosIntegrador := TFDQuery.Create(nil);
        qrParametrosIntegrador.Connection := thConnection;

        Self.BuscaIntegrador(qrIntegrador, thConnection);

        qrEventos := TFDQuery.Create(nil);
        with qrEventos do
        begin
          Connection := thConnection;
          SQL.Add('update EVENTS_DATASYNC');
          SQL.Add('set THREADID = ' + IntToStr(newThread.ThreadID) + ', NUM_SINC = coalesce(NUM_SINC, 0) + 1 ');
          SQL.Add('where SINCRONIZADO = ''N''');
          SQL.Add('and THREADID is null');
          ExecSQL;
          Close;
          SQL.Clear;
          SQL.Add('select * from EVENTS_DATASYNC e');
          SQL.Add('where e.THREADID = ' + IntToStr(newThread.ThreadID));
          SQL.Add('order by codseq');
          Open;
          First;
        end;

        Memo1.lines.Add('Total de registros pendentes para sincronização: ' + IntToStr(qrEventos.RecordCount));

        while not qrEventos.eof do
        begin
          Self.EnviarRegistroApi(qrEventos, qrIntegrador, qrParametrosIntegrador, thConnection);
          qrEventos.Next;

          Sleep(1000);
        end;

        Self.ExibirResumo;

        FreeAndNil(qrEventos);
        FreeAndNil(qrIntegrador);
        FreeAndNil(qrParametrosIntegrador);
        FreeAndNil(thConnection);
      except
        on E: Exception do
        begin
          FreeAndNil(qrEventos);
          FreeAndNil(qrIntegrador);
          FreeAndNil(qrParametrosIntegrador);
          FreeAndNil(thConnection);
          MessageDLG('Falha ao iniciar sincronização de dados: ' + #13 + e.Message, mtError, [mbOK], 0);
        end;
      end;
    end, False);
end;

end.


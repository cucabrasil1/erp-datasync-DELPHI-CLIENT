unit frmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, FireDAC.Phys.Intf, FireDAC.Stan.Option, FireDAC.Stan.Intf,
  FireDAC.Comp.Client, Vcl.StdCtrls, System.JSON, system.DateUtils,
  System.Generics.Collections, uEntityBase, uLogger, cxGraphics, cxControls,
  cxCheckBox, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, cxGroupBox, cxCheckGroup, Vcl.ExtCtrls, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, dxBarBuiltInMenu, cxPC, System.ImageList, Vcl.ImgList,
  cxImageList, AdvGlowButton, JvExControls, JvNavigationPane, uSyncOrchestrator;

type
  TTableSummary = record
    Sucessos: Integer;
    Erros: Integer;
  end;

  TEntidadeSync = record
    CheckboxName: string;
    TableName: string;
  end;

  TGroupSyncDef = record
    CheckboxName: string;
    Tabelas: TArray<string>;
  end;

  TForm2 = class(TForm)
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
    chkAcabamentos: TcxCheckBox;
    chkCenario: TcxCheckBox;
    Panel1: TPanel;
    Panel2: TPanel;
    chkFornecedor: TcxCheckBox;
    chkTpPagamento: TcxCheckBox;
    chkCor: TcxCheckBox;
    chkTodos: TcxCheckBox;
    Panel3: TPanel;
    chkPedVenda: TcxCheckBox;
    Panel4: TPanel;
    chkTransportador: TcxCheckBox;
    JvNavPanelHeader3: TJvNavPanelHeader;
    btnSyncAll: TButton;
    chkFuncioanrio: TcxCheckBox;
    procedure monitorEventosAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure chkTodosClick(Sender: TObject);
    procedure btnSyncAllClick(Sender: TObject);
  private
    FDatabaseType: TDatabaseType;
    FSummary: TDictionary<string, TTableSummary>;
    hMutex: THandle;
    function GetDatabaseType: TDatabaseType;
    function NomeTabela(const ATabela: string): string;
    procedure IncrementarContador(const ATabela: string; ASucesso: Boolean);
    procedure ExibirResumo;
    procedure EnviarRegistroApi(qrRecord, qrIntegrador, qrParametrosIntegrador: TFDQuery; thConnection: TFDConnection);
    procedure BuscaIntegrador(qrIntegrador: TFDQuery; thConnection: TFDConnection; vWhereClauses: string = '');

    function SyncGroup(AConnection: TFDConnection; qrIntegrador: TFDQuery; const ATabelas: TArray<string>; const ACodFilial: string): Boolean;
    function GetGruposSync: TArray<TGroupSyncDef>;
    procedure AtualizarEventoSync(qrEvento: TFDQuery; const ASyncResult: TSyncResult);
  end;

var
  Form2: TForm2;

implementation

uses
  uThreadCuca, dmModulo, uMRestIntegracao, uEntityFactory, uApiClient;

{$R *.dfm}

function TForm2.GetDatabaseType: TDatabaseType;
var
  vParam: string;
begin
  vParam := UpperCase(Trim(ParamStr(1)));

  Result := dtIndustrial; // default industrial

  if vParam <> 'INDUSTRIAL' then       //comercial proloja
    Result := dtCommercial;

  TLogger.Log(llInfo, lcSystem, 'Modo banco: ' + vParam, []);
  pnSincronizar.Visible := False;

end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  hMutex := CreateMutex(nil, False, 'CucaBrasilDataSync_UnicaInstancia');
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    CloseHandle(hMutex);
    MessageBox(0, 'Aplica??o j? est? em execu??o.', 'Aviso', MB_OK or MB_ICONINFORMATION);
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
  TLogger.SetDBConnection(modulo.conexao);

  FDatabaseType := GetDatabaseType;
  FSummary := TDictionary<string, TTableSummary>.Create;

  TLogger.OnLog :=
    procedure(const ALine: string)
    begin
      Memo1.Lines.Add(ALine);
    end;

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
      TLogger.Log(llError, lcAuth, 'Mensagem: ' + E.Message, []);

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

function TForm2.GetGruposSync: TArray<TGroupSyncDef>;
begin
  SetLength(Result, 10);

  //clientes ('Regioes-C000005', 'GrupoCliente-C000144', 'Cliente-C000007')
  Result[0].CheckboxName := 'chkClientes';
  Result[0].Tabelas := TArray<string>.Create('C000005', 'C000144', 'C000007');

  //cores (C000129)
  Result[1].CheckboxName := 'chkCor';
  Result[1].Tabelas := TArray<string>.Create('C000129');

  //acabamentos (C000250)
  Result[2].CheckboxName := 'chkAcabamentos';
  Result[2].Tabelas := TArray<string>.Create('C000250');

  //cenario faturamento (C000233)
  Result[3].CheckboxName := 'chkCenario';
  Result[3].Tabelas := TArray<string>.Create('C000233');

  //Fornecedores (C000009)
  Result[4].CheckboxName := 'chkFornecedor';
  Result[4].Tabelas := TArray<string>.Create('C000009');

  //Transportadores (C000010)
  Result[5].CheckboxName := 'chkTransportador';
  Result[5].Tabelas := TArray<string>.Create('C000010');

  //Tipos de Pagamento ('Tipo - C000014', 'Condicoes - C000015', 'Parcelamento - C000016')
  Result[6].CheckboxName := 'chkTpPagamento';
  Result[6].Tabelas := TArray<string>.Create('C000014', 'C000015', 'C000016');

  //Produtos ('Grupo - C000017', 'Subgrupo - C000018', 'Produto - C000025', 'VAriacao - C000279')
  Result[7].CheckboxName := 'chkProdutos';
//  Result[7].Tabelas := TArray<string>.Create('C000017', 'C000018', 'C000025', 'C000279');
  Result[7].Tabelas := TArray<string>.Create('C000017', 'C000018', 'C000279');

  //Funcionarios (C000008)
  Result[8].CheckboxName := 'chkFuncioanrio';
  Result[8].Tabelas := TArray<string>.Create('C000008');
end;

procedure TForm2.btnSyncAllClick(Sender: TObject);
var
  GRUPOS: TArray<TGroupSyncDef>;
  vCodFilial: string;
  t: TThreadCuca;
begin
  if cmbEmpresa.ItemIndex < 0 then
    raise Exception.Create('Nenhuma empresa selecionada. Verifique.');

  vCodFilial := Copy(cmbEmpresa.Properties.Items[cmbEmpresa.ItemIndex], 1, Pos(' - ', cmbEmpresa.Properties.Items[cmbEmpresa.ItemIndex]) - 1);

  if Trim(vCodFilial) = '' then
    raise Exception.Create('Erro ao extrair código da filial.');

  //definir entidades a serem exportadas
  GRUPOS := Self.GetGruposSync;

  t := TThreadCuca.Create(
    procedure
    var
      thConnection: TFDConnection;
      qrIntegrador: TFDQuery;
      chk: TcxCheckBox;
      i: Integer;
    begin
      try
        thConnection := TFDConnection.Create(nil);
        modulo.DoConnectionDatabase(thConnection);

        qrIntegrador := TFDQuery.Create(nil);
        qrIntegrador.Connection := thConnection;

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
          ParamByName('pFilial').Value := vCodFilial;
          Open;
        end;

        if qrIntegrador.IsEmpty then
        begin
          TLogger.Log(llWarn, lcAuth, 'Nenhum integrador para empresa selecionada', ['filial=' + vCodFilial]);
          Exit;
        end;

        for i := 0 to High(GRUPOS) do
        begin
          chk := FindComponent(GRUPOS[i].CheckboxName) as TcxCheckBox;
          if not Assigned(chk) or not chk.Checked then
            Continue;

          if not Self.SyncGroup(thConnection, qrIntegrador, GRUPOS[i].Tabelas, vCodFilial) then
          begin
            TLogger.Log(llError, lcSync, 'Grupo abortado por falha em dependência: ' + GRUPOS[i].CheckboxName, ['filial=' + vCodFilial]);
          end;
        end;

        FreeAndNil(qrIntegrador);
        FreeAndNil(thConnection);
      except
        on E: Exception do
          MessageDlg('Falha no SyncAll: ' + #13 + E.Message, mtError, [mbOK], 0);
      end;
    end, False);
end;

function TForm2.SyncGroup(AConnection: TFDConnection; qrIntegrador: TFDQuery; const ATabelas: TArray<string>; const ACodFilial: string): Boolean;
var
  i: Integer;
  Entity: TEntityBase;
  SyncResult: TSyncResult;
  vToken: string;
  vUrl: string;
  StartTime: TDateTime;
  ElapsedSec: Double;
begin
  Result := False;
  vUrl := qrIntegrador.FieldByName('url').AsString;

  { Autentica antes de iniciar o grupo }
  with TApiClient.Create('', AConnection) do
  try
    AutenticaApi(ACodFilial);
  finally
    Free;
  end;

  qrIntegrador.Close;
  qrIntegrador.Open;
  vToken := qrIntegrador.FieldByName('token').AsString;

  for i := 0 to High(ATabelas) do
  begin
    try
      Entity := TEntityFactory.GetEntity(AConnection, ATabelas[i], FDatabaseType);
      Entity.Filial := ACodFilial;
      Entity.OnProgress :=
        procedure(const AMsg: string)
        begin
          if Pos('falhou', LowerCase(AMsg)) > 0 then
            TLogger.Log(llError, lcExport, Trim(AMsg), ['tabela=' + ATabelas[i], 'filial=' + ACodFilial])
          else
            TLogger.Log(llInfo, lcExport, Trim(AMsg), ['tabela=' + ATabelas[i], 'filial=' + ACodFilial]);
        end;
      try
        StartTime := Now;
        if vToken <> '' then
          SyncResult := Entity.SyncAll(vUrl, 'Bearer ' + vToken, 'Authorization')
        else
          SyncResult := Entity.SyncAll(vUrl, '', '');

        if SyncResult.NeedAuth then
        begin
          with TApiClient.Create('', AConnection) do
          try
            AutenticaApi(ACodFilial);
          finally
            Free;
          end;
          qrIntegrador.Close;
          qrIntegrador.Open;
          vToken := qrIntegrador.FieldByName('token').AsString;
          if vToken <> '' then
            SyncResult := Entity.SyncAll(vUrl, 'Bearer ' + vToken, 'Authorization')
          else
            SyncResult := Entity.SyncAll(vUrl, '', '');
        end;

        ElapsedSec := (Now - StartTime) * 24 * 60 * 60;

        if SyncResult.Success then
          TLogger.Log(llInfo, lcExport, Format('%d registro(s) sincronizado(s) em %.1fs - %s', [SyncResult.RecordCount, ElapsedSec, Entity.GetSyncAllMessage(True, '')]), ['tabela=' + ATabelas[i], 'filial=' + ACodFilial])
        else
        begin
          TLogger.Log(llError, lcExport, Format('%d registro(s) com erro em %.1fs - %s', [SyncResult.RecordCount, ElapsedSec, Entity.GetSyncAllMessage(False, SyncResult.ErrorMessage)]), ['tabela=' + ATabelas[i], 'filial=' + ACodFilial]);
          Exit; { abort group }
        end;

      finally
        Entity.Free;
      end;
    except
      on E: Exception do
      begin
        TLogger.Log(llError, lcExport, 'Falha ao sincronizar ' + ATabelas[i] + ': ' + E.Message, ['tabela=' + ATabelas[i], 'filial=' + ACodFilial]);
        Exit; { abort group }
      end;
    end;
  end;

  Result := True;
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
  linhas: TStringBuilder;
begin
  linhas := TStringBuilder.Create;
  try
    linhas.Append('=== RESUMO === ');
    for Key in FSummary.Keys do
    begin
      Sum := FSummary[Key];
      linhas.Append(Format('Tabela %s - Sucesso: %d  Erro: %d | ', [Key, Sum.Sucessos, Sum.Erros]));
    end;

    TLogger.Log(llInfo, lcSync, linhas.ToString.TrimEnd([' ', '|']), []);
  finally
    linhas.Free;
    FSummary.Clear;
  end;
end;

procedure TForm2.chkTodosClick(Sender: TObject);
var
  i: Integer;
  chk: TcxCheckBox;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TcxCheckBox then
    begin
      chk := TcxCheckBox(Components[i]);
      if (Copy(chk.Name, 1, 3) = 'chk') and (chk.Name <> 'chkTodos') then
        chk.Checked := chkTodos.Checked;
    end;
  end;
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
      TLogger.Log(llError, lcAuth, 'Integrador não cadastrado ou desabilitado', ['filial=' + qrRecord.FieldByName('CODIGOFILIAL').AsString]);
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
        TLogger.Log(llError, lcSync, SyncResult.ErrorMessage, ['codseq=' + qrRecord.FieldByName('codseq').AsString, 'coderecord=' + qrRecord.FieldByName('coderecord_db').AsString, 'tabela=' + Self.NomeTabela(qrRecord.FieldByName('tablename_db').AsString), 'filial=' + qrRecord.FieldByName('CODIGOFILIAL').AsString]);
        Exit;
      end;
    end;

    try
      with TApiClient.Create('', thConnection) do
      try
        AutenticaApi(qrRecord.FieldByName('codigofilial').AsString);
      finally
        Free;
      end;

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
          with TApiClient.Create('', thConnection) do
          try
            AutenticaApi(qrRecord.FieldByName('codigofilial').AsString);
          finally
            Free;
          end;
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
        TLogger.Log(llInfo, lcSync, 'Evento sincronizado com sucesso', ['codseq=' + qrRecord.FieldByName('codseq').AsString, 'coderecord=' + qrRecord.FieldByName('coderecord_db').AsString, 'tabela=' + Self.NomeTabela(qrRecord.FieldByName('tablename_db').AsString), 'filial=' + qrRecord.FieldByName('CODIGOFILIAL').AsString])
      end
      else
      begin
        Self.IncrementarContador(qrRecord.FieldByName('tablename_db').AsString, False);
        TLogger.Log(llError, lcSync, SyncResult.ErrorMessage, ['codseq=' + qrRecord.FieldByName('codseq').AsString, 'coderecord=' + qrRecord.FieldByName('coderecord_db').AsString, 'tabela=' + Self.NomeTabela(qrRecord.FieldByName('tablename_db').AsString), 'filial=' + qrRecord.FieldByName('CODIGOFILIAL').AsString]);
      end;

    except
      on E: Exception do
      begin
        SyncResult.Success := False;
        SyncResult.ApiId := '';
        SyncResult.ErrorMessage := 'Falha no sync: ' + E.Message;
        Self.AtualizarEventoSync(qrRecord, SyncResult);
        Self.IncrementarContador(qrRecord.FieldByName('tablename_db').AsString, False);
        TLogger.Log(llError, lcSync, SyncResult.ErrorMessage, ['codseq=' + qrRecord.FieldByName('codseq').AsString, 'coderecord=' + qrRecord.FieldByName('coderecord_db').AsString, 'tabela=' + Self.NomeTabela(qrRecord.FieldByName('tablename_db').AsString), 'filial=' + qrRecord.FieldByName('CODIGOFILIAL').AsString]);
      end;
    end;

    Entity.Free;
  except
    on E: Exception do
    begin
      TLogger.Log(llError, lcAuth, 'Mensagem: ' + E.Message, ['filial=' + qrRecord.FieldByName('CODIGOFILIAL').AsString]);
    end;
  end;
end;

procedure TForm2.monitorEventosAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
var
  newThread: TThreadCuca;
begin
  TLogger.Log(llInfo, lcSystem, 'Processando eventos', []);

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

        TLogger.Log(llInfo, lcSystem, 'Registros pendentes: ' + IntToStr(qrEventos.RecordCount), []);

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


unit uLogger;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, SyncObjs, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TLogLevel = (llInfo, llWarn, llError, llDebug);

  TLogCategory = (lcAuth, lcSync, lcExport, lcImport, lcSystem);

  TLogProc = reference to procedure(const ALine: string);

  TLogger = class
  private
    class var FLock: TCriticalSection;
    class var FLogDir: string;
    class var FCurrentDate: TDate;
    class var FStream: TStreamWriter;
    class var FOnLog: TLogProc;
    class var FDBConnection: TFDConnection;
    class function GetLogFileName: string;
    class procedure RotateFile;
    class function CategoryToString(ACat: TLogCategory): string;
    class function LevelToString(ALevel: TLogLevel): string;
    class function ExtractValue(const APair: string): string;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure Log(ALevel: TLogLevel; ACategory: TLogCategory;
      const AMsg: string; const AExtra: array of string);
    class procedure SetDBConnection(AConn: TFDConnection);
    class property OnLog: TLogProc read FOnLog write FOnLog;
  end;

implementation

uses
  System.IOUtils;

class constructor TLogger.Create;
begin
  FLock := TCriticalSection.Create;
  FLogDir := ExtractFilePath(ParamStr(0));
  FCurrentDate := 0;
  FStream := nil;
  FOnLog := nil;
end;

class destructor TLogger.Destroy;
begin
  FLock.Enter;
  try
    FreeAndNil(FStream);
  finally
    FLock.Leave;
  end;
  FreeAndNil(FLock);
end;

class function TLogger.GetLogFileName: string;
begin
  Result := TPath.Combine(FLogDir, Format('datasync_%s.log', [FormatDateTime('yyyymmdd', Now)]));
end;

class procedure TLogger.RotateFile;
var
  newName: string;
  fs: TFileStream;
begin
  newName := GetLogFileName;

  if (FStream = nil) or (FCurrentDate <> Date) then
  begin
    FreeAndNil(FStream);
    FCurrentDate := Date;

    fs := TFile.Open(newName, TFileMode.fmOpenOrCreate, TFileAccess.faWrite, TFileShare.fsReadWrite);
    fs.Seek(0, soEnd);
    FStream := TStreamWriter.Create(fs, TEncoding.UTF8);
    FStream.WriteLine('--- Log iniciado em ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' ---');
    FStream.Flush;
  end;
end;

class function TLogger.CategoryToString(ACat: TLogCategory): string;
begin
  case ACat of
    lcAuth:   Result := 'AUTH';
    lcSync:   Result := 'SYNC';
    lcExport: Result := 'EXPORT';
    lcImport: Result := 'IMPORT';
    lcSystem: Result := 'SYSTEM';
  else
    Result := 'UNKN';
  end;
end;

class function TLogger.LevelToString(ALevel: TLogLevel): string;
begin
  case ALevel of
    llInfo:  Result := 'INFO';
    llWarn:  Result := 'WARN';
    llError: Result := 'ERROR';
    llDebug: Result := 'DEBUG';
  else
    Result := 'INFO';
  end;
end;

class function TLogger.ExtractValue(const APair: string): string;
var
  p: Integer;
begin
  p := Pos('=', APair);
  if p > 0 then
    Result := Copy(APair, p + 1, MaxInt)
  else
    Result := APair;
end;

class procedure TLogger.SetDBConnection(AConn: TFDConnection);
begin
  FDBConnection := AConn;
end;

class procedure TLogger.Log(ALevel: TLogLevel; ACategory: TLogCategory;
  const AMsg: string; const AExtra: array of string);
var
  line: string;
  tid: TThreadID;
  extra: string;
  i: Integer;
  vFilial: string;
  vCodSeq: string;
  vTabela: string;
  vExtraRest: string;
  Pair: string;
  Key: string;
  Qry: TFDQuery;
begin
  FLock.Enter;
  try
    tid := TThread.CurrentThread.ThreadID;

    extra := '';
    vFilial := '';
    vCodSeq := '';
    vTabela := '';
    vExtraRest := '';

    for i := 0 to High(AExtra) do
    begin
      extra := extra + ' | ' + AExtra[i];
      Pair := AExtra[i];
      Key := LowerCase(Copy(Pair, 1, Pos('=', Pair) - 1));

      if Key = 'filial' then
        vFilial := ExtractValue(Pair)
      else if Key = 'codseq' then
        vCodSeq := ExtractValue(Pair)
      else if Key = 'tabela' then
        vTabela := ExtractValue(Pair)
      else
        vExtraRest := vExtraRest + IfThen(vExtraRest <> '', '; ', '') + Pair;
    end;

    line := Format('[%s] [TID=%d] [%s] [%s] %s%s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
       tid,
       LevelToString(ALevel),
       CategoryToString(ACategory),
       AMsg,
       extra]);

    RotateFile;
    if FStream <> nil then
    begin
      FStream.WriteLine(line);
      FStream.Flush;
    end;

    if Assigned(FOnLog) then
      FOnLog(line);

    if FDBConnection <> nil then
    begin
      Qry := TFDQuery.Create(nil);
      try
        Qry.Connection := FDBConnection;
        Qry.SQL.Add('insert into EVENTS_DATASYNC_LOG (datahora, nivel, categoria, tabela, filial, codseq, mensagem, extra)');
        Qry.SQL.Add('values (:datahora, :nivel, :categoria, :tabela, :filial, :codseq, :mensagem, :extra)');
        Qry.ParamByName('datahora').AsDateTime := Now;
        Qry.ParamByName('nivel').AsString := LevelToString(ALevel);
        Qry.ParamByName('categoria').AsString := CategoryToString(ACategory);
        if vTabela <> '' then
          Qry.ParamByName('tabela').AsString := vTabela
        else
          Qry.ParamByName('tabela').Clear;
        if vFilial <> '' then
          Qry.ParamByName('filial').AsString := vFilial
        else
          Qry.ParamByName('filial').Clear;
        if vCodSeq <> '' then
          Qry.ParamByName('codseq').AsString := vCodSeq
        else
          Qry.ParamByName('codseq').Clear;
        Qry.ParamByName('mensagem').AsString := AMsg;
        if vExtraRest <> '' then
          Qry.ParamByName('extra').AsString := vExtraRest
        else
          Qry.ParamByName('extra').Clear;
        Qry.ExecSQL;
      finally
        Qry.Free;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

end.
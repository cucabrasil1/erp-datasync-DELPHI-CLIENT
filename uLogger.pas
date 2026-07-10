unit uLogger;

interface

uses
  System.SysUtils, System.Classes, SyncObjs;

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
    class function GetLogFileName: string;
    class procedure RotateFile;
    class function CategoryToString(ACat: TLogCategory): string;
    class function LevelToString(ALevel: TLogLevel): string;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure Log(ALevel: TLogLevel; ACategory: TLogCategory;
      const AMsg: string; const AExtra: array of string); overload;
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

class procedure TLogger.Log(ALevel: TLogLevel; ACategory: TLogCategory;
  const AMsg: string; const AExtra: array of string);
var
  line: string;
  tid: TThreadID;
  extra: string;
  i: Integer;
begin
  FLock.Enter;
  try
    tid := TThread.CurrentThread.ThreadID;

    extra := '';
    for i := 0 to High(AExtra) do
      extra := extra + ' | ' + AExtra[i];

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
  finally
    FLock.Leave;
  end;
end;

end.

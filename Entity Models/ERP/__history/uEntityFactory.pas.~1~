unit uEntityFactory;

interface

uses
  System.Generics.Collections, System.SysUtils,
  uEntityBase, FireDAC.Comp.Client;

type
  TEntityFactory = class
  private
    class var FRegistry: TDictionary<string, TEntityBaseClass>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure RegisterEntity(const ATableName: string; AEntityClass: TEntityBaseClass);
    class function GetEntity(AConnection: TFDConnection; const ATableName: string;
      ADatabaseType: TDatabaseType = dtIndustrial): TEntityBase;
    class function HasEntity(const ATableName: string): Boolean;
    class function GetRegisteredTables: TArray<string>;
  end;

implementation

{ TEntityFactory }

class constructor TEntityFactory.Create;
begin
  FRegistry := TDictionary<string, TEntityBaseClass>.Create;
end;

class destructor TEntityFactory.Destroy;
begin
  FreeAndNil(FRegistry);
end;

class procedure TEntityFactory.RegisterEntity(const ATableName: string; AEntityClass: TEntityBaseClass);
begin
  FRegistry.AddOrSetValue(UpperCase(ATableName), AEntityClass);
end;

class function TEntityFactory.GetEntity(AConnection: TFDConnection; const ATableName: string;
  ADatabaseType: TDatabaseType): TEntityBase;
var
  LClass: TEntityBaseClass;
begin
  if not FRegistry.TryGetValue(UpperCase(ATableName), LClass) then
    raise Exception.CreateFmt('Nenhum mapper registrado para tabela "%s"', [ATableName]);

  Result := LClass.Create(AConnection, ADatabaseType);
end;

class function TEntityFactory.HasEntity(const ATableName: string): Boolean;
begin
  Result := FRegistry.ContainsKey(UpperCase(ATableName));
end;

class function TEntityFactory.GetRegisteredTables: TArray<string>;
var
  Key: string;
  List: TList<string>;
begin
  List := TList<string>.Create;
  try
    for Key in FRegistry.Keys do
      if Copy(Key, 1, 1) = 'C' then
        List.Add(Key);
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

end.

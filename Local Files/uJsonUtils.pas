unit uJsonUtils;

interface

uses
  System.JSON, System.SysUtils, System.RegularExpressions;

function JsonStrOrEmpty(const AKey: string; const AJson: TJSONObject): string;
function JsonIntOrZero(const AKey: string; const AJson: TJSONObject): Integer;
function JsonFloatOrZero(const AKey: string; const AJson: TJSONObject): Double;

function StrOrNull(const AValue: string): TJSONValue;
function NumOrNull(const AValue: Double): TJSONValue;
function IntOrNull(const AValue: Integer): TJSONValue;

function CleanNumOrNull(const AValue: string): TJSONValue;
function CleanDocOrNull(const AValue: string): TJSONValue;
function PerfilOrNull(const AValue: Integer): TJSONValue;

function FormatDateToISO(const ADateStr: string): string;

implementation

function JsonStrOrEmpty(const AKey: string; const AJson: TJSONObject): string;
begin
  if (AJson.GetValue(AKey) = nil) or (AJson.GetValue(AKey) is TJSONNull) then
    Result := ''
  else
    Result := AJson.GetValue<string>(AKey);
end;

function JsonIntOrZero(const AKey: string; const AJson: TJSONObject): Integer;
begin
  if (AJson.GetValue(AKey) = nil) or (AJson.GetValue(AKey) is TJSONNull) then
    Result := 0
  else
    Result := AJson.GetValue<Integer>(AKey);
end;

function JsonFloatOrZero(const AKey: string; const AJson: TJSONObject): Double;
begin
  if (AJson.GetValue(AKey) = nil) or (AJson.GetValue(AKey) is TJSONNull) then
    Result := 0
  else
    Result := AJson.GetValue<Double>(AKey);
end;

function StrOrNull(const AValue: string): TJSONValue;
begin
  if AValue = '' then
    Result := TJSONNull.Create
  else
    Result := TJSONString.Create(AValue);
end;

function NumOrNull(const AValue: Double): TJSONValue;
begin
  if AValue = 0 then
    Result := TJSONNull.Create
  else
    Result := TJSONNumber.Create(AValue);
end;

function IntOrNull(const AValue: Integer): TJSONValue;
begin
  if AValue = 0 then
    Result := TJSONNull.Create
  else
    Result := TJSONNumber.Create(AValue);
end;

function CleanNumOrNull(const AValue: string): TJSONValue;
var
  v: string;
begin
  v := TRegEx.Replace(AValue, '[^0-9]', '');
  if v = '' then
    Result := TJSONNull.Create
  else
    Result := TJSONString.Create(v);
end;

function CleanDocOrNull(const AValue: string): TJSONValue;
var
  v: string;
begin
  v := UpperCase(TRegEx.Replace(AValue, '[^0-9A-Za-z]', ''));
  if v = '' then
    Result := TJSONNull.Create
  else
    Result := TJSONString.Create(v);
end;

function PerfilOrNull(const AValue: Integer): TJSONValue;
begin
  if AValue = 0 then
    Result := TJSONNull.Create
  else
    Result := TJSONNumber.Create(AValue);
end;

function FormatDateToISO(const ADateStr: string): string;
begin
  if ADateStr.Trim.IsEmpty then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd', StrToDateTime(ADateStr));
end;

end.

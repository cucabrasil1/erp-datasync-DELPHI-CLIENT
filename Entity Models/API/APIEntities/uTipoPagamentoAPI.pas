unit uTipoPagamentoAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math;

type
  TTipoPagamentoAPI = class
  public
    // --- campos enviados (ERP . API) ---
    codigoerp: string;
    descricao: string;
    habilitado: Integer;

    // --- campos retornados pela API (GET) ---
    id: string;
    tenant_id: string;
    is_deleted: Integer;
    deleted_at: string;
    synced_at: string;
    created_at: string;
    updated_at: string;

    class function ResourceName: string;
    function ToJson: TJSONObject;
    procedure FromJson(AJson: TJSONObject);
  end;

implementation

{ TTipoPagamentoAPI }
class function TTipoPagamentoAPI.ResourceName: string;
begin
  Result := '/tipopagamento';
end;


function TTipoPagamentoAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigoerp', codigoerp);
  Result.AddPair('descricao', descricao);
  Result.AddPair('habilitado', TJSONNumber.Create(habilitado));
end;

procedure TTipoPagamentoAPI.FromJson(AJson: TJSONObject);

  function StrOrEmpty(const AKey: string): string;
  begin
    if (AJson.GetValue(AKey) = nil) or (AJson.GetValue(AKey) is TJSONNull) then
      Result := ''
    else
      Result := AJson.GetValue<string>(AKey);
  end;

  function IntOrZero(const AKey: string): Integer;
  begin
    if (AJson.GetValue(AKey) = nil) or (AJson.GetValue(AKey) is TJSONNull) then
      Result := 0
    else
      Result := AJson.GetValue<Integer>(AKey);
  end;

begin
  codigoerp  := StrOrEmpty('codigoerp');
  descricao  := StrOrEmpty('descricao');
  habilitado := IntOrZero('habilitado');
  id         := StrOrEmpty('id');
  tenant_id  := StrOrEmpty('tenant_id');
  is_deleted := IntOrZero('is_deleted');
  deleted_at := StrOrEmpty('deleted_at');
  synced_at  := StrOrEmpty('synced_at');
  created_at := StrOrEmpty('created_at');
  updated_at := StrOrEmpty('updated_at');
end;

end.




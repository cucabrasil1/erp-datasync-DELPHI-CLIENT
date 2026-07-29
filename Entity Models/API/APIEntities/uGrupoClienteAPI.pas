unit uGrupoClienteAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, uJsonUtils;

type
  TGrupoClienteAPI = class
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

{ TGrupoClienteAPI }
class function TGrupoClienteAPI.ResourceName: string;
begin
  Result := '/grupocliente';
end;


function TGrupoClienteAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigoerp', codigoerp);
  Result.AddPair('descricao', descricao);
  Result.AddPair('habilitado', TJSONNumber.Create(habilitado));
end;

procedure TGrupoClienteAPI.FromJson(AJson: TJSONObject);
begin
  codigoerp  := JsonStrOrEmpty('codigoerp', AJson);
  descricao  := JsonStrOrEmpty('descricao', AJson);
  habilitado := JsonIntOrZero('habilitado', AJson);
  id         := JsonStrOrEmpty('id', AJson);
  tenant_id  := JsonStrOrEmpty('tenant_id', AJson);
  is_deleted := JsonIntOrZero('is_deleted', AJson);
  deleted_at := JsonStrOrEmpty('deleted_at', AJson);
  synced_at  := JsonStrOrEmpty('synced_at', AJson);
  created_at := JsonStrOrEmpty('created_at', AJson);
  updated_at := JsonStrOrEmpty('updated_at', AJson);
end;

end.




unit uCorAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, uJsonUtils;

type
  TCorAPI = class
  public
    // --- campos enviados (ERP . API) ---
    codigoerp: string;
    descricao: string;
    habilitadoweb: Smallint;

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

{ TCorAPI }
class function TCorAPI.ResourceName: string;
begin
  Result := '/cor';
end;


function TCorAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigoerp', codigoerp);
  Result.AddPair('descricao', descricao);
  Result.AddPair('habilitadoweb', TJSONNumber.Create(habilitadoweb));
end;

procedure TCorAPI.FromJson(AJson: TJSONObject);
begin
  codigoerp  := JsonStrOrEmpty('codigoerp', AJson);
  descricao  := JsonStrOrEmpty('descricao', AJson);
  habilitadoweb := JsonIntOrZero('habilitadoweb', AJson);
  id         := JsonStrOrEmpty('id', AJson);
  tenant_id  := JsonStrOrEmpty('tenant_id', AJson);
  is_deleted := JsonIntOrZero('is_deleted', AJson);
  deleted_at := JsonStrOrEmpty('deleted_at', AJson);
  synced_at  := JsonStrOrEmpty('synced_at', AJson);
  created_at := JsonStrOrEmpty('created_at', AJson);
  updated_at := JsonStrOrEmpty('updated_at', AJson);
end;

end.




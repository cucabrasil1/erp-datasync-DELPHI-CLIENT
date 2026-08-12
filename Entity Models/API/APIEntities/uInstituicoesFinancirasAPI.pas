unit uInstituicoesFinancirasAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, uJsonUtils;

type
  TInstituicoesFinancirasAPI = class
  public
    // --- campos enviados (ERP . API) ---
    numerobanco: string;
    descricao: string;
    cartaocredito: Integer;   //bool
    tipo: string;             //'BANCO' e 'FINANCEIRA'
    creditocomissao: Double;
    creditoprazo: Integer;
    debitocomissao: Double;
    debitoprazo: Integer;
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

{   TInstituicoesFinancirasAPI }

class function TInstituicoesFinancirasAPI.ResourceName: string;
begin
  Result := '/instituicaofinanceira';
end;

function TInstituicoesFinancirasAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('descricao', descricao);
  Result.AddPair('numerobanco', numerobanco);
  Result.AddPair('tipo', tipo);
  Result.AddPair('cartaocredito', TJSONNumber.Create(cartaocredito));
  Result.AddPair('creditocomissao', TJSONNumber.Create(creditocomissao));
  Result.AddPair('creditoprazo', TJSONNumber.Create(creditoprazo));
  Result.AddPair('debitocomissao', TJSONNumber.Create(debitocomissao));
  Result.AddPair('debitoprazo', TJSONNumber.Create(debitoprazo));
  Result.AddPair('habilitadoweb', TJSONNumber.Create(habilitadoweb));
end;

procedure TInstituicoesFinancirasAPI.FromJson(AJson: TJSONObject);
begin
  descricao       := JsonStrOrEmpty('descricao', AJson);
  numerobanco     := JsonStrOrEmpty('numerobanco', AJson);
  tipo            := JsonStrOrEmpty('tipo', AJson);
  cartaocredito   := JsonIntOrZero('cartaocredito', AJson);
  creditocomissao := JsonFloatOrZero('creditocomissao', AJson);
  creditoprazo    := JsonIntOrZero('creditoprazo', AJson);
  debitocomissao  := JsonFloatOrZero('debitocomissao', AJson);
  debitoprazo     := JsonIntOrZero('debitoprazo', AJson);
  habilitadoweb      := JsonIntOrZero('habilitadoweb', AJson);
  id              := JsonStrOrEmpty('id', AJson);
  tenant_id       := JsonStrOrEmpty('tenant_id', AJson);
  is_deleted      := JsonIntOrZero('is_deleted', AJson);
  deleted_at      := JsonStrOrEmpty('deleted_at', AJson);
  synced_at       := JsonStrOrEmpty('synced_at', AJson);
  created_at      := JsonStrOrEmpty('created_at', AJson);
  updated_at      := JsonStrOrEmpty('updated_at', AJson);
end;

end.

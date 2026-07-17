unit uProdutoAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math;

type
  TProdutoAPI = class
  public
    // --- campos enviados (ERP . API) ---
    codigoerp: string;
    produto: string;
    referencia: string;
    codbarras: string;
    unidade: string;
    ncm: string;
    cest: string;
    precocompra: Double;
    precocusto: Double;
    precovenda: Double;
    tipo: string;
    qtdevolume: Integer;
    m3: Double;
    pesobruto: Double;
    pesoliquido: Double;
    ativo: string;
    caminhoimagem1: string;
    caminhoimagem2: string;
    caminhoimagem3: string;

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

{ TProdutoAPI }
class function TProdutoAPI.ResourceName: string;
begin
  Result := '/produto';
end;


function TProdutoAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigoerp', codigoerp);
  Result.AddPair('produto', produto);
  Result.AddPair('referencia', referencia);
  Result.AddPair('codbarras', codbarras);
  Result.AddPair('unidade', unidade);
  Result.AddPair('ncm', ncm);
  Result.AddPair('cest', cest);
  Result.AddPair('precocompra', TJSONNumber.Create(precocompra));
  Result.AddPair('precocusto', TJSONNumber.Create(precocusto));
  Result.AddPair('precovenda', TJSONNumber.Create(precovenda));
  Result.AddPair('tipo', tipo);
  Result.AddPair('qtdevolume', TJSONNumber.Create(qtdevolume));
  Result.AddPair('m3', TJSONNumber.Create(m3));
  Result.AddPair('pesobruto', TJSONNumber.Create(pesobruto));
  Result.AddPair('pesoliquido', TJSONNumber.Create(pesoliquido));
  Result.AddPair('ativo', ativo);
  Result.AddPair('caminhoimagem1', caminhoimagem1);
  Result.AddPair('caminhoimagem2', caminhoimagem2);
  Result.AddPair('caminhoimagem3', caminhoimagem3);
end;

procedure TProdutoAPI.FromJson(AJson: TJSONObject);

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
  codigoerp      := StrOrEmpty('codigoerp');
  produto        := StrOrEmpty('produto');
  referencia     := StrOrEmpty('referencia');
  codbarras      := StrOrEmpty('codbarras');
  unidade        := StrOrEmpty('unidade');
  ncm            := StrOrEmpty('ncm');
  cest           := StrOrEmpty('cest');
  precocompra    := IntOrZero('precocompra');
  precocusto     := IntOrZero('precocusto');
  precovenda     := IntOrZero('precovenda');
  tipo           := StrOrEmpty('tipo');
  qtdevolume     := IntOrZero('qtdevolume');
  m3             := IntOrZero('m3');
  pesobruto      := IntOrZero('pesobruto');
  pesoliquido    := IntOrZero('pesoliquido');
  ativo          := StrOrEmpty('ativo');
  caminhoimagem1 := StrOrEmpty('caminhoimagem1');
  caminhoimagem2 := StrOrEmpty('caminhoimagem2');
  caminhoimagem3 := StrOrEmpty('caminhoimagem3');
  id             := StrOrEmpty('id');
  tenant_id      := StrOrEmpty('tenant_id');
  is_deleted     := IntOrZero('is_deleted');
  deleted_at     := StrOrEmpty('deleted_at');
  synced_at      := StrOrEmpty('synced_at');
  created_at     := StrOrEmpty('created_at');
  updated_at     := StrOrEmpty('updated_at');
end;

end.




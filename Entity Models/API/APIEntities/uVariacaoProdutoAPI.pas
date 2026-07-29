unit uVariacaoProdutoAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, uJsonUtils;

type
  TVariacaoProdutoAPI = class
  public
    // --- campos enviados (ERP . API) ---
    codigoerp: string;
    ativo: Integer;
    codproduto: string;
    descricao: string;
    variacaobase: Integer;
    datamodificacao: string;
    precocusto: Double;
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

{ TVariacaoProdutoAPI }

class function TVariacaoProdutoAPI.ResourceName: string;
begin
  Result := '/variacaoproduto';
end;

function TVariacaoProdutoAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigoerp', codigoerp);
  Result.AddPair('ativo', TJSONNumber.Create(ativo));
  Result.AddPair('codproduto', codproduto);
  Result.AddPair('descricao', descricao);
  Result.AddPair('variacaobase', TJSONNumber.Create(variacaobase));
  Result.AddPair('datamodificacao', datamodificacao);
  Result.AddPair('precocusto', TJSONNumber.Create(precocusto));
  Result.AddPair('habilitado', TJSONNumber.Create(habilitado));
end;

procedure TVariacaoProdutoAPI.FromJson(AJson: TJSONObject);
begin
  codigoerp       := JsonStrOrEmpty('codigoerp', AJson);
  ativo           := JsonIntOrZero('ativo', AJson);
  codproduto      := JsonStrOrEmpty('codproduto', AJson);
  descricao       := JsonStrOrEmpty('descricao', AJson);
  variacaobase    := JsonIntOrZero('variacaobase', AJson);
  datamodificacao := JsonStrOrEmpty('datamodificacao', AJson);
  precocusto      := JsonFloatOrZero('precocusto', AJson);
  habilitado      := JsonIntOrZero('habilitado', AJson);
  id              := JsonStrOrEmpty('id', AJson);
  tenant_id       := JsonStrOrEmpty('tenant_id', AJson);
  is_deleted      := JsonIntOrZero('is_deleted', AJson);
  deleted_at      := JsonStrOrEmpty('deleted_at', AJson);
  synced_at       := JsonStrOrEmpty('synced_at', AJson);
  created_at      := JsonStrOrEmpty('created_at', AJson);
  updated_at      := JsonStrOrEmpty('updated_at', AJson);
end;

end.

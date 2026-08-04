unit uProdutoAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.Generics.Collections,
  uJsonUtils;

type
  TProdutoAPI = class
  public
    ativo: Integer;
    codigoerp: string;
    idproduto: string;
    produto: string;
    referencia: string;
    codbarras: string;
    codbarrastributavel: string;
    unidade: string;
    origem: Integer;
    classificacao: string;
    cst: string;
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
    altura: Double;
    largura: Double;
    profundidade: Double;
    possuivariacaocor: Integer;
    destacargtindfe: Integer;
    observacoes: string;
    volumes: TJSONArray;
    habilitado: Integer;
    codigogrupo: string;
    idgrupo: string;
    nomegrupo: string;
    codigosubgrupo: string;
    idsubgrupo: string;
    nomesubgrupo: string;
    caminhoimagem1: string;
    caminhoimagem2: string;
    caminhoimagem3: string;

    id: string;
    tenant_id: string;
    is_deleted: Integer;
    deleted_at: string;
    synced_at: string;
    created_at: string;
    updated_at: string;

    constructor Create;
    destructor Destroy; override;

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

constructor TProdutoAPI.Create;
begin
  inherited;
  volumes := TJSONArray.Create;
end;

destructor TProdutoAPI.Destroy;
begin
  volumes.Free;
  inherited;
end;

function TProdutoAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigoerp',                  StrOrNull(codigoerp));
  Result.AddPair('ativo',                   TJSONNumber.Create(ativo));
  Result.AddPair('idproduto',               StrOrNull(idproduto));
  Result.AddPair('produto',                 StrOrNull(produto));
  Result.AddPair('referencia',              StrOrNull(referencia));
  Result.AddPair('codbarras',               StrOrNull(codbarras));
  Result.AddPair('codbarrastributavel',     StrOrNull(codbarrastributavel));
  Result.AddPair('unidade',                 StrOrNull(unidade));
  Result.AddPair('origem',                  TJSONNumber.Create(origem));
  Result.AddPair('classificacao',           StrOrNull(classificacao));
  Result.AddPair('cst',                     StrOrNull(cst));
  Result.AddPair('ncm',                     StrOrNull(ncm));
  Result.AddPair('cest',                    StrOrNull(cest));
  Result.AddPair('precocompra',             TJSONNumber.Create(precocompra));
  Result.AddPair('precocusto',              TJSONNumber.Create(precocusto));
  Result.AddPair('precovenda',              TJSONNumber.Create(precovenda));
  Result.AddPair('tipo',                    StrOrNull(tipo));
  Result.AddPair('qtdevolume',              TJSONNumber.Create(qtdevolume));
  Result.AddPair('m3',                      TJSONNumber.Create(m3));
  Result.AddPair('pesobruto',               TJSONNumber.Create(pesobruto));
  Result.AddPair('pesoliquido',             TJSONNumber.Create(pesoliquido));
  Result.AddPair('altura',                  TJSONNumber.Create(altura));
  Result.AddPair('largura',                 TJSONNumber.Create(largura));
  Result.AddPair('profundidade',            TJSONNumber.Create(profundidade));
  Result.AddPair('possuivariacaocor',       TJSONNumber.Create(possuivariacaocor));
  Result.AddPair('destacargtindfe',         TJSONNumber.Create(destacargtindfe));
  Result.AddPair('observacoes',             StrOrNull(observacoes));
  Result.AddPair('volumes',                 volumes);
  Result.AddPair('habilitado',              TJSONNumber.Create(habilitado));
  Result.AddPair('codigogrupo',             StrOrNull(codigogrupo));
  Result.AddPair('idgrupo',                 StrOrNull(idgrupo));
  Result.AddPair('nomegrupo',               StrOrNull(nomegrupo));
  Result.AddPair('codigosubgrupo',          StrOrNull(codigosubgrupo));
  Result.AddPair('idsubgrupo',              StrOrNull(idsubgrupo));
  Result.AddPair('nomesubgrupo',            StrOrNull(nomesubgrupo));
  Result.AddPair('caminhoimagem1',          StrOrNull(caminhoimagem1));
  Result.AddPair('caminhoimagem2',          StrOrNull(caminhoimagem2));
  Result.AddPair('caminhoimagem3',          StrOrNull(caminhoimagem3));
end;

procedure TProdutoAPI.FromJson(AJson: TJSONObject);
var
  Arr: TJSONArray;
begin
  id                      := JsonStrOrEmpty('id', AJson);
  tenant_id               := JsonStrOrEmpty('tenant_id', AJson);
  codigoerp               := JsonStrOrEmpty('codigoerp', AJson);
  ativo                   := JsonIntOrZero('ativo', AJson);
  idproduto               := JsonStrOrEmpty('idproduto', AJson);
  produto                 := JsonStrOrEmpty('produto', AJson);
  referencia              := JsonStrOrEmpty('referencia', AJson);
  codbarras               := JsonStrOrEmpty('codbarras', AJson);
  codbarrastributavel     := JsonStrOrEmpty('codbarrastributavel', AJson);
  unidade                 := JsonStrOrEmpty('unidade', AJson);
  origem                  := JsonIntOrZero('origem', AJson);
  classificacao           := JsonStrOrEmpty('classificacao', AJson);
  cst                     := JsonStrOrEmpty('cst', AJson);
  ncm                     := JsonStrOrEmpty('ncm', AJson);
  cest                    := JsonStrOrEmpty('cest', AJson);
  precocompra             := JsonFloatOrZero('precocompra', AJson);
  precocusto              := JsonFloatOrZero('precocusto', AJson);
  precovenda              := JsonFloatOrZero('precovenda', AJson);
  tipo                    := JsonStrOrEmpty('tipo', AJson);
  qtdevolume              := JsonIntOrZero('qtdevolume', AJson);
  m3                      := JsonFloatOrZero('m3', AJson);
  pesobruto               := JsonFloatOrZero('pesobruto', AJson);
  pesoliquido             := JsonFloatOrZero('pesoliquido', AJson);
  altura                  := JsonFloatOrZero('altura', AJson);
  largura                 := JsonFloatOrZero('largura', AJson);
  profundidade            := JsonFloatOrZero('profundidade', AJson);
  possuivariacaocor       := JsonIntOrZero('possuivariacaocor', AJson);
  destacargtindfe         := JsonIntOrZero('destacargtindfe', AJson);
  observacoes             := JsonStrOrEmpty('observacoes', AJson);
  habilitado              := JsonIntOrZero('habilitado', AJson);
  codigogrupo             := JsonStrOrEmpty('codigogrupo', AJson);
  idgrupo                 := JsonStrOrEmpty('idgrupo', AJson);
  nomegrupo               := JsonStrOrEmpty('nomegrupo', AJson);
  codigosubgrupo          := JsonStrOrEmpty('codigosubgrupo', AJson);
  idsubgrupo              := JsonStrOrEmpty('idsubgrupo', AJson);
  nomesubgrupo            := JsonStrOrEmpty('nomesubgrupo', AJson);
  caminhoimagem1          := JsonStrOrEmpty('caminhoimagem1', AJson);
  caminhoimagem2          := JsonStrOrEmpty('caminhoimagem2', AJson);
  caminhoimagem3          := JsonStrOrEmpty('caminhoimagem3', AJson);
  is_deleted              := JsonIntOrZero('is_deleted', AJson);
  deleted_at              := JsonStrOrEmpty('deleted_at', AJson);
  synced_at               := JsonStrOrEmpty('synced_at', AJson);
  created_at              := JsonStrOrEmpty('created_at', AJson);
  updated_at              := JsonStrOrEmpty('updated_at', AJson);

  if AJson.TryGetValue('volumes', Arr) then
  begin
    volumes.Free;
    volumes := Arr.Clone as TJSONArray;
  end;
end;

end.

unit uProdutoAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.Generics.Collections,
  uJsonUtils;

type
  TProdutoVolume = class
  public
    // campos enviados (ERP . API)
    codigoerp: string;
    descricao: string;
    codbarras: string;
    referencia: string;
    pesobruto: Double;
    pesoliquido: Double;
    altura: Integer;
    largura: Integer;
    profundidade: Integer;
    quantidade: Integer;
    m3: Double;
    seqvolume: string;

    // campos retornados pela API (GET)
    id: string;
    produto_id: string;
    is_deleted: Integer;

    function ToJson: TJSONObject;
    procedure FromJson(AJson: TJSONObject);
  end;

  TProdutoAPI = class
  private
    FVolumes: TObjectList<TProdutoVolume>;
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
    habilitado: Integer;
    codigogrupo: string;
    idgrupo: string;
    nomegrupo: string;
    codigosubgrupo: string;
    idsubgrupo: string;
    nomesubgrupo: string;
    imagens: TArray<string>;

    id: string;
    tenant_id: string;
    is_deleted: Integer;
    deleted_at: string;
    synced_at: string;
    created_at: string;
    updated_at: string;

    constructor Create;
    destructor Destroy; override;

    procedure AddVolume(const ACodigoErp, ADescricao, ACodbarras, AReferencia: string;
      APesobruto, APesoliquido: Double; AAltura, ALargura, AProfundidade: Integer;
      AQuantidade: Integer; AM3: Double; ASeqVolume: string);
    procedure AddImagem(const AUrl: string);

    class function ResourceName: string;
    function ToJson: TJSONObject;
    procedure FromJson(AJson: TJSONObject);
  end;

implementation

{ TProdutoVolume }

function TProdutoVolume.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigoerp',   StrOrNull(codigoerp));
  Result.AddPair('descricao',   StrOrNull(descricao));
  Result.AddPair('codbarras',   StrOrNull(codbarras));
  Result.AddPair('referencia',  StrOrNull(referencia));
  Result.AddPair('pesobruto',   TJSONNumber.Create(pesobruto));
  Result.AddPair('pesoliquido', TJSONNumber.Create(pesoliquido));
  Result.AddPair('altura',      TJSONNumber.Create(altura));
  Result.AddPair('largura',     TJSONNumber.Create(largura));
  Result.AddPair('profundidade', TJSONNumber.Create(profundidade));
  Result.AddPair('quantidade',  TJSONNumber.Create(quantidade));
  Result.AddPair('m3',          TJSONNumber.Create(m3));
  Result.AddPair('seqvolume',   StrOrNull(seqvolume));
end;

procedure TProdutoVolume.FromJson(AJson: TJSONObject);
begin
  codigoerp   := JsonStrOrEmpty('codigoerp', AJson);
  descricao   := JsonStrOrEmpty('descricao', AJson);
  codbarras   := JsonStrOrEmpty('codbarras', AJson);
  referencia  := JsonStrOrEmpty('referencia', AJson);
  pesobruto   := JsonFloatOrZero('pesobruto', AJson);
  pesoliquido := JsonFloatOrZero('pesoliquido', AJson);
  altura      := JsonIntOrZero('altura', AJson);
  largura     := JsonIntOrZero('largura', AJson);
  profundidade := JsonIntOrZero('profundidade', AJson);
  quantidade  := JsonIntOrZero('quantidade', AJson);
  m3          := JsonFloatOrZero('m3', AJson);
  seqvolume   := JsonStrOrEmpty('seqvolume', AJson);
  id          := JsonStrOrEmpty('id', AJson);
  produto_id  := JsonStrOrEmpty('produto_id', AJson);
  is_deleted  := JsonIntOrZero('is_deleted', AJson);
end;

{ TProdutoAPI }

class function TProdutoAPI.ResourceName: string;
begin
  Result := '/produtos';
end;

constructor TProdutoAPI.Create;
begin
  inherited;
  FVolumes := TObjectList<TProdutoVolume>.Create(True);
end;

destructor TProdutoAPI.Destroy;
begin
  FVolumes.Free;
  inherited;
end;

procedure TProdutoAPI.AddVolume(const ACodigoErp, ADescricao, ACodbarras, AReferencia: string;
  APesobruto, APesoliquido: Double; AAltura, ALargura, AProfundidade: Integer;
  AQuantidade: Integer; AM3: Double; ASeqVolume: string);
var
  V: TProdutoVolume;
begin
  if (Trim(ACodigoErp) = '') and (Trim(ADescricao) = '') and (Trim(ACodbarras) = '') then
    Exit;

  V := TProdutoVolume.Create;

  V.codigoerp   := ACodigoErp;
  V.descricao   := ADescricao;
  V.codbarras   := ACodbarras;
  V.referencia  := AReferencia;
  V.pesobruto   := APesobruto;
  V.pesoliquido := APesoliquido;
  V.altura      := AAltura;
  V.largura     := ALargura;
  V.profundidade := AProfundidade;
  V.quantidade  := AQuantidade;
  V.m3          := AM3;
  V.seqvolume   := ASeqVolume;

  FVolumes.Add(V);
end;

procedure TProdutoAPI.AddImagem(const AUrl: string);
begin
  SetLength(imagens, Length(imagens) + 1);
  imagens[High(imagens)] := AUrl;
end;

function TProdutoAPI.ToJson: TJSONObject;
var
  Arr: TJSONArray;
  V: TProdutoVolume;
  s: string;
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

  Arr := TJSONArray.Create;
  for V in FVolumes do
    Arr.AddElement(V.ToJson);
  Result.AddPair('volumes',                 Arr);

  Result.AddPair('habilitado',              TJSONNumber.Create(habilitado));
  Result.AddPair('codigogrupo',             StrOrNull(codigogrupo));
  Result.AddPair('idgrupo',                 StrOrNull(idgrupo));
  Result.AddPair('nomegrupo',               StrOrNull(nomegrupo));
  Result.AddPair('codigosubgrupo',          StrOrNull(codigosubgrupo));
  Result.AddPair('idsubgrupo',              StrOrNull(idsubgrupo));
  Result.AddPair('nomesubgrupo',            StrOrNull(nomesubgrupo));

  Arr := TJSONArray.Create;
  for s in imagens do
    Arr.AddElement(StrOrNull(s));
  Result.AddPair('imagens',                 Arr);
end;

procedure TProdutoAPI.FromJson(AJson: TJSONObject);
var
  Arr: TJSONArray;
  V: TProdutoVolume;
  i: Integer;
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
  is_deleted              := JsonIntOrZero('is_deleted', AJson);
  deleted_at              := JsonStrOrEmpty('deleted_at', AJson);
  synced_at               := JsonStrOrEmpty('synced_at', AJson);
  created_at              := JsonStrOrEmpty('created_at', AJson);
  updated_at              := JsonStrOrEmpty('updated_at', AJson);

  if AJson.TryGetValue('volumes', Arr) then
    for i := 0 to Arr.Count - 1 do
    begin
      V := TProdutoVolume.Create;
      V.FromJson(TJSONObject(Arr.Items[i]));
      FVolumes.Add(V);
    end;

  if AJson.TryGetValue('imagens', Arr) then
    for i := 0 to Arr.Count - 1 do
    begin
      if Arr.Items[i] is TJSONNull then
        AddImagem('')
      else
        AddImagem(Arr.Items[i].Value);
    end;
end;

end.

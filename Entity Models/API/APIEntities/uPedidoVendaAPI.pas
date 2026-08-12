unit uPedidoVendaAPI;

interface

uses
  System.JSON, System.SysUtils, System.Generics.Collections,
  uJsonUtils;

type
  TPedidoVendaItemAPI = class
  public
    // --- campos enviados (ERP . API) ---
    codigo: string;
    sequencia: Integer;
    pedido_codigoerp: string;
    produto_codigoerp: string;
    cor_codigoerp: string;
    acabamento_codigoerp: string;
    variacao_codigoerp: string;
    idproduto: string;
    idvariacao: string;
    nomeproduto: string;
    referencia: string;
    cor: string;
    tamanho: string;
    quantidade: Double;
    quantidadeproduzir: Double;
    valorunitario: Double;
    valorsubtotal: Double;
    percentualdesconto: Double;
    valordesconto: Double;
    valortotal: Double;
    codigofilial: string;
    setor: string;
    numeroserie: string;
    pesobruto: Double;
    pesoliquido: Double;
    m3: Double;
    qtdevolumes: Double;
    observacoes: string;
    ordemcompra: string;
    sku: string;

    // --- campos retornados pela API (GET) ---
    id: string;
    pedido_id: string;
    is_deleted: Integer;

    function ToJson: TJSONObject;
    procedure FromJson(AJson: TJSONObject);
  end;

  TPedidoVendaAPI = class
  private
    FItens: TObjectList<TPedidoVendaItemAPI>;
    function GetItens: TJSONArray;
  public
    // --- campos enviados (ERP . API) ---
    codigoerp: string;
    pedido: string;
    cliente_codigoerp: string;
    representante_codigoerp: string;
    supervisor_codigoerp: string;
    transportadora_codigoerp: string;
    endereco_codigoerp: string;
    tabelafaturamento_codigoerp: string;
    condicaopagamento_codigoerp: string;
    tipopagamento_codigoerp: string;
    setor_codigoerp: string;
    tabelapreco_codigoerp: string;
    datapedido: string;
    previsaoentrega: string;
    dataentrega: string;
    datacadastro: string;
    database: string;
    idcliente: string;
    nomecliente: string;
    idrepresentante: string;
    nomerepresentante: string;
    idsupervisor: string;
    nomesupervisor: string;
    idtransportadora: string;
    idcondicaopagamento: string;
    valorprodutos: Double;
    valorpedido: Double;
    valordesconto: Double;
    valorfrete: Double;
    valorantecipacao: Double;
    percentualfretecif: Double;
    percentualfretefob: Double;
    valorfreteciffob: Double;
    percentualcomissao: Double;
    percentualcomissaosupervisor: Double;
    observacao1: string;
    observacao2: string;
    observacao3: string;
    observacao4: string;
    observacao5: string;
    observacaonfe: string;
    observacao: string;
    situacao: Integer;
    situacaoproducao: Integer;
    usuariocadastro: string;
    prazo1: Integer;
    prazo2: Integer;
    prazo3: Integer;
    prazo4: Integer;
    prazo5: Integer;
    prazo6: Integer;
    prazo7: Integer;
    prazo8: Integer;
    prazo9: Integer;
    prazo10: Integer;
    prazo11: Integer;
    prazo12: Integer;
    vencimento1: string;
    vencimento2: string;
    vencimento3: string;
    vencimento4: string;
    vencimento5: string;
    vencimento6: string;
    vencimento7: string;
    vencimento8: string;
    vencimento9: string;
    vencimento10: string;
    vencimento11: string;
    vencimento12: string;
    codigofilial: string;
    tipo: string;
    gerarfaturamento: string;
    gerarcontasreceber: string;
    movimento: string;
    gerarcomissao: string;
    imprimirduplicata: string;
    tipofrete: Integer;
    carga_codigoerp: string;
    notafiscal: string;
    dataemissaonf: string;
    datasaidanf: string;
    notafiscalassistencia: string;
    volumes: Double;
    especie: string;
    pesobruto: Double;
    pesoliquido: Double;
    m3: Double;
    bloqueado: string;
    datafaturamento: string;
    assistenciatecnica: string;
    codigorastreamento: string;
    vendaloja: string;
    idpedido: string;
    pedidoweb: string;
    responsavelentrega: string;
    habilitadoweb: Smallint;
    tipodesconto: Integer;

    // --- campos retornados pela API (GET) ---
    id: string;
    tenant_id: string;
    is_deleted: Integer;
    deleted_at: string;
    synced_at: string;
    created_at: string;
    updated_at: string;

    constructor Create;
    destructor Destroy; override;

    procedure AddItem(AItem: TPedidoVendaItemAPI);

    class function ResourceName: string;
    function ToJson: TJSONObject;
    procedure FromJson(AJson: TJSONObject);
  end;

implementation

{ TPedidoVendaItemAPI }

function TPedidoVendaItemAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigo',             StrOrNull(codigo));
  Result.AddPair('sequencia',          TJSONNumber.Create(sequencia));
  Result.AddPair('pedido_codigoerp',          StrOrNull(pedido_codigoerp));
  Result.AddPair('produto_codigoerp',         StrOrNull(produto_codigoerp));
  Result.AddPair('cor_codigoerp',             StrOrNull(cor_codigoerp));
  Result.AddPair('acabamento_codigoerp',      StrOrNull(acabamento_codigoerp));
  Result.AddPair('variacao_codigoerp',        StrOrNull(variacao_codigoerp));
  Result.AddPair('idproduto',          StrOrNull(idproduto));
  Result.AddPair('idvariacao',         StrOrNull(idvariacao));
  Result.AddPair('nomeproduto',        StrOrNull(nomeproduto));
  Result.AddPair('referencia',         StrOrNull(referencia));
  Result.AddPair('cor',                StrOrNull(cor));
  Result.AddPair('tamanho',            StrOrNull(tamanho));
  Result.AddPair('quantidade',         TJSONNumber.Create(quantidade));
  Result.AddPair('quantidadeproduzir', TJSONNumber.Create(quantidadeproduzir));
  Result.AddPair('valorunitario',      TJSONNumber.Create(valorunitario));
  Result.AddPair('valorsubtotal',      TJSONNumber.Create(valorsubtotal));
  Result.AddPair('percentualdesconto', TJSONNumber.Create(percentualdesconto));
  Result.AddPair('valordesconto',      TJSONNumber.Create(valordesconto));
  Result.AddPair('valortotal',         TJSONNumber.Create(valortotal));
  Result.AddPair('codigofilial',       StrOrNull(codigofilial));
  Result.AddPair('setor',              StrOrNull(setor));
  Result.AddPair('numeroserie',        StrOrNull(numeroserie));
  Result.AddPair('pesobruto',          TJSONNumber.Create(pesobruto));
  Result.AddPair('pesoliquido',        TJSONNumber.Create(pesoliquido));
  Result.AddPair('m3',                 TJSONNumber.Create(m3));
  Result.AddPair('qtdevolumes',        TJSONNumber.Create(qtdevolumes));
  Result.AddPair('observacoes',        StrOrNull(observacoes));
  Result.AddPair('ordemcompra',        StrOrNull(ordemcompra));
  Result.AddPair('sku',                StrOrNull(sku));
end;

procedure TPedidoVendaItemAPI.FromJson(AJson: TJSONObject);
begin
  codigo             := JsonStrOrEmpty('codigo', AJson);
  sequencia          := JsonIntOrZero('sequencia', AJson);
  pedido_codigoerp          := JsonStrOrEmpty('pedido_codigoerp', AJson);
  produto_codigoerp         := JsonStrOrEmpty('produto_codigoerp', AJson);
  cor_codigoerp             := JsonStrOrEmpty('cor_codigoerp', AJson);
  acabamento_codigoerp      := JsonStrOrEmpty('acabamento_codigoerp', AJson);
  variacao_codigoerp        := JsonStrOrEmpty('variacao_codigoerp', AJson);
  idproduto          := JsonStrOrEmpty('idproduto', AJson);
  idvariacao         := JsonStrOrEmpty('idvariacao', AJson);
  nomeproduto        := JsonStrOrEmpty('nomeproduto', AJson);
  referencia         := JsonStrOrEmpty('referencia', AJson);
  cor                := JsonStrOrEmpty('cor', AJson);
  tamanho            := JsonStrOrEmpty('tamanho', AJson);
  quantidade         := JsonFloatOrZero('quantidade', AJson);
  quantidadeproduzir := JsonFloatOrZero('quantidadeproduzir', AJson);
  valorunitario      := JsonFloatOrZero('valorunitario', AJson);
  valorsubtotal      := JsonFloatOrZero('valorsubtotal', AJson);
  percentualdesconto := JsonFloatOrZero('percentualdesconto', AJson);
  valordesconto      := JsonFloatOrZero('valordesconto', AJson);
  valortotal         := JsonFloatOrZero('valortotal', AJson);
  codigofilial       := JsonStrOrEmpty('codigofilial', AJson);
  setor              := JsonStrOrEmpty('setor', AJson);
  numeroserie        := JsonStrOrEmpty('numeroserie', AJson);
  pesobruto          := JsonFloatOrZero('pesobruto', AJson);
  pesoliquido        := JsonFloatOrZero('pesoliquido', AJson);
  m3                 := JsonFloatOrZero('m3', AJson);
  qtdevolumes        := JsonFloatOrZero('qtdevolumes', AJson);
  observacoes        := JsonStrOrEmpty('observacoes', AJson);
  ordemcompra        := JsonStrOrEmpty('ordemcompra', AJson);
  sku                := JsonStrOrEmpty('sku', AJson);
  id                 := JsonStrOrEmpty('id', AJson);
  pedido_id          := JsonStrOrEmpty('pedido_id', AJson);
  is_deleted         := JsonIntOrZero('is_deleted', AJson);
end;

{ TPedidoVendaAPI }

class function TPedidoVendaAPI.ResourceName: string;
begin
  Result := '/pedidosvenda';
end;

constructor TPedidoVendaAPI.Create;
begin
  inherited;
  FItens := TObjectList<TPedidoVendaItemAPI>.Create(True);
end;

destructor TPedidoVendaAPI.Destroy;
begin
  FItens.Free;
  inherited;
end;

procedure TPedidoVendaAPI.AddItem(AItem: TPedidoVendaItemAPI);
begin
  FItens.Add(AItem);
end;

function TPedidoVendaAPI.GetItens: TJSONArray;
var
  Item: TPedidoVendaItemAPI;
begin
  Result := TJSONArray.Create;
  for Item in FItens do
    Result.AddElement(Item.ToJson);
end;

function TPedidoVendaAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigoerp',                 StrOrNull(codigoerp));
  Result.AddPair('pedido',                    StrOrNull(pedido));
  Result.AddPair('cliente_codigoerp',                StrOrNull(cliente_codigoerp));
  Result.AddPair('representante_codigoerp',          StrOrNull(representante_codigoerp));
  Result.AddPair('supervisor_codigoerp',             StrOrNull(supervisor_codigoerp));
  Result.AddPair('transportadora_codigoerp',         StrOrNull(transportadora_codigoerp));
  Result.AddPair('endereco_codigoerp',               StrOrNull(endereco_codigoerp));
  Result.AddPair('tabelafaturamento_codigoerp',      StrOrNull(tabelafaturamento_codigoerp));
  Result.AddPair('condicaopagamento_codigoerp',      StrOrNull(condicaopagamento_codigoerp));
  Result.AddPair('tipopagamento_codigoerp',          StrOrNull(tipopagamento_codigoerp));
  Result.AddPair('setor_codigoerp',                  StrOrNull(setor_codigoerp));
  Result.AddPair('tabelapreco_codigoerp',            StrOrNull(tabelapreco_codigoerp));
  Result.AddPair('datapedido',                StrOrNull(datapedido));
  Result.AddPair('previsaoentrega',           StrOrNull(previsaoentrega));
  Result.AddPair('dataentrega',               StrOrNull(dataentrega));
  Result.AddPair('datacadastro',              StrOrNull(datacadastro));
  Result.AddPair('database',                  StrOrNull(database));
  Result.AddPair('idcliente',                 StrOrNull(idcliente));
  Result.AddPair('nomecliente',               StrOrNull(nomecliente));
  Result.AddPair('idrepresentante',           StrOrNull(idrepresentante));
  Result.AddPair('nomerepresentante',         StrOrNull(nomerepresentante));
  Result.AddPair('idsupervisor',              StrOrNull(idsupervisor));
  Result.AddPair('nomesupervisor',            StrOrNull(nomesupervisor));
  Result.AddPair('idtransportadora',          StrOrNull(idtransportadora));
  Result.AddPair('idcondicaopagamento',       StrOrNull(idcondicaopagamento));
  Result.AddPair('valorprodutos',             TJSONNumber.Create(valorprodutos));
  Result.AddPair('valorpedido',               TJSONNumber.Create(valorpedido));
  Result.AddPair('valordesconto',             TJSONNumber.Create(valordesconto));
  Result.AddPair('valorfrete',                TJSONNumber.Create(valorfrete));
  Result.AddPair('valorantecipacao',          TJSONNumber.Create(valorantecipacao));
  Result.AddPair('percentualfretecif',        TJSONNumber.Create(percentualfretecif));
  Result.AddPair('percentualfretefob',        TJSONNumber.Create(percentualfretefob));
  Result.AddPair('valorfreteciffob',          TJSONNumber.Create(valorfreteciffob));
  Result.AddPair('percentualcomissao',        TJSONNumber.Create(percentualcomissao));
  Result.AddPair('percentualcomissaosupervisor', TJSONNumber.Create(percentualcomissaosupervisor));
  Result.AddPair('observacao1',               StrOrNull(observacao1));
  Result.AddPair('observacao2',               StrOrNull(observacao2));
  Result.AddPair('observacao3',               StrOrNull(observacao3));
  Result.AddPair('observacao4',               StrOrNull(observacao4));
  Result.AddPair('observacao5',               StrOrNull(observacao5));
  Result.AddPair('observacaonfe',             StrOrNull(observacaonfe));
  Result.AddPair('observacao',                StrOrNull(observacao));
  Result.AddPair('situacao',                  TJSONNumber.Create(situacao));
  Result.AddPair('situacaoproducao',          TJSONNumber.Create(situacaoproducao));
  Result.AddPair('usuariocadastro',           StrOrNull(usuariocadastro));
  Result.AddPair('prazo1',                    TJSONNumber.Create(prazo1));
  Result.AddPair('prazo2',                    TJSONNumber.Create(prazo2));
  Result.AddPair('prazo3',                    TJSONNumber.Create(prazo3));
  Result.AddPair('prazo4',                    TJSONNumber.Create(prazo4));
  Result.AddPair('prazo5',                    TJSONNumber.Create(prazo5));
  Result.AddPair('prazo6',                    TJSONNumber.Create(prazo6));
  Result.AddPair('prazo7',                    TJSONNumber.Create(prazo7));
  Result.AddPair('prazo8',                    TJSONNumber.Create(prazo8));
  Result.AddPair('prazo9',                    TJSONNumber.Create(prazo9));
  Result.AddPair('prazo10',                   TJSONNumber.Create(prazo10));
  Result.AddPair('prazo11',                   TJSONNumber.Create(prazo11));
  Result.AddPair('prazo12',                   TJSONNumber.Create(prazo12));
  Result.AddPair('vencimento1',               StrOrNull(vencimento1));
  Result.AddPair('vencimento2',               StrOrNull(vencimento2));
  Result.AddPair('vencimento3',               StrOrNull(vencimento3));
  Result.AddPair('vencimento4',               StrOrNull(vencimento4));
  Result.AddPair('vencimento5',               StrOrNull(vencimento5));
  Result.AddPair('vencimento6',               StrOrNull(vencimento6));
  Result.AddPair('vencimento7',               StrOrNull(vencimento7));
  Result.AddPair('vencimento8',               StrOrNull(vencimento8));
  Result.AddPair('vencimento9',               StrOrNull(vencimento9));
  Result.AddPair('vencimento10',              StrOrNull(vencimento10));
  Result.AddPair('vencimento11',              StrOrNull(vencimento11));
  Result.AddPair('vencimento12',              StrOrNull(vencimento12));
  Result.AddPair('codigofilial',              StrOrNull(codigofilial));
  Result.AddPair('tipo',                      StrOrNull(tipo));
  Result.AddPair('gerarfaturamento',          StrOrNull(gerarfaturamento));
  Result.AddPair('gerarcontasreceber',        StrOrNull(gerarcontasreceber));
  Result.AddPair('movimento',                 StrOrNull(movimento));
  Result.AddPair('gerarcomissao',             StrOrNull(gerarcomissao));
  Result.AddPair('imprimirduplicata',         StrOrNull(imprimirduplicata));
  Result.AddPair('tipofrete',                 TJSONNumber.Create(tipofrete));
  Result.AddPair('carga_codigoerp',                  StrOrNull(carga_codigoerp));
  Result.AddPair('notafiscal',                StrOrNull(notafiscal));
  Result.AddPair('dataemissaonf',             StrOrNull(dataemissaonf));
  Result.AddPair('datasaidanf',               StrOrNull(datasaidanf));
  Result.AddPair('notafiscalassistencia',     StrOrNull(notafiscalassistencia));
  Result.AddPair('volumes',                   TJSONNumber.Create(volumes));
  Result.AddPair('especie',                   StrOrNull(especie));
  Result.AddPair('pesobruto',                 TJSONNumber.Create(pesobruto));
  Result.AddPair('pesoliquido',               TJSONNumber.Create(pesoliquido));
  Result.AddPair('m3',                        TJSONNumber.Create(m3));
  Result.AddPair('bloqueado',                 StrOrNull(bloqueado));
  Result.AddPair('datafaturamento',           StrOrNull(datafaturamento));
  Result.AddPair('assistenciatecnica',        StrOrNull(assistenciatecnica));
  Result.AddPair('codigorastreamento',        StrOrNull(codigorastreamento));
  Result.AddPair('vendaloja',                 StrOrNull(vendaloja));
  Result.AddPair('idpedido',                  StrOrNull(idpedido));
  Result.AddPair('pedidoweb',                 StrOrNull(pedidoweb));
  Result.AddPair('responsavelentrega',        StrOrNull(responsavelentrega));
  Result.AddPair('habilitadoweb',             TJSONNumber.Create(habilitadoweb));
  Result.AddPair('tipodesconto',              TJSONNumber.Create(tipodesconto));

  Result.AddPair('itens',                     GetItens);
end;

procedure TPedidoVendaAPI.FromJson(AJson: TJSONObject);
var
  Arr: TJSONArray;
  i: Integer;
  Item: TPedidoVendaItemAPI;
begin
  codigoerp                 := JsonStrOrEmpty('codigoerp', AJson);
  pedido                    := JsonStrOrEmpty('pedido', AJson);
  cliente_codigoerp                := JsonStrOrEmpty('cliente_codigoerp', AJson);
  representante_codigoerp          := JsonStrOrEmpty('representante_codigoerp', AJson);
  supervisor_codigoerp             := JsonStrOrEmpty('supervisor_codigoerp', AJson);
  transportadora_codigoerp         := JsonStrOrEmpty('transportadora_codigoerp', AJson);
  endereco_codigoerp               := JsonStrOrEmpty('endereco_codigoerp', AJson);
  tabelafaturamento_codigoerp      := JsonStrOrEmpty('tabelafaturamento_codigoerp', AJson);
  condicaopagamento_codigoerp      := JsonStrOrEmpty('condicaopagamento_codigoerp', AJson);
  tipopagamento_codigoerp          := JsonStrOrEmpty('tipopagamento_codigoerp', AJson);
  setor_codigoerp                  := JsonStrOrEmpty('setor_codigoerp', AJson);
  tabelapreco_codigoerp            := JsonStrOrEmpty('tabelapreco_codigoerp', AJson);
  datapedido                := JsonStrOrEmpty('datapedido', AJson);
  previsaoentrega           := JsonStrOrEmpty('previsaoentrega', AJson);
  dataentrega               := JsonStrOrEmpty('dataentrega', AJson);
  datacadastro              := JsonStrOrEmpty('datacadastro', AJson);
  database                  := JsonStrOrEmpty('database', AJson);
  idcliente                 := JsonStrOrEmpty('idcliente', AJson);
  nomecliente               := JsonStrOrEmpty('nomecliente', AJson);
  idrepresentante           := JsonStrOrEmpty('idrepresentante', AJson);
  nomerepresentante         := JsonStrOrEmpty('nomerepresentante', AJson);
  idsupervisor              := JsonStrOrEmpty('idsupervisor', AJson);
  nomesupervisor            := JsonStrOrEmpty('nomesupervisor', AJson);
  idtransportadora          := JsonStrOrEmpty('idtransportadora', AJson);
  idcondicaopagamento       := JsonStrOrEmpty('idcondicaopagamento', AJson);
  valorprodutos             := JsonFloatOrZero('valorprodutos', AJson);
  valorpedido               := JsonFloatOrZero('valorpedido', AJson);
  valordesconto             := JsonFloatOrZero('valordesconto', AJson);
  valorfrete                := JsonFloatOrZero('valorfrete', AJson);
  valorantecipacao          := JsonFloatOrZero('valorantecipacao', AJson);
  percentualfretecif        := JsonFloatOrZero('percentualfretecif', AJson);
  percentualfretefob        := JsonFloatOrZero('percentualfretefob', AJson);
  valorfreteciffob          := JsonFloatOrZero('valorfreteciffob', AJson);
  percentualcomissao        := JsonFloatOrZero('percentualcomissao', AJson);
  percentualcomissaosupervisor := JsonFloatOrZero('percentualcomissaosupervisor', AJson);
  observacao1               := JsonStrOrEmpty('observacao1', AJson);
  observacao2               := JsonStrOrEmpty('observacao2', AJson);
  observacao3               := JsonStrOrEmpty('observacao3', AJson);
  observacao4               := JsonStrOrEmpty('observacao4', AJson);
  observacao5               := JsonStrOrEmpty('observacao5', AJson);
  observacaonfe             := JsonStrOrEmpty('observacaonfe', AJson);
  observacao                := JsonStrOrEmpty('observacao', AJson);
  situacao                  := JsonIntOrZero('situacao', AJson);
  situacaoproducao          := JsonIntOrZero('situacaoproducao', AJson);
  usuariocadastro           := JsonStrOrEmpty('usuariocadastro', AJson);
  prazo1                    := JsonIntOrZero('prazo1', AJson);
  prazo2                    := JsonIntOrZero('prazo2', AJson);
  prazo3                    := JsonIntOrZero('prazo3', AJson);
  prazo4                    := JsonIntOrZero('prazo4', AJson);
  prazo5                    := JsonIntOrZero('prazo5', AJson);
  prazo6                    := JsonIntOrZero('prazo6', AJson);
  prazo7                    := JsonIntOrZero('prazo7', AJson);
  prazo8                    := JsonIntOrZero('prazo8', AJson);
  prazo9                    := JsonIntOrZero('prazo9', AJson);
  prazo10                   := JsonIntOrZero('prazo10', AJson);
  prazo11                   := JsonIntOrZero('prazo11', AJson);
  prazo12                   := JsonIntOrZero('prazo12', AJson);
  vencimento1               := JsonStrOrEmpty('vencimento1', AJson);
  vencimento2               := JsonStrOrEmpty('vencimento2', AJson);
  vencimento3               := JsonStrOrEmpty('vencimento3', AJson);
  vencimento4               := JsonStrOrEmpty('vencimento4', AJson);
  vencimento5               := JsonStrOrEmpty('vencimento5', AJson);
  vencimento6               := JsonStrOrEmpty('vencimento6', AJson);
  vencimento7               := JsonStrOrEmpty('vencimento7', AJson);
  vencimento8               := JsonStrOrEmpty('vencimento8', AJson);
  vencimento9               := JsonStrOrEmpty('vencimento9', AJson);
  vencimento10              := JsonStrOrEmpty('vencimento10', AJson);
  vencimento11              := JsonStrOrEmpty('vencimento11', AJson);
  vencimento12              := JsonStrOrEmpty('vencimento12', AJson);
  codigofilial              := JsonStrOrEmpty('codigofilial', AJson);
  tipo                      := JsonStrOrEmpty('tipo', AJson);
  gerarfaturamento          := JsonStrOrEmpty('gerarfaturamento', AJson);
  gerarcontasreceber        := JsonStrOrEmpty('gerarcontasreceber', AJson);
  movimento                 := JsonStrOrEmpty('movimento', AJson);
  gerarcomissao             := JsonStrOrEmpty('gerarcomissao', AJson);
  imprimirduplicata         := JsonStrOrEmpty('imprimirduplicata', AJson);
  tipofrete                 := JsonIntOrZero('tipofrete', AJson);
  carga_codigoerp                  := JsonStrOrEmpty('carga_codigoerp', AJson);
  notafiscal                := JsonStrOrEmpty('notafiscal', AJson);
  dataemissaonf             := JsonStrOrEmpty('dataemissaonf', AJson);
  datasaidanf               := JsonStrOrEmpty('datasaidanf', AJson);
  notafiscalassistencia     := JsonStrOrEmpty('notafiscalassistencia', AJson);
  volumes                   := JsonFloatOrZero('volumes', AJson);
  especie                   := JsonStrOrEmpty('especie', AJson);
  pesobruto                 := JsonFloatOrZero('pesobruto', AJson);
  pesoliquido               := JsonFloatOrZero('pesoliquido', AJson);
  m3                        := JsonFloatOrZero('m3', AJson);
  bloqueado                 := JsonStrOrEmpty('bloqueado', AJson);
  datafaturamento           := JsonStrOrEmpty('datafaturamento', AJson);
  assistenciatecnica        := JsonStrOrEmpty('assistenciatecnica', AJson);
  codigorastreamento        := JsonStrOrEmpty('codigorastreamento', AJson);
  vendaloja                 := JsonStrOrEmpty('vendaloja', AJson);
  idpedido                  := JsonStrOrEmpty('idpedido', AJson);
  pedidoweb                 := JsonStrOrEmpty('pedidoweb', AJson);
  responsavelentrega        := JsonStrOrEmpty('responsavelentrega', AJson);
  habilitadoweb             := JsonIntOrZero('habilitadoweb', AJson);
  tipodesconto              := JsonIntOrZero('tipodesconto', AJson);
  id                        := JsonStrOrEmpty('id', AJson);
  tenant_id                 := JsonStrOrEmpty('tenant_id', AJson);
  is_deleted                := JsonIntOrZero('is_deleted', AJson);
  deleted_at                := JsonStrOrEmpty('deleted_at', AJson);
  synced_at                 := JsonStrOrEmpty('synced_at', AJson);
  created_at                := JsonStrOrEmpty('created_at', AJson);
  updated_at                := JsonStrOrEmpty('updated_at', AJson);

  if AJson.TryGetValue('itens', Arr) then
    for i := 0 to Arr.Count - 1 do
    begin
      Item := TPedidoVendaItemAPI.Create;
      Item.FromJson(TJSONObject(Arr.Items[i]));
      FItens.Add(Item);
    end;
end;

end.

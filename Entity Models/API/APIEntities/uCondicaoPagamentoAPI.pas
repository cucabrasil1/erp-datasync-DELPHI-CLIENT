unit uCondicaoPagamentoAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.Generics.Collections,
  uJsonUtils;

type
  TParcelaAPI = class
  public
    // --- campos enviados (ERP . API) ---
    codigoerp: string;
    parcela: Integer;
    dias: Integer;
    percentual: Double;
    juros: Double;

    // --- campos retornados pela API (GET) ---
    id: string;
    condicao_id: string;
    is_deleted: Integer;
    created_at: string;
    updated_at: string;

    function ToJson: TJSONObject;
    procedure FromJson(AJson: TJSONObject);
  end;

  TCondicaoPagamentoAPI = class
  private
    FParcelas: TObjectList<TParcelaAPI>;
    function GetParcelas: TJSONArray;
  public
    // --- campos enviados (ERP . API) ---
    codigoerp: string;
    descricao: string;
    codtipopagamento: string;
    qtdeparcelas: Integer;
    habilitado: Integer;

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

    procedure AddParcela(const ACodigoerp: string; AParcela, ADias: Integer;
      APercentual, AJuros: Double);

    class function ResourceName: string;
    function ToJson: TJSONObject;
    procedure FromJson(AJson: TJSONObject);
  end;

implementation

{ TParcelaAPI }

function TParcelaAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigoerp',  codigoerp);
  Result.AddPair('parcela',    TJSONNumber.Create(parcela));
  Result.AddPair('dias',       TJSONNumber.Create(dias));
  Result.AddPair('percentual', TJSONNumber.Create(percentual));
  Result.AddPair('juros',      TJSONNumber.Create(juros));
end;

procedure TParcelaAPI.FromJson(AJson: TJSONObject);
begin
  codigoerp    := JsonStrOrEmpty('codigoerp', AJson);
  parcela      := JsonIntOrZero('parcela', AJson);
  dias         := JsonIntOrZero('dias', AJson);
  percentual   := JsonFloatOrZero('percentual', AJson);
  juros        := JsonFloatOrZero('juros', AJson);
  id           := JsonStrOrEmpty('id', AJson);
  condicao_id  := JsonStrOrEmpty('condicao_id', AJson);
  is_deleted   := JsonIntOrZero('is_deleted', AJson);
  created_at   := JsonStrOrEmpty('created_at', AJson);
  updated_at   := JsonStrOrEmpty('updated_at', AJson);
end;

{ TCondicaoPagamentoAPI }

class function TCondicaoPagamentoAPI.ResourceName: string;
begin
  Result := '/condicaopagamento';
end;

constructor TCondicaoPagamentoAPI.Create;
begin
  inherited;
  FParcelas := TObjectList<TParcelaAPI>.Create(True);
end;

destructor TCondicaoPagamentoAPI.Destroy;
begin
  FParcelas.Free;
  inherited;
end;

procedure TCondicaoPagamentoAPI.AddParcela(const ACodigoerp: string;
  AParcela, ADias: Integer; APercentual, AJuros: Double);
var
  P: TParcelaAPI;
begin
  P := TParcelaAPI.Create;
  P.codigoerp  := ACodigoerp;
  P.parcela     := AParcela;
  P.dias        := ADias;
  P.percentual  := APercentual;
  P.juros       := AJuros;
  FParcelas.Add(P);
end;

function TCondicaoPagamentoAPI.GetParcelas: TJSONArray;
var
  P: TParcelaAPI;
begin
  Result := TJSONArray.Create;
  for P in FParcelas do
    Result.AddElement(P.ToJson);
end;

function TCondicaoPagamentoAPI.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigoerp',        codigoerp);
  Result.AddPair('descricao',        descricao);
  Result.AddPair('codtipopagamento', codtipopagamento);
  Result.AddPair('qtdeparcelas',     TJSONNumber.Create(qtdeparcelas));
  Result.AddPair('habilitado',       TJSONNumber.Create(habilitado));
  Result.AddPair('parcelas',         GetParcelas);
end;

procedure TCondicaoPagamentoAPI.FromJson(AJson: TJSONObject);
var
  Arr: TJSONArray;
  i: Integer;
  P: TParcelaAPI;
begin
  codigoerp        := JsonStrOrEmpty('codigoerp', AJson);
  descricao        := JsonStrOrEmpty('descricao', AJson);
  codtipopagamento := JsonStrOrEmpty('codtipopagamento', AJson);
  qtdeparcelas     := JsonIntOrZero('qtdeparcelas', AJson);
  habilitado       := JsonIntOrZero('habilitado', AJson);
  id               := JsonStrOrEmpty('id', AJson);
  tenant_id        := JsonStrOrEmpty('tenant_id', AJson);
  is_deleted       := JsonIntOrZero('is_deleted', AJson);
  deleted_at       := JsonStrOrEmpty('deleted_at', AJson);
  synced_at        := JsonStrOrEmpty('synced_at', AJson);
  created_at       := JsonStrOrEmpty('created_at', AJson);
  updated_at       := JsonStrOrEmpty('updated_at', AJson);

  if AJson.TryGetValue('parcelas', Arr) then
    for i := 0 to Arr.Count - 1 do
    begin
      P := TParcelaAPI.Create;
      P.FromJson(TJSONObject(Arr.Items[i]));
      FParcelas.Add(P);
    end;
end;

end.



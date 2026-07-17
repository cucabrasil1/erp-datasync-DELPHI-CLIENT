unit uCondicaoPagamentoAPI;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.Generics.Collections;

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

  function DblOrZero(const AKey: string): Double;
  begin
    if (AJson.GetValue(AKey) = nil) or (AJson.GetValue(AKey) is TJSONNull) then
      Result := 0
    else
      Result := AJson.GetValue<Double>(AKey);
  end;

begin
  codigoerp    := StrOrEmpty('codigoerp');
  parcela      := IntOrZero('parcela');
  dias         := IntOrZero('dias');
  percentual   := DblOrZero('percentual');
  juros        := DblOrZero('juros');
  id           := StrOrEmpty('id');
  condicao_id  := StrOrEmpty('condicao_id');
  is_deleted   := IntOrZero('is_deleted');
  created_at   := StrOrEmpty('created_at');
  updated_at   := StrOrEmpty('updated_at');
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

var
  Arr: TJSONArray;
  i: Integer;
  P: TParcelaAPI;
begin
  codigoerp        := StrOrEmpty('codigoerp');
  descricao        := StrOrEmpty('descricao');
  codtipopagamento := StrOrEmpty('codtipopagamento');
  qtdeparcelas     := IntOrZero('qtdeparcelas');
  habilitado       := IntOrZero('habilitado');
  id               := StrOrEmpty('id');
  tenant_id        := StrOrEmpty('tenant_id');
  is_deleted       := IntOrZero('is_deleted');
  deleted_at       := StrOrEmpty('deleted_at');
  synced_at        := StrOrEmpty('synced_at');
  created_at       := StrOrEmpty('created_at');
  updated_at       := StrOrEmpty('updated_at');

  if AJson.TryGetValue('parcelas', Arr) then
    for i := 0 to Arr.Count - 1 do
    begin
      P := TParcelaAPI.Create;
      P.FromJson(TJSONObject(Arr.Items[i]));
      FParcelas.Add(P);
    end;
end;

end.



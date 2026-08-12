unit uEntityProduto;

interface

uses
  System.JSON, System.SysUtils, System.Math, System.StrUtils, FireDAC.Comp.Client, Data.DB,
  uEntityBase, uProdutoAPI;

type
  TEntityProduto = class(TEntityBase)
  protected
    class function GetTableNameClass: string; override;
    function GetResourceName: string; override;
    function GetRecord(ACodRecord: string): TDataSet; override;
    function MapToJson(ADataSet: TDataSet): TJSONObject; override;
    function GetApiId(ADataSet: TDataSet): string; override;
    function GetUnsyncedRecords: TDataSet; override;
    function GetBatchSize: Integer; override;
    function GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string; override;
    procedure StoreApiIdBack(ACodRecord, AApiId: string); override;
    function GetVolumes(ACodProduto: string): TDataSet;
  end;

implementation

uses
  FireDAC.Stan.Param, uEntityFactory;

{ TEntityProduto }

class function TEntityProduto.GetTableNameClass: string;
begin
  Result := 'C000025';
end;

function TEntityProduto.GetResourceName: string;
begin
  Result := TProdutoAPI.ResourceName;
end;

function TEntityProduto.GetRecord(ACodRecord: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select p.*, sbg.idsubgrupo, sbg.subgrupo,');
    Qry.SQL.Add('gp.idgrupo, gp.grupo,');
    Qry.SQL.Add('case when exists (select 1 from C000248 v where v.codproduto = p.codigo)');
    Qry.SQL.Add('  then 1 else 0 end as possui_volume');
    Qry.SQL.Add('from ' + GetTableNameClass + ' p');
    Qry.SQL.Add('left outer join C000018 sbg on sbg.codigo = p.codsubgrupo');
    Qry.SQL.Add('left outer join C000017 gp on gp.codigo = p.codgrupo');
    Qry.SQL.Add('where p.codigo = :cod');
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityProduto.GetApiId(ADataSet: TDataSet): string;
begin
  if FDatabaseType = dtIndustrial then
    Result := ADataSet.FieldByName('IDPRODUTO').AsString
  else
    Result := ADataSet.FieldByName('IDPRODUTO').AsString; // ajustar para comercial se diferente
end;

function TEntityProduto.GetVolumes(ACodProduto: string): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select * from C000248');
    Qry.SQL.Add('where codproduto = :cod');
    Qry.ParamByName('cod').AsString := ACodProduto;
    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityProduto.MapToJson(ADataSet: TDataSet): TJSONObject;
var
  DTO: TProdutoAPI;
  VolumesDs: TDataSet;

  function DescricaoTipoItem(const ACodTipoItem: Integer): string;
  begin
    case ACodTipoItem of
      0:  Result := 'Mercadoria para Revenda';
      1:  Result := 'Materia-prima';
      2:  Result := 'Embalagem';
      3:  Result := 'Produto em Processo';
      4:  Result := 'Produto Acabado';
      5:  Result := 'Subproduto';
      6:  Result := 'Produto Intermediario';
      7:  Result := 'Material de Uso e Consumo';
      8:  Result := 'Ativo Imobilizado';
      9:  Result := 'Serviço';
      10: Result := 'Outros insumos';
      99: Result := 'Outras';
    else
      Result := '';
    end;
  end;

begin
  DTO := TProdutoAPI.Create;
  try
    DTO.codigoerp             := ADataSet.FieldByName('codigo').AsString;
    DTO.produto               := ADataSet.FieldByName('produto').AsString;
    DTO.referencia            := ADataSet.FieldByName('referencia').AsString;
    DTO.codbarras             := ADataSet.FieldByName('codbarra').AsString;
    DTO.codbarrastributavel   := ADataSet.FieldByName('codbarratributavel').AsString;
    DTO.unidade               := ADataSet.FieldByName('unidade').AsString;
    DTO.origem                := ADataSet.FieldByName('origemproduto').AsInteger;
    DTO.classificacao         := DescricaoTipoItem(ADataSet.FieldByName('codtipoitem').AsInteger);
    DTO.codtipoitem           := ADataSet.FieldByName('codtipoitem').AsInteger;
    DTO.cst                   := ADataSet.FieldByName('cst').AsString;
    DTO.ncm                   := ADataSet.FieldByName('ncm').AsString;
    DTO.cest                  := ADataSet.FieldByName('codigocest').AsString;
//    DTO.precocompra           := ADataSet.FieldByName('precocompra').AsFloat;
//    DTO.precocusto            := ADataSet.FieldByName('precocusto').AsFloat;
//    DTO.precovenda            := ADataSet.FieldByName('precovenda').AsFloat;
//    DTO.tipo                  := ADataSet.FieldByName('tipo').AsString;
    DTO.qtdevolume            := ADataSet.FieldByName('qtde_embalagem').AsInteger;
    DTO.m3                    := ADataSet.FieldByName('m3').AsFloat;
    DTO.pesobruto             := ADataSet.FieldByName('peso').AsFloat;
    DTO.pesoliquido           := ADataSet.FieldByName('peso_liquido').AsFloat;
    DTO.altura                := ADataSet.FieldByName('altura').AsFloat;
    DTO.largura               := ADataSet.FieldByName('largura').AsFloat;
    DTO.profundidade          := ADataSet.FieldByName('profundidade').AsFloat;
    DTO.possuivariacaocor     := IfThen(ADataSet.FieldByName('produtopossuivariacaocor').AsString = 'S', 1, 0);
    DTO.destacargtindfe       := IfThen(ADataSet.FieldByName('destacargtindfe').AsString = 'S', 1, 0);
    DTO.observacoes           := ADataSet.FieldByName('observacoes').AsString;
    DTO.codigogrupo           := ADataSet.FieldByName('codgrupo').AsString;
    DTO.idgrupo               := ADataSet.FieldByName('idgrupo').AsString;
    DTO.nomegrupo             := ADataSet.FieldByName('grupo').AsString;
    DTO.codigosubgrupo        := ADataSet.FieldByName('codsubgrupo').AsString;
    DTO.idsubgrupo            := ADataSet.FieldByName('idsubgrupo').AsString;
    DTO.nomesubgrupo          := ADataSet.FieldByName('subgrupo').AsString;
    DTO.ativo                 := ifthen(ADataSet.FieldByName('situacao').AsInteger = 0, 1, 0);
    DTO.habilitadoweb            := ifthen(ADataSet.FieldByName('habilitadoweb').AsString = 'S', 1, 0);
    DTO.AddImagem('');
    DTO.AddImagem('');
    DTO.AddImagem('');

    // Volumes: busca so quando produto possuir volume (flag possui_volume)
    if ADataSet.FieldByName('possui_volume').AsInteger > 0 then
    begin
      VolumesDs := GetVolumes(ADataSet.FieldByName('codigo').AsString);
      try
        while not VolumesDs.Eof do
        begin
          DTO.AddVolume(
            VolumesDs.FieldByName('codigo').AsString,
            VolumesDs.FieldByName('nome').AsString,
            VolumesDs.FieldByName('codbarras').AsString,
            VolumesDs.FieldByName('referencia').AsString,
            VolumesDs.FieldByName('pesobruto').AsFloat,
            VolumesDs.FieldByName('pesoliquido').AsFloat,
            VolumesDs.FieldByName('altura').AsInteger,
            VolumesDs.FieldByName('largura').AsInteger,
            VolumesDs.FieldByName('profundidade').AsInteger,
            VolumesDs.FieldByName('quantidade').AsInteger,
            VolumesDs.FieldByName('m3').AsFloat,
            VolumesDs.FieldByName('seqvolume').AsString
          );

          VolumesDs.Next;
        end;
      finally
        VolumesDs.Free;
      end;
    end;

    case FDatabaseType of
      dtIndustrial:
      begin
        // <<CHANGE_ME: campos especificos industrial>>
      end;

      dtCommercial:
      begin
        // <<CHANGE_ME: campos especificos comercial>>
      end;
    end;

    Result := DTO.ToJson;
  finally
    DTO.Free;
  end;
end;

function TEntityProduto.GetUnsyncedRecords: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('select p.*, sbg.idsubgrupo, sbg.subgrupo,');
    Qry.SQL.Add('gp.idgrupo, gp.grupo,');
    Qry.SQL.Add('case when exists (select 1 from C000248 v where v.codproduto = p.codigo)');
    Qry.SQL.Add('  then 1 else 0 end as possui_volume');
    Qry.SQL.Add('from ' + GetTableNameClass + ' p');
    Qry.SQL.Add('left outer join C000018 sbg on sbg.codigo = p.codsubgrupo');
    Qry.SQL.Add('left outer join C000017 gp on gp.codigo = p.codgrupo');
    Qry.SQL.Add('where p.idproduto is null');
    if FDatabaseType = dtIndustrial then
    begin
      Qry.SQL.Add('and p.codigofilial = :filial');
      Qry.ParamByName('filial').AsString := FFilial;
    end;
    Qry.SQL.Add('order by p.codigo');

    Qry.Open;
  except
    Qry.Free;
    raise;
  end;
  Result := Qry;
end;

function TEntityProduto.GetBatchSize: Integer;
begin
  Result := 1000;
end;

function TEntityProduto.GetSyncAllMessage(ASuccess: Boolean; const AErrorMsg: string): string;
begin
  if ASuccess then
    Result := 'Produtos sincronizados com sucesso'
  else
    Result := 'Erro em Produtos: ' + AErrorMsg;
end;

procedure TEntityProduto.StoreApiIdBack(ACodRecord, AApiId: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Add('update ' + GetTableNameClass + ' set idproduto = :apiid');
    Qry.SQL.Add('where codigo = :cod');
    Qry.ParamByName('apiid').AsString := AApiId;
    Qry.ParamByName('cod').AsString := ACodRecord;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

initialization
  TEntityFactory.RegisterEntity(TEntityProduto.GetTableNameClass, TEntityProduto);
end.








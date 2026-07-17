program cucabrasil_proloja_datasync;

uses
  Vcl.Forms,
  frmPrincipal in 'frmPrincipal.pas' {Form2},
  uThreadCuca in 'C:\Fontes\Comuns\Models\uThreadCuca.pas',
  uMRestIntegracao in 'C:\Fontes\Comuns\Models\uMRestIntegracao.pas',
  ufuncoes in 'C:\Fontes\Comuns\ufuncoes.pas',
  dmModulo in 'Local Files\dmModulo.pas' {modulo: TDataModule},
  uLogger in 'uLogger.pas',
  uApiClient in 'Entity Models\API\uApiClient.pas',
  uEntityBase in 'Entity Models\ERP\uEntityBase.pas',
  uEntityFactory in 'Entity Models\ERP\uEntityFactory.pas',
  uPessoaAPI in 'Entity Models\API\APIEntities\uPessoaAPI.pas',
  uAcabamentoAPI in 'Entity Models\API\APIEntities\uAcabamentoAPI.pas',
  uCorAPI in 'Entity Models\API\APIEntities\uCorAPI.pas',
  uTipoPagamentoAPI in 'Entity Models\API\APIEntities\uTipoPagamentoAPI.pas',
  uGrupoClienteAPI in 'Entity Models\API\APIEntities\uGrupoClienteAPI.pas',
  uCenarioFaturamentoAPI in 'Entity Models\API\APIEntities\uCenarioFaturamentoAPI.pas',
  uProdutoAPI in 'Entity Models\API\APIEntities\uProdutoAPI.pas',
  uCondicaoPagamentoAPI in 'Entity Models\API\APIEntities\uCondicaoPagamentoAPI.pas',
  uGrupoProdutoAPI in 'Entity Models\API\APIEntities\uGrupoProdutoAPI.pas',
  uRegiaoClienteAPI in 'Entity Models\API\APIEntities\uRegiaoClienteAPI.pas',
  uSubgrupoProdutoAPI in 'Entity Models\API\APIEntities\uSubgrupoProdutoAPI.pas',
  uEntityCliente in 'Entity Models\ERP\ERPEntities\uEntityCliente.pas',
  uEntityProduto in 'Entity Models\ERP\ERPEntities\uEntityProduto.pas',
  uEntityAcabamento in 'Entity Models\ERP\ERPEntities\uEntityAcabamento.pas',
  uEntityCenarioFaturamento in 'Entity Models\ERP\ERPEntities\uEntityCenarioFaturamento.pas',
  uEntityCondicaoPagamento in 'Entity Models\ERP\ERPEntities\uEntityCondicaoPagamento.pas',
  uEntityCor in 'Entity Models\ERP\ERPEntities\uEntityCor.pas',
  uEntityFornecedor in 'Entity Models\ERP\ERPEntities\uEntityFornecedor.pas',
  uEntityGrupoCliente in 'Entity Models\ERP\ERPEntities\uEntityGrupoCliente.pas',
  uEntityGrupoProduto in 'Entity Models\ERP\ERPEntities\uEntityGrupoProduto.pas',
  uEntityPedidoVenda in 'Entity Models\ERP\ERPEntities\uEntityPedidoVenda.pas',
  uEntityRegiaoCliente in 'Entity Models\ERP\ERPEntities\uEntityRegiaoCliente.pas',
  uEntitySubgrupoProduto in 'Entity Models\ERP\ERPEntities\uEntitySubgrupoProduto.pas',
  uEntitySupervisor in 'Entity Models\ERP\ERPEntities\uEntitySupervisor.pas',
  uEntityTipoPagamento in 'Entity Models\ERP\ERPEntities\uEntityTipoPagamento.pas',
  uEntityTransportador in 'Entity Models\ERP\ERPEntities\uEntityTransportador.pas',
  uEntityVariacaoProduto in 'Entity Models\ERP\ERPEntities\uEntityVariacaoProduto.pas',
  uEntityVendedor in 'Entity Models\ERP\ERPEntities\uEntityVendedor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(Tmodulo, modulo);
  Application.Run;
end.

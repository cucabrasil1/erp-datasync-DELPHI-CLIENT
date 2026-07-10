program cucabrasil_proloja_datasync;



uses
  Vcl.Forms,
  frmPrincipal in 'frmPrincipal.pas' {Form2},
  uThreadCuca in 'C:\Fontes\Comuns\Models\uThreadCuca.pas',
  uMRestIntegracao in 'C:\Fontes\Comuns\Models\uMRestIntegracao.pas',
  ufuncoes in 'C:\Fontes\Comuns\ufuncoes.pas',
  dmModulo in 'Local Files\dmModulo.pas' {modulo: TDataModule},
  uEntityBase in 'Entity Models\uEntityBase.pas',
  uEntityFactory in 'Entity Models\uEntityFactory.pas',
  uEntityCliente in 'Entity Models\uEntityCliente.pas',
  uEntityProduto in 'Entity Models\uEntityProduto.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(Tmodulo, modulo);
  Application.Run;
end.

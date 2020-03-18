program DrTrack;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.dialogs,
  system.sysutils,
  uPrincipal in 'Units\uPrincipal.pas' {fPrincipal},
  uNovaViagem in 'Units\uNovaViagem.pas' {fNovaViagem},
  uAcelerometroDAO in 'Units\uAcelerometroDAO.pas',
  UClasses in 'Units\UClasses.pas',
  uLocalizacaoDAO in 'Units\uLocalizacaoDAO.pas',
  uUsuarioDAO in 'Units\uUsuarioDAO.pas',
  uViagemDAO in 'Units\uViagemDAO.pas',
  uLogin in 'Units\uLogin.pas' {FLogin},
  uConfiguracao in 'Units\uConfiguracao.pas' {FConfiguracao},
  uFinalizarViagem in 'Units\uFinalizarViagem.pas' {fFinalizarViagem},
  uNovoUsuario in 'Units\uNovoUsuario.pas' {FNovoUsuario},
  uMinhasViagens in 'Units\uMinhasViagens.pas' {fMinhasViagens},
  uConexao in 'Units\uConexao.pas';

{$R *.res}

begin
  Application.Initialize;
  conexao := TConexao.Create;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TFLogin, FLogin);
  Application.Run;
end.

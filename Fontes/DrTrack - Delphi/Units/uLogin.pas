unit uLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, uConexao, uPrincipal, uclasses;

type
  TFLogin = class(TForm)
    pnlFundo: TPanel;
    rctFundo: TRectangle;
    pnlMeio: TPanel;
    rctMeio: TRectangle;
    lblUsuario: TLabel;
    lblSenha: TLabel;
    edtUsuario: TEdit;
    edtSenha: TEdit;
    btnAcessar: TCornerButton;
    Panel1: TPanel;
    rctTopo: TRectangle;
    Image1: TImage;
    Label1: TLabel;
    Rectangle1: TRectangle;
    procedure btnAcessarClick(Sender: TObject);
    procedure edtSenhaKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure edtUsuarioKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure Label1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fPrincipal : TFPrincipal;
  public
    { Public declarations }
  end;

var
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses uNovoUsuario;
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TFLogin.btnAcessarClick(Sender: TObject);
begin
  Conexao.acaoUsuario := auNenhum;
  try
    conexao.LogarUsuario(edtUsuario.Text, edtSenha.Text);
  except on E: Exception do
    ShowMessage(e.Message);
  end;

  if conexao.UsuarioConectado.getId <> 0 then
  begin
    fPrincipal := TFPrincipal.Create(self);
    fPrincipal.Show;
  end;
end;

procedure TFLogin.edtSenhaKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkReturn then
    btnAcessarClick(sender);
end;

procedure TFLogin.edtUsuarioKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkReturn then
    edtSenha.SetFocus;
end;

procedure TFLogin.FormCreate(Sender: TObject);
begin
  Label1.BringToFront;
end;

procedure TFLogin.Label1Click(Sender: TObject);
var
  fnovoUsuario : TFNovoUsuario;
begin
  fnovoUsuario := TFNovoUsuario.Create(self);
  fnovoUsuario.Show;
end;

end.

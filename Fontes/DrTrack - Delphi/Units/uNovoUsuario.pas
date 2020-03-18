unit uNovoUsuario;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, uConexao, uPrincipal, uclasses,
  uUsuarioDAO;

type
  TFNovoUsuario = class(TForm)
    pnlFundo: TPanel;
    rctFundo: TRectangle;
    pnlMeio: TPanel;
    rctMeio: TRectangle;
    lblUsuario: TLabel;
    lblSenha: TLabel;
    edtUsuario: TEdit;
    edtSenha: TEdit;
    edtConfirmacaoSenha: TEdit;
    Panel1: TPanel;
    rctTopo: TRectangle;
    Image1: TImage;
    lblErro: TLabel;
    procedure edtSenhaKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure edtUsuarioKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCadastrarClick(Sender: TObject);
    procedure edtConfirmacaoSenhaKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
  private
    { Private declarations }
    fPrincipal : TFPrincipal;
    funUsuario : TUsuarioDAO;
    function dadosValidos: boolean;
  public
    { Public declarations }
  end;

var
  FLogin: TFNovoUsuario;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TFNovoUsuario.btnCadastrarClick(Sender: TObject);
var
  usuario : TUsuario;
  resultado : String;
begin
  if dadosValidos then
  begin
    resultado := '';
    usuario := TUsuario.Create;
    try
      usuario.setNome(edtUsuario.Text);
      usuario.setSenha(edtSenha.Text);
      resultado := funUsuario.GravarDadosUsuario(usuario);

      if resultado = '' then
      begin
        ShowMessage('Usuário Cadastrado');
        close;
      end
      else
        ShowMessage(resultado);
    finally
      usuario.Free;
    end;

  end;
end;

function TFNovoUsuario.dadosValidos: boolean;
begin
  lblErro.text := '';
  result := true;

  if funUsuario.ExisteUsuario(edtUsuario.Text) then
  begin
    result := false;
    lblErro.text := 'Nome de usuário já cadastrado!';
  end
  else
  begin
    if edtSenha.Text <> edtConfirmacaoSenha.Text then
    begin
      result := false;
      lblErro.text := 'Senha não confere com a confirmação!';
    end
    else
    begin
      if edtSenha.Text = '' then
      begin
        result := false;
        lblErro.text := 'Senha não pode estar vazia!';
      end;
    end;

  end;
end;

procedure TFNovoUsuario.edtConfirmacaoSenhaKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkReturn then
    btnCadastrarClick(sender);
end;

procedure TFNovoUsuario.edtSenhaKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkReturn then
    edtConfirmacaoSenha.SetFocus;
end;

procedure TFNovoUsuario.edtUsuarioKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkReturn then
    edtSenha.SetFocus;
end;

procedure TFNovoUsuario.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  funUsuario.Free;
end;

procedure TFNovoUsuario.FormCreate(Sender: TObject);
begin
  funUsuario := TUsuarioDAO.create;
end;

end.

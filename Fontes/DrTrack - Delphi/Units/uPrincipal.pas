unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Maps,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Gestures,
  FMX.ScrollBox, FMX.Memo, Generics.Collections, uClasses, uConexao;

type
  TfPrincipal = class(TForm)
    pnlFundo: TPanel;
    rctFundo: TRectangle;
    btnNovaViagem: TCornerButton;
    imgBtnMenu: TImage;
    PnlMenu: TPanel;
    Rectangle1: TRectangle;
    BtnPrincipal: TImage;
    Label1: TLabel;
    Line1: TLine;
    TimerAnimMenu: TTimer;
    btnImgConfig: TImage;
    btnImgSair: TImage;
    lblNomeTela: TLabel;
    lblNomeCondutor: TLabel;
    imgNotaGeral: TImage;
    imgVelocidade: TImage;
    imgCurva: TImage;
    ImgAceleracao: TImage;
    lblNotaGeral: TLabel;
    lblNota: TLabel;
    lblCurva: TLabel;
    lblAceleracao: TLabel;
    Line2: TLine;
    lblVelocidade: TLabel;
    lblNotaVelocidade: TLabel;
    lblNotaCurva: TLabel;
    lblNotaAceleracao: TLabel;
    Label2: TLabel;
    BtnImgMinhasViagens: TImage;
    procedure btnNovaViagemClick(Sender: TObject);
    procedure BtnPrincipalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerAnimMenuTimer(Sender: TObject);
    procedure imgBtnMenuClick(Sender: TObject);
    procedure rctFundoClick(Sender: TObject);
    procedure lblNotaGeralClick(Sender: TObject);
    procedure imgNotaGeralClick(Sender: TObject);
    procedure btnImgSairClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnImgConfigClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BtnImgMinhasViagensClick(Sender: TObject);
  private
    { Private declarations }
    bMostrarMenu : boolean;

    procedure marcarBotaoMenu(botao : TImage);
    procedure AlterarOpacidadeFundo(opacidade : double);
    procedure carDCondutorTela(condutor : TUsuario);
    function retornarCorPelaNota(valor : Integer) : cardinal;
    function retornarIndiceImagemPelaNota(valor : Integer) : Integer;
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation
  uses uNovaViagem, uConfiguracao, uLogin, uMinhasViagens, System.Permissions,
  Androidapi.JNI.Os, Androidapi.JNI.JavaTypes, Androidapi.Helpers;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfPrincipal.AlterarOpacidadeFundo(opacidade: double);
begin
  imgNotaGeral.Opacity := opacidade;
  imgVelocidade.Opacity := opacidade;
  imgCurva.Opacity := opacidade;
  ImgAceleracao.Opacity := opacidade;
  lblNomeCondutor.Opacity := opacidade;
  lblNotaGeral.Opacity := opacidade;
  lblNota.Opacity := opacidade;
  lblCurva.Opacity := opacidade;
  lblAceleracao.Opacity := opacidade;
  lblVelocidade.Opacity := opacidade;
  lblNotaVelocidade.Opacity := opacidade;
  lblNotaCurva.Opacity := opacidade;
  lblNotaAceleracao.Opacity := opacidade;
  lblNomeCondutor.Opacity := opacidade;
  lblNomeTela.Opacity := opacidade;
end;

procedure TfPrincipal.btnImgConfigClick(Sender: TObject);
var
  fConfiguracao : TFConfiguracao;
begin
  try
    fConfiguracao := TFConfiguracao.Create(self);
    fConfiguracao.Show;
  except on E: Exception do
    showmessage(e.Message);
  end;
end;

procedure TfPrincipal.BtnImgMinhasViagensClick(Sender: TObject);
var
  fMinhasViagens : TfMinhasViagens;
begin
  fMinhasViagens := TfMinhasViagens.Create(self);
  fMinhasViagens.Show;
end;

procedure TfPrincipal.btnImgSairClick(Sender: TObject);
begin
  Conexao.acaoUsuario := auLogout;
  close;
end;

procedure TfPrincipal.btnNovaViagemClick(Sender: TObject);

begin
  PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
  procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
  var
    fNovaViagem : TFNovaViagem;
  begin
    if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
    begin
      try
        fNovaViagem := TfNovaViagem.Create(self);
        fNovaViagem.Show;
      except on E: Exception do
        showmessage(e.Message);
      end;
    end
    else
    begin
      ShowMessage('Location permission not granted');
    end;
  end)

end;

procedure TfPrincipal.FormActivate(Sender: TObject);
begin
  if Conexao.acaoUsuario = auLogout  then
    close
  else
  begin
    carDCondutorTela(Conexao.UsuarioConectado);
  end;
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
begin
  PnlMenu.Align := TAlignLayout.Left;
  PnlMenu.visible := false;
  PnlMenu.Position.x := PnlMenu.Width *-1;
  rctFundo.Width := pnlFundo.Width;
  rctFundo.Height := pnlFundo.Height;
  bMostrarMenu := false;
  rctFundo.Fill.Color := TAlphaColorRec.White;
  rctFundo.position.x := 0;
  rctFundo.position.y := 0;
  PnlMenu.BringToFront;
  carDCondutorTela(Conexao.UsuarioConectado);
//  marcarBotaoMenu(BtnPrincipal);
end;

procedure TfPrincipal.FormKeyUp(Sender: TObject; var Key: Word;  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkHardwareBack then
  begin
    key := 0;
    if Owner = FLogin then
      Application.Terminate
    else
      close;
  end;
end;

procedure TfPrincipal.FormShow(Sender: TObject);
begin
  if Conexao.acaoUsuario = auLogout  then
    close;
end;

procedure TfPrincipal.BtnPrincipalClick(Sender: TObject);
begin
  bMostrarMenu := false;
  TimerAnimMenu.Enabled := true;

  carDCondutorTela(Conexao.UsuarioConectado);
end;

procedure TfPrincipal.carDCondutorTela(condutor: TUsuario);
begin
  lblNomeCondutor.Text := condutor.getNome;
  lblNotaGeral.Text := intToStr(condutor.getvalNotaGeral);
  lblNotaVelocidade.Text := intToStr(condutor.getvalNotaVelocidade);
  lblNotaCurva.Text := intToStr(condutor.getvalNotaCurvas);
  lblNotaAceleracao.Text := intToStr(condutor.getvalNotaAceleracao);

  lblNotaGeral.TextSettings.FontColor := retornarCorPelaNota(condutor.getvalNotaGeral);
  lblNotaVelocidade.TextSettings.FontColor := retornarCorPelaNota(condutor.getvalNotaVelocidade);
  lblNotaCurva.TextSettings.FontColor := retornarCorPelaNota(condutor.getvalNotaCurvas);
  lblNotaAceleracao.TextSettings.FontColor := retornarCorPelaNota(condutor.getvalNotaAceleracao);

  imgNotaGeral.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(condutor.getvalNotaGeral)].Bitmap;
  imgVelocidade.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(condutor.getvalNotaVelocidade)].Bitmap;
  imgCurva.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(condutor.getvalNotaCurvas)].Bitmap;
  ImgAceleracao.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(condutor.getvalNotaAceleracao)].Bitmap;

end;

procedure TfPrincipal.imgBtnMenuClick(Sender: TObject);
begin
  bMostrarMenu := true;
  PnlMenu.visible := true;
  PnlMenu.Position.x := PnlMenu.Width *-1;
  TimerAnimMenu.Enabled := true;
  rctFundo.Fill.Color := TAlphaColorRec.Silver;
  AlterarOpacidadeFundo(0.5);
end;


procedure TfPrincipal.imgNotaGeralClick(Sender: TObject);
begin
  lblNotaGeralClick(sender);
end;

procedure TfPrincipal.lblNotaGeralClick(Sender: TObject);
begin
  showmessage('teste');
end;

procedure TfPrincipal.marcarBotaoMenu(botao: TImage);
var
  controle : Fmx.Controls.TControl;
  laco: Integer;
begin
  for laco := 0 to PnlMenu.Controls.Count -1 do
  begin
    controle := PnlMenu.Controls[laco];
    if controle is TImage then
    begin
      if controle = botao then
        botao.Bitmap := botao.MultiResBitmap.Items[0].Bitmap
      else
        botao.Bitmap := botao.MultiResBitmap.Items[1].Bitmap;
    end;
  end;

end;

procedure TfPrincipal.rctFundoClick(Sender: TObject);
begin
  bMostrarMenu := false;
  TimerAnimMenu.Enabled := true;
end;

function TfPrincipal.retornarCorPelaNota(valor: Integer): cardinal;
begin
  if valor <= 20 then
    result := TAlphaColorRec.red
  else
    if valor <= 40 then
      result := TAlphaColorRec.orangeRed
    else
      if valor <= 60 then
        result := TAlphaColorRec.Orange
      else
        if valor <= 80 then
          result := TAlphaColorRec.olive
        else
          result := TAlphaColorRec.Green;
end;

function TfPrincipal.retornarIndiceImagemPelaNota(valor: Integer): Integer;
begin
  result := 4;
  if valor <= 20 then
    result := 0
  else
    if valor <= 40 then
      result := 1
    else
      if valor <= 60 then
        result := 2
      else
        if valor <= 80 then
          result := 3;
end;

procedure TfPrincipal.TimerAnimMenuTimer(Sender: TObject);
begin
  if bMostrarMenu then
  begin
    PnlMenu.Position.x := PnlMenu.Position.x + 28;
    if pnlmenu.Position.x = 0 then
    begin
      TimerAnimMenu.Enabled := false;
      btnNovaViagem.Enabled := false;
    end;
  end
  else
  begin
    PnlMenu.Position.x := PnlMenu.Position.x - 28;
    if pnlmenu.Position.x = (PnlMenu.Width * -1) then
    begin
      TimerAnimMenu.Enabled := false;
      PnlMenu.Visible := false;
      rctFundo.Fill.Color := TAlphaColorRec.White;
      btnNovaViagem.Enabled := true;
      AlterarOpacidadeFundo(1);
    end;
  end;
end;

end.

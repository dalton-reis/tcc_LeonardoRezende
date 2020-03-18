unit uFinalizarViagem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Maps,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Gestures,
  FMX.ScrollBox, FMX.Memo, Generics.Collections, uClasses, uConexao, FMX.Layouts;

type
  TfFinalizarViagem = class(TForm)
    pnlFundo: TPanel;
    rctFundo: TRectangle;
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
    btnFechar: TButton;
    ScrollBar1: TVertScrollBox;
    mapView: TMapView;
    procedure btnNovaViagemClick(Sender: TObject);
    procedure BtnPrincipalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgBtnMenuClick(Sender: TObject);
    procedure rctFundoClick(Sender: TObject);
    procedure imgNotaGeralClick(Sender: TObject);
    procedure btnImgSairClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnImgConfigClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    { Private declarations }
    bMostrarMenu : boolean;

    procedure marcarBotaoMenu(botao : TImage);
    procedure AlterarOpacidadeFundo(opacidade : double);
    procedure carDCondutorTela(condutor : TUsuario);
    function retornarCorPelaNota(valor : Integer) : cardinal;
    function retornarIndiceImagemPelaNota(valor : Integer) : Integer;
    procedure pintarMapa;
  public
    { Public declarations }
    viagem : TViagem;
    localizacoes : TObjectList<TLocalizacao>;

  end;

var
  fPrincipal: TfFinalizarViagem;

implementation
  uses uNovaViagem, uConfiguracao, uLogin;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfFinalizarViagem.AlterarOpacidadeFundo(opacidade: double);
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

procedure TfFinalizarViagem.pintarMapa;
var
  coordenadas : array of TMapCoordinate;
  coordenadaMapa : TMapCoordinate;
  MyLine : TMapPolylineDescriptor;
  circulo : TMapCircleDescriptor;
  laco: Integer;
begin
  SetLength(coordenadas, localizacoes.Count);
  for laco := 0 to localizacoes.Count-1 do
  begin
    coordenadaMapa := TMapCoordinate.Create(localizacoes[laco].getValLatitude, localizacoes[laco].getValLongitude);
    coordenadas[laco] := coordenadaMapa;
  end;

  if localizacoes.Count > 0 then
    mapView.Location := coordenadaMapa;

  mapView.Zoom := 15;

  myline := TMapPolylineDescriptor.Create(TArray<FMX.Maps.TMapCoordinate>(coordenadas));
  myline.StrokeColor := TAlphaColorRec.Blue;
  myline.StrokeWidth := 20;
  mapView.AddPolyline(MyLine);
end;

procedure TfFinalizarViagem.btnFecharClick(Sender: TObject);
begin
  close;
end;

procedure TfFinalizarViagem.btnImgConfigClick(Sender: TObject);
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

procedure TfFinalizarViagem.btnImgSairClick(Sender: TObject);
begin
  Conexao.acaoUsuario := auLogout;
  close;
end;

procedure TfFinalizarViagem.btnNovaViagemClick(Sender: TObject);
var
  fNovaViagem : TFNovaViagem;
begin
  try
    fNovaViagem := TfNovaViagem.Create(self);
    fNovaViagem.Show;
  except on E: Exception do
    showmessage(e.Message);
  end;
end;

procedure TfFinalizarViagem.FormActivate(Sender: TObject);
begin
  if Conexao.acaoUsuario = auLogout  then
    close
  else
  begin
    carDCondutorTela(Conexao.UsuarioConectado);
    pintarMapa;
  end;
end;

procedure TfFinalizarViagem.FormCreate(Sender: TObject);
begin
  rctFundo.Width := pnlFundo.Width;
  rctFundo.Height := pnlFundo.Height;
  bMostrarMenu := false;
  rctFundo.Fill.Color := TAlphaColorRec.White;
  rctFundo.position.x := 0;
  rctFundo.position.y := 0;
//  carDCondutorTela(Conexao.UsuarioConectado);
//  marcarBotaoMenu(BtnPrincipal);
end;

procedure TfFinalizarViagem.FormKeyUp(Sender: TObject; var Key: Word;  var KeyChar: Char; Shift: TShiftState);
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

procedure TfFinalizarViagem.FormShow(Sender: TObject);
begin
  if Conexao.acaoUsuario = auLogout  then
    close;
end;

procedure TfFinalizarViagem.BtnPrincipalClick(Sender: TObject);
begin
  bMostrarMenu := false;

  carDCondutorTela(Conexao.UsuarioConectado);
end;

procedure TfFinalizarViagem.carDCondutorTela(condutor: TUsuario);
begin
  lblNomeCondutor.Text := condutor.getNome;

  lblNotaGeral.Text := intToStr(viagem.getValNotaGeral);
  lblNotaVelocidade.Text := intToStr(viagem.getvalNotaVelocidade);
  lblNotaCurva.Text := intToStr(viagem.getvalNotaCurvas);
  lblNotaAceleracao.Text := intToStr(viagem.getvalNotaAceleracao);

  lblNotaGeral.TextSettings.FontColor := retornarCorPelaNota(viagem.getvalNotaGeral);
  lblNotaVelocidade.TextSettings.FontColor := retornarCorPelaNota(viagem.getvalNotaVelocidade);
  lblNotaCurva.TextSettings.FontColor := retornarCorPelaNota(viagem.getvalNotaCurvas);
  lblNotaAceleracao.TextSettings.FontColor := retornarCorPelaNota(viagem.getvalNotaAceleracao);

  imgNotaGeral.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(viagem.getvalNotaGeral)].Bitmap;
  imgVelocidade.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(viagem.getvalNotaVelocidade)].Bitmap;
  imgCurva.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(viagem.getvalNotaCurvas)].Bitmap;
  ImgAceleracao.Bitmap := imgNotaGeral.MultiResBitmap.Items[retornarIndiceImagemPelaNota(viagem.getvalNotaAceleracao)].Bitmap;

end;

procedure TfFinalizarViagem.imgBtnMenuClick(Sender: TObject);
begin
  bMostrarMenu := true;
  rctFundo.Fill.Color := TAlphaColorRec.Silver;
  AlterarOpacidadeFundo(0.5);
end;


procedure TfFinalizarViagem.imgNotaGeralClick(Sender: TObject);
begin
//  lblNotaGeralClick(sender);
end;

procedure TfFinalizarViagem.marcarBotaoMenu(botao: TImage);
var
  controle : Fmx.Controls.TControl;
  laco: Integer;
begin

end;

procedure TfFinalizarViagem.rctFundoClick(Sender: TObject);
begin
  bMostrarMenu := false;
end;

function TfFinalizarViagem.retornarCorPelaNota(valor: Integer): cardinal;
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

function TfFinalizarViagem.retornarIndiceImagemPelaNota(valor: Integer): Integer;
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

end.

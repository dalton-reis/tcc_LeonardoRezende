unit uConfiguracao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Maps,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Gestures,
  FMX.ScrollBox, FMX.Memo, Generics.Collections, uClasses, uConexao,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FMX.Edit, FMX.EditBox, FMX.NumberBox, System.Sensors,
  System.Sensors.Components, system.Math ;

type
  TfConfiguracao = class(TForm)
    pnlFundo: TPanel;
    rctFundo: TRectangle;
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
    Line2: TLine;
    btnLimparDados: TButton;
    BtnImgMinhasViagens: TImage;
    edtVelocidadeMaxima: TNumberBox;
    btnGravarVelocidade: TButton;
    Label2: TLabel;
    senLocalizacao: TLocationSensor;
    procedure btnNovaViagemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerAnimMenuTimer(Sender: TObject);
    procedure imgBtnMenuClick(Sender: TObject);
    procedure rctFundoClick(Sender: TObject);
    procedure lblNotaGeralClick(Sender: TObject);
    procedure imgNotaGeralClick(Sender: TObject);
    procedure btnImgSairClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btnImgConfigClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BtnPrincipalClick(Sender: TObject);
    procedure btnLimparDadosClick(Sender: TObject);
    procedure BtnImgMinhasViagensClick(Sender: TObject);
    procedure btnGravarVelocidadeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    bMostrarMenu : boolean;

    procedure marcarBotaoMenu(botao : TImage);
    procedure AlterarOpacidadeFundo(opacidade : double);
    procedure carDCondutorTela(condutor : TUsuario);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfConfiguracao;

implementation
  uses uNovaViagem, uPrincipal, uMinhasViagens;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfConfiguracao.AlterarOpacidadeFundo(opacidade: double);
begin
  lblNomeCondutor.Opacity := opacidade;
  lblNomeTela.Opacity := opacidade;
end;

procedure TfConfiguracao.btnGravarVelocidadeClick(Sender: TObject);
var
  resultado : String;
begin
  if FloatToStr(senLocalizacao.Sensor.Latitude) = 'NAN' then
    ShowMessage('Não foi possível obter localização. Tente novamente!')
  else
  begin
//    showMessage(FloatToStr(senLocalizacao.Sensor.Latitude));
    resultado := Conexao.gravarVelocidadeMaxima(senLocalizacao.Sensor.Latitude, senLocalizacao.Sensor.Longitude, round(edtVelocidadeMaxima.Value));


    if resultado <> '' then
      showMessage(resultado)
    else
      showMessage('Sucesso');
  end;
end;

procedure TfConfiguracao.btnImgConfigClick(Sender: TObject);
begin
  bMostrarMenu := false;
  TimerAnimMenu.Enabled := true;

  carDCondutorTela(Conexao.UsuarioConectado);
end;

procedure TfConfiguracao.BtnImgMinhasViagensClick(Sender: TObject);
var
  fMinhasViagens : TfMinhasViagens;
begin
  fMinhasViagens := TfMinhasViagens.Create(self);
  fMinhasViagens.Show;
end;

procedure TfConfiguracao.btnImgSairClick(Sender: TObject);
begin
  Conexao.acaoUsuario := auLogout;
  close;
end;

procedure TfConfiguracao.btnLimparDadosClick(Sender: TObject);
var
  fSQL : TFDQuery;
  resultado : String;
begin
 resultado := '';
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;
    try
      fsql.SQL.Text := 'delete from Localizacao;';
      fsql.ExecSQL;
      fsql.SQL.Text := 'delete from ACELEROMETRO;';
      fsql.ExecSQL;
      fsql.SQL.Text := 'delete from VIAGEM;';
      fsql.ExecSQL;
      fsql.SQL.Text := 'update usuario set ValNotaGeral=0, ' +
                       ' valNotaAceleracao=0, ' +
                       ' valNotaFrenagem=0, ' +
                       ' ValNotaVelocidade=0, ' +
                       ' valNotaCurvas=0; ';
      fsql.ExecSQL;
      fsql.SQL.Text := 'update usuario set ValNotaGeral=0, ' +
                       ' QtdLocalizacao=(select count(*) from LOCALIZACAO), ' +
                       ' QtdAceleracaos=(Select count(*) from ACELEROMETRO), ' +
                       ' QtdViagem=(Select count(*) from VIAGEM);';
      fsql.ExecSQL;
    except on E: Exception do
      resultado := e.ClassName + '-'+e.Message;
    end;

  finally
    fSQL.free;
  end;

  if resultado = '' then
    showMessage('Banco de dados limpo com sucesso!')
  else
    showMessage(resultado);
end;

procedure TfConfiguracao.btnNovaViagemClick(Sender: TObject);
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

procedure TfConfiguracao.BtnPrincipalClick(Sender: TObject);
var
  fPrincipal : TFPrincipal;
begin
  try
    fPrincipal := TfPrincipal.Create(self);
    fPrincipal.Show;
  except on E: Exception do
  end;
end;

procedure TfConfiguracao.FormActivate(Sender: TObject);
begin
  if Conexao.acaoUsuario = auLogout  then
    close;
end;

procedure TfConfiguracao.FormCreate(Sender: TObject);
begin
  senLocalizacao.Active := true;
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
  btnLimparDados.Visible := uppercase(Conexao.UsuarioConectado.getNome) = 'LEONARDO';
//  marcarBotaoMenu(BtnPrincipal);
end;

procedure TfConfiguracao.FormDestroy(Sender: TObject);
begin
  senLocalizacao.Active := false;;
end;

procedure TfConfiguracao.FormKeyUp(Sender: TObject; var Key: Word;  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkHardwareBack then
  begin
    key := 0;
    Application.Terminate;
  end;
end;

procedure TfConfiguracao.carDCondutorTela(condutor: TUsuario);
begin
  lblNomeCondutor.Text := condutor.getNome;
end;

procedure TfConfiguracao.imgBtnMenuClick(Sender: TObject);
begin
  bMostrarMenu := true;
  PnlMenu.visible := true;
  PnlMenu.Position.x := PnlMenu.Width *-1;
  TimerAnimMenu.Enabled := true;
  rctFundo.Fill.Color := TAlphaColorRec.Silver;
  AlterarOpacidadeFundo(0.5);
end;


procedure TfConfiguracao.imgNotaGeralClick(Sender: TObject);
begin
  lblNotaGeralClick(sender);
end;

procedure TfConfiguracao.lblNotaGeralClick(Sender: TObject);
begin
  showmessage('teste');
end;

procedure TfConfiguracao.marcarBotaoMenu(botao: TImage);
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

procedure TfConfiguracao.rctFundoClick(Sender: TObject);
begin
  bMostrarMenu := false;
  TimerAnimMenu.Enabled := true;
end;

procedure TfConfiguracao.TimerAnimMenuTimer(Sender: TObject);
begin
  if bMostrarMenu then
  begin
    PnlMenu.Position.x := PnlMenu.Position.x + 28;
    if pnlmenu.Position.x = 0 then
    begin
      TimerAnimMenu.Enabled := false;
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
      AlterarOpacidadeFundo(1);
    end;
  end;
end;

end.

unit uMinhasViagens;

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
  FireDAC.Comp.Client, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, uViagemDAO, System.Sensors,
  uLocalizacaoDAO, uFinalizarViagem ;

type
  TfMinhasViagens = class(TForm)
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
    BtnImgMinhasViagens: TImage;
    ListView1: TListView;
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    { Private declarations }
    bMostrarMenu : boolean;

    lista : TObjectList<TViagem>;
    FunViagem : TViagemDAO;
    fFinalizarViagem : TfFinalizarViagem;
    cidade : String;

    procedure marcarBotaoMenu(botao : TImage);
    procedure AlterarOpacidadeFundo(opacidade : double);
    procedure carDCondutorTela(condutor : TUsuario);

    procedure CarListView;
  public
    { Public declarations }
  end;

var
  fPrincipal: TfMinhasViagens;

implementation
  uses uNovaViagem, uPrincipal, uConfiguracao;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfMinhasViagens.AlterarOpacidadeFundo(opacidade: double);
begin
  lblNomeCondutor.Opacity := opacidade;
  lblNomeTela.Opacity := opacidade;
end;

procedure TfMinhasViagens.btnImgConfigClick(Sender: TObject);
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


procedure TfMinhasViagens.BtnImgMinhasViagensClick(Sender: TObject);
begin
  bMostrarMenu := false;
  TimerAnimMenu.Enabled := true;

  carDCondutorTela(Conexao.UsuarioConectado);
end;

procedure TfMinhasViagens.btnImgSairClick(Sender: TObject);
begin
  Conexao.acaoUsuario := auLogout;
  close;
end;

procedure TfMinhasViagens.btnLimparDadosClick(Sender: TObject);
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

procedure TfMinhasViagens.btnNovaViagemClick(Sender: TObject);
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

procedure TfMinhasViagens.BtnPrincipalClick(Sender: TObject);
var
  fPrincipal : TFPrincipal;
begin
  try
    fPrincipal := TfPrincipal.Create(self);
    fPrincipal.Show;
  except on E: Exception do
  end;
end;

procedure TfMinhasViagens.FormActivate(Sender: TObject);
begin
  if Conexao.acaoUsuario = auLogout  then
    close;
end;

procedure TfMinhasViagens.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FunViagem.Free;
end;

procedure TfMinhasViagens.FormCreate(Sender: TObject);
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
  FunViagem := TViagemDAO.cria;
  carDCondutorTela(Conexao.UsuarioConectado);

//  marcarBotaoMenu(BtnPrincipal);
end;

procedure TfMinhasViagens.FormKeyUp(Sender: TObject; var Key: Word;  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkHardwareBack then
  begin
    key := 0;
    Application.Terminate;
  end;
end;

procedure TfMinhasViagens.carDCondutorTela(condutor: TUsuario);
var
  item : TListViewItem;
begin
  lblNomeCondutor.Text := condutor.getNome;

  lista := FunViagem.retornarListaViagens(condutor.getId);

  CarListView;
end;

procedure TfMinhasViagens.CarListView;
var
  laco: Integer;
  item : TListViewItem;
begin
  for laco := 0 to lista.Count-1 do
  begin
    item := ListView1.Items.Add;
    item.Data['index'] := laco;
    item.Text := ' Viagem '+FormatDateTime('dd/mm/yyyy', lista[laco].getDataIncio);
    if lista[laco].getDataIncio <> round(lista[laco].getDataIncio) then
      item.Detail := FormatDateTime('hh:mm:ss', lista[laco].getDataIncio);
  end;
end;

procedure TfMinhasViagens.imgBtnMenuClick(Sender: TObject);
begin
  bMostrarMenu := true;
  PnlMenu.visible := true;
  PnlMenu.Position.x := PnlMenu.Width *-1;
  TimerAnimMenu.Enabled := true;
  rctFundo.Fill.Color := TAlphaColorRec.Silver;
  AlterarOpacidadeFundo(0.5);
end;


procedure TfMinhasViagens.imgNotaGeralClick(Sender: TObject);
begin
  lblNotaGeralClick(sender);
end;

procedure TfMinhasViagens.lblNotaGeralClick(Sender: TObject);
begin
  showmessage('teste');
end;

procedure TfMinhasViagens.ListView1ItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  if fFinalizarViagem <> nil then
    fFinalizarViagem.Free;

  fFinalizarViagem := TfFinalizarViagem.Create(self);

  fFinalizarViagem.viagem := lista[aitem.Data['index'].AsInteger];
  fFinalizarViagem.localizacoes := lista[aitem.Data['index'].AsInteger].Localizacoes;
  fFinalizarViagem.Show;
end;

procedure TfMinhasViagens.marcarBotaoMenu(botao: TImage);
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


procedure TfMinhasViagens.rctFundoClick(Sender: TObject);
begin
  bMostrarMenu := false;
  TimerAnimMenu.Enabled := true;
end;

procedure TfMinhasViagens.TimerAnimMenuTimer(Sender: TObject);
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

unit uNovaViagem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  System.Sensors.Components, FMX.Maps, FMX.Controls.Presentation, FMX.StdCtrls,
  uClasses, Generics.Collections, uConexao, FMX.Ani, FMX.Objects, system.dateutils,
  FMX.Edit, FMX.EditBox, FMX.SpinBox, FMX.ScrollBox, FMX.Memo, System.UIConsts,
  Androidapi.JNI.Os, uViagemDao, Fmx.DialogService;

type
  TfNovaViagem = class(TForm)
    senLocalizacao: TLocationSensor;
    pnlFundo: TPanel;
    lblCurva: TLabel;
    Rectangle1: TRectangle;
    Splitter1: TSplitter;
    pnlMapa: TPanel;
    mapa: TMapView;
    Rectangle2: TRectangle;
    lblVelocidade: TLabel;
    senAcelerometro: TMotionSensor;
    Timer: TTimer;
    edtLog: TMemo;
    lblDesAceleracao: TLabel;
    lblAceleracao: TLabel;
    lblTipCurva: TLabel;
    Line1: TLine;
    lnlNomeTela: TLabel;
    btnFinalizar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure senLocalizacaoLocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
//    procedure Button1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblAceleracaoDblClick(Sender: TObject);
    procedure lblAceleracaoTap(Sender: TObject; const Point: TPointF);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btnFinalizarClick(Sender: TObject);
  private
    { Private declarations }
    viagem : TViagem;
    localizacoes : TObjectList<TLocalizacao>;
    aceleracoes : TObjectList<TAcelerometro>;
    contador : Integer;
    localizacao,  localizacaoOld, localizacaoExcluida: TLocalizacao;
    aceleracao, acelaracaoAnterior : TAcelerometro;
    powerManager : JPowerManager;
    wakeLock : JPowerManager_WakeLock;
    dataUltimaLocalizacao, dataUltimaVerificacao : TDateTime;
    circuloMapa : TMapCircle;
    fViagemDAO : TViagemDao;

    bPausado : boolean;
    procedure IniciarNovaViagem;
    procedure LocalizacaoChange(aLatitude, aLongitude: Double);
    function getPowerManager : JPowerMAnager;
    procedure FinalizarViagem;
    procedure AnalisarViagem;
  public
    { Public declarations }
  end;

var
  fNovaViagem: TfNovaViagem;

implementation
  uses Androidapi.JNI.GraphicsContentViewText,
     Androidapi.JNI.JavaTypes,
     Androidapi.Helpers,
     Androidapi.JNIBridge, uFinalizarViagem;


{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

{ TfNovaViagem }

//procedure TfNovaViagem.Button1Click(Sender: TObject);
//var
//  velocidadeMaxima : TVelocidade;
//begin
//  velocidadeMaxima := TVelocidade.create;
//  try
//    velocidadeMaxima.setvalLatitude(senLocalizacao.Sensor.Latitude);
//    velocidadeMaxima.setvalLongitude(senLocalizacao.Sensor.Longitude);
//    velocidadeMaxima.setValVelocidadeMaxima(edtVelocidadeMaxima.Value);
//  finally
//    velocidadeMaxima.Free;
//  end;
//end;

procedure TfNovaViagem.AnalisarViagem;
begin
  fViagemDAO.AnalisarViagem(viagem, aceleracoes, localizacoes);
end;

procedure TfNovaViagem.btnFinalizarClick(Sender: TObject);
begin
  FinalizarViagem;
end;

procedure TfNovaViagem.FinalizarViagem;
var
  resultado : String;
  fFinalizarViagem : TfFinalizarViagem;
begin
  viagem.setDataFim(now);
  AnalisarViagem;

  resultado := fViagemDAO.GravarDadosViagem(viagem, aceleracoes, localizacoes);

  if resultado <> '' then
  begin
    ShowMessage(resultado);
  end
  else
  begin
    fFinalizarViagem := TfFinalizarViagem.Create(self);
    fFinalizarViagem.viagem := viagem;
    fFinalizarViagem.localizacoes := localizacoes;
    fFinalizarViagem.Show;
    TAndroidHelper.Activity.getWindow.clearFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON);
    close;
  end;
end;

procedure TfNovaViagem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  wakeLock.release;
  fViagemDAO.free;
end;

procedure TfNovaViagem.FormCreate(Sender: TObject);
begin
  powerManager := getPowerManager;
  wakeLock := powerManager.newWakeLock(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON, StringToJString('DrTrack'));
  wakeLock.acquire;
  IniciarNovaViagem;
  contador := 0;
  edtLog.Visible := false;
  pnlFundo.Height := lblDesAceleracao.position.Y + lblDesAceleracao.Height + 5;
  fViagemDAO := TViagemDAo.Create;
end;

procedure TfNovaViagem.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkHardwareBack then
  begin
    key := 0;
    FinalizarViagem;
  end;

end;

function TfNovaViagem.getPowerManager: JPowerMAnager;
var
  Native : JObject;
begin
  Native:= TAndroidHelper.Context.getSystemService(TJContext.JavaClass.POWER_SERVICE);
  if not Assigned(Native) then
  begin
     raise Exception.Create('Could not locate Connectivity Service');
  end;
  Result:=TJPowerManager.Wrap((Native as ILocalObject).GetObjectID) ;
  if not Assigned(Result) then
  begin
     raise Exception.Create('Could not access Connectivity Manager');
  end;
end;

(******************************************************************************)
procedure TfNovaViagem.IniciarNovaViagem;
begin
  try
    TAndroidHelper.Activity.getWindow.addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON);
    viagem := TViagem.Create;
    viagem.setDataInicio(now);
  //  viagem.setUsuario(Conexao.UsuarioConectado);
    localizacoes := TObjectList<TLocalizacao>.create;
    aceleracoes := TObjectList<TAcelerometro>.create;
    bPausado := false;
    senLocalizacao.Active := true;
    Timer.Enabled := true;
    lblVelocidade.Text := 'Velocidade : ';
  except on E: Exception do
    ShowMessage(e.Message);
  end;
end;

procedure TfNovaViagem.lblAceleracaoDblClick(Sender: TObject);
begin
  edtLog.Visible := false;
  pnlFundo.Height := lblDesAceleracao.position.Y + lblDesAceleracao.Height + 5;

  if edtLog.Visible then
  begin
    edtLog.Visible := false;
    pnlFundo.Height := lblDesAceleracao.position.Y + lblDesAceleracao.Height + 5;
  end
  else
  begin
    edtLog.Visible := true;
    pnlFundo.Height := edtLog.position.Y + edtLog.Height + 5;
  end;

end;

procedure TfNovaViagem.lblAceleracaoTap(Sender: TObject; const Point: TPointF);
begin
  lblAceleracaoDblClick(sender);
end;

procedure TfNovaViagem.LocalizacaoChange(aLatitude, aLongitude: Double);
var
  indExcluiLocalizacao : boolean;

  procedure pintarMapa(localizacao1, localizacao2 : TLocalizacao);
  var
    coordenadas : array of TMapCoordinate;
    coordenadaMapa : TMapCoordinate;
    MyLine : TMapPolylineDescriptor;
    circulo : TMapCircleDescriptor;
  begin
    SetLength(coordenadas, 2);
    if localizacao1 <> nil then
    begin
      coordenadaMapa := TMapCoordinate.Create(localizacao1.getValLatitude, localizacao1.getValLongitude);
      coordenadas[0] := coordenadaMapa;
    end;

    if localizacao2 <> nil then
    begin
      coordenadaMapa := TMapCoordinate.Create(localizacao2.getValLatitude, localizacao2.getValLongitude);
      coordenadas[1] := coordenadaMapa;
    end;

    if localizacoes.Count > 0 then
      mapa.Location := coordenadaMapa;
    mapa.Zoom := 16;

    if localizacao1 <> nil then
    begin
      myline := TMapPolylineDescriptor.Create(TArray<FMX.Maps.TMapCoordinate>(coordenadas));
      myline.StrokeColor := TAlphaColorRec.Blue;
      myline.StrokeWidth := 20;
      mapa.AddPolyline(MyLine);
    end;

    if circuloMapa <> nil then
      circuloMapa.Remove;

    circulo := TMapCircleDescriptor.Create(coordenadaMapa, 5);
    circulo.StrokeWidth := 5;
    circulo.StrokeColor := TAlphaColorRec.Blue;
    circulo.FillColor := TAlphaColorRec.Aquamarine;
    circuloMapa := mapa.AddCircle(circulo);

    circulo := TMapCircleDescriptor.Create(coordenadaMapa, 2);
    circulo.StrokeWidth := 5;
    circulo.StrokeColor := TAlphaColorRec.red;
    circulo.FillColor := TAlphaColorRec.red;
    mapa.AddCircle(circulo);
  end;
begin
  try
    dataUltimaVerificacao := now;
    dataUltimaLocalizacao := now;
    indExcluiLocalizacao := false;
    if localizacao <> nil then
      localizacaoOld := localizacao;
    localizacao := TLocalizacao.Create;
    localizacao.setDataLocalizacao(now);
    localizacao.setValLatitude(aLatitude);
    localizacao.setValLongitude(aLongitude);
    localizacao.setViagem(viagem);

    if localizacaoOld <> nil then
    begin
  //    lblDistancia.Text := 'Distancia : '+formatFloat('###,###,##0.000', localizacao.calcularDistancia(localizacaoOld.getValLatitude, localizacaoOld.getValLongitude));
      if (localizacao.calcularDistancia(localizacaoOld.getValLatitude, localizacaoOld.getValLongitude) > 25)  then
      begin
        if localizacaoExcluida <> nil then
        begin
          if (localizacao.calcularDistancia(localizacaoExcluida.getValLatitude, localizacaoExcluida.getValLongitude) > 30) then
          begin
            indExcluiLocalizacao := true;
          end;
        end
        else
          indExcluiLocalizacao := true;

        if indExcluiLocalizacao then
        begin
          if localizacaoExcluida <> nil then
            localizacaoExcluida.Free;

          localizacaoExcluida := localizacao;
          localizacao := nil;
        end;
      end;
    end;


    if localizacao <> nil then
    begin
      try
        if senAcelerometro.Sensor.Speed <> 0 then
        begin
          localizacao.setValVelocidade(senAcelerometro.Sensor.Speed*3.6);
        end
        else
        begin
          localizacao.calcularVelocidadeDeslocamento(localizacaoOld);
        end;
      except on E: Exception do
        ShowMessage(e.Message);
      end;

      localizacoes.Add(localizacao);
      pintarMapa(localizacaoOld, Localizacao);
      inc(contador);
  //    lblTeste.Text := IntToStr(contador);
      if localizacao.getValVelocidade > 0 then
        lblvelocidade.text := 'Velocidade : '+FormatFloat('##0.00', localizacao.getValVelocidade)+' km/h'
      else
        lblvelocidade.text := 'Velocidade : ';
    end;
  except on E: Exception do
    ShowMessage(e.Message);
  end;
end;

procedure TfNovaViagem.senLocalizacaoLocationChanged(Sender: TObject;  const OldLocation, NewLocation: TLocationCoord2D);
begin
  LocalizacaoChange(NewLocation.Latitude, NewLocation.Longitude);
end;

procedure TfNovaViagem.TimerTimer(Sender: TObject);
begin
  timer.Enabled := false;
  if IncSecond(dataUltimaLocalizacao, 2) < now then
  begin
    if (senLocalizacao.Sensor <> nil)  then
    begin
      if (localizacao = nil) or
         (((localizacao.getValLatitude <> senLocalizacao.Sensor.Latitude) and
          (localizacao.getValLongitude <> senLocalizacao.Sensor.Longitude)) or
          (localizacao.getValVelocidade <> 0)) then
      begin
        if (senLocalizacao.Sensor.Latitude <> 0) and (senLocalizacao.Sensor.longitude <> 0) then
        begin
          LocalizacaoChange(senLocalizacao.Sensor.Latitude, senLocalizacao.Sensor.Longitude);
        end;
      end;
    end;
  end;

  if IncSecond(dataUltimaVerificacao, 2) < now then
  begin
    senLocalizacao.sensor.Stop;
    senLocalizacao.sensor.start;
    dataUltimaVerificacao := now;
  end;

  if not bPausado then
  begin
    acelaracaoAnterior := aceleracao;
    aceleracao := TAcelerometro.Create;
    aceleracoes.Add(aceleracao);
    aceleracao.setValEixoX(abs(senAcelerometro.Sensor.AccelerationX));
    aceleracao.setValEixoY(abs(senAcelerometro.Sensor.AccelerationY));
    aceleracao.setValEixoZ(abs(senAcelerometro.Sensor.AccelerationZ));
    if localizacao <> nil then
      aceleracao.setLocalizacao(localizacao);


      edtLog.Lines.Add('Resultante   : '+FormatFloat('###,###,##0.0000', aceleracao.getAceleracaoResultante));
//    edtLog.Lines.Add('Soma   : '+FormatFloat('###,###,##0.0000', aceleracao.getValEixoZ+aceleracao.getValEixoY+aceleracao.getValEixoX));
//    edtLog.Lines.Add('X   : '+FormatFloat('###,###,##0.0000', aceleracao.getValEixoX));
//    edtLog.Lines.Add('Y   : '+FormatFloat('###,###,##0.0000', aceleracao.getValEixoY));
//    edtLog.Lines.Add('Z   : '+FormatFloat('###,###,##0.0000', aceleracao.getValEixoZ));
    edtLog.GoToTextEnd;

    lblAceleracao.Text := aceleracao.getDescricaoTipoAceleracao(aceleracao.getAceleracao);
    lblAceleracao.FontColor := aceleracao.getCorAceleracao(aceleracao.getAceleracao);
    lblAceleracao.Repaint;

    lblTipCurva.Text := aceleracao.getDescricaoTipoAceleracao(aceleracao.getTipoCurva);
    lblTipCurva.FontColor := aceleracao.getCorAceleracao(aceleracao.getTipoCurva);
    lblTipCurva.Repaint;
  end;
  timer.Enabled := true;
end;

end.

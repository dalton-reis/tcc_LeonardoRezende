unit UClasses;

interface
uses System.SysUtils, System.UITypes, DateUtils, fmx.dialogs, math,
     Generics.Collections, System.UIConsts;

  type
    TTipoAcaoUSuario = (auNenhum, auLogout);
  type
    TUsuario = class
      private
        Id : Integer;
        Nome,
        Senha : String;
        valNotaGeral,
        valNotaAceleracao,
        valNotaFrenagem,
        valNotaVelocidade,
        valNotaCurvas,
        QtdViagem,
        QtdLocalizacao,
        QtdAceleracao : Integer;
      public
        function getId : Integer;
        function getNome : String;
        function getSenha : String;
        function getvalNotaGeral : integer;
        function getvalNotaAceleracao : integer;
        function getvalNotaFrenagem : integer;
        function getvalNotaVelocidade : integer;
        function getvalNotaCurvas : integer;
        function getQtdViagem : Integer;
        function getQtdLocalizacao : Integer;
        function getQtdAceleracao : Integer;
        procedure setId(aId : Integer);
        procedure setNome(aNome : String);
        procedure setSenha(aSenha : String);
        procedure setvalNotaGeral(aValNotaGeral : integer);
        procedure setvalNotaAceleracao(AValNotaAceleracao : integer);
        procedure setvalNotaFrenagem(aValNotaFrenagem : integer);
        procedure setvalNotaVelocidade(aValNotaVelocidade : integer);
        procedure setvalNotaCurvas(aValNotaCurvas : integer);
        procedure setQtdViagem(aQtdViagem : Integer);
        procedure setQtdLocalizacao(aQtdLocalizacao : Integer);
        procedure setQtdAceleracao(aQtdAceleracao : Integer);
    end;
    TLocalizacao = class;
    TViagem = class
      private
        Id : Integer;
        dataInicio,
        dataFim : TdateTime;
        valNotaGeral,
        valNotaAceleracao,
        valNotaFrenagem,
        valNotaVelocidade,
        valNotaCurvas : integer;
        usuario : TUsuario;
      public
        localizacoes : TObjectList<TLocalizacao>;
        function getId : Integer;
        function getDataIncio : TDateTime;
        function getDataFim : TDateTime;
        function getValNotaGeral : integer;
        function getValNotaAceleracao : integer;
        function getValNotaFrenagem : integer;
        function getValNotaVelocidade : integer;
        function getvalNotaCurvas : integer;
        function getUsuario : TUsuario;
        procedure setId(aId : Integer);
        procedure setDataInicio(aDataInicio : TDateTime);
        procedure setDataFim(aDataFim : TDateTime);
        procedure setValNotaGeral(aValNotaGeral : integer);
        procedure setValNotaAceleracao(aValNotaAceleracao : integer);
        procedure setValNotaFrenagem(aValNotaFrenagem : integer);
        procedure setValNotaVelocidade(aValNotaVelocidade : integer);
        procedure setValNotaCurvas(aValNotaCurvas : integer);
        procedure setUsuario(aUsuario : TUsuario);
        destructor Destroy;override;
    end;

    TLocalizacao = class
      private
        id : Integer;
        DataLocalizacao : TDateTime;
        valLatitude,
        valLongitude,
        valVelocidade : Double;
        viagem : TViagem;
      public
        function getId : Integer;
        function getDataLocalizacao : TDateTime;
        function getValLatitude : double;
        function getValLongitude : double;
        function getValVelocidade : double;
        function getViagem : TViagem;
        procedure setId(aID : Integer);
        procedure setDataLocalizacao(aDataLocalizacao : TdateTime);
        procedure setValLatitude(aValLatitude : Double);
        procedure setValLongitude(aValLongitude : double);
        procedure setValVelocidade(aValVelocidade : Double);
        procedure setViagem(aViagem : TViagem);
        function calcularDistancia(latitude, longitude : double):double;
        function GetDiferencaSegundos(localizacaoOld  : TLocalizacao): double;
        procedure calcularVelocidadeDeslocamento(localizacaoOld : TLocalizacao);
        procedure calcularVelocidadeMediaDeslocamento(localizacoes : TObjectList<TLocalizacao>);
        Constructor Create;
    end;

    TTipoAceleracao = (taNormal, taForte, taMuitoForte, taExtrema);
    TAcelerometro = class
      private
        id : integer;
        valEixoX : double;
        valEixoY : double;
        valEixoZ : double;
        localizacao : TLocalizacao;
        viagem : TViagem;
      public
        function getId : Integer;
        function getValEixoX : double;
        function getValEixoY : double;
        function getValEixoZ : double;
        function getLocalizacao : TLocalizacao;
        function getViagem : TViagem;
        procedure setId(aId : Integer);
        procedure setValEixoX(aValEixoX : double);
        procedure setValEixoY(aValEixoY : double);
        procedure setValEixoZ(aValEixoZ : double);
        procedure setLocalizacao(aLocalizacao : TLocalizacao);
        procedure setViagem(aViagem : TViagem);
        function getAceleracao: TTipoAceleracao;
        function getAceleracaoResultante:double;
        function getCorAceleracao(aTipoAceleracao : TTipoAceleracao): Cardinal;
        function getTipoCurva : TTipoAceleracao;
        function getDescricaoTipoAceleracao(aTipoAceleracao : TTipoAceleracao) : String;
    end;

    TConfiguracoes = class
      private
        UsuarioConectado : TUsuario;
        manterConectado : boolean;
      public
        function getUsuarioConectado : TUsuario;
        function getManterConectado : boolean;
        procedure setUsuarioConectado(aUsuario : TUsuario);
        procedure setManterConectado(aManterConectado : boolean);
    end;

    TVelocidade = class
      private
        id : Integer;
        valLatitude,
        valLongitude,
        valVelocidadeMaxima : double;
      public
        procedure setValLatitude(valLatitude : double);
        procedure setValLongitude(valLongitude : double);
        procedure setValVelocidadeMaxima(valVelocidadeMaxima : double);
        procedure setID(Id : Integer);
        function getValLatitude : double;
        function getValLongitude : double;
        function getVelocidadeMaxima : double;
        function getID : Integer;
    end;

    procedure filtroMediaMascara3(lista : TList<double>);
    function mediaValoresLista(lista : TList<double>) : double;


implementation

function mediaValoresLista(lista : TList<double>):double;
var
  laco: Integer;
begin
  result := 0;
  for laco := 0 to lista.Count-1 do
  begin
    result := result + lista[laco];
  end;
  result := result / lista.Count;
end;

procedure filtroMediaMascara3(lista : TList<double>);
var
  numeroAtual, numeroAnterior, numeroPosterior : Double;
  laco: Integer;
begin
  if lista.Count > 1 then
  begin
    numeroAtual := lista[0];
    numeroPosterior := lista[1];
    lista[0]:= (numeroAtual + numeroPosterior)/2;

    for laco := 1 to lista.Count -2 do
    begin
      numeroAtual := lista[laco];
      numeroAnterior := Lista[laco-1];
      numeroPosterior := lista[laco+1];
      lista[laco] := (numeroAtual + numeroAnterior + numeroPosterior)/3;
    end;
    numeroAtual := lista[lista.Count-1];
    numeroAnterior := Lista[lista.Count-2];
    lista[laco] := (numeroAtual + numeroAnterior)/2;
  end;
end;

{ TAcelerometro }

function TAcelerometro.getAceleracaoResultante: double;
  function pitagoras(cateto1, cateto2 : double):double;
  begin
    result := Sqrt(power(cateto1, 2)+power(cateto2, 2));
  end;
begin
  result := pitagoras(getValEixoY, getvalEixoZ);
end;

function TAcelerometro.getCorAceleracao(aTipoAceleracao : TTipoAceleracao): Cardinal;
begin
  result := 0;
  case aTipoAceleracao of
      taNormal     : result := claGreen;
      taForte      : result := claOlive;
      taMuitoForte : result := claOrange;
      taExtrema    : result := claRed;
    end;
end;

function TAcelerometro.getDescricaoTipoAceleracao(aTipoAceleracao: TTipoAceleracao): String;
begin
  result := '';
  case aTipoAceleracao of
    taNormal: result := 'Normal';
    taForte: result := 'Forte';
    taMuitoForte: result := 'Muito Forte';
    taExtrema: result := 'EXTREMA';
  end;
end;

function TAcelerometro.getAceleracao: TTipoAceleracao;
const
  ACELERACAO_NORMAL = 0.05;
  ACELERACAO_FORTE = 0.11;
  ACELERACAO_MUITO_FORTE = 0.17;
  VALOR_EM_REPOUSO = 1.00501; // valor com a gravidade
Var
  valSomaEixos, percentualVariacao : Double;

  function retornarMediaAceleracaoResultante:double;
  begin
    result := getAceleracaoResultante
  end;
begin
  valSomaEixos := retornarMediaAceleracaoResultante;

  result := taExtrema;

  percentualVariacao := abs(1-((valSomaEixos / VALOR_EM_REPOUSO)));
    if percentualVariacao <= ACELERACAO_NORMAL then
      result := taNormal
    else
      if percentualVariacao <= ACELERACAO_FORTE then
        result := taForte
      else
        if percentualVariacao <= ACELERACAO_MUITO_FORTE then
          result := taMuitoForte;
end;

function TAcelerometro.getId: Integer;
begin
  result := self.id;
end;

function TAcelerometro.getLocalizacao: TLocalizacao;
begin
  result := self.localizacao;
end;

function TAcelerometro.getTipoCurva: TTipoAceleracao;
Const
  CURVA_NORMAL = 0.4;
  CURVA_FORTE = 0.7;
  CURVA_MUITO_FORTE = 1;
begin
  result := taExtrema;
  if Abs(getValEixoX) <= CURVA_NORMAL then
    result := taNormal
  else
    if Abs(getValEixoX) <= CURVA_FORTE then
      result := taForte
    else
      if Abs(getValEixoX) <= CURVA_MUITO_FORTE then
    result := taMuitoForte;
end;

function TAcelerometro.getValEixoX: double;
begin
  result := self.valEixoX;
end;

function TAcelerometro.getValEixoY: double;
begin
  result := self.valEixoY;
end;

function TAcelerometro.getValEixoZ: double;
begin
  result := self.valEixoZ;
end;

function TAcelerometro.getViagem: TViagem;
begin
  result := self.viagem;
end;

procedure TAcelerometro.setId(aId: Integer);
begin
  self.id := aId;
end;

procedure TAcelerometro.setLocalizacao(aLocalizacao: TLocalizacao);
begin
  self.localizacao := aLocalizacao;
end;

procedure TAcelerometro.setValEixoX(aValEixoX: double);
begin
  self.valEixoX := aValEixoX;
end;

procedure TAcelerometro.setValEixoY(aValEixoY: double);
begin
  self.valEixoY := aValEixoY;
end;

procedure TAcelerometro.setValEixoZ(aValEixoZ: double);
begin
  self.valEixoZ := aValEixoZ;
end;

procedure TAcelerometro.setViagem(aViagem: TViagem);
begin
  self.viagem := aViagem;
end;

{ TLocalizacao }

function TLocalizacao.getValLatitude: double;
begin
  result := self.valLatitude;
end;

function TLocalizacao.calcularDistancia(latitude, longitude: double): double;
const
  r:Double = 6371.0;//Raio da terra
var
  Val, Lng, Lat,
  lat1, lat2, lng1, lng2: Double;


  function sgn(a: real): real;
  begin
    if a < 0 then
      result := -1
    else
      result := 1;
  end;

  function atan2(y, x: real): real;
  begin
    if x > 0  then
      result := arctan(y/x)
    else
      if x < 0  then
        result := arctan(y/x) + pi
      else
        result := pi/2 * sgn(y);
  end;
begin
  lat1 := latitude*pi/180;
  lat2 := getValLatitude*pi/180;//;
  lng1 := longitude*pi/180;//;
  lng2 := getValLongitude*pi/180;//;

  Lat := lat1 - lat2;
  Lng := lng1 - lng2;

  Val := sin(Lat / 2) * sin(Lat / 2) + cos(lat2) * cos(lat1) * sin(Lng / 2) * sin(Lng / 2);
  Val := 2 * ATan2(sqrt(Val), sqrt(1 - Val));

  Result:= (r * Val)*1000;
end;

procedure TLocalizacao.calcularVelocidadeDeslocamento(localizacaoOld: TLocalizacao);
var
  diferenca : double;
//  horas, minutos, segundos : Integer;
begin
  if localizacaoOld <> nil then
  begin
    diferenca := secondSpan(localizacaoOld.getDataLocalizacao, getDataLocalizacao);
//    horas := StrToIntDef(FormatDateTime('h', diferenca), 0);
//    Minutos := StrToIntDef(FormatDateTime('m', diferenca), 0);
//    segundos := StrToIntDef(FormatDateTime('s', diferenca), 0);

    setValVelocidade((calcularDistancia(localizacaoOld.getValLatitude, localizacaoOld.getValLongitude)/diferenca)*3.6);
  end;
end;

procedure TLocalizacao.calcularVelocidadeMediaDeslocamento(localizacoes: TObjectList<TLocalizacao>);
var
   laco : Integer;
   soma : double;
   localizacao, localizacaoInicial : TLocalizacao;
begin
  soma := 0;
  localizacao := nil;
  if localizacoes.Count > 2 then
  begin
    localizacaoInicial := localizacoes[localizacoes.Count-3];
    for laco := localizacoes.Count-3 to localizacoes.Count-1 do
    begin
      if localizacao <> nil then
        soma := soma + localizacoes[laco].calcularDistancia(localizacao.getValLatitude, localizacao.getValLongitude);
      localizacao := localizacoes[laco];
    end;
    setValVelocidade(3.6*soma/localizacao.GetDiferencaSegundos(localizacaoInicial));
  end;
end;

constructor TLocalizacao.Create;
begin
  inherited;
  setValVelocidade(0);
  setValLatitude(0);
  setValLongitude(0);
end;

function TLocalizacao.getDataLocalizacao: TDateTime;
begin
  result := self.DataLocalizacao;
end;

function TLocalizacao.GetDiferencaSegundos(localizacaoOld: TLocalizacao): double;
begin
  result := secondSpan(localizacaoOld.getDataLocalizacao, getDataLocalizacao);
end;

function TLocalizacao.getId: Integer;
begin
  result := self.id;
end;

function TLocalizacao.getValLongitude: double;
begin
  result := self.valLongitude;
end;

function TLocalizacao.getValVelocidade: double;
begin
  result := valVelocidade;
end;

function TLocalizacao.getViagem: TViagem;
begin
  result := self.viagem;
end;

procedure TLocalizacao.setDataLocalizacao(aDataLocalizacao: TdateTime);
begin
  Self.DataLocalizacao := aDataLocalizacao;
end;

procedure TLocalizacao.setId(aID: Integer);
begin
  self.id := aID;
end;

procedure TLocalizacao.setValLatitude(aValLatitude: Double);
begin
  self.valLatitude := aValLatitude;
end;

procedure TLocalizacao.setValLongitude(aValLongitude: double);
begin
  self.valLongitude := aValLongitude;
end;

procedure TLocalizacao.setValVelocidade(aValVelocidade: Double);
begin
  self.valVelocidade := aValVelocidade;
end;

procedure TLocalizacao.setViagem(aViagem: TViagem);
begin
  self.viagem := aViagem;
end;

{ TViagem }

destructor TViagem.Destroy;
begin
  if localizacoes <> nil then
    localizacoes.Free;
  inherited;
end;

function TViagem.getDataFim: TDateTime;
begin
  result := self.DataFim;
end;

function TViagem.getDataIncio: TDateTime;
begin
  result := self.dataInicio;
end;

function TViagem.getId: Integer;
begin
  result := self.Id;
end;

function TViagem.getUsuario: TUsuario;
begin
  result := self.usuario;
end;

function TViagem.getValNotaAceleracao: integer;
begin
  result := self.ValNotaAceleracao;
end;

function TViagem.getvalNotaCurvas: integer;
begin
  result := self.valNotaCurvas;
end;

function TViagem.getValNotaFrenagem: integer;
begin
  result := self.ValNotaFrenagem;
end;

function TViagem.getValNotaGeral: integer;
begin
  result := self.ValNotaGeral;
end;

function TViagem.getValNotaVelocidade: integer;
begin
  result := self.valNotaVelocidade;
end;

procedure TViagem.setDataFim(aDataFim: TDateTime);
begin
  self.dataFim := aDataFim;
end;

procedure TViagem.setDataInicio(aDataInicio: TDateTime);
begin
  self.dataInicio := aDataInicio;
end;

procedure TViagem.setId(aId: Integer);
begin
  self.Id := aId;
end;

procedure TViagem.setUsuario(aUsuario: TUsuario);
begin
  self.usuario := aUsuario;
end;

procedure TViagem.setValNotaAceleracao(aValNotaAceleracao: integer);
begin
  self.valNotaAceleracao := aValNotaAceleracao;
end;

procedure TViagem.setValNotaCurvas(aValNotaCurvas: integer);
begin
  self.valNotaCurvas := aValNotaCurvas;
end;

procedure TViagem.setValNotaFrenagem(aValNotaFrenagem: integer);
begin
  self.valNotaFrenagem := aValNotaFrenagem;
end;

procedure TViagem.setValNotaGeral(aValNotaGeral: integer);
begin
  self.valNotaGeral := aValNotaGeral;
end;

procedure TViagem.setValNotaVelocidade(aValNotaVelocidade: integer);
begin
  self.valNotaVelocidade := aValNotaVelocidade;
end;

{ TUsuario }

function TUsuario.getId: Integer;
begin
  result := self.id;
end;

function TUsuario.getNome: String;
begin
  result := self.Nome;
end;

function TUsuario.getQtdAceleracao: Integer;
begin
  result := QtdAceleracao;
end;

function TUsuario.getQtdLocalizacao: Integer;
begin
  result := QtdLocalizacao;
end;

function TUsuario.getQtdViagem: Integer;
begin
  result := QtdViagem;
end;

function TUsuario.getSenha: String;
begin
  result := self.senha;
end;

function TUsuario.getvalNotaAceleracao: integer;
begin
  result := self.valNotaAceleracao;
end;

function TUsuario.getvalNotaCurvas: integer;
begin
  result := self.valNotaCurvas;
end;

function TUsuario.getvalNotaFrenagem: integer;
begin
  result := self.valNotaFrenagem;
end;

function TUsuario.getvalNotaGeral: integer;
begin
  result := self.valNotaGeral;
end;

function TUsuario.getvalNotaVelocidade: integer;
begin
  result := self.valNotaVelocidade;
end;

procedure TUsuario.setId(aId: Integer);
begin
  self.Id := aId;
end;

procedure TUsuario.setNome(aNome: String);
begin
  self.Nome := aNome;
end;

procedure TUsuario.setQtdAceleracao(aQtdAceleracao: Integer);
begin
  self.QtdAceleracao := aQtdAceleracao;
end;

procedure TUsuario.setQtdLocalizacao(aQtdLocalizacao: Integer);
begin
  self.QtdLocalizacao := aQtdLocalizacao;
end;

procedure TUsuario.setQtdViagem(aQtdViagem: Integer);
begin
  self.QtdViagem := aQtdViagem
end;

procedure TUsuario.setSenha(aSenha: String);
begin
  self.Senha := aSenha;
end;

procedure TUsuario.setvalNotaAceleracao(AValNotaAceleracao: integer);
begin
  self.valNotaAceleracao := AValNotaAceleracao;
end;

procedure TUsuario.setvalNotaCurvas(aValNotaCurvas: integer);
begin
  self.valNotaCurvas := aValNotaCurvas;
end;

procedure TUsuario.setvalNotaFrenagem(aValNotaFrenagem: integer);
begin
  self.valNotaFrenagem := aValNotaFrenagem;
end;

procedure TUsuario.setvalNotaGeral(aValNotaGeral: integer);
begin
  self.valNotaGeral := aValNotaGeral;
end;

procedure TUsuario.setvalNotaVelocidade(aValNotaVelocidade: integer);
begin
  self.valNotaVelocidade := aValNotaVelocidade;
end;

{ TConfiguracoes }

function TConfiguracoes.getManterConectado: boolean;
begin
  result := self.manterConectado;
end;

function TConfiguracoes.getUsuarioConectado: TUsuario;
begin
  result := self.UsuarioConectado;
end;

procedure TConfiguracoes.setManterConectado(aManterConectado: boolean);
begin
  self.manterConectado := aManterConectado;
end;

procedure TConfiguracoes.setUsuarioConectado(aUsuario: TUsuario);
begin
  self.UsuarioConectado := aUsuario;
end;

{ TVelocidade }

function TVelocidade.getID: Integer;
begin
  result := self.id;
end;

function TVelocidade.getValLatitude: double;
begin
  result := self.valLatitude;
end;

function TVelocidade.getValLongitude: double;
begin
  result := self.valLongitude;
end;

function TVelocidade.getVelocidadeMaxima: double;
begin
  result := self.valVelocidadeMaxima;
end;

procedure TVelocidade.setID(Id: Integer);
begin
  self.id := id;
end;

procedure TVelocidade.setValLatitude(valLatitude: double);
begin
  self.valLatitude := valLatitude;
end;

procedure TVelocidade.setValLongitude(valLongitude: double);
begin
  self.valLongitude := valLongitude;
end;

procedure TVelocidade.setValVelocidadeMaxima(valVelocidadeMaxima: double);
begin
  self.valVelocidadeMaxima := valVelocidadeMaxima;
end;

end.

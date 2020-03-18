unit uConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, uclasses, uUsuarioDAO, system.JSON, generics.Collections;

type
  TConexao = class
  private
    { Private declarations }
    FunUsuario : TUsuarioDao;
    procedure CriarTabelaUsuario(fSQL: TFDQuery);
    procedure CriarTabelaViagem(fSQL: TFDQuery);
    procedure CriarTabelaLocalizacao(fSQL: TFDQuery);
    procedure CriarTabelaAcelerometro(fSQL: TFDQuery);
    procedure CriarVelocidadeLocalizacao(fSQL: TFDQuery);
    procedure CriarCamposNovosUsuario(fSQL: TFDQuery);
    procedure CriarTabelaConfiguracao(fSQL: TFDQuery);
  public
    { Public declarations }
    UsuarioConectado : TUsuario;
    DBConnection: TFDConnection;
    acaoUsuario : TTipoAcaoUSuario;

    procedure criarBanco;
    procedure LogarUsuario(aNome, aSenha : String);
    function gravarVelocidadeMaxima(aLatitude, aLongitude : double; aVelocidadeMaxima : Integer):String;
    function getVelocidadeMaximaVia(aLatitude, aLongitude : double):double;
    constructor Create;
    destructor Destroy;override;
  end;

var
  Conexao: TConexao;

implementation

uses System.IOUtils, fmx.dialogs, REST.Client, REST.types;

constructor TConexao.create;
begin
  acaoUsuario := aunenhum;
  DBConnection:= TFDConnection.Create(nil);
  try
    DBConnection.Params.Values['DriverID'] := 'SQLite';
    DBConnection.LoginPrompt := False;
    {$IF DEFINED (ANDROID) || (IOS)}
      DBConnection.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'drTrack.db');
    {$ENDIF}
    {$IF DEFINED (MSWINDOWS)}
      DBConnection.Params.Values['DataBase'] := '${CAMINHO_DB}';
    {$ENDIF}
    DBConnection.Connected := True;

    UsuarioConectado := TUsuario.Create;
    FunUsuario := TUsuarioDao.create;
    criarBanco;
  finally
  end;
end;

procedure TConexao.criarBanco;
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := DBConnection;
    try
      CriarTabelaUsuario(fSQL);
      CriarTabelaViagem(fSQL);
      CriarTabelaLocalizacao(fSQL);
      CriarTabelaAcelerometro(fSQL);
      CriarVelocidadeLocalizacao(fSQL);
      CriarCamposNovosUsuario(fSQL);
      CriarTabelaConfiguracao(fSQL);
    except on E: Exception do
      ShowMessage(e.ClassName + '-'+e.Message);
    end;
    
  finally
    fSQL.free;
  end;
end;

destructor TConexao.destroy;
begin
  UsuarioConectado.Free;
  FunUsuario.free;
  DBConnection.Free;
end;

function TConexao.getVelocidadeMaximaVia(aLatitude, aLongitude: double): double;
var
  restClient : TRestClient;
  restRequest : TRestRequest;
  restResponse : TRestResponse;
  param : TRESTRequestParameter;
  lista : TObjectList<TLocalizacao>;

  procedure gerarListaVelocidadesJSON(json : TJSONArray);
  var
    laco: Integer;
    latitude, longitude, velocidade : String;
    localizacao : TLocalizacao;
  begin
    for laco := 0 to json.Count - 1 do
    begin
      latitude := json.Items[laco].FindValue('latitude').ToString;
      longitude := json.Items[laco].FindValue('longitude').ToString;
      velocidade := json.Items[laco].FindValue('Velocidade').ToString;

      localizacao := TLocalizacao.Create;
      localizacao.setValLatitude(StrToFloatDef(copy(latitude, 2, length(latitude)-2), 0));
      localizacao.setValLongitude(StrToFloatDef(copy(longitude, 2, length(longitude)-2), 0));
      localizacao.setValVelocidade(strToFloatDef(copy(velocidade, 2, length(velocidade)-2), 0));
      lista.Add(localizacao);
    end;
  end;

  procedure lerWebservice(aLAt, aLong : double);
  var
    sLat, sLong : String;
  begin
    sLat := copy(floatToStR(aLat), 1, 3)+'.'+copy(floatToStR(aLat), 5, 3);
    sLong := copy(floatToStR(aLong), 1, 3)+'.'+copy(floatToStR(aLong), 5, 3);
    restClient := TRestClient.Create('https://lyy57mlpx4.execute-api.us-east-1.amazonaws.com/dev/retornarVelocidadesMaximas?latitude='+sLat+'&longitude='+sLong);
    try
      restRequest := TRESTRequest.Create(nil);
      try
        restResponse := TRESTResponse.Create(nil);
        try
          restRequest.Client := restClient;
          restRequest.Method := rmGET;
          restRequest.Response := restResponse;
          restRequest.Execute;

          if restResponse.StatusCode = 200 then
          begin
            gerarListaVelocidadesJSON(restResponse.JSONValue.FindValue('message').FindValue('Items') as TJsonArray);
          end;
        finally
          restResponse.Free;
        end;

      finally
        restRequest.Free;
      end;
    finally
      restClient.Free;
    end;
  end;

  function retornarVelocidade:double;
  var
    menorDistancia, distanciaAtual : double;
    laco: Integer;
  begin
    result := 0;
    if lista.Count > 0 then
    begin
      result := lista[0].getValVelocidade;
      menorDistancia := lista[0].calcularDistancia(aLatitude, aLongitude);

      for laco := 1 to lista.Count - 1 do
      begin
        distanciaAtual := lista[laco].calcularDistancia(aLatitude, aLongitude);

        if distanciaAtual < menorDistancia then
        begin
          result := lista[laco].getValVelocidade;
        end;
      end;
    end;
  end;

begin
  result:=50;
  lista := TObjectList<TLocalizacao>.create;
  try
    try
      lista.OwnsObjects := true;
      lerWebservice(aLatitude, aLongitude);
      result := retornarVelocidade;
    except on E: Exception do
      result := 50;
    end;

  finally
    lista.Free;
  end;
end;

function TConexao.gravarVelocidadeMaxima(aLatitude, aLongitude: double; aVelocidadeMaxima: Integer): String;
var
  restClient : TRestClient;
  restRequest : TRestRequest;
  restResponse : TRestResponse;
  param : TRESTRequestParameter;
begin
  result := '';
  restClient := TRestClient.Create('https://v2sslx063l.execute-api.us-east-1.amazonaws.com/dev/gravarVelocidadeMaxima?latitude='+FloatToStr(aLatitude)+
                                                                                                                     '&longitude='+floatToStr(aLongitude)+
                                                                                                                     '&velocidade='+intToStr(aVelocidadeMaxima));
  try
    restRequest := TRESTRequest.Create(nil);
    try
      restResponse := TRESTResponse.Create(nil);
      try
        restRequest.Client := restClient;
        restRequest.Method := rmPOST;
        restRequest.Response := restResponse;
        restRequest.AddParameter('latitude', FloatToStr(aLatitude));
        restRequest.AddParameter('longitude', floatToStr(aLongitude));
        restRequest.AddParameter('velocidade', intToStr(aVelocidadeMaxima));
        restRequest.Execute;

        if restResponse.StatusCode <> 200 then
        begin
          result := restResponse.JSONValue.ToString+#13+' ' +restResponse.Content;
        end;
      finally
        restResponse.Free;
      end;

    finally
      restRequest.Free;
    end;
  finally
    restClient.Free;
  end;
end;

procedure TConexao.CriarCamposNovosUsuario(fSQL: TFDQuery);
begin
  try
    fsql.Open('select QtdLocalizacao from Usuario where ID = 0');
  except
    on E: Exception do
    begin
      fsql.SQL.Text := 'ALTER TABLE Usuario ADD COLUMN QtdLocalizacao Integer;';
      fsql.ExecSQL;
      fsql.SQL.Text := 'ALTER TABLE Usuario ADD COLUMN QtdAceleracaos Integer;';
      fsql.ExecSQL;
      fsql.SQL.Text := 'ALTER TABLE Usuario ADD COLUMN QtdViagem Integer;';
      fsql.ExecSQL;
    end;
  end;
end;

procedure TConexao.CriarTabelaAcelerometro(fSQL: TFDQuery);
begin
  try
    fsql.Open('select 1 from ACELEROMETRO where ID = 0');
  except
    on E: Exception do
    begin
      fsql.SQL.Text := 'CREATE TABLE Acelerometro ( '+
                       ' id             INTEGER         PRIMARY KEY, '+
                       ' id_viagem      INTEGER         REFERENCES Viagem (id) ON DELETE CASCADE, '+
                       ' id_localizacao INTEGER         REFERENCES Localizacao (id) ON DELETE CASCADE, '+
                       ' valEixoX       DOUBLE (15, 6), '+
                       ' valEixoY       DOUBLE (15, 6), '+
                       ' valEixoZ       INTEGER (15, 6) '+
                       ' )';
      fsql.ExecSQL;
    end;
  end;
end;

procedure TConexao.CriarTabelaConfiguracao(fSQL: TFDQuery);
begin
  try
    fsql.Open('select 1 from CONFIGURACAO where ID = 0');
  except
    on E: Exception do
    begin
      fsql.SQL.Text := 'CREATE TABLE CONFIGURACAO ( '+
                       ' id                  INTEGER        PRIMARY KEY, '+
                       ' id_UsuarioConectado INTEGER, '+
                       ' ValPadraoAceleracao DOUBLE(7,5), '+
                       ' ValPadraoCurva      DOUBLE(7,5))'; ;
      fsql.ExecSQL;
    end;
  end;
end;

procedure TConexao.CriarTabelaLocalizacao(fSQL: TFDQuery);
begin
  try
    fsql.Open('select 1 from LOCALIZACAO where ID = 0');
  except
    on E: Exception do
    begin
      fsql.SQL.Text := 'CREATE TABLE Localizacao ( '+
                       ' id              INTEGER        PRIMARY KEY, '+
                       ' id_viagem       INTEGER        REFERENCES Viagem (id) ON DELETE CASCADE, '+
                       ' dataLocalizacao DATETIME, '+
                       ' valLatitude     DOUBLE (10, 6), '+
                       ' valLongitude    DOUBLE (10, 6) '+
                       ' )';
      fsql.ExecSQL;
    end;
  end;
end;

procedure TConexao.CriarTabelaUsuario(fSQL: TFDQuery);
begin
  try
    fsql.Open('select 1 from USUARIO where ID = 0');
  except
    on E: Exception do
    begin
      fsql.SQL.Text := 'CREATE TABLE Usuario ( ' +
                       ' id                INTEGER      PRIMARY KEY, ' +
                       ' nome              STRING (100), ' +
                       ' ValNotaGeral      INTEGER, ' +
                       ' valNotaAceleracao INTEGER, ' +
                       ' valNotaFrenagem   INTEGER, ' +
                       ' ValNotaVelocidade INTEGER, ' +
                       ' valNotaCurvas     INTEGER, ' +
                       ' senha             STRING (100) ' +
                       ' )';
      fsql.ExecSQL;
    end;
  end;
end;

procedure TConexao.CriarTabelaViagem(fSQL: TFDQuery);
begin
  try
    fsql.Open('select 1 from Viagem where ID = 0');
  except
    on E: Exception do
    begin
      fsql.SQL.Text := 'CREATE TABLE Viagem ( '+
                       ' id                INTEGER PRIMARY KEY, '+
                       ' dataInicioViagem  DATETime, '+
                       ' dataFimViagem     DATETime, '+
                       ' valNotaGeral      INTEGER, '+
                       ' valNotaAceleracao INTEGER, '+
                       ' valNotaFrenagem   INTEGER, '+
                       ' valNotaVelocidade INTEGER, '+
                       ' valNotaCurvas     INTEGER, '+
                       '  id_usuario        INTEGER REFERENCES Usuario (id) ON DELETE CASCADE '+
                       '                                                    ON UPDATE CASCADE '+
                       ')';
      fsql.ExecSQL;
    end;
  end;
end;

procedure TConexao.CriarVelocidadeLocalizacao(fSQL: TFDQuery);
begin
  try
    fsql.Open('select valVelocidade from Localizacao where ID = 0');
  except
    on E: Exception do
    begin
      fsql.SQL.Text := 'ALTER TABLE LOCALIZACAO ADD COLUMN ValVelocidade DOUBLE (15, 6);';
      fsql.ExecSQL;
    end;
  end;
end;

procedure TConexao.LogarUsuario(aNome, aSenha: String);
var
  fUsuario : TUsuario;
begin
//  fUsuario := TUsuario.Create;
//  fUsuario.setNome(aNome);
//  fUsuario.setSenha(asenha);
//  FunUsuario.GravarDadosUsuario(fUsuario);
  FunUsuario.CarregarUsuarioPeloUSuarioESenha(UsuarioConectado, anome, asenha);
end;

end.

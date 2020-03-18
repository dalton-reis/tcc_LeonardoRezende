unit uViagemDAO;

interface
  uses uclasses, firedac.comp.client, uConexao, sysutils, Generics.Collections,
  uAcelerometroDao, uLocalizacaoDao, uUsuarioDao, fmx.Dialogs;

  type
    TViagemDAO = class
      private
        fLocalizacaoDao : TLocalizacaoDAO;
        fAceleracaoDao : TAcelerometroDAO;
        fUsuarioDao : TUsuarioDAO;
        function gerarId : Integer;
      public
        function GravarDadosViagem(aViagem : TViagem; aAceleracoes : TObjectList<TAcelerometro>; aLocalizacao : TObjectList<TLocalizacao>) : String;
        procedure CarregarDadosViagem(aViagem : TViagem; aIdViagem : Integer);
        procedure AnalisarViagem(aViagem : TViagem; aAceleracoes : TObjectList<TAcelerometro>; aLocalizacao : TObjectList<TLocalizacao>);
        function retornarListaViagens(aUsuario : Integer):TObjectList<TViagem>;
        constructor cria;
        destructor Destroy;override;
    end;

implementation

{ TViagemDAO }

procedure TViagemDAO.AnalisarViagem(aViagem: TViagem; aAceleracoes: TObjectList<TAcelerometro>; aLocalizacao: TObjectList<TLocalizacao>);
begin
  aviagem.setValNotaAceleracao(fAceleracaoDao.analisarAcelerometroViagem(aAceleracoes));
  aviagem.setValNotaCurvas(fAceleracaoDao.analisarCurvasViagem(aAceleracoes));

  aViagem.setValNotaVelocidade(fLocalizacaoDao.AnalisarVelocidade(aLocalizacao));

  aViagem.setUsuario(Conexao.UsuarioConectado);
  aViagem.setValNotaGeral(round((aViagem.getValNotaAceleracao+aViagem.getValNotaVelocidade+aViagem.getvalNotaCurvas)/3));
end;

procedure TViagemDAO.CarregarDadosViagem(aViagem: TViagem; aIdViagem: Integer);
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.Create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fSQL.SQL.Text := 'select * from Viagem '+
                     ' where ID = '+IntToStr(aIdViagem);

    fSQL.open;
    if not fSQL.Eof then
    begin
      aViagem.setId(aIdViagem);
      aViagem.setDataInicio(fSQL.FieldByName('dataInicioViagem').asDateTime);
      aViagem.setDataFim(fSQL.FieldByName('dataFimViagem').asdateTime);
      aViagem.setValNotaGeral(fSQL.FieldByName('valNotaGeral').AsInteger);
      aViagem.setValNotaAceleracao(fSQL.FieldByName('valNotaAceleracao').AsInteger);
      aViagem.setValNotaVelocidade(fSQL.FieldByName('valNotaVelocidade').AsInteger);
      aviagem.setValNotaCurvas(fSQL.FieldByName('valNotaCurvas').AsInteger);
      aViagem.setUsuario(conexao.UsuarioConectado);
      aViagem.localizacoes := fLocalizacaoDao.retornarLocalizacoesViagem(aViagem.getId);
    end;
  finally
    fSQL.Free;
  end;
end;

constructor TViagemDAO.cria;
begin
  fLocalizacaoDao := TLocalizacaoDAO.Create;
  fAceleracaoDao := TAcelerometroDAO.Create;
  fUsuarioDao := TUsuarioDAO.create;
end;

destructor TViagemDAO.destroy;
begin
  fLocalizacaoDao.Free;
  fAceleracaoDao.Free;
  fUsuarioDao.Free;
  inherited;
end;

function TViagemDAO.gerarId: Integer;
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select max(ID) as ULTIMO from VIAGEM');

    try
      result := fsql.FieldByName('ULTIMO').AsInteger + 1;
    except on E: Exception do
      result := 1;
    end;

  finally
    fSQL.free;
  end;

end;

function TViagemDAO.GravarDadosViagem(aViagem: TViagem; aAceleracoes : TObjectList<TAcelerometro>; aLocalizacao : TObjectList<TLocalizacao>): String;
var
  fSQL : TFDQuery;

  function gravarAceleracaoViagem: String;
  var
    ilaco: Integer;
  begin
    for ilaco := 0 to aAceleracoes.Count -1 do
    begin
      aAceleracoes[ilaco].setViagem(aviagem);
      result := fAceleracaoDao.GravarDadosAcelerometro(aAceleracoes[ilaco]);
      if result <> '' then
        break;
    end;
  end;

  function gravarLocalizacaoViagem: String;
  var
    ilaco: Integer;
  begin
    for ilaco := 0 to aLocalizacao.Count -1 do
    begin
      aLocalizacao[ilaco].setViagem(aviagem);
      result := fLocalizacaoDao.GravarDadosLocalizacao(aLocalizacao[ilaco]);
      if result <> '' then
        break;
    end;
  end;

  function atualizarEstatisticaUsuario:String;
  var
    valNotaVelocidade : double;
  begin
    if (aAceleracoes.Count + Conexao.UsuarioConectado.getQtdAceleracao) > 0 then
    begin
      Conexao.UsuarioConectado.setvalNotaAceleracao(round(
                                                          ((Conexao.UsuarioConectado.getvalNotaAceleracao * Conexao.UsuarioConectado.getQtdAceleracao) +
                                                          (aViagem.getValNotaAceleracao * aAceleracoes.Count))/(aAceleracoes.Count + Conexao.UsuarioConectado.getQtdAceleracao)));
    end;

    if (aAceleracoes.Count + Conexao.UsuarioConectado.getQtdAceleracao) > 0 then
    begin
      Conexao.UsuarioConectado.setvalNotaCurvas(round(
                                                          ((Conexao.UsuarioConectado.getvalNotaCurvas * Conexao.UsuarioConectado.getQtdAceleracao) +
                                                          (aViagem.getvalNotaCurvas * aAceleracoes.Count))/(aAceleracoes.Count + Conexao.UsuarioConectado.getQtdAceleracao)));
    end;

    if (aLocalizacao.Count + Conexao.UsuarioConectado.getQtdLocalizacao) > 0 then
    begin
      Conexao.UsuarioConectado.setvalNotaVelocidade(round(
                                                          ((Conexao.UsuarioConectado.getvalNotaVelocidade * Conexao.UsuarioConectado.getQtdLocalizacao) +
                                                          (aViagem.getValNotaVelocidade * aLocalizacao.Count))/(aLocalizacao.Count + Conexao.UsuarioConectado.getQtdLocalizacao)));
    end;

    Conexao.UsuarioConectado.setvalNotaGeral(round((Conexao.UsuarioConectado.getvalNotaAceleracao+Conexao.UsuarioConectado.getvalNotaVelocidade+Conexao.UsuarioConectado.getvalNotaCurvas)/3));
    Conexao.UsuarioConectado.setQtdViagem(Conexao.UsuarioConectado.getQtdViagem+1);
    Conexao.UsuarioConectado.setQtdLocalizacao(Conexao.UsuarioConectado.getQtdLocalizacao+aLocalizacao.Count);
    Conexao.UsuarioConectado.setQtdAceleracao(Conexao.UsuarioConectado.getQtdAceleracao+aAceleracoes.Count);

    result := fUsuarioDao.GravarDadosUsuario(Conexao.UsuarioConectado);
  end;


begin
  result := '';
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fSQL.Open('select * from VIAGEM '+
                     ' where ID = '+IntToStr(aViagem.getId));

    if fSQL.eof then
      fSQL.Append
    else
      fSQL.edit;

    fSQL.FieldByName('dataInicioViagem').asDateTime := aViagem.getDataIncio;
    fSQL.FieldByName('dataFimViagem').asdateTime := aViagem.getDataFim;
    fSQL.FieldByName('valNotaGeral').AsInteger := aViagem.getValNotaGeral;
    fSQL.FieldByName('valNotaAceleracao').AsInteger := aViagem.getValNotaAceleracao;
    fSQL.FieldByName('valNotaFrenagem').AsInteger := aViagem.getValNotafrenagem;
    fSQL.FieldByName('valNotaVelocidade').AsInteger := aViagem.getValNotaVelocidade;
    fSQL.FieldByName('valNotaCurvas').AsInteger := aViagem.getValNotaCurvas;
    fSQL.FieldByName('id_usuario').AsInteger := aViagem.getUsuario.getId;

    if aViagem.getId = 0 then
      aViagem.setId(gerarId);

    fSQL.FieldByName('id').AsInteger := aViagem.getId;

    try
      fSQL.post;
    except on E: Exception do
      result := 'Erro ao gravar viagem : '+e.StackTrace;
    end;
  finally
    fSQL.free;
  end;

  if result = '' then
  begin
    result := gravarAceleracaoViagem;
    if result = '' then
    begin
      result := gravarLocalizacaoViagem;
      if result = '' then
      begin
        result := atualizarEstatisticaUsuario;
      end;
    end;
  end;
end;

function TViagemDAO.retornarListaViagens(aUsuario: Integer): TObjectList<TViagem>;
var
  fSQL : TFDQuery;
  viagem : TViagem;
begin
  Result := TObjectList<TViagem>.create;
  fSQL := TFDQuery.Create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fSQL.SQL.Text := 'select ID from Viagem '+
                     ' where ID_Usuario = '+IntToStr(aUsuario);

    fSQL.open;
    while not fSQL.Eof do
    begin
      viagem := TViagem.Create;
      CarregarDadosViagem(viagem, fSQL.FieldByName('ID').AsInteger);
      Result.Add(viagem);

      fSQL.next;
    end;
  finally
    fSQL.Free;
  end;
end;

end.

unit uUsuarioDAO;

interface
  uses uclasses, firedac.comp.client, sysutils, fmx.dialogs, FireDac.Dapt;

  type
    TUsuarioDAO = class
      private
//        fConexao : TFDCustomConnection;
        function gerarId : Integer;
      public
        function GravarDadosUsuario(aUsuario : TUsuario) : String;
        procedure carregaDadosUsuario(aUsuario : TUsuario; aIDUsuario : Integer);
        procedure CarregarUsuarioPeloUSuarioESenha(aUsuario : TUsuario; aNome, aSenha : String);
        function ExisteUsuario(aUsuario : String) : boolean;

        constructor create;
    end;

implementation
  uses data.DB, uConexao;

{ TViagemDAO }

procedure TUsuarioDAO.carregaDadosUsuario(aUsuario: TUsuario; aIDUsuario: Integer);
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select * from USUARIO'+
              ' where ID = '+IntToStr(aIDUsuario));

    aUsuario.setNome(fsql.FieldByName('NOME').AsString);
    aUsuario.setSenha(fsql.FieldByName('SENHA').AsString);
    ausuario.setvalNotaGeral(fsql.FieldByName('VALNOTAGERAL').asInteger);
    ausuario.setvalNotaAceleracao(fsql.FieldByName('VALNOTAAceleracao').asInteger);
    ausuario.setvalNotaFrenagem(fsql.FieldByName('VALNOTAFRENAGEM').asInteger);
    ausuario.setvalNotaVelocidade(fsql.FieldByName('VALNOTAVELOCIDADE').asInteger);
    ausuario.setvalNotaCurvas(fsql.FieldByName('VALNOTACURVAS').asInteger);
    ausuario.setQtdViagem(fsql.FieldByName('QTDVIAGEM').asInteger);
    ausuario.setQtdLocalizacao(fsql.FieldByName('QTDLOCALIZACAO').asInteger);
    ausuario.setQtdAceleracao(fsql.FieldByName('QtdAceleracaos').asInteger);
    ausuario.setId(aIDUsuario);

    fsql.close;
  finally
    fSQL.free;
  end;
end;

procedure TUsuarioDAO.CarregarUsuarioPeloUSuarioESenha(aUsuario: TUsuario; aNome, aSenha: String);
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select ID from USUARIO' +
              ' where UPPER(NOME) = UPPER('+QuotedStr(aNome)+')'+
              ' and SENHA = '+QuotedStr(aSenha));


    if fsql.IsEmpty then
      raise Exception.Create('Nome/Senha incorretos!');

    carregaDadosUsuario(aUsuario, fSQL.FieldByName('ID').AsInteger);

    fsql.close;
  finally
    fSQL.free;
  end;
end;

constructor TUsuarioDAO.create;
begin
//  Conexao := aConexao;
end;

function TUsuarioDAO.ExisteUsuario(aUsuario: String): boolean;
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select 1 from USUARIO '+
              ' where UPPER(NOME) = UPPER('+QuotedStr(aUsuario)+')');

    result := not fSQL.Eof;
  finally
    fSQL.free;
  end;

end;

function TUsuarioDAO.gerarId: Integer;
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select max(ID) as ULTIMO from USUARIO');

    if fsql.FieldByName('ULTIMO').asString <> '' then
      result := fsql.FieldByName('ULTIMO').AsInteger + 1
    else
      result := 1;
  finally
    fSQL.free;
  end;

end;

function TUsuarioDAO.GravarDadosUsuario(aUsuario : TUsuario) : String;
var
  fSQL : TFDQuery;
begin
  result := '';
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := conexao.dbConnection;

    fSQL.Open('select * from Usuario '+
                   ' where ID = '+IntToStr(aUsuario.getId));

    if fSQL.eof then
      fSQL.Append
    else
      fSQL.edit;

    fSQL.FieldByName('nome').asString := aUsuario.getNome;
    fSQL.FieldByName('senha').asString := aUsuario.getSenha;
    fSQL.FieldByName('valNotaGeral').AsInteger := aUsuario.getValNotaGeral;
    fSQL.FieldByName('valNotaAceleracao').AsInteger := aUsuario.getValNotaAceleracao;
    fSQL.FieldByName('valNotaFrenagem').AsInteger := aUsuario.getValNotafrenagem;
    fSQL.FieldByName('valNotaVelocidade').AsInteger := aUsuario.getValNotaVelocidade;
    fSQL.FieldByName('valNotaCurvas').AsInteger := aUsuario.getValNotaCurvas;
    fSQL.FieldByName('qtdViagem').AsInteger := aUsuario.getQtdViagem;
    fSQL.FieldByName('qtdLocalizacao').AsInteger := aUsuario.getQtdLocalizacao;
    fSQL.FieldByName('QtdAceleracaos').AsInteger := aUsuario.getQtdAceleracao;

    if aUsuario.getId = 0 then
      aUsuario.setId(gerarId);

    fSQL.FieldByName('id').AsInteger := aUsuario.getId;

    try
      fSQL.post;
    except on E: Exception do
      result := 'Erro ao gravar usuário : '+e.StackTrace;
    end;
  finally
    fSQL.free;
  end;
end;

end.


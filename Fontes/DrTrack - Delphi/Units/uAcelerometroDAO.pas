unit uAcelerometroDAO;

interface
  uses uclasses, firedac.comp.client, uConexao, sysutils, Generics.Collections;

  type
    TAcelerometroDAO = class
      private
        function gerarId : Integer;
      public
        function GravarDadosAcelerometro(aAcelerometro : TAcelerometro) : String;
        function analisarAcelerometroViagem(aListaAcelerometro : TObjectList<TAcelerometro>):Integer;
        function analisarCurvasViagem(aListaAcelerometro : TObjectList<TAcelerometro>):Integer;
    end;

implementation

{ TViagemDAO }

function TAcelerometroDAO.analisarAcelerometroViagem(aListaAcelerometro: TObjectList<TAcelerometro>): Integer;
var
  notas : TList<double>;
  laco : Integer ;
begin
  if aListaAcelerometro.Count = 0 then
    result := 100
  else
  begin
    notas := TList<double>.create;
    for laco := 0 to aListaAcelerometro.Count-1 do
    begin
      case aListaAcelerometro[laco].getAceleracao of
        taNormal : notas.Add(100);
        taForte : notas.Add(66.666);
        taMuitoForte : notas.Add(33.333);
        taExtrema : notas.Add(0);
      end;
    end;
    filtroMediaMascara3(notas);

    result := round(mediaValoresLista(notas));
  end;
end;

function TAcelerometroDAO.analisarCurvasViagem(aListaAcelerometro: TObjectList<TAcelerometro>): Integer;
var
  notas : TList<double>;
  laco : Integer ;
begin
  if aListaAcelerometro.Count = 0 then
    result := 100
  else
  begin
    notas := TList<double>.create;
    for laco := 0 to aListaAcelerometro.Count-1 do
    begin
      case aListaAcelerometro[laco].getTipoCurva of
        taNormal : notas.Add(100);
        taForte : notas.Add(66.666);
        taMuitoForte : notas.Add(33.333);
        taExtrema : notas.Add(0);
      end;
    end;
    filtroMediaMascara3(notas);

    result := round(mediaValoresLista(notas));
  end;
end;

function TAcelerometroDAO.gerarId: Integer;
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select max(ID) as ULTIMO from Acelerometro');

    try
      result := fsql.FieldByName('ULTIMO').AsInteger + 1;
    except on E: Exception do
      result := 1;
    end;

  finally
    fSQL.free;
  end;

end;

function TAcelerometroDAO.GravarDadosAcelerometro(aAcelerometro : TAcelerometro) : String;
var
  fSQL : TFDQuery;
begin
  result := '';
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fSQL.Open('select * from Acelerometro '+
                     ' where ID = '+IntToStr(aAcelerometro.getId));

    if fSQL.eof then
      fSQL.Append
    else
      fSQL.edit;

    fSQL.FieldByName('ValEixoX').asFloat := aAcelerometro.getValEixoX;
    fSQL.FieldByName('ValEixoY').asFloat := aAcelerometro.getValEixoY;
    fSQL.FieldByName('ValEixoZ').asFloat := aAcelerometro.getValEixoZ;
    if aAcelerometro.getLocalizacao <> nil then
      if aAcelerometro.getLocalizacao.getId <> 0 then
        fSQL.FieldByName('id_localizacao').AsInteger := aAcelerometro.getLocalizacao.getId;

    fSQL.FieldByName('id_viagem').AsInteger := aAcelerometro.getViagem.getId;

    if aAcelerometro.getId = 0 then
      aAcelerometro.setId(gerarId);

    fSQL.FieldByName('id').AsInteger := aAcelerometro.getId;

    try
      fSQL.post;
    except on E: Exception do
      result := 'Erro ao gravar viagem : '+e.StackTrace;
    end;
  finally
    fSQL.free;
  end;
end;

end.



unit uLocalizacaoDAO;

interface
  uses uclasses, firedac.comp.client, uConexao, sysutils, Generics.Collections, Math;

  type
    TLocalizacaoDAO = class
      private
        function gerarId : Integer;
      public
        function GravarDadosLocalizacao(aLocalizacao : TLocalizacao) : String;
        procedure CarDLocalizacao(aLocalizacao : TLocalizacao; aID : Integer);
        function retornarLocalizacoesViagem(aIDViagem : Integer):TObjectList<TLocalizacao>;
        function AnalisarVelocidade(aLocalizacoes : TObjectList<TLocalizacao>) : integer;
        function retornarVelocidadeMaximaVia(aLocalizacao : TLocalizacao):double;
    end;

implementation

{ TViagemDAO }

function TLocalizacaoDAO.AnalisarVelocidade(aLocalizacoes: TObjectList<TLocalizacao>):integer;
var
  iLaco : Integer;
  fListaVelocidade : TList<Double>;
begin
  result := 0;
  if aLocalizacoes.Count > 0 then
  begin
    fListaVelocidade := TList<Double>.create;
    try
      for ilaco := 0 to aLocalizacoes.Count - 1 do
      begin
        fListaVelocidade.Add(aLocalizacoes[ilaco].getValVelocidade);
      end;
      filtroMediaMascara3(fListaVelocidade);

      for ilaco := 0 to aLocalizacoes.Count - 1 do
      begin
        aLocalizacoes[ilaco].setValVelocidade(fListaVelocidade[ilaco]);

        //Valores da velocidade permitida retirados do CTB
        //7 km/h - Tolerancia(Margem de erro)
        //até 20% média
        //de 20% até 50% grave
        //acima de 50% gravíssima
        if aLocalizacoes[ilaco].getValVelocidade <= retornarVelocidadeMaximaVia(aLocalizacoes[ilaco]) then
        begin
          result := result + 100;
        end
        else
        begin
          if aLocalizacoes[ilaco].getValVelocidade <= (retornarVelocidadeMaximaVia(aLocalizacoes[ilaco]) + 7)then
          begin
            result := result + 75;
          end
          else
          begin
            if aLocalizacoes[ilaco].getValVelocidade <= (retornarVelocidadeMaximaVia(aLocalizacoes[ilaco])+
                                                        (retornarVelocidadeMaximaVia(aLocalizacoes[ilaco])*0.2))then
            begin
              result := result + 50;
            end
            else
            begin
              if aLocalizacoes[ilaco].getValVelocidade <= (retornarVelocidadeMaximaVia(aLocalizacoes[ilaco]) +
                                                          (retornarVelocidadeMaximaVia(aLocalizacoes[ilaco])*0.5))then
              begin
                result := result + 25;
              end
            end;
          end;
        end;
      end;
      result := round(result / aLocalizacoes.Count);

    finally
      fListaVelocidade.Free;
    end;
  end
  else
    result := 100;
end;

procedure TLocalizacaoDAO.CarDLocalizacao(aLocalizacao: TLocalizacao; aId : Integer);
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select * from Localizacao '+
              ' where ID = '+IntToStr(aId)+
              ' order by dataLocalizacao');

    if not fSQL.Eof then
    begin
      aLocalizacao.setId(aid);
      aLocalizacao.setDataLocalizacao(fSQL.FieldByName('dataLocalizacao').AsDateTime);
      aLocalizacao.setValLatitude(fSQL.FieldByName('valLatitude').asFloat);
      aLocalizacao.setValLongitude(fSQL.FieldByName('ValLongitude').asFloat);
      aLocalizacao.setValVelocidade(fSQL.FieldByName('ValVelocidade').asFloat);
    end;
  finally
    fSQL.free;
  end;

end;

function TLocalizacaoDAO.gerarId: Integer;
var
  fSQL : TFDQuery;
begin
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select max(ID) as ULTIMO from Localizacao');

    try
      result := fsql.FieldByName('ULTIMO').AsInteger + 1;
    except on E: Exception do
      result := 1;
    end;
  finally
    fSQL.free;
  end;

end;

function TLocalizacaoDAO.GravarDadosLocalizacao(aLocalizacao : TLocalizacao) : String;
var
  fSQL : TFDQuery;
begin
  result := '';
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fSQL.Open('select * from Localizacao '+
                     ' where ID = '+IntToStr(aLocalizacao.getId));

    if fSQL.eof then
      fSQL.Append
    else
      fSQL.edit;

    fSQL.FieldByName('dataLocalizacao').AsDateTime := aLocalizacao.getDataLocalizacao;
    fSQL.FieldByName('valLatitude').asFloat := aLocalizacao.getValLatitude;
    fSQL.FieldByName('ValLongitude').asFloat := aLocalizacao.getValLongitude;
    fSQL.FieldByName('ValVelocidade').asFloat := aLocalizacao.getValVelocidade;
    fSQL.FieldByName('id_viagem').AsInteger := aLocalizacao.getViagem.getId;

    if aLocalizacao.getId = 0 then
      aLocalizacao.setId(gerarId);

    fSQL.FieldByName('id').AsInteger := aLocalizacao.getId;

    try
      fSQL.post;
    except on E: Exception do
      result := 'Erro ao gravar viagem : '+e.StackTrace;
    end;
  finally
    fSQL.free;
  end;
end;

function TLocalizacaoDAO.retornarLocalizacoesViagem(aIDViagem: Integer): TObjectList<TLocalizacao>;
var
  fSQL : TFDQuery;
  localizacao : TLocalizacao;
begin
  result := TObjectList<TLocalizacao>.create;
  fSQL := TFDQuery.create(nil);
  try
    fSQL.Connection := Conexao.DBConnection;

    fsql.Open('select ID from Localizacao '+
              ' where ID_VIAGEM = '+IntToStr(aIDViagem)+
              ' order by dataLocalizacao');

    while not fSQL.Eof do
    begin
      localizacao := TLocalizacao.Create;
      CarDLocalizacao(localizacao, fSql.FieldByName('ID').asInteger);
      result.Add(localizacao);
      fSQL.next;
    end;
  finally
    fSQL.free;
  end;

end;

function TLocalizacaoDAO.retornarVelocidadeMaximaVia(aLocalizacao: TLocalizacao): double;
begin
  result :=  50;//Conexao.getVelocidadeMaximaVia(roundTo(aLocalizacao.getValLatitude, 3), roundTo(aLocalizacao.getValLongitude, 3));
end;

end.



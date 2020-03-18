unit uConexaoFirebase;

interface

uses UClasses;

const
  API_KEY = 'AIzaSyC7ZR25n8w-krfrdzD0JmRfJMoy6SdGVJA';
  API_EMAIL = 'leorzd17@gmail.com';
  API_SENHA = '@Leo171729';
  API_URL = 'http://drtrack-1536013523011.firebaseapp.com';

type
  TConexaoFireBase = class
    private
      idToken : String;
    public
      procedure conectar;
      procedure PostVelocidadeMaxima(aVelocidadeMaxima : TVelocidade);
  end;

implementation

uses Firebase.Interfaces,
     Firebase.Auth,
     Firebase.Database,
     System.JSON,
     System.Net.HttpClient,
     System.Generics.Collections,
     System.JSON.Types,
     System.JSON.Writers,
     System.Classes;

{ TConexaoFireBase }

procedure TConexaoFireBase.conectar;
var
  Auth: IFirebaseAuth;
  AResponse: IFirebaseResponse;
  JSONResp: TJSONValue;
  Obj: TJSONObject;
begin
  Auth := TFirebaseAuth.Create;
  Auth.SetApiKey(API_KEY);
  AResponse := Auth.SignInWithEmailAndPassword(API_EMAIL, API_SENHA);
  JSONResp := TJSONObject.ParseJSONValue(AResponse.ContentAsString);
  if (not Assigned(JSONResp)) or (not(JSONResp is TJSONObject)) then
  begin
    if Assigned(JSONResp) then
    begin
      JSONResp.Free;
    end;
    Exit;
  end;
  Obj := JSONResp as TJSONObject;
  idToken := Obj.Values['idToken'].Value;
end;


procedure TConexaoFireBase.PostVelocidadeMaxima(aVelocidadeMaxima: TVelocidade);
var
  ADatabase: TFirebaseDatabase;
  AResponse: IFirebaseResponse;
  JSONReq: TJSONObject;
  JSONResp: TJSONValue;
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
begin
  StringWriter := TStringWriter.Create();
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.None;

  // Start
  Writer.WriteStartObject;

  Writer.WritePropertyName('valLatitude');
  Writer.WriteValue(aVelocidadeMaxima.getValLatitude);

  Writer.WritePropertyName('valLongitude');
  Writer.WriteValue(aVelocidadeMaxima.getValLongitude);

  Writer.WritePropertyName('valVelocidadeMaxima');
  Writer.WriteValue(aVelocidadeMaxima.getVelocidadeMaxima);

  Writer.WriteEndObject;

  JSONReq := TJSONObject.ParseJSONValue(StringWriter.ToString) as TJSONObject;

  ADatabase := TFirebaseDatabase.Create;
  ADatabase.SetBaseURI(API_URL);
  ADatabase.SetToken(idToken);
  try
    AResponse := ADatabase.Post(['/VelocidadeMaxima.json'], JSONReq);
    JSONResp := TJSONObject.ParseJSONValue(AResponse.ContentAsString);
    if (not Assigned(JSONResp)) or (not(JSONResp is TJSONObject)) then
    begin
      if Assigned(JSONResp) then
      begin
        JSONResp.Free;
      end;
      Exit;
    end;
//    memoResp.Text := JSONResp.ToString;
  finally
    ADatabase.Free;
  end;

end;

end.

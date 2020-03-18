unit uLocalizacaoSensor;

interface
  uses Androidapi.JNI.Location, Androidapi.JNIBridge, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Os, Androidapi.Helpers;

implementation

type
  TLocationListener = class(TJavaLocal, JLocationListener)
  private
    speed : double;
  public
    procedure onLocationChanged(location: JLocation); cdecl;
    procedure onProviderDisabled(provider: JString); cdecl;
    procedure onProviderEnabled(provider: JString); cdecl;
    procedure onStatusChanged(provider: JString; status: Integer; extras: JBundle); cdecl;
    function getSpeed : double;
end;

{ TLocationListener }

function TLocationListener.getSpeed: double;
begin
  result := speed;
end;

procedure TLocationListener.onLocationChanged(location: JLocation);
begin
  speed := location.getSpeed;
end;

procedure TLocationListener.onProviderDisabled(provider: JString);
begin

end;

procedure TLocationListener.onProviderEnabled(provider: JString);
begin

end;

procedure TLocationListener.onStatusChanged(provider: JString; status: Integer;
  extras: JBundle);
begin

end;

end.

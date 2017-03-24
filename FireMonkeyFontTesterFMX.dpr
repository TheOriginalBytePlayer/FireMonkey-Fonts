program FireMonkeyFontTesterFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  FireMonkeyTestForm in 'FireMonkeyTestForm.pas' {Form27},
  FMXFontInstaller in 'FMXFontInstaller.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm27, Form27);
  Application.Run;
end.


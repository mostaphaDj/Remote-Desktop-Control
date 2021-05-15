program Server;

uses
  Forms,
  MainServer_U in 'MainServer_U.pas' {FormMainServer},
  jpeg in '..\JPGImage\jpeg.pas',
  ScreenShots_U in 'ScreenShots_U.pas',
  DataConnection_U in 'DataConnection_U.pas' {DataConnection: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMainServer, FormMainServer);
  Application.CreateForm(TDataConnection, DataConnection);
  Application.Run;
end.

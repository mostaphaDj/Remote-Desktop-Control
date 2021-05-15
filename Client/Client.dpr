program Client;

uses
  Forms,
  MainClient_U in 'MainClient_U.pas' {FormMainClient},
  jpeg in '..\JPGImage\jpeg.pas',
  QualityPerformanceOptions_U in 'QualityPerformanceOptions_U.pas' {FormQualityPerformanceOptions},
  ConnectionOptions_U in 'ConnectionOptions_U.pas' {FormConnectionOptions};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMainClient, FormMainClient);
  Application.Run;
end.

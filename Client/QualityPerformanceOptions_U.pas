unit QualityPerformanceOptions_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient,jpeg,IdStack, IdAntiFreezeBase, IdAntiFreeze,IdGlobal,IniFiles,
  ComCtrls;

type
  TFormQualityPerformanceOptions = class(TForm)
    GroupBox2: TGroupBox;
    LabelQuality: TLabel;
    GroupBoxCompressionDecompression: TGroupBox;
    CheckBoxGrayScale: TCheckBox;
    CheckBoxProgressiveEncoding: TCheckBox;
    ButtonApply: TButton;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    Label5: TLabel;
    TrackBarQuality: TTrackBar;
    TrackBarSpeed: TTrackBar;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormQualityPerformanceOptions: TFormQualityPerformanceOptions;

implementation

uses MainClient_U;

{$R *.dfm}

procedure TFormQualityPerformanceOptions.ButtonApplyClick(Sender: TObject);
begin
  with QualityPerformanceOptions,TIniFile.Create(IniFileName) do
  begin
    CompressionQuality:=TrackBarQuality.Position;
    WriteInteger('QualityPerformanceOptions','CompressionQuality',CompressionQuality);
    GrayScale:=CheckBoxGrayScale.Checked;
    JpegImg.GrayScale:=QualityPerformanceOptions.GrayScale;
    WriteBool('QualityPerformanceOptions','GrayScale',GrayScale);
    ProgressiveEncoding:=CheckBoxProgressiveEncoding.Checked;
    WriteBool('QualityPerformanceOptions','ProgressiveEncoding',ProgressiveEncoding);
    JpegImg.ProgressiveEncoding:=QualityPerformanceOptions.ProgressiveEncoding;
    Sleep1:=(1000-TrackBarSpeed.Position);
    WriteInteger('QualityPerformanceOptions','Speed',Sleep1);
    Free
  end;
  with FormMainClient.IdTCPClientOptiorus do
  begin
    if Connected then
      try
        IOHandler.Write(RawToBytes(QualityPerformanceOptions,SizeOf(QualityPerformanceOptions)));
      finally
      end;
  end;
end;

procedure TFormQualityPerformanceOptions.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormQualityPerformanceOptions.ButtonOKClick(Sender: TObject);
begin
  ButtonApplyClick(Sender);
  Close;
end;

procedure TFormQualityPerformanceOptions.FormCreate(Sender: TObject);
begin
  with QualityPerformanceOptions do
  begin
    TrackBarQuality.Position:=CompressionQuality;
    CheckBoxGrayScale.Checked:=GrayScale;
    CheckBoxProgressiveEncoding.Checked:=ProgressiveEncoding;
    TrackBarSpeed.Position:=(1000-Sleep1);
  end;
end;

end.

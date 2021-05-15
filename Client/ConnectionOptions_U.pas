unit ConnectionOptions_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,IniFiles,IdStack;

type
  TFormConnectionOptions = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ComboBoxHostRemote: TComboBox;
    EditPortUDPControl: TEdit;
    EditPortUDPScreenShots: TEdit;
    ButtonApply: TButton;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormConnectionOptions: TFormConnectionOptions;

implementation

uses MainClient_U;

{$R *.dfm}

procedure TFormConnectionOptions.ButtonApplyClick(Sender: TObject);
begin
  with ConnectionOptions,TIniFile.Create(IniFileName) do
  begin
    HostRemote:=ComboBoxHostRemote.Text;
    WriteString('ConnectionOptions','HostRemote',HostRemote);
    PortUDPScreenShots:=StrToInt(EditPortUDPScreenShots.Text);
    WriteInteger('ConnectionOptions','PortUDPScreenShots',PortUDPScreenShots);
    PortUDPControl:=StrToInt(EditPortUDPControl.Text);
    WriteInteger('ConnectionOptions','PortUDPControl',PortUDPControl);
    Free;
  end;
  FormMainClient.Connect1Click(nil);
end;

procedure TFormConnectionOptions.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormConnectionOptions.ButtonOKClick(Sender: TObject);
begin
ButtonApplyClick(Sender);
Close;
end;

procedure TFormConnectionOptions.FormCreate(Sender: TObject);
begin
  with ConnectionOptions do
  begin
    ComboBoxHostRemote.Text:=HostRemote;
    EditPortUDPScreenShots.Text:=IntToStr(PortUDPScreenShots);
    EditPortUDPControl.Text:=IntToStr(PortUDPControl);
  end;
end;

end.

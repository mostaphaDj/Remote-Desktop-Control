unit MainClient_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Jpeg, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer,IdSocketHandle, ExtCtrls, IdUDPClient, StdCtrls, Menus,
  IdTCPConnection, IdTCPClient,IdGlobal,IniFiles,IdStack;

type
  TFormMainClient = class(TForm)
    IdUDPServerScreenShots: TIdUDPServer;
    UDPAntiFreeze: TIdAntiFreeze;
    IdUDPClientControl: TIdUDPClient;
    Image1: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    IdTCPClientOptiorus: TIdTCPClient;
    Connect1: TMenuItem;
    Options1: TMenuItem;
    Disconnect1: TMenuItem;
    FullScreen1: TMenuItem;
    Exit1: TMenuItem;
    Control1: TMenuItem;
    Mouse1: TMenuItem;
    Keyboard1: TMenuItem;
    Connection1: TMenuItem;
    procedure IdUDPServerScreenShotsUDPRead(AThread: TIdUDPListenerThread; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Options1Click(Sender: TObject);
    procedure Connect1Click(Sender: TObject);
    procedure Disconnect1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FullScreen1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Connection1Click(Sender: TObject);
    procedure Mouse1Click(Sender: TObject);
    procedure Keyboard1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Type
  TConnectionOptions =packed record
    LocalHost:string[255];
    PortUDPScreenShots,
    PortUDPControl:Word;
  end;
  TQualityPerformanceOptions=packed record
    CompressionQuality:1..100;
    GrayScale,
    ProgressiveEncoding:Boolean;
    Sleep1:0..1000;
    SizeBitmap:Word;
  end;

  TResolution=packed record
    X,Y:Word;
  end;

Var
  QualityPerformanceOptions:TQualityPerformanceOptions;
  ConnectionOptions:TConnectionOptions;
  Resolution:TResolution;

  HostRemote:string;
  IniFileName:string='Option.ini';

var
  FormMainClient: TFormMainClient;
  JpegImg:TJpegImage;

implementation

uses ConnectionOptions_U, QualityPerformanceOptions_U;

{$R *.dfm}

//var
//  ScreenShotFirst,ScreenShotLast:TBitmap;

Function MergeChange(BitmapFirst,BitmapLast:TBitmap):TBitmap;// œ„Ã «· €ÌÌ— ⁄·Ï «·’Ê—…
type
  TRGB32 = packed record
    B, G, R : Byte;
  end;
  TRGB32Array = packed array[0..MaxInt div SizeOf(TRGB32)-1] of TRGB32;
  PRGB32Array = ^TRGB32Array;
var
  x,y  : Integer;
  LineFirst,LineLast : PRGB32Array;
begin
  if BitmapFirst.Handle=0 then
  begin
  //  »œÌ· «·⁄‰Ê«‰‰Ì‰
    BitmapFirst.Assign(BitmapLast);
    Result:=BitmapFirst;
    Exit;
  end;

  BitmapFirst.PixelFormat := pf24bit;
  BitmapLast.PixelFormat := pf24bit;

  for y := 0 to BitmapFirst.Height - 1 do
  begin
    LineFirst := BitmapFirst.Scanline[y];
    LineLast := BitmapLast.Scanline[y];
    for x := 0 to BitmapFirst.Width - 1 do
    begin
      if not((LineLast[x].B=0) and (LineLast[x].G=0) and (LineLast[x].R=0)) then
      begin
        LineFirst[x].B := LineLast[x].B;
        LineFirst[x].G := LineLast[x].G;
        LineFirst[x].R := LineLast[x].R;
      end;
    end;
  end;
  Result:=BitmapFirst;
end;

procedure TFormMainClient.Connect1Click(Sender: TObject);
Var
  Data:TBytes;
begin
with IdTCPClientOptiorus do
begin
  if Connected then Disconnect;
    Host:=HostRemote;
  try
    ConnectionOptions.LocalHost:=GStack.HostName;
    Connect;
    IOHandler.Write(RawToBytes(ConnectionOptions,SizeOf(ConnectionOptions)));
    IOHandler.ReadBytes(Data,SizeOf(Resolution));
    BytesToRaw(Data,Resolution,SizeOf(Resolution));
    IOHandler.Write(RawToBytes(QualityPerformanceOptions,SizeOf(QualityPerformanceOptions)));
  finally
    IdUDPServerScreenShots.DefaultPort:=ConnectionOptions.PortUDPScreenShots;
    IdUDPServerScreenShots.Active:=True;
    IdUDPClientControl.Host:=HostRemote;
    IdUDPClientControl.Port:=ConnectionOptions.PortUDPControl;
    Connect1.Enabled:=False;
    Disconnect1.Enabled:=True;
  end;
end;

end;


procedure TFormMainClient.Connection1Click(Sender: TObject);
begin
  FormConnectionOptions:=TFormConnectionOptions.Create(Self);
  FormConnectionOptions.ShowModal;
  FormConnectionOptions.Free;
end;

procedure TFormMainClient.Disconnect1Click(Sender: TObject);
begin
if IdTCPClientOptiorus.Connected then IdTCPClientOptiorus.Disconnect;
  FormMainClient.IdUDPServerScreenShots.Active:=False;
  Disconnect1.Enabled:=False;
  Connect1.Enabled:=True;
  Mouse1Click(Sender);
  Keyboard1Click(Sender);
end;

procedure TFormMainClient.Exit1Click(Sender: TObject);
begin
  Close
end;

procedure TFormMainClient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
IdTCPClientOptiorus.Disconnect;
IdUDPServerScreenShots.Active:=False;
end;

procedure TFormMainClient.FormCreate(Sender: TObject);
begin
//  ScreenShotFirst:=TBitmap.Create;
//  ScreenShotLast:=TBitmap.Create;
  JpegImg:=TJPEGImage.Create;
//
//-----------------------
begin
  with TIniFile.Create(IniFileName) do
  begin
    with ConnectionOptions do
    begin
      HostRemote:=ReadString('ConnectionOptions','HostRemote','127.0.0.1');
      PortUDPScreenShots:=ReadInteger('ConnectionOptions','PortUDPScreenShots',7218);
      PortUDPControl:=ReadInteger('ConnectionOptions','PortUDPControl',7219);
    end;
    with QualityPerformanceOptions do
    begin
      CompressionQuality:=ReadInteger('QualityPerformanceOptions','CompressionQuality',20);
      GrayScale:=ReadBool('QualityPerformanceOptions','GrayScale',False);
      ProgressiveEncoding:=ReadBool('QualityPerformanceOptions','ProgressiveEncoding',True);
      Sleep1:=ReadInteger('QualityPerformanceOptions','Speed',0);
      SizeBitmap:=ReadInteger('QualityPerformanceOptions','SizeBitmap',Screen.Width);
      ClientWidth:=SizeBitmap;
    end;
    Free;
  end;
end;
end;

procedure TFormMainClient.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IdUDPClientControl.Send('KeyDn'{Down}+UIntToStr(Key));
  Key:=0;
end;

procedure TFormMainClient.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  IdUDPClientControl.Send('KeyUp'+UIntToStr(Key));
  Key:=0;
end;

procedure TFormMainClient.FormResize(Sender: TObject);
begin
  ClientHeight:=(ClientWidth * Screen.Height) div Screen.Width;
  with QualityPerformanceOptions,TIniFile.Create(IniFileName) do
  begin
    SizeBitmap:=ClientWidth;
    WriteInteger('QualityPerformanceOptions','SizeBitmap',SizeBitmap);
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

procedure TFormMainClient.FullScreen1Click(Sender: TObject);
begin
if Not(FullScreen1.Checked) then
begin
  BorderStyle:=bsNone;
  WindowState:=wsMaximized;
  FullScreen1.Checked:=True;
  File1.Visible:=False;
end
else
begin
  BorderStyle:=bsSizeable;
  WindowState:=wsNormal;
  FullScreen1.Checked:=False;
  File1.Visible:=True;
end;


end;

procedure TFormMainClient.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var  StrButton:string;
begin
  if button=mbLeft then StrButton:='LeftDown'
  else if button=mbRight then StrButton:='RightDown'
  else if button=mbMiddle then StrButton:='MiddleDown';
  IdUDPClientControl.Send('MOUSE'+'X='+IntToStr((X*Resolution.X)div Image1.Width)+'Y='+IntToStr((Y*Resolution.Y)div Image1.Height)+'Button='+StrButton);
end;

procedure TFormMainClient.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
const StrButton:string='Mouve';
begin
  IdUDPClientControl.Send('MOUSE'+'X='+IntToStr((X*Resolution.X)div Image1.Width)+'Y='+IntToStr((Y*Resolution.Y)div Image1.Height)+'Button='+StrButton);
end;

procedure TFormMainClient.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var StrButton:string;
begin
  if button=mbLeft then StrButton:='LeftUp'
  else if Button=mbRight then StrButton:='RightUp'
  else if Button=mbMiddle then StrButton:='MiddleUp';
  IdUDPClientControl.Send('MOUSE'+'X='+IntToStr((X*Resolution.X)div Image1.Width)+'Y='+IntToStr((Y*Resolution.Y)div Image1.Height)+'Button='+StrButton);
end;

procedure TFormMainClient.Keyboard1Click(Sender: TObject);
begin
if not(Keyboard1.Checked)  then
begin
  if IdTCPClientOptiorus.Connected then
  begin
    OnKeyDown:=FormKeyDown;
    OnKeyUp:=FormKeyUp;
    Keyboard1.Checked:=True;
  end;
end
else
begin
  OnKeyDown:=nil;
  OnKeyUp:=nil;
  Keyboard1.Checked:=False;
end;
end;

procedure TFormMainClient.Mouse1Click(Sender: TObject);
begin
  if not(Mouse1.Checked) then
  begin
    if IdTCPClientOptiorus.Connected then
    begin
      Image1.OnMouseDown:=Image1MouseDown;
      Image1.OnMouseMove:=Image1MouseMove;
      Image1.OnMouseUp:=Image1MouseUp;
      Image1.Cursor:=crDefault;
      Mouse1.Checked:=True;
    end;
  end
  else
  begin
    Image1.OnMouseDown:=nil;
    Image1.OnMouseMove:=nil;
    Image1.OnMouseUp:=nil;
    Image1.Cursor:=crNo;
    Mouse1.Checked:=False;
  end;
end;

procedure TFormMainClient.Options1Click(Sender: TObject);
begin
  FormQualityPerformanceOptions:=TFormQualityPerformanceOptions.Create(Self);
  FormQualityPerformanceOptions.ShowModal;
  FormQualityPerformanceOptions.Free;
end;

procedure TFormMainClient.IdUDPServerScreenShotsUDPRead(AThread: TIdUDPListenerThread; AData: TBytes;
  ABinding: TIdSocketHandle);
var LengthAData:Word;
begin
  LengthAData:=Length(AData);
  JpegImg.Image.WriteBuffer(Pointer(AData)^, LengthAData);
  if (AData[LengthAData-2]=$FF) And (AData[LengthAData-1]=$D9) then
  begin
    try
      try
       JpegImg.Decompress;
      finally
        Image1.Picture.Bitmap.Handle:=JpegImg.Bitmap.Handle;
        JpegImg.Image.Position:=0;
        JpegImg.Image.Size:=0;
        FreeMem(JpegImg.Image.Memory);
      end;
    except
      JpegImg.Image.Position:=0;
      JpegImg.Image.Size:=0;
      FreeMem(JpegImg.Image.Memory);
    end;
  end
end;

end.

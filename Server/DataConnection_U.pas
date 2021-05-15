unit DataConnection_U;

interface

uses
  Windows,SysUtils, Classes, IdCustomTCPServer, IdTCPServer, IdUDPServer,
  IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient,IdContext,IdSocketHandle,IdGlobal,Forms;

type
  TDataConnection = class(TDataModule)
    IdUDPClientScreenShots: TIdUDPClient;
    UDPAntiFreeze: TIdAntiFreeze;
    IdUDPServerControl: TIdUDPServer;
    IdTCPServerOptiorus: TIdTCPServer;
    procedure IdUDPServerControlUDPRead(AThread: TIdUDPListenerThread;
      AData: TBytes; ABinding: TIdSocketHandle);
    procedure IdTCPServerOptiorusConnect(AContext: TIdContext);
    procedure IdTCPServerOptiorusDisconnect(AContext: TIdContext);
    procedure IdTCPServerOptiorusExecute(AContext: TIdContext);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataConnection: TDataConnection;

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

implementation

uses ScreenShots_U;

{$R *.dfm}

procedure TDataConnection.IdTCPServerOptiorusConnect(AContext: TIdContext);
Var
  Data:TBytes;
begin
  AContext.Connection.IOHandler.ReadBytes(Data,SizeOf(ConnectionOptions));
  BytesToRaw(Data,ConnectionOptions,SizeOf(ConnectionOptions));
  with ConnectionOptions do
  begin
    IdUDPClientScreenShots.Host:=LocalHost;
    IdUDPClientScreenShots.Port:=PortUDPScreenShots;
    IdUDPServerControl.DefaultPort:=PortUDPControl;
  end;
  Resolution.X:=Screen.Width;
  Resolution.Y:=Screen.Height;
  AContext.Connection.IOHandler.Write(RawToBytes(Resolution,SizeOf(Resolution)));
  IdUDPServerControl.Active:=True;
  ThreadScreenShots:=TThreadScreenShots.Create(False);
end;

procedure TDataConnection.IdTCPServerOptiorusDisconnect(AContext: TIdContext);
begin
  IdUDPServerControl.Active:=False;
  ThreadScreenShots.Free;
end;

procedure TDataConnection.IdTCPServerOptiorusExecute(AContext: TIdContext);
Var
  Data:TBytes;
begin
  AContext.Connection.IOHandler.ReadBytes(Data,SizeOf(QualityPerformanceOptions));
  BytesToRaw(Data,QualityPerformanceOptions,SizeOf(QualityPerformanceOptions));
  with ThreadScreenShots do
  begin
    FJpegImg.CompressionQuality:=QualityPerformanceOptions.CompressionQuality;
    FJpegImg.GrayScale:=QualityPerformanceOptions.GrayScale;
    FJpegImg.ProgressiveEncoding:=QualityPerformanceOptions.ProgressiveEncoding;
    FRect.Right := QualityPerformanceOptions.SizeBitmap;
    FRect.Bottom := (QualityPerformanceOptions.SizeBitmap * Screen.Height) div Screen.Width;
  end;
end;

procedure TDataConnection.IdUDPServerControlUDPRead(AThread: TIdUDPListenerThread;
  AData: TBytes; ABinding: TIdSocketHandle);
var  StrCommand:string;
     PosX,PosY,PosButton:Word;
     CursorPos : TPoint;
     StrButton:string;
     Key:Word;
begin
 StrCommand :=BytesToString(AData);
 if Pos ('MOUSE', strCommand) = 1 then
 begin
    PosX:=Pos('X=',StrCommand)+2;
    PosY:=Pos('Y=',StrCommand)+2;
    PosButton:=Pos('Button=',StrCommand)+7;
    CursorPos.X:=StrToInt(Copy(StrCommand,PosX,(PosY-2)-PosX));
    CursorPos.Y:=StrToInt(Copy(StrCommand,PosY,(PosButton-7)-(PosY)));
    StrButton:=Copy(StrCommand,PosButton,Length(StrCommand));
    if StrButton='Mouve' then
    begin
       SetCursorPos(CursorPos.X,CursorPos.Y);
    end
    else
    if StrButton='LeftDown'then
    begin
      SetCursorPos(CursorPos.X,CursorPos.Y);
      Mouse_Event(MOUSEEVENTF_LEFTDOWN,CursorPos.X, CursorPos.Y, 0, 0);
    end
    else
    if StrButton='RightDown' then
    begin
      SetCursorPos(CursorPos.X,CursorPos.Y);
      Mouse_Event(MOUSEEVENTF_RIGHTDOWN,CursorPos.X, CursorPos.Y, 0, 0)
    end
    else
    if StrButton='MiddleDown' then
    begin
      SetCursorPos(CursorPos.X,CursorPos.Y);
      Mouse_Event(MOUSEEVENTF_MIDDLEDOWN,CursorPos.X, CursorPos.Y, 0, 0);
    end
    else
    if StrButton='LeftUp'then
    begin
      SetCursorPos(CursorPos.X,CursorPos.Y);
      Mouse_Event(MOUSEEVENTF_LEFTUP,CursorPos.X, CursorPos.Y, 0, 0);
    end
    else
    if StrButton='RightUp' then
    begin
      SetCursorPos(CursorPos.X,CursorPos.Y);
      Mouse_Event(MOUSEEVENTF_RIGHTUP,CursorPos.X, CursorPos.Y, 0, 0);
    end
    else
    if StrButton='MiddleUp' then
    begin
      SetCursorPos(CursorPos.X,CursorPos.Y);
      Mouse_Event(MOUSEEVENTF_MIDDLEUP,CursorPos.X, CursorPos.Y, 0, 0);
    end;
  end
  else
  if Pos ('Key', StrCommand) = 1 then
  begin
    Key:=StrToInt(Copy(StrCommand,6,Length(StrCommand)));
    if Pos ('Dn'{Down}, StrCommand) = 4 then
    begin
      Keybd_event(Key, 0,0{KEYEVENTF_KEYDown}, 0);
    end
    else
    if Pos ('Up', StrCommand)=8 then
    begin
      Keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
    end
  end;
//    else if Pos ('DOUBL', strCommand) = 1 then
//       begin
//             SetCursorPos(CursorPos.X,CursorPos.Y);
//             Mouse_Event(MOUSEEVENTF_ABSOLUTE or
//                 MOUSEEVENTF_LEFTDOWN,CursorPos.X, CursorPos.Y, 0, 0);
//             Mouse_Event(MOUSEEVENTF_ABSOLUTE or
//                 MOUSEEVENTF_LEFTUP,CursorPos.X, CursorPos.Y, 0, 0);
//             Mouse_Event(MOUSEEVENTF_ABSOLUTE or
//                 MOUSEEVENTF_LEFTDOWN,CursorPos.X, CursorPos.Y, 0, 0);
//             Mouse_Event(MOUSEEVENTF_ABSOLUTE or
//                 MOUSEEVENTF_LEFTUP,CursorPos.X, CursorPos.Y, 0, 0);
//       end
//    else
//       begin
//          try
//            StrButton:=strCommand;
//            if s='VK_TAB' then begin b:=VK_TAB;SimulateKeystroke(b,0) end
//            else if s='VK_ESCAPE' then begin b:=VK_ESCAPE;SimulateKeystroke(b,0) end
//            else if s='VK_CAPITAL' then begin  b:=VK_CAPITAL;SimulateKeystroke(b,0) end
//            else if s='VK_HOME' then begin b:=VK_HOME;SimulateKeystroke(b,0) end
//            else if s='VK_END' then begin b:=VK_END;SimulateKeystroke(b,0) end
//            else if s='VK_INSERT' then begin b:=VK_INSERT;SimulateKeystroke(b,0) end
//            else if s='VK_DELETE' then begin b:=VK_DELETE;SimulateKeystroke(b,0) end
//            else if s='VK_SNAPSHOT' then begin b:=VK_SNAPSHOT;SimulateKeystroke(b,0) end
//            else if s='VK_NUMLOCK' then begin b:=VK_NUMLOCK;SimulateKeystroke(b,0) end
//            else if s='VK_UP' then begin b:=VK_UP;SimulateKeystroke(b,0) end
//            else if s='VK_DOWN' then begin b:=VK_DOWN;SimulateKeystroke(b,0) end
//            else if s='VK_LEFT' then begin b:=VK_LEFT;SimulateKeystroke(b,0) end
//            else if s='VK_RIGHT' then begin b:=VK_RIGHT;SimulateKeystroke(b,0) end
//            else Sendkeys(s);
//            s:='';
//         except
//            exit;
//         end;
end;

end.

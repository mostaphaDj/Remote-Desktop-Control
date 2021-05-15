object FormMainClient: TFormMainClient
  Left = 480
  Top = 0
  BiDiMode = bdLeftToRight
  Caption = 'FormMainClient'
  ClientHeight = 645
  ClientWidth = 528
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 529
    Height = 645
    Cursor = crNo
    AutoSize = True
  end
  object IdUDPServerScreenShots: TIdUDPServer
    BufferSize = 65507
    Bindings = <>
    DefaultPort = 7218
    OnUDPRead = IdUDPServerScreenShotsUDPRead
    Left = 56
    Top = 8
  end
  object UDPAntiFreeze: TIdAntiFreeze
    IdleTimeOut = 0
    Left = 55
    Top = 160
  end
  object IdUDPClientControl: TIdUDPClient
    Host = '127.0.0.1'
    Port = 7219
    Left = 56
    Top = 56
  end
  object MainMenu1: TMainMenu
    Left = 56
    Top = 216
    object File1: TMenuItem
      Caption = 'File'
      object Connect1: TMenuItem
        Caption = 'Connect'
        ShortCut = 49219
        OnClick = Connect1Click
      end
      object Disconnect1: TMenuItem
        Caption = 'Disconnect'
        Enabled = False
        ShortCut = 49220
        OnClick = Disconnect1Click
      end
      object Control1: TMenuItem
        Caption = 'Control'
        object Mouse1: TMenuItem
          Caption = 'Mouse'
          ShortCut = 49229
          OnClick = Mouse1Click
        end
        object Keyboard1: TMenuItem
          Caption = 'Keyboard'
          ShortCut = 49227
          OnClick = Keyboard1Click
        end
      end
      object FullScreen1: TMenuItem
        Caption = 'Full Screen'
        ShortCut = 32781
        OnClick = FullScreen1Click
      end
      object Connection1: TMenuItem
        Caption = 'Connection...'
        ShortCut = 49230
        OnClick = Connection1Click
      end
      object Options1: TMenuItem
        Caption = 'Quality/Performance...'
        GroupIndex = 2
        ShortCut = 49233
        OnClick = Options1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        GroupIndex = 2
        ShortCut = 49274
        OnClick = Exit1Click
      end
    end
  end
  object IdTCPClientOptiorus: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 7220
    ReadTimeout = -1
    Left = 55
    Top = 108
  end
end

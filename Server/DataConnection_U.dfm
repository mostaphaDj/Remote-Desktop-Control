object DataConnection: TDataConnection
  OldCreateOrder = False
  Height = 239
  Width = 125
  object IdUDPClientScreenShots: TIdUDPClient
    BufferSize = 65507
    Host = '127.0.0.1'
    Port = 7218
    ReceiveTimeout = 0
    Left = 48
    Top = 8
  end
  object UDPAntiFreeze: TIdAntiFreeze
    IdleTimeOut = 0
    Left = 48
    Top = 160
  end
  object IdUDPServerControl: TIdUDPServer
    Bindings = <>
    DefaultPort = 7219
    OnUDPRead = IdUDPServerControlUDPRead
    Left = 48
    Top = 64
  end
  object IdTCPServerOptiorus: TIdTCPServer
    Active = True
    Bindings = <>
    DefaultPort = 7220
    OnConnect = IdTCPServerOptiorusConnect
    OnDisconnect = IdTCPServerOptiorusDisconnect
    OnExecute = IdTCPServerOptiorusExecute
    Left = 48
    Top = 112
  end
end

object FormConnectionOptions: TFormConnectionOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsDialog
  Caption = 'Connection Options'
  ClientHeight = 142
  ClientWidth = 256
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 240
    Height = 97
    Caption = 'Connection'
    TabOrder = 0
    object Label1: TLabel
      Left = 14
      Top = 19
      Width = 65
      Height = 13
      Caption = 'Host Remote '
    end
    object Label2: TLabel
      Left = 14
      Top = 46
      Width = 106
      Height = 13
      Caption = 'Port UDP ScreenShots'
    end
    object Label3: TLabel
      Left = 14
      Top = 71
      Width = 81
      Height = 13
      Caption = 'Port UDP Control'
    end
    object ComboBoxHostRemote: TComboBox
      Left = 143
      Top = 16
      Width = 89
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'PC-Mostapha'
      Items.Strings = (
        'PC-Mostapha'
        'PC-Virtual'
        'Pc-belkacem')
    end
    object EditPortUDPControl: TEdit
      Left = 143
      Top = 68
      Width = 89
      Height = 21
      TabOrder = 1
    end
    object EditPortUDPScreenShots: TEdit
      Left = 143
      Top = 43
      Width = 89
      Height = 21
      TabOrder = 2
    end
  end
  object ButtonApply: TButton
    Left = 173
    Top = 111
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 1
    OnClick = ButtonApplyClick
  end
  object ButtonCancel: TButton
    Left = 91
    Top = 111
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = ButtonCancelClick
  end
  object ButtonOK: TButton
    Left = 8
    Top = 111
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = ButtonOKClick
  end
end

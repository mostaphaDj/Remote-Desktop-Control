object FormQualityPerformanceOptions: TFormQualityPerformanceOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsDialog
  Caption = 'Options Quality / Performance'
  ClientHeight = 232
  ClientWidth = 289
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
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 273
    Height = 185
    Caption = 'Quality / Performance'
    TabOrder = 0
    object LabelQuality: TLabel
      Left = 12
      Top = 20
      Width = 34
      Height = 13
      Caption = 'Quality'
    end
    object Label5: TLabel
      Left = 12
      Top = 79
      Width = 30
      Height = 13
      Caption = 'Speed'
    end
    object GroupBoxCompressionDecompression: TGroupBox
      Left = 8
      Top = 135
      Width = 257
      Height = 42
      Caption = 'Compression/Decompression'
      TabOrder = 0
      object CheckBoxGrayScale: TCheckBox
        Left = 16
        Top = 15
        Width = 113
        Height = 21
        Caption = 'Gray Scale'
        TabOrder = 0
      end
      object CheckBoxProgressiveEncoding: TCheckBox
        Left = 123
        Top = 17
        Width = 129
        Height = 18
        Caption = 'Progressive Encoding'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
    end
    object TrackBarQuality: TTrackBar
      Left = 3
      Top = 39
      Width = 267
      Height = 34
      Max = 100
      Min = 1
      Position = 20
      TabOrder = 1
    end
  end
  object ButtonApply: TButton
    Left = 206
    Top = 199
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 1
    OnClick = ButtonApplyClick
  end
  object ButtonCancel: TButton
    Left = 125
    Top = 199
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = ButtonCancelClick
  end
  object ButtonOK: TButton
    Left = 44
    Top = 199
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = ButtonOKClick
  end
  object TrackBarSpeed: TTrackBar
    Left = 11
    Top = 105
    Width = 267
    Height = 34
    Max = 1000
    Position = 1000
    TabOrder = 4
  end
end

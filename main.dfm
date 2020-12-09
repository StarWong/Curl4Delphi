object mainform: Tmainform
  Left = 0
  Top = 0
  Caption = 'curl_download'
  ClientHeight = 399
  ClientWidth = 717
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 128
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 232
    Top = 32
    Width = 75
    Height = 25
    Caption = #35299#21387
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 350
    Top = 32
    Width = 75
    Height = 25
    Caption = 'classinfo'
    TabOrder = 2
  end
  object Button4: TButton
    Left = 15
    Top = 32
    Width = 75
    Height = 25
    Caption = 'DLoad'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 608
    Top = 32
    Width = 89
    Height = 25
    Caption = 'DoDownLoad'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clFuchsia
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object StaticText3: TStaticText
    Left = 17
    Top = 208
    Width = 41
    Height = 41
    AutoSize = False
    Caption = 'Log:'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 5
  end
  object Button6: TButton
    Left = 496
    Top = 32
    Width = 75
    Height = 25
    Caption = 'debug'
    TabOrder = 6
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 634
    Top = 159
    Width = 75
    Height = 25
    Caption = #26032#22686#19979#36733
    TabOrder = 7
    OnClick = Button7Click
  end
  object lv1: TListView
    Left = 64
    Top = 190
    Width = 625
    Height = 185
    Columns = <
      item
        Caption = ' '#20219#21153#21495
        Width = 60
      end
      item
        AutoSize = True
        Caption = '01'
      end
      item
        Caption = #24050#19979#36733
        Width = 60
      end
      item
        Caption = '111111111111'
        Width = 90
      end
      item
        Caption = #23383#33410
      end
      item
        Caption = #29366#24577
      end
      item
        Caption = 'aaaaaaaaaaaaaaaaaaaaaaaaa'
        Width = 280
      end>
    DoubleBuffered = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    ShowColumnHeaders = False
    TabOrder = 8
    ViewStyle = vsReport
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 656
    Top = 104
  end
end

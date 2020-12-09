object NewTaskForm: TNewTaskForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'NewTask'
  ClientHeight = 136
  ClientWidth = 806
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 24
    Top = 24
    Width = 21
    Height = 17
    Caption = 'Url:'
    TabOrder = 0
  end
  object RzEdit1: TRzEdit
    Left = 51
    Top = 20
    Width = 718
    Height = 21
    TabOrder = 1
  end
  object StaticText2: TStaticText
    Left = 24
    Top = 64
    Width = 41
    Height = 17
    Caption = 'saveto:'
    TabOrder = 2
  end
  object RzButtonEdit1: TRzButtonEdit
    Left = 67
    Top = 60
    Width = 702
    Height = 21
    TabOrder = 3
    OnButtonClick = RzButtonEdit1ButtonClick
  end
  object RzButton1: TRzButton
    Left = 512
    Top = 93
    Caption = 'Add'
    TabOrder = 4
    OnClick = RzButton1Click
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 688
    Top = 88
  end
end

unit AddTask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, RzEdit, RzBtnEdt, RzButton;

type
  TNewTaskForm = class(TForm)
    StaticText1: TStaticText;
    RzEdit1: TRzEdit;
    StaticText2: TStaticText;
    RzButtonEdit1: TRzButtonEdit;
    RzButton1: TRzButton;
    FileOpenDialog1: TFileOpenDialog;
    procedure RzButton1Click(Sender: TObject);
    procedure RzButtonEdit1ButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private

  public
  url:AnsiString;
  fileDir:string;
  end;

var
  NewTaskForm: TNewTaskForm;

implementation
uses
Logger;
{$R *.dfm}





procedure TNewTaskForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if Self.ModalResult <> mrOk then
  Self.ModalResult:= mrCancel;
end;

procedure TNewTaskForm.RzButton1Click(Sender: TObject);
begin
     url:=Self.RzEdit1.Text;
     fileDir:=Self.RzButtonEdit1.Text;
     Self.ModalResult:=mrOk;
end;

procedure TNewTaskForm.RzButtonEdit1ButtonClick(Sender: TObject);
 begin
 FileOpenDialog1.Options:= [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
 if FileOpenDialog1.Execute then
 begin
 RzButtonEdit1.Text:=FileOpenDialog1.FileName;
 end;
end;


end.

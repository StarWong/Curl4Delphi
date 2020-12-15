unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TypInfo, Rtti, Mask, RzEdit, RzBtnEdt, RzShellDialogs,Download,
  ComCtrls, RzListVw,Generics.Collections;
{$M+}
{$M-}
//https://onedrive.live.com/embed?cid=5C35A253395FC77B&resid=5C35A253395FC77B%21141&authkey=ABWH2cHjKe3AC_Q

//http://storage.live.com/items/5C35A253395FC77B%21141?authkey=ABWH2cHjKe3AC_Q

type
  Tmainform = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    StaticText3: TStaticText;
    FileOpenDialog1: TFileOpenDialog;
    Button6: TButton;
    Button7: TButton;
    lv1: TListView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
  msgInfo:TMsgInfo;
  public
    procedure DoMsg(var msg:TMsgInfo);
    function GetFileExtension(const content:AnsiString;out Extension:AnsiString):LongBool;
    procedure Updata(var msg:TMsgInfo);
  end;

var
  mainform: Tmainform;
  List:TDictionary<TDownLoadlauncher,Cardinal>;
implementation

uses
  Logger,Curl,PerlRegEx,SyncObjs,AddTask,UIntUtils,sevenzip;
{$R *.dfm}

type

  PFile = ^TFileStream;

var
  t: UInt64;

  FMCSLock,LVLcok:TCriticalSection;
procedure AddIndex(info:TDownLoadlauncher);
var
Count:Cardinal;
begin
    FMCSLock.Enter;
     count:=List.Count;
     List.Add(info,Count);
    FMCSLock.Leave;
end;

function GetIndex(info:TDownLoadlauncher):Cardinal;
begin
    FMCSLock.Enter;
     Result:=List[info];
    FMCSLock.Leave;
end;

procedure RemoveIndex(info:TDownLoadlauncher);
begin
    FMCSLock.Enter;
   List.Remove(info);
    FMCSLock.Leave;
end;



function DecoeData: LongBool;
var
  f: string;
begin
  f := ExtractFilePath(ParamStr(0));
  with CreateInArchive(CLSID_CFormatZip) do
  begin
    SetPassword('wiki.guildwars.com');
    OpenFile(f + 'GTBX.bin');
    ExtractTo(f);
  end;
end;

function RecvData(data: Pointer; size: Cardinal; nmemb: Cardinal;
  user_p: TMemoryStream): Cardinal; cdecl;

begin
Result:=nmemb*size;
user_p.WriteBuffer(data^,Result);
end;



procedure Tmainform.Button1Click(Sender: TObject);
const
  // webSite:AnsiString ='https://github.com/HasKha/GWToolboxpp/releases/download/4.2_Release/GWToolboxdll.dll';
  webSite: AnsiString =
    'http://altd.embarcadero.com/devsupport/delphi/d7/update1r2/Delphi_71_Ent_Update_Inline/d7_ent_upd1_1.exe';
  header: AnsiString =
    'User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko';
  // header:AnsiString = 'curl/7.71.1';
var
  curl: Integer;
  retCode: TCurlCode;
  header_list: Pcurl_slist;
  f: TMemoryStream;
  size: Double;
  code: Integer;
begin
  F:=TMemoryStream.Create;
  try
   curl_global_init(CURL_GLOBAL_ALL);
   Log(curl_version);

    curl := curl_easy_init();
    Log('curl_easy_init:' + IntToHex(curl, 8));

    {
      retCode:=curl_easy_set_integer(curl,CURLOPT_PROTOCOLS,1 shr 0);
      Log('CURLOPT_PROTOCOLS:' + IntToStr(Integer(retCode)));


      retCode:=curl_easy_set_integer(curl,CURLOPT_HTTPGET,1);
      Log('CURLOPT_HTTPGET:' + IntToStr(Integer(retCode)));

    header_list := nil;
    header_list := curl_slist_append(header_list, @header[1]);
    Log('curl_slist_append:' + IntToHex(Cardinal(header_list), 8));

    retCode := curl_easy_set_pointer(curl, CURLOPT_HTTPHEADER, header_list);
    Log('CURLOPT_HTTPHEADER:' + IntToStr(Integer(retCode)));

    retCode := Curl_Easy_set_PAnsiChar(curl, CURLOPT_URL, PAnsiChar(@webSite[1]));
    Log('CURLOPT_URL:' + IntToStr(Integer(retCode)));

    //retCode := curl_easy_set_integer(curl, CURLOPT_HEADER, 1);
    //Log('CURLOPT_HEADER:' + IntToStr(Integer(retCode)));

    retCode := curl_easy_set_integer(curl, CURLOPT_NOBODY, 1);
    Log('CURLOPT_HEADER:' + IntToStr(Integer(retCode)));

    retCode := curl_easy_set_integer(curl, CURLOPT_FOLLOWLOCATION, 1);
    Log('CURLOPT_FOLLOWLOCATION:' + IntToStr(Integer(retCode)));


      retCode:=curl_easy_set_integer(curl,CURLOPT_SSL_VERIFYPEER,0);
      Log('CURLOPT_SSL_VERIFYPEER:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_integer(curl,CURLOPT_SSL_VERIFYHOST,0);
      Log('CURLOPT_SSL_VERIFYHOST:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_integer(curl,CURLOPT_VERBOSE,0);
      Log('CURLOPT_VERBOSE:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_pointer(curl,CURLOPT_READFUNCTION,nil);
      Log('CURLOPT_READFUNCTION:' + IntToStr(Integer(retCode)));


      retCode:=curl_easy_set_pointer(curl,CURLOPT_WRITEFUNCTION,@RecvData);
      Log('CURLOPT_WRITEFUNCTION:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_integer(curl,CURLOPT_MAXREDIRS,5);
      Log('CURLOPT_MAXREDIRS:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_integer(curl,CURLOPT_FOLLOWLOCATION,1);
      Log('CURLOPT_FOLLOWLOCATION:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_pointer(curl,CURLOPT_PROGRESSFUNCTION,@ProgressCallback);
      Log('CURLOPT_PROGRESSFUNCTION:' + IntToStr(Integer(retCode)));
        retCode:=curl_easy_set_pointer(curl,CURLOPT_PROGRESSDATA,Self);
      Log('CURLOPT_PROGRESSDATA:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_pointer(curl,CURLOPT_WRITEDATA,F);
      Log('CURLOPT_FILE:' + IntToStr(Integer(retCode)));
      f.Position:=0;

      retCode:=curl_easy_set_integer(curl,CURLOPT_NOPROGRESS,0);
      Log('CURLOPT_NOPROGRESS:' + IntToStr(Integer(retCode)));




      retCode:=curl_easy_set_integer(curl,CURLOPT_NOSIGNAL,1);
      Log('CURLOPT_NOSIGNAL:' + IntToStr(Integer(retCode)));


      retCode:=curl_easy_set_integer(curl, CURLOPT_CONNECTTIMEOUT,0); //CONN TIME OUT
      Log(' CURLOPT_CONNECTTIMEOUT:' + IntToStr(Integer(retCode)));


      retCode:=curl_easy_set_integer(curl,CURLOPT_CONNECTTIMEOUT_MS,0); //CONN TIME OUT
      Log('CURLOPT_CONNECTTIMEOUT_MS:' + IntToStr(Integer(retCode)));


      retCode:=curl_easy_set_integer(curl,CURLOPT_TIMEOUT_MS,0);//TIMEOUT
      Log('CURLOPT_TIMEOUT_MS:' + IntToStr(Integer(retCode)));

      retCode:=curl_easy_set_integer(curl,CURLOPT_TIMEOUT,0);
      Log('CURLOPT_TIMEOUT:' + IntToStr(Integer(retCode)));

    }
      t:=GetTickCount;

    retCode := curl_easy_perform(curl);
    Log('curl_easy_perform:' + IntToStr(Integer(retCode)));


    retCode := curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, @code);
    Log('CURLINFO_RESPONSE_CODE:' + IntToStr(Integer(code)));

    f.SaveToFile('this.iso');
    curl_easy_cleanup(curl);
    curl_global_cleanup();
  finally
     F.Free;
  end;

end;

procedure Tmainform.Button2Click(Sender: TObject);
var
  f: string;
begin
  f := ExtractFilePath(ParamStr(0));
  with CreateInArchive(CLSID_CFormatZip) do
  begin
    SetPassword('wiki.guildwars.com');
    OpenFile(f + 'GTBX.bin');
    ExtractTo(f);
  end;
end;

procedure Tmainform.Button4Click(Sender: TObject);
begin
test;
//DownloadFile('http://cg.ys168.com/f_ht/ajcx/ml.aspx?cz=ml_dq&_dlmc=scxs&_dlmm=',ExtractFilePath(ParamStr(0)) + 'abc.txt')
end;

procedure Tmainform.Button6Click(Sender: TObject);
const
int64_max : int64 = 9223372036854775807;
var
i,ii:Int64;
u:UInt64;
begin
    i:=int64_max;
    Move(i,u,8);                      //bit(0) + 63 bit(1)->  i = u = 9223372036854775807
 InterlockedExchangeAdd64(u,1);
    Move(u,i,8);                      //bit(1) + 63 bit(0)->  i = -1;u = 9223372036854775807+1
 Sleep(0);
end;                                  //int64: from 0->9223372036854775807->           -1      ->-9223372036854775807
                                      //Uint64 from 0->9223372036854775807->9223372036854775808->18446744073709551615
                                      //memory from 64bit(0)->64bit(1)


procedure Tmainform.Button7Click(Sender: TObject);
var
FTask:TNewTaskForm;
down:TDownLoadlauncher;
begin
     FTask:= TNewTaskForm.Create(Self);

     try
       if  FTask.ShowModal <> mrOk then  Exit;
        down:=TDownLoadlauncher.Create;
        down.fileUrl:=FTask.url;
        down.OutFileDir:=FTask.fileDir;
        down.Progresser:=Self.Updata;
        AddIndex(down);
        down.Resume;
     finally
        FTask.Free;
     end;
end;

procedure Tmainform.DoMsg(var msg: TMsgInfo);
begin
{
     case msg.typeID of
      MsgType.err:begin
         Self.Memo1.Lines.Add('发送错误: ' + msg.dynamicData + ' 字节');
        end;
      MsgType.downloading:
        begin
         Self.Memo1.Lines.Add('已下载: ' + IntToStr(Cardinal(msg.staticData)) + ' 字节');
        end;
      MsgType.fileSizeInfo:
      begin
        Self.Memo1.Lines.Add('文件大小: ' + IntToStr(Cardinal(msg.staticData)) + ' 字节');
      end;
      MsgType.finish:
      begin
        Self.Memo1.Lines.Add('下载完成');
      end;
      MsgType.Start:
      begin
        Self.Memo1.Lines.Add('下载开始');
      end
        else
        begin

        end;
     end;

     }
end;

function Tmainform.GetFileExtension(const content:AnsiString;out Extension:AnsiString):LongBool;
var
reg:TPerlRegEx;
index,ret:Cardinal;
pContent:PAnsiChar;
begin
Result:=False;
reg:=TPerlRegEx.Create;
try
reg.Subject:=content;
reg.RegEx:='((http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?)';
if reg.Match then
begin
      ret:=0;
     // index:=0;
      repeat
      pContent:=@Content[ret+1];
     index:=Pos('/',pContent);
     if index <> 0 then
     Inc(ret,index);
      until index = 0;
      if ret<> 0 then
      begin
           if Pos('.',pContent) <> 0 then
           begin
             Extension:= pContent;
             Result:=True;
           end;
      end;
end;
finally
  reg.Free;
end;
end;



procedure Tmainform.Updata(var msg: TMsgInfo);
var
  Item: TListItem;
begin

  try
 // Self.ActiveControl:=lv1;
 // lv1.ItemIndex:=0;
  if (lv1.FindCaption(GetIndex(msg.classAddr) + 1, Trim('任务号'), True, True, True) = nil) then
    begin
      lv1.Items.BeginUpdate;
      Item := lv1.Items.Add;
      Item.Caption := '任务号:';
      Item.SubItems.Add(IntToStr(GetIndex(msg.classAddr)));//SubItems:0
      Item.SubItems.Add('已下载:'); //1
      Item.SubItems.Add(''); //SubItems:2
      Item.SubItems.Add('字节'); //SubItems:3
      Item.SubItems.Add('状态:');//4
      Item.SubItems.Add('准备');//SubItems:5
      lv1.Items.EndUpdate;

    end
    else
    begin

      Item := (lv1.FindCaption(GetIndex(msg.classAddr), Trim('任务号'), True, True, True));
      Item.SubItems.Strings[0]:= IntToStr(GetIndex(msg.classAddr));

     // LockWindowUpdate(lv1.Handle);
      lv1.Items.BeginUpdate;
      case msg.typeID of
      MsgType.err:begin
       Item.SubItems.Strings[5] :='发生错误: ' + msg.dynamicData;
       end;
      MsgType.downloading:
        begin
         Item.SubItems.Strings[2] := UIntToStr(Cardinal(msg.staticData));
         Item.SubItems.Strings[5] :='下载中...';
        end;
      MsgType.fileSizeInfo:
      begin
        Item.SubItems.Strings[5]:='文件大小: ' + UIntToStr(Cardinal(msg.staticData)) + ' 字节';
      end;
      MsgType.finish:
      begin
        Item.SubItems.Strings[2]:=UIntToStr(Cardinal(msg.staticData));
        Item.SubItems.Strings[5]:='下载完成';
      end;
      MsgType.Start:
      begin
        Item.SubItems.Strings[5]:='下载开始';
      end;
      MsgType.abort:
      begin
        Item.SubItems.Strings[5]:='下载中断';
      end;
        else
        begin
          Item.SubItems.Strings[5]:='下载中';
        end;
     end;


      lv1.Items.EndUpdate;
    //  LockWindowUpdate(0);

    end;
  finally

  end;
end;

function GetVarNames(const AClass: TObject): TStringList;
var
  lType: TRttiType;
  lContext: TRttiContext;
  lProperty: TRttiProperty;
  lField: TRttiField;
begin
  Result := TStringList.create;
  lType := lContext.GetType(AClass.ClassType);
  if assigned(lType) then
  begin
    for lProperty in lType.GetProperties do
    begin
      Result.Add(lProperty.Name);
      // Get current value:
      Result.Add(lProperty.GetValue(AClass).ToString);
    end;
    for lField in lType.GetFields do
    begin
      Result.Add(lField.Name);
      // Get current value:
      Result.Add(lField.GetValue(AClass).ToString);
    end;
  end;
end;

initialization

t := GetTickCount;
FMCSLock:=TCriticalSection.Create;
//LVLcok:=TCriticalSection.Create;
List:=TDictionary<TDownLoadlauncher,Cardinal>.Create;
finalization
FMCSLock.Free;
//LVLcok.Free;
List.Free;
end.

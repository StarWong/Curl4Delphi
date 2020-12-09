unit Download;
 {$WARN CONSTRUCTING_ABSTRACT OFF}
interface

uses
  Classes, CurlDownLoadCore;

// function DownloadFile(const fileUrl:AnsiString;const outFileDir:string):LongBool;
type
  TMsgType = Cardinal;

  MsgType = class
  public const
    err = 0;

  const
    fileSizeInfo = 5;

  const
    downloading = 1;

  const
    start = 2;

  const
    finish = 3;

  const
    abort = 4;

  const
    ReTry = 5;
  end;

  TMsgInfo = record
    classAddr: Pointer;
    typeId: TMsgType;
    case Integer of
      0:
        (dynamicData: PAnsiChar);
      1:
        (staticData: UInt64)
  end;

  TSenderFunc = procedure(var msg: TMsgInfo) of object;

  TAsyncFileDownloader = class;

  TAsyncFileDownloader = class(TAsyncRestClient)

  strict private
    m_RemoteFileSize: UInt64;
    m_DownloadLength: UInt64;
    m_FileName: string;
    CanDoAcquireViaRanges: LongBool;
  strict private
    procedure OnContent(const buffer: PAnsiChar; const Count: size_t); override;
    procedure OnHeader(const buffer: PAnsiChar; const Count: size_t); override;
  public
    constructor Create; overload;
    destructor Destroy; override;
    procedure Free; overload;
    function GetDownloadCount: UInt64; inline;
    function GetFileSize: UInt64; inline;
    procedure SaveFile(const fileFullPath: string); override;
    procedure ReTry; override;
  end;

  TDownLoadlauncher = class;

  TDownLoadlauncher = class(TThread)
  strict private
    m_OutFileDir: string;
    m_fileUrl: AnsiString;
    m_Progresser: TSenderFunc;
    msgInfo: TMsgInfo;
    maxReTryCount: Cardinal;
    ReTryTimeTictCount: Cardinal;
  strict private
    Async: TAsyncFileDownloader;
  strict private
    function AsyncDownloadFile: LongBool;
    procedure SendMsgToUI;
  strict private
    procedure SendStatus(const typeId: TMsgType; const value: UInt64);
      overload; inline;
    procedure SendStatus(const typeId: TMsgType; const value: AnsiString);
      overload; inline;
    procedure SendFileSize; inline;
  public
    constructor Create; overload;
    destructor Destroy; override;
  protected
    procedure execute; override;
  public
    property OutFileDir: string write m_OutFileDir;
    property fileUrl: AnsiString write m_fileUrl;
    property Progresser: TSenderFunc write m_Progresser;
  end;

procedure test;

implementation

uses
  Logger, PerlRegEx, Windows, SysUtils, UIntUtils, Dialogs;


// function InterlockedExchangeAdd64(Target:PUInt64;Value:UInt64):UInt64;
// stdcall;external kernel32 name 'InterlockedExchangeAdd64';

function GetMenuId(const context: String): string;
var
  reg: TPerlRegEx;
begin
  reg := TPerlRegEx.Create;
  try
    reg.Subject := context;
    reg.RegEx :=
      '<li id="ml_([0-9]+)" class="gml">(<[^<>]+>){3}GTBX</a><label></label>';
    if reg.Match then
    begin
      reg.Subject := reg.MatchedText;
      reg.RegEx := '<li id="ml_([0-9]+)"';
      if reg.Match then
      begin
        reg.Subject := reg.MatchedText;
        reg.RegEx := '([0-9]+)';
        if reg.Match then
        begin
          Result := reg.MatchedText;
        end;

      end;

    end
    else
      Result := '';
  finally
    reg.Free;
  end;
end;

function GetFileWebLink(const context: String): string;
var
  reg: TPerlRegEx;
begin
  reg := TPerlRegEx.Create;
  try
    reg.Subject := context;
    reg.RegEx := '<a href="([^<>]+)">000000.bin</a>';
    if reg.Match then
    begin
      reg.Subject := reg.MatchedText;
      reg.RegEx := '"([^"]+)/000000.bin"';
      if reg.Match then
      begin
        reg.Subject := reg.MatchedText;
        reg.RegEx := '([^"]+)';
        if reg.Match then
        begin
          Result := reg.MatchedText;
        end;

      end;

    end
    else
      Result := '';
  finally
    reg.Free;
  end;
end;

{
  function DownloadFile(const fileUrl:AnsiString;const outFileDir:string):LongBool;
  var
  client:TRestClient;
  begin
  client:=TRestClient.Create;
  try
  client.SetUrl(fileUrl);
  client.SetVerifyPeer(False);
  client.SetTimeoutSec(5);
  client.SetUserAgent('curl/7.71.1');
  client.Execute;
  if not client.IsSuccessful then Printf(client.GetStatus,client.GetStatusStr);
  client.SaveFile(outFileDir);
  finally
  client.Free;
  end;
  end;
}
function TDownLoadlauncher.AsyncDownloadFile: LongBool;
begin
  with Self.Async do
  begin
    SetUrl(m_fileUrl);
    SetVerifyPeer(false);
    SetFollowLocation(True);
    SetUserAgent('curl/7.71.1');
    ExecuteAsync;
  end;

end;

function ys168_GetMainMenuID(out content: string): LongBool;
var
  client: TRestClient;
begin
  Result := false;
  client := TRestClient.Create;
  try
    client.SetUrl(
      'http://cg.ys168.com/f_ht/ajcx/ml.aspx?cz=ml_dq&_dlmc=scxs&_dlmm=');
    client.SetVerifyPeer(false);
    client.SetTimeoutSec(5);
    client.SetUserAgent('curl/7.71.1');
    client.SetHeader(
      'Referer: http://cg.ys168.com/f_ht/ajcx/000ht.html?bbh=1134');
    client.execute;
    if not client.IsSuccessful then
      Printf(client.GetStatus, client.GetStatusStr)
    else
      Result := True;
    content := GetMenuId(client.GetContent);
  finally
    client.Free;
  end;
end;

function ys168_GetFileUrl(const id: string; out downLoadUrl: string): LongBool;
var
  client: TRestClient;
begin
  Result := false;
  client := TRestClient.Create;
  try
    client.SetUrl('http://cg.ys168.com/f_ht/ajcx/wj.aspx?cz=dq&mlbh=' + id +
        '&_dlmc=scxs&_dlmm=');
    client.SetVerifyPeer(false);
    client.SetTimeoutSec(5);
    client.SetUserAgent('curl/7.71.1');
    client.SetHeader(
      'Referer: http://cg.ys168.com/f_ht/ajcx/000ht.html?bbh=1134');
    client.execute;
    if not client.IsSuccessful then
      Printf(client.GetStatus, client.GetStatusStr)
    else
      Result := True;
    downLoadUrl := client.GetContent;
  finally
    client.Free;
  end;

end;

procedure test;
var
  content: string;
  fileUrl: string;
  down: TDownLoadlauncher;
begin
  ys168_GetMainMenuID(content);
  ys168_GetFileUrl(content, fileUrl);
  down := TDownLoadlauncher.Create;
  down.fileUrl := GetFileWebLink(fileUrl);
  down.OutFileDir := '123456.bin';
  down.Resume;
end;

{ TAsyncFileDownloader }

constructor TAsyncFileDownloader.Create;
begin
  inherited Create;
  Self.m_DownloadLength := 0;
  Self.m_FileName := '';
  Self.m_RemoteFileSize := 0;
end;

destructor TAsyncFileDownloader.Destroy;
begin
  inherited Destroy;
end;

procedure TAsyncFileDownloader.Free;
begin
  if Self <> nil then
    Self.Destroy;
end;

function TAsyncFileDownloader.GetDownloadCount: UInt64;
begin
  // Result:=Self.m_DownloadLength;
  Move(Self.m_DownloadLength, Result, 8);
end;

function TAsyncFileDownloader.GetFileSize: UInt64;
begin
  // Result:=Self.m_RemoteFileSize;
  Move(Self.m_RemoteFileSize, Result, 8);
end;

procedure TAsyncFileDownloader.OnContent(const buffer: PAnsiChar;
  const Count: size_t);
begin
  inherited OnContent(buffer, Count);
  InterlockedExchangeAdd64(Self.m_DownloadLength, Count);
end;

procedure TAsyncFileDownloader.OnHeader(const buffer: PAnsiChar;
  const Count: size_t);
const
  SizeMark: AnsiString = 'Content-Length: '; // 16+1 bytes
  NameMark: AnsiString = 'Content-Disposition: ';
  RangesMark: AnsiString = 'Accept-Ranges: ';
var
  content: AnsiString;
  fileSize: UInt64;
  index, tmpIndex: Cardinal;
  str_len: AnsiString;
begin
  inherited OnHeader(buffer, Count);
  SetString(content, buffer, Count);
  if StartsWith(content, SizeMark) then // 16 bytes
  begin
    if Count > 16 then
    begin
      fileSize := 0;
      // str_len:=Copy(content,17,Count - 16 + 2);
      SetString(str_len, buffer + 16, Count - 16 - 2);
      if TryStrToUInt64(str_len, fileSize) then
      begin
        InterlockedExchangeAdd64(m_RemoteFileSize, fileSize);
        Printf(fileSize, 'recv filesize:');
      end
      else
        Printf(fileSize, 'Failed On convert');
    end;
  end
  else if StartsWith(content, NameMark) then
  begin
    index := Pos('filename="', content);
    if index > 0 then
    begin
      tmpIndex := index;
      index := Pos('"', PAnsiChar(@content[tmpIndex + 10]));
      if index > 1 then
      begin
        Self.m_FileName := Copy(PAnsiChar(@content[tmpIndex + 10]), 1,
          index - 1);
      end;
    end;
  end
  else if StartsWith(content, RangesMark) then
  begin
    if Pos('bytes', content) <> 0 then
      CanDoAcquireViaRanges := True;
  end;

end;

procedure TAsyncFileDownloader.SaveFile(const fileFullPath: string);
var
  tmpDir: string;
begin
  if Not EndsWith(fileFullPath, '/') then
    tmpDir := fileFullPath + '/'
  else
    tmpDir := fileFullPath;
  if m_FileName <> '' then
  begin
    if m_fileName_Local <> '' then
    begin
      if SameText(m_fileName_Local, m_FileName) then
        Printf('The Server Sended the name:' + m_FileName +
            'not equl to the local name :' + m_fileName_Local);
    end;
    inherited SaveFile(fileFullPath + m_FileName)
  end
  else
  begin
    if m_fileName_Local <> '' then
    begin
      inherited SaveFile(fileFullPath + m_fileName_Local);
    end
    else
    begin
      inherited SaveFile(fileFullPath + 'unKnow');
    end;
  end;
end;

procedure TAsyncFileDownloader.ReTry;
var
 ranges:AnsiString;
begin
  inherited ReTry;
  if Self.m_RemoteFileSize <> 0 then
  begin
   ranges:=UIntToStr(Self.m_DownloadLength + 1) + '-' + UIntToStr
    (m_RemoteFileSize);
  end
  else
    ranges:=UIntToStr(Self.m_DownloadLength + 1) + '-';
    SetRanges(ranges);
end;

{ TDownLoadlauncher }

constructor TDownLoadlauncher.Create;
begin
  inherited Create(True);
  Async := TAsyncFileDownloader.Create;
  Self.msgInfo.classAddr := Self;
  Self.msgInfo.typeId := $FFFFFFFF;
  Self.maxReTryCount:=5;
  Self.ReTryTimeTictCount:=1000;
end;

destructor TDownLoadlauncher.Destroy;
begin
  Async.Free;
  inherited;
end;

procedure TDownLoadlauncher.execute;
const
  perSleepCount: Cardinal = 20;
var
  Count: Cardinal;
  ReTryCount: Cardinal;
  ReTryTimeTict: Cardinal;
begin
  inherited;
  FreeOnTerminate := True;
  Self.SendStatus(MsgType.start, 0);
  Self.AsyncDownloadFile;
  Self.SendFileSize;
  Count := 0;
  ReTryCount := 0;
  ReTryTimeTict := GetTickCount;
  while not Terminated do
  begin
    if Count >= perSleepCount then
    begin
      if Self.Async.IsCompleted then
      begin
        if Self.Async.IsSuccessful then
        begin
          Self.SendStatus(MsgType.finish, Async.GetDownloadCount);
          Self.Async.SaveFile(m_OutFileDir);
          Break;
        end
        else
        begin
          if Self.Async.GetStatus = ResponseStatus.RecvError then
          begin
          Printf('rer');
            if ReTryCount > maxReTryCount then
            begin
            Printf('rer3');
              Self.SendStatus(MsgType.abort, Async.GetDownloadCount);
              Break;
            end
            else
            begin
            Printf('rer1');
              if GetTickCount > ReTryTimeTict then
              begin
                if (GetTickCount - ReTryTimeTict) > ReTryTimeTictCount then
                begin
                Printf('rer2');
                  Inc(ReTryCount);
                  Self.Async.ReTry;
                  Self.Async.ExecuteAsync;
                  Self.SendStatus(MsgType.ReTry, ReTryCount);
                end;
              end;
            end;
          end
          else
          begin
            Self.SendStatus(MsgType.abort, Async.GetDownloadCount);
            Break;
          end;
        end;
      end
      else
      begin
        ReTryCount := 0;
        ReTryTimeTict := GetTickCount;
        Self.SendStatus(MsgType.downloading, Async.GetDownloadCount);
      end;
      Count := 0;
    end
    else
      Inc(Count);
    Sleep(50);
  end;

end;

procedure TDownLoadlauncher.SendFileSize;
var
  I: Cardinal;
begin

  for I := 0 to 99 do
  begin
    if Async.GetFileSize > 0 then
    begin
      Self.SendStatus(MsgType.fileSizeInfo, Async.GetFileSize);
      Exit;
    end;
    Sleep(50);
  end;
  Self.SendStatus(MsgType.err, 'can get file size');

end;

procedure TDownLoadlauncher.SendMsgToUI;
begin
  if Assigned(Self.m_Progresser) then
    Self.m_Progresser(Self.msgInfo);
end;

procedure TDownLoadlauncher.SendStatus(const typeId: TMsgType;
  const value: AnsiString);
begin
  Self.msgInfo.typeId := typeId;
  Self.msgInfo.dynamicData := @value[1];
  Synchronize(SendMsgToUI);
end;

procedure TDownLoadlauncher.SendStatus(const typeId: TMsgType;
  const value: UInt64);
begin
  Self.msgInfo.typeId := typeId;
  Self.msgInfo.staticData := value;
  Synchronize(SendMsgToUI);
end;

end.

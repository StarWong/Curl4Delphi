unit CurlWrapper;

interface

uses
  Classes, curl_h;

type

  CURL = Pointer;
  CURLM = Pointer;
  size_t = Cardinal;

  {$REGION 'Enum::ResponseStatus'}
  type
  TResponseStatus = Integer;
  ResponseStatus = class
  const
    None = 0;
    Completed = 1;
    TimedOut =2;
    Error =3;
    Aborted =4;
    TResponseStatus =5;
  end;
  {$ENDREGION}

  {$REGION 'Enum::ContentFlag'}
  type
  TContentFlag = Integer;
  ContentFlag = class
  const
    Copy = 0;
    ByRef = 1;
  end;
  {$ENDREGION}

  {$REGION 'Enum::HttpMethod '}
  type
  THttpMethod  = Integer;
  HttpMethod  = class
  const
    Get = 0;
    Put = 1;
    Post =2;
    THttpMethod =3;
  end;
  {$ENDREGION}

  {$REGION 'Enum::Protocol '}
  type
  TProtocol = Integer;
  Protocol  = class
  const
    None = 0;
    Ftp =1;
    _File = 2;
    Http =3;
    Https = 4;
  end;

  {$ENDREGION}

type

  CurlEasy = class
  private type
    TUploadBuffer = record
      data: PByte;
      size: size_t;
      rpos: size_t end;
    private
      m_Headers: pcurl_slist;
      m_Status: Integer;
    private
      m_Content: string;
      m_File: TFileStream;
    private
      m_UploadContent: string;
      m_UploadFile: TFileStream;
      m_UploadBuffer: TUploadBuffer;
    private
      m_Header: string;
      m_StatusCode: Integer;
    private
      m_Handle: Integer;
      InitializeCount: Cardinal;
      m_MultiHandle: Integer;
    private
      procedure NewFile(const filePath: string);
    private
     class  procedure _Debug(const retCode: TCurlCode; extra: string = 'unknow');static;inline;
    private
      class function WriteCallback(buffer: PAnsiChar; size: size_t;
        nitems: size_t; userdata: Pointer): size_t; static; cdecl;
      class function HeaderCallback(buffer: PAnsiChar; size: size_t;
        nitems: size_t; userdata: Pointer): size_t; static; cdecl;
      class function ReadFileCallback(buffer: PAnsiChar; size: size_t;
        nitems: size_t; userdata: Pointer): size_t; static; cdecl;
      class function ReadBufferCallback(buffer: PAnsiChar; size: size_t;
        nitems: size_t; userdata: Pointer): size_t; static; cdecl;
    protected
      procedure UpdateStatus(CurlStatus: Integer);
      procedure OnPerformed; virtual;
      procedure OnHeader; virtual;
      procedure OnContent; virtual;
    protected
      constructor Create(m_Headers: CURL; m_UploadFile: Pointer;
        m_Status: Integer; m_StatusCode: Integer;
        m_MultiHandle: Pointer); overload;
      destructor Destroy; override;
    public
      function Initialize(): LongBool;
      procedure Terminate();
    public
      procedure ReSet;
      function Perform: LongBool;
      procedure Clear;
    public
      function GetHeader: string; inline;
      function GetContent: string; inline;
      function GetHandle: CURL; inline;
      function GetStatus: Integer; inline;
      function GetStatusStr:AnsiString;inline;
    private
      function GetProtocolPrefix(const proto: TProtocol):AnsiString;
      function GetHttpMethodName(const method:THttpMethod):AnsiString;
    public
      procedure SetUrl(const url: AnsiString);overload;
      procedure SetUrl(const proto: TProtocol; const url: AnsiString);overload;
      procedure SetPort(const port:Word);
      procedure SetMethod(const method:AnsiString);overload;
      procedure SetMethod(const method:THttpMethod);overload;
      procedure SetHeader(const field:AnsiString);overload;
      procedure SetHeader(const name,value:AnsiString);overload;
      procedure SetHeaders(var headers:TStringList);
      procedure SetUserAgent(const user_agent:AnsiString);
      procedure SetTimeoutMs(const timeout_ms:Integer);
      procedure SetTimeoutSec(const timeout_sec:Integer);
      procedure SetLowSpeedLimit(const MinBytes,TimeSec:Integer);
      procedure SetMaxRedirects(const amount:Integer);
      procedure SetNoBody(const enable:LongBool);
      procedure SetTcpNoDelay(const enable:LongBool);
      procedure SetVerifyPeer(const enable:LongBool);
      procedure SetFollowLocation(const enable:LongBool);
      procedure SetProxy(const url:AnsiString);overload;
      procedure SetProxy(const url:AnsiString;const port:Word);overload;
      procedure SetProxyAuth(const username:AnsiString;const password:AnsiString);
      procedure SetBufferSize(const size:size_t);
      procedure SetPostContent(const content:AnsiString;const flag:TContentFlag);overload;
      procedure SetPostContent(const content:AnsiString;const Size:size_t;const flag:TContentFlag);overload;
      procedure SetUploadBuffer(const content:AnsiString;const flag:TContentFlag);overload;
      procedure SetUploadBuffer(const content:AnsiString;const size:size_t;const flag:TContentFlag);overload;
      procedure SetUploadFile(const fileFullPath:string);
      protected
    end;


  PCurlMulti = ^CurlMulti;
  CurlMulti = class
    protected
      m_Handle: Integer;
    protected
    function  Initialize:LongBool;
    procedure Terminate;
    public
      procedure Perform;
      function GetHandle: Integer;
      procedure AddHandle(easy: CurlEasy);
      procedure RemoveHandle(easy: CurlEasy);
    end;

implementation

uses
  Logger, SysUtils;
{ CurlEasy }

function InterlockedIncrement(Addend: PInteger): Integer; stdcall;
external 'Kernel32.dll' name 'InterlockedIncrement';
function InterlockedDecrement(Addend: PInteger): Integer; stdcall;
external 'Kernel32.dll' name 'InterlockedDecrement';
function InterlockedExchange(Target: PInteger; Value: Integer): Integer;
  stdcall; external 'Kernel32.dll' name 'InterlockedExchange';

function StartsWith(str:PAnsiChar;prefix:PAnsiChar):LongBool;overload;
begin
  Result:=False;
  repeat
     if str^ <> prefix^  then  Exit;
     Inc(str);
     Inc(prefix);
  until (str^ = #0);
  Result:=True;
end;

function StartsWith(const str:AnsiString;prefix:AnsiString):LongBool;overload;
begin
  Result := Copy(str, 1, Length(prefix)) = prefix;
end;

function StartsWith(const str:String;prefix:String):LongBool;overload;
begin
  Result := Copy(str, 1, Length(prefix)) = prefix;
end;

function EndsWith(const str:AnsiString;suffix:PAnsiChar):LongBool;overload;
var
suffix_len,str_Size,str_start:size_t;
  I: size_t;
begin
        Result:=False;
        suffix_len:=StrLen(suffix);
        str_Size:=Length(str);
        if str_Size < suffix_len then Exit;
         str_start:=str_Size - suffix_len;
         for I := 0 to suffix_len - 1 do
begin
        if str[str_start + i + 1] <>  suffix^ then  Exit;
          Inc(suffix);
end;
Result:=True;

end;

function EndsWith(const str:String;const suffix:String):LongBool;overload;
begin
     if Length(suffix) > Length(str) then Exit(False);
     Result:=Copy(str,Length(str) - Length(suffix) + 1,Length(suffix)) = suffix;
end;

function EndsWith(const str:AnsiString;const suffix:AnsiString):LongBool;overload;
begin
     if Length(suffix) > Length(str) then Exit(False);
     Result:=Copy(str,Length(str) - Length(suffix) + 1,Length(suffix)) = suffix;
end;

function GetFileSize(const fileFullPath:string;out size:Int64):LongBool;
var
f:TFileStream;
begin
Result:=False;
f:=TFileStream.Create(fileFullPath,fmShareDenyNone);
try
size:=f.Size;
Result:=True;
finally
if f <> nil then
f.Free;
end;
end;



procedure CurlEasy.Clear;
begin
  m_Header := '';
  m_Content := '';
  m_Status := 0;
  m_StatusCode := 0;
end;

constructor CurlEasy.Create(m_Headers: CURL; m_UploadFile: Pointer;
  m_Status: Integer; m_StatusCode: Integer; m_MultiHandle: Pointer);
begin

end;

destructor CurlEasy.Destroy;
begin
  ReSet;
  curl_easy_cleanup(m_Handle);
  inherited;
end;

function CurlEasy.GetContent: string;
begin

end;

function CurlEasy.GetHandle: CURL;
begin

end;

function CurlEasy.GetHeader: string;
begin

end;

function CurlEasy.GetHttpMethodName(const method: THttpMethod): AnsiString;
begin

end;

function CurlEasy.GetProtocolPrefix(const proto: TProtocol): AnsiString;
begin
           case proto of
           Protocol.Ftp:Result:='ftp://';
           Protocol._File:Result:='file://';
           Protocol.Http:Result:='http://';
           Protocol.Https:Result:='https://';
           else
           Result:='';
           end;
end;

function CurlEasy.GetStatus: Integer;
begin

end;

class function CurlEasy.HeaderCallback(buffer: PAnsiChar; size, nitems: size_t;
  userdata: Pointer): size_t;
begin

end;

function CurlEasy.Initialize(): LongBool;
begin
  if InitializeCount = 0 then
  begin
    InterlockedIncrement(@InitializeCount);
    curl_global_init(CURL_GLOBAL_ALL);
  end;
end;

procedure CurlEasy.NewFile(const filePath: string);
begin
  Assert(m_File <> nil);
  m_File := TFileStream.Create(filePath, fmOpenReadWrite or fmCreate);
end;

procedure CurlEasy.OnContent;
begin

end;

procedure CurlEasy.OnHeader;
begin

end;

procedure CurlEasy.OnPerformed;
begin

end;

function CurlEasy.Perform: LongBool;
var
  retCode: TCurlCode;
begin
  Clear;
  _Debug(curl_easy_set_pointer(m_Handle, CURLOPT_HTTPHEADER, m_Headers),
    'CURLOPT_HTTPHEADER');
  retCode := curl_easy_perform(m_Handle);
  UpdateStatus(Integer(retCode));
  OnPerformed;
  Result := retCode = CURLE_OK;
end;

class function CurlEasy.ReadBufferCallback(buffer: PAnsiChar;
  size, nitems: size_t; userdata: Pointer): size_t;
begin

end;

class function CurlEasy.ReadFileCallback(buffer: PAnsiChar;
  size, nitems: size_t; userdata: Pointer): size_t;
begin

end;

procedure CurlEasy.ReSet;
var
  retCode: TCurlCode;
begin
  m_UploadFile := nil;
  if m_File <> nil then
    m_File.Free;
  m_UploadContent := '';
  m_UploadBuffer.data := nil;
  m_UploadBuffer.size := 0;
  m_UploadBuffer.rpos := 0;

  if m_Headers <> nil then
  begin
    curl_slist_free_all(m_Headers);
    m_Headers := nil;
  end;
  curl_easy_reset(m_Handle);
  retCode := curl_easy_set_pointer(m_Handle, CURLOPT_WRITEFUNCTION,
    @WriteCallback);
  Log('CURLOPT_WRITEFUNCTION:' + IntToStr(Integer(retCode)));
  retCode := curl_easy_set_pointer(m_Handle, CURLOPT_WRITEDATA, m_File);
  Log('CURLOPT_WRITEDATA:' + IntToStr(Integer(retCode)));
  retCode := curl_easy_set_pointer(m_Handle, CURLOPT_HEADERFUNCTION,
    @HeaderCallback);
  Log('CURLOPT_HEADERFUNCTION:' + IntToStr(Integer(retCode)));
  retCode := curl_easy_set_pointer(m_Handle, CURLOPT_HEADERDATA, m_File);
  Log('CURLOPT_HEADERDATA:' + IntToStr(Integer(retCode)));
end;

procedure CurlEasy.SetBufferSize(const size: size_t);
begin

end;

procedure CurlEasy.SetFollowLocation(const enable: LongBool);
begin

end;

procedure CurlEasy.SetHeader(const field: AnsiString);
begin

end;

procedure CurlEasy.SetHeader(const name, value: AnsiString);
begin

end;

procedure CurlEasy.SetHeaders(var headers: TStringList);
begin

end;

procedure CurlEasy.SetLowSpeedLimit(const MinBytes, TimeSec: Integer);
begin

end;

procedure CurlEasy.SetMaxRedirects(const amount: Integer);
begin

end;

procedure CurlEasy.SetMethod(const method: THttpMethod);
begin

end;

procedure CurlEasy.SetMethod(const method: AnsiString);
begin

end;

procedure CurlEasy.SetNoBody(const enable: LongBool);
begin

end;

procedure CurlEasy.SetPort(const port: Word);
begin

end;

procedure CurlEasy.SetPostContent(const content: AnsiString;
  const flag: TContentFlag);
begin

end;

procedure CurlEasy.SetPostContent(const content: AnsiString; const Size: size_t;
  const flag: TContentFlag);
begin

end;

procedure CurlEasy.SetProxy(const url: AnsiString);
begin

end;

procedure CurlEasy.SetProxy(const url: AnsiString; const port: Word);
begin

end;

procedure CurlEasy.SetProxyAuth(const username, password: AnsiString);
begin

end;

procedure CurlEasy.SetTcpNoDelay(const enable: LongBool);
begin

end;

procedure CurlEasy.SetTimeoutMs(const timeout_ms: Integer);
begin

end;

procedure CurlEasy.SetTimeoutSec(const timeout_sec: Integer);
begin

end;

procedure CurlEasy.SetUploadBuffer(const content: AnsiString;
  const size: size_t; const flag: TContentFlag);
begin

end;

procedure CurlEasy.SetUploadBuffer(const content: AnsiString;
  const flag: TContentFlag);
begin

end;

procedure CurlEasy.SetUploadFile(const fileFullPath: string);
begin

end;

procedure CurlEasy.SetUrl(const proto: TProtocol; const url: AnsiString);
var
tmp:AnsiString;
begin
       tmp:=GetProtocolPrefix(proto);
       if StartsWith(url,tmp) then
       SetUrl(url)
       else
       SetUrl(tmp + url);
end;

procedure CurlEasy.SetUserAgent(const user_agent: AnsiString);
begin

end;

procedure CurlEasy.SetVerifyPeer(const enable: LongBool);
begin

end;

procedure CurlEasy.SetUrl(const url: AnsiString);
var
  retCode: TCurlCode;
begin
  retCode := curl_easy_set_pchar(m_Handle, CURLOPT_URL, @url[1]);
  Log('CURLOPT_URL:' + IntToStr(Integer(retCode)));
end;

procedure CurlEasy.Terminate;
begin
  Assert(InitializeCount > 0);
  if InitializeCount = 1 then
  begin
    InterlockedDecrement(@InitializeCount);
    curl_global_cleanup;
  end;

end;

procedure CurlEasy.UpdateStatus(CurlStatus: Integer);
var
  ResponseStatus: Integer;
begin
  m_StatusCode := 0;
  if curl_easy_getinfo(m_Handle, CURLINFO_RESPONSE_CODE, @ResponseStatus)
    = CURLE_OK then
  begin
    m_StatusCode := ResponseStatus;
  end
  else
    Exception.Create('curl_easy_getinfo');
  case CurlStatus of
    Integer(CURLE_OK):
      begin
       // m_Status := Completed;
      end;
    Integer(CURLE_OPERATION_TIMEDOUT):
      begin
       // m_Status := TimedOut;
      end;
    Integer(CURLE_ABORTED_BY_CALLBACK):
      begin
       // m_Status := Aborted;
      end;
  else
    begin
    //  m_Status := Error;
    end;

  end;
end;

class function CurlEasy.WriteCallback(buffer: PAnsiChar; size, nitems: size_t;
  userdata: Pointer): size_t;
begin

end;

class procedure CurlEasy._Debug(const retCode: TCurlCode; extra: string = 'unknow');
begin
  Log(extra + ':' + IntToStr(Integer(retCode)));
end;


function CurlEasy.GetStatusStr:AnsiString;
begin
       case GetStatus of
       ResponseStatus.None:Result:='None';
       ResponseStatus.Completed:Result:='Completed';
       ResponseStatus.Error:Result:='Error';
       ResponseStatus.TimedOut:Result:='TimedOut';
       ResponseStatus.Aborted:Result:='Aborted';
       else
       Result:='Unknown';
       end;

end;

procedure ComposeUrl(const url, host, path: AnsiString); overload;
begin

end;

procedure ComposeUrl(); overload;
begin

end;

function EscapeUrl(const url: AnsiString; const pUrl: PAnsiChar): LongBool;
begin

end;

{ CurlMulti }

procedure CurlMulti.AddHandle(easy: CurlEasy);
begin
  Assert(easy.m_MultiHandle = 0);
  easy._Debug(curl_easy_set_pointer(self.m_Handle, CURLOPT_HTTPHEADER,
      easy.m_Headers));

end;

function CurlMulti.GetHandle: Integer;
begin

end;

function CurlMulti.Initialize: LongBool;
begin
      Self.m_Handle:=curl_multi_init;
      Result:= Self.m_Handle = 0;
end;

procedure CurlMulti.Perform;
var
running_handles:Integer;
begin
      running_handles:=0;
      CurlEasy._Debug(curl_multi_perform(Self.m_Handle,running_handles),'curl_multi_perform');
end;

procedure CurlMulti.RemoveHandle(easy: CurlEasy);
var
  retCode: Integer;
begin
  Assert(easy.m_MultiHandle <> 0);
  retCode := curl_multi_remove_handle(self.m_Handle, easy.m_Handle);
  Assert(retCode = 0);
  if retCode = 0 then
  begin
    easy.m_MultiHandle := 0;
  end;
end;




procedure CurlMulti.Terminate;
begin
       curl_multi_cleanup(m_Handle);
end;

end.

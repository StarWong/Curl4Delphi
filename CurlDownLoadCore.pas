unit CurlDownLoadCore;

interface

uses
  Classes, Generics.Collections, SyncObjs,Curl;

type

  size_t = Cardinal;
{$REGION 'Enum::ResponseStatus'}

type
  TResponseStatus = Integer;

  ResponseStatus = class
  const
    None = 0;
    Completed = 1;
    TimedOut = 2;
    Error = 3;
    Aborted = 4;
    RecvError = 5;
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
  THttpMethod = Integer;

  HttpMethod = class
  const
    Get = 0;
    Put = 1;
    Post = 2;
    THttpMethod = 3;
  end;
{$ENDREGION}
{$REGION 'Enum::Protocol '}

type
  TProtocol = Integer;

  Protocol = class
  const
    None = 0;
    Ftp = 1;
    _File = 2;
    Http = 3;
    Https = 4;
  end;
{$ENDREGION}

type

  TRecursiveMutex = class;

  TRecursiveMutex = class
  strict private
    mapMutex: TCriticalSection;
    recursiveMutex: TCriticalSection;
    lockNums: TDictionary<THandle, Integer>;
  public
    constructor Create; overload;
    destructor Destroy; override;
  public
    procedure Enter;
    procedure Leave;
  end;

  TCurlEvent = class;
  PCurlEvent = ^TCurlEvent;

  TCurlEvent = class
  strict private
    handle: THandle;
  public
    constructor Create(const ManualReset, InitialState: LongBool;
      name: PAnsiChar = nil); overload;
    destructor Destroy; override;
  public
    procedure Pulse;
    procedure SetDone;
    procedure Reset;
    procedure WaitUntilDone;
    function WaitWithTimeout(WaitMs: Cardinal): LongBool;
    function TryWait: LongBool;
    class procedure WaitAny(const Events: TCurlEvent; const Count: size_t;
      const EventSignaled: PCurlEvent); static;
    class procedure WaitAll(const Events: TCurlEvent; Count: size_t); static;
    class function WaitAnyWithTimeout(const Events: array of TCurlEvent;
      const Count: size_t; const WaitMs: Cardinal;
      const EventSignaled: PCurlEvent): LongBool; static;
    class function WaitAllWithTimeout(const Events: array of TCurlEvent;
      const Count: size_t; const WaitMs: Cardinal): LongBool; static;
    class function TryWaitAny(const Events: TCurlEvent; const Count: size_t;
      EventSignaled: PCurlEvent): LongBool; static;
    class function TryWaitAll(const Events: TCurlEvent;
      const Count: size_t): LongBool; static;
  end;

  // TOnHeader = procedure(const buffer: PAnsiChar; Count: size_t) of object;

type
  TCurlDownLoadCore = class;
  TCurlDownLoadManager = class;
  CurlMulti = class;
  TAsyncRestScopeInit = class;

  TAsyncRestScopeInit = class
    constructor Create; overload;
    destructor Destroy; override;
  end;

  TCurlDownLoadCore = class
  strict private
{$IFDEF DEBUG}
    m_ErrorBuffer: array [0 .. 63] of Cardinal;
{$ENDIF}
    m_Url: AnsiString;
  private
    m_MultiHandle: Integer;
  protected
    m_Headers: PCurl_slist; // url:headers
    m_Status: TResponseStatus; // from UpdateStatus,curl_multi_info_read
    m_StatusCode: Integer; // from curl_easy_getinfo
    m_header: TMemoryStream; // url head
    m_Content: TMemoryStream; // url context
    m_handle: Integer; // easy handle
    m_FileName_Local: string; // fileName From Url
  protected
    procedure OnHeader(const buffer: PAnsiChar; const Count: size_t); virtual;
    procedure OnContent(const buffer: PAnsiChar; const Count: size_t); virtual;
    procedure OnPerformed; virtual;
  protected
    constructor Create;virtual;
    destructor Destroy;virtual;
  strict private
    class function WriteCallback(buffer: PAnsiChar; size: size_t;
      nitems: size_t; userdata: TCurlDownLoadCore): size_t; static; cdecl;
    class function HeaderCallback(buffer: PAnsiChar; size: size_t;
      nitems: size_t; userdata: TCurlDownLoadCore): size_t; static; cdecl;
    class function ReadFileCallback(buffer: PAnsiChar; size: size_t;
      nitems: size_t; userdata: Pointer): size_t; static; cdecl;
    class function ReadBufferCallback(buffer: PAnsiChar; size: size_t;
      nitems: size_t; userdata: Pointer): size_t; static; cdecl;
  strict private
    function curl_easy_set(const option: TCURLoption;
      const value: Integer): Integer; overload; inline;
    function curl_easy_set(const option: TCURLoption;
      const value: Pointer): Integer; overload; inline;
    function curl_easy_set(const option: TCURLoption;
      const value: AnsiString): Integer; overload; inline;
  strict private
    procedure SetCallBack;
    procedure Debug(const retCode: Integer; name: string = ''); overload;
    procedure Debug(const retCode: TCurlCode; name: string = ''); overload;
    function GetFileExtension(const content: AnsiString;
      out Extension: AnsiString): LongBool;
  public
    procedure SetUrl(const url: AnsiString); overload;
    procedure SetRanges(const ranges: AnsiString);
    procedure SetUrl(const proto: TProtocol; const url: AnsiString); overload;
      virtual; abstract;
    procedure SetPort(const port: Word); virtual; abstract;
    procedure SetMethod(const method: AnsiString); overload; virtual; abstract;
    procedure SetMethod(const method: THttpMethod); overload; virtual; abstract;
    procedure SetHeader(const field: AnsiString); overload;
    procedure SetHeader(const name, value: AnsiString); overload; virtual;
      abstract;
    procedure SetHeaders(var headers: TStringList); virtual; abstract;
    procedure SetUserAgent(const user_agent: AnsiString);
    procedure SetTimeoutMs(const timeout_ms: Integer); virtual; abstract;
    procedure SetTimeoutSec(const timeout_sec: Integer);
    procedure SetLowSpeedLimit(const MinBytes, TimeSec: Integer); virtual;
      abstract;
    procedure SetMaxRedirects(const amount: Integer); virtual; abstract;
    procedure SetNoBody(const enable: LongBool); virtual; abstract;
    procedure SetTcpNoDelay(const enable: LongBool); virtual; abstract;
    procedure SetVerifyPeer(const enable: LongBool);
    procedure SetFollowLocation(const enable: LongBool);
    procedure SetProxy(const url: AnsiString); overload; virtual; abstract;
    procedure SetProxy(const url: AnsiString; const port: Word); overload;
      virtual; abstract;
    procedure SetProxyAuth(const username: AnsiString;
      const password: AnsiString); virtual; abstract;
    procedure SetBufferSize(const size: size_t); virtual; abstract;
    procedure SetPostContent(const content: AnsiString;
      const flag: TContentFlag); overload; virtual; abstract;
    procedure SetPostContent(const content: AnsiString; const size: size_t;
      const flag: TContentFlag); overload; virtual; abstract;
    procedure SetUploadBuffer(const content: AnsiString;
      const flag: TContentFlag); overload; virtual; abstract;
    procedure SetUploadBuffer(const content: AnsiString; const size: size_t;
      const flag: TContentFlag); overload; virtual; abstract;
    procedure SetUploadFile(const fileFullPath: string); virtual; abstract;
    procedure SaveFile(const fileFullPath: string); virtual;
    function GetHeader: string;
    function GetContent: String;
    function GetHandle: Integer; virtual; abstract;
    function GetStatus: Integer; inline;
    function GetStatusStr: AnsiString;
    class function GetProtocolPrefix(const proto: TProtocol): AnsiString;
      static;
    class function GetHttpMethodName(const method: THttpMethod): AnsiString;
      static;
    function Perform: LongBool;
    function GetErrorStr: AnsiString; inline;
    procedure Reset;
    procedure ReTry; virtual;
  protected
    procedure Clear;
    procedure UpdateStatus(CurlStatus: TCurlCode);
  end;

  TRestClient = class(TCurlDownLoadCore)
  public
    procedure Execute;
    function IsSuccessful: LongBool;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Free; overload;
  end;

  TAsyncRestClient = class(TRestClient)
  strict private
    m_Event: TCurlEvent;
    status: Integer;
  public
    function Wait(timeoutMs: Cardinal): LongBool; overload;
    procedure Wait; overload;
    function IsPending: LongBool;
    procedure Clear;
    function IsCompleted: LongBool;
    procedure OnCompletion(status: TCurlCode);
    procedure ExecuteAsync; // recv the msg from manager thread
    procedure Abort;
  public
    constructor Create; overload;
    destructor Destroy; override;
    procedure Free; overload;
  end;

  TWinMainMsg = procedure(const msg: string) of object;

  TCurlDownLoadManager = class(TThread)
  strict private
    FMsg: string;
    FEvent: TWinMainMsg;
    procedure SendEvent;
  strict private
    m_ThreadCount: Integer;
    m_Running: LongBool;
    m_Clients: TDictionary<THandle, TAsyncRestClient>;
  strict private

    //
  public
    procedure start;
    procedure stop;
    procedure ExecuteTheTask(const client: TAsyncRestClient);
    procedure Abort(const client: TAsyncRestClient);
  protected
    procedure Execute; override;
  public
    constructor Create; overload;
    destructor Destroy; override;
  public
    property Event: TWinMainMsg read FEvent write FEvent;
  end;

  CurlMulti = class
  private
    class var m_handle: Integer;
  protected
    class constructor Create;
    class destructor Destroy;
  public
    class function enable: LongBool; static;
    class function Disable:LongBool; static;
    class procedure Perform; static;
    class function ReadHandle(var msgsLeft: Integer): PCURLMsg; static;
    class function GetHandle: Integer; static; inline;
    class procedure AddHandle(const client: TAsyncRestClient); static;
    class procedure RemoveHandle(const client: TAsyncRestClient); static;
  end;

function StartsWith(const str: AnsiString; prefix: AnsiString): LongBool;
  overload;
function StartsWith(const str: String; prefix: String): LongBool; overload;
function EndsWith(const str: String; const suffix: String): LongBool; overload;
function EndsWith(const str: AnsiString; const suffix: AnsiString): LongBool;
  overload;

implementation

uses
  Logger, Windows, PerlRegEx;

const
  MAX_WAIT_OBJECTS: size_t = 64;

var
  ScopeInit: TAsyncRestScopeInit;
  s_RestThread: TCurlDownLoadManager = nil;
  InitializeCount, s_InitializeCount: Integer;
  htLock: TRecursiveMutex;
{$REGION 'Some  Functions'}

procedure FreeAndNil(var Obj); inline;
var
  Temp: TObject;
begin
  if Pointer(Obj) <> nil then
  begin
    Temp := TObject(Obj);
    Pointer(Obj) := nil;
    Temp.Free;
  end;
end;

function StartsWith(const str: AnsiString; prefix: AnsiString): LongBool;
  overload;
begin
  Result := Copy(str, 1, Length(prefix)) = prefix;
end;

function StartsWith(const str: String; prefix: String): LongBool; overload;
begin
  Result := Copy(str, 1, Length(prefix)) = prefix;
end;

function EndsWith(const str: String; const suffix: String): LongBool; overload;
begin
  if Length(suffix) > Length(str) then
    Exit(False);
  Result := Copy(str, Length(str) - Length(suffix) + 1, Length(suffix))
    = suffix;
end;

function EndsWith(const str: AnsiString; const suffix: AnsiString): LongBool;
  overload;
begin
  if Length(suffix) > Length(str) then
    Exit(False);
  Result := Copy(str, Length(str) - Length(suffix) + 1, Length(suffix))
    = suffix;
end;

function ComposeUrl(const url, host, path: AnsiString): AnsiString; overload;
begin
  Result := url;
  if not EndsWith(url, '/') then
    Result := Result + '/';
  if StartsWith(path, '/') then
    Result := Result + PAnsiChar(@path[2]);

end;

function ComposeUrl(const url: AnsiString; proto: TProtocol;
  const host, path: AnsiString): AnsiString; overload;
begin
  Result := TCurlDownLoadCore.GetProtocolPrefix(proto);
  if not StartsWith(host, Result) then
    Result := url + Result;
  Result := ComposeUrl(Result, host, path);
end;

function EscapeUrl(Out url: AnsiString; const _Url: AnsiString): LongBool;
var
  pEscapedUrl: PAnsiChar;
begin
  Result := False;
  pEscapedUrl := curl_escape(@_Url[1], 0);
  if pEscapedUrl = nil then
    Exit;
  url := pEscapedUrl;
  Result := True;
end;
{$ENDREGION}

procedure Initialize;
begin
  s_RestThread := TCurlDownLoadManager.Create;
  Assert(s_RestThread <> nil);
end;

procedure Terminate;
begin
  FreeAndNil(s_RestThread);
end;

procedure InitCurl;
begin
  if InitializeCount = 0 then
  begin
    curl_global_init(CURL_GLOBAL_ALL);
  end;
  InterlockedIncrement(InitializeCount);
end;

procedure ShutdownCurl;
begin
  Assert(InitializeCount > 0);
  InterlockedDecrement(InitializeCount);
  if InitializeCount = 0 then
    curl_global_cleanup;
end;

{ Init }

procedure InitAsyncRest;
begin
  if s_InitializeCount = 0 then
  begin
    InitCurl;
    s_RestThread.start;
  end;
  InterlockedIncrement(s_InitializeCount);
end;

procedure ShutdownAsyncRest;
begin
  Assert(s_InitializeCount > 0);
  InterlockedDecrement(s_InitializeCount);
  if s_InitializeCount = 0 then
  begin
    s_RestThread.stop;
    ShutdownCurl;
  end;

end;

{ TCurlDownLoadManager }

procedure TCurlDownLoadManager.Abort(const client: TAsyncRestClient);
begin
  htLock.Enter;
  if m_Clients.ContainsKey(client.m_handle) then
  begin
    CurlMulti.RemoveHandle(client);
    Self.m_Clients.Remove(client.m_handle);
  end;
  htLock.Leave;
end;

constructor TCurlDownLoadManager.Create;
begin
  inherited Create(True);
  m_Clients := TDictionary<THandle, TAsyncRestClient>.Create;

end;

destructor TCurlDownLoadManager.Destroy;
begin

  m_Clients.Free;
  Self.Terminate;
  inherited;
end;

procedure TCurlDownLoadManager.Execute;
var
  pMsg: PCURLMsg;
  msgsLeft: Integer;
  client: TAsyncRestClient;
begin
  inherited;
  FreeOnTerminate := False;
  while Self.m_Running do
  begin
    htLock.Enter;
    begin
      CurlMulti.Perform;
      pMsg := CurlMulti.ReadHandle(msgsLeft);
      while pMsg <> nil do
      begin
        if m_Clients.ContainsKey(pMsg.easy_handle) then
        begin
          client := m_Clients[pMsg.easy_handle];
          m_Clients.Remove(pMsg.easy_handle);
          CurlMulti.RemoveHandle(client);
          client.OnCompletion(pMsg.data.Result);
          pMsg := CurlMulti.ReadHandle(msgsLeft);
        end;
      end;
    end;
    htLock.Leave;
    Sleep(16);
  end;

end;

procedure TCurlDownLoadManager.ExecuteTheTask(const client: TAsyncRestClient);
begin
  htLock.Enter;
  m_Clients.Add(client.m_handle, client);
  CurlMulti.AddHandle(client);
  htLock.Leave;
end;

procedure TCurlDownLoadManager.SendEvent;
begin
  if Assigned(FEvent) then
    FEvent(FMsg);
end;

procedure TCurlDownLoadManager.start;
begin
  InterlockedExchange(Integer(Self.m_Running), 1); // true
  Self.Resume; // start
  Assert(CurlMulti.enable = True);
end;

procedure TCurlDownLoadManager.stop;
begin
  InterlockedExchange(Integer(Self.m_Running), 0); // false
  Assert(CurlMulti.Disable = True);
  Self.Terminate; // stop
end;

{ TCurlDownLoadCore }

procedure TCurlDownLoadCore.Clear;
begin
  m_header.Clear;
  m_Content.Clear;
  m_Status := 0;
  m_StatusCode := 0;
end;

constructor TCurlDownLoadCore.Create;
begin
  inherited;
  Self.m_handle := curl_easy_init;
  Assert(Self.m_handle <> 0);
  m_header := TMemoryStream.Create;
  m_Content := TMemoryStream.Create;
  Self.m_Headers := nil;
  Self.m_MultiHandle := 0;
  Self.m_FileName_Local := '';
  Self.Reset;
end;

function TCurlDownLoadCore.curl_easy_set(const option:TCURLoption;const value: Integer): Integer;
begin
  Result := Integer(curl_easy_set_integer(Self.m_handle, Integer(option), value));
end;

function TCurlDownLoadCore.curl_easy_set(const option: TCURLoption;
  const value: Pointer): Integer;
begin
  Result := Integer(curl_easy_set_pointer(Self.m_handle, Integer(option), value));
end;

function TCurlDownLoadCore.curl_easy_set(const option: TCURLoption;
  const value: AnsiString): Integer;
begin
  Result := Integer(Curl_Easy_set_PAnsiChar(Self.m_handle, Integer(option),
      PAnsiChar(@value[1])));
end;

procedure TCurlDownLoadCore.Debug(const retCode: Integer; name: string = '');
begin
  Printf(retCode, name);
end;

procedure TCurlDownLoadCore.Debug(const retCode: TCurlCode; name: string);
var
  ret: Integer;
begin
  ret := Ord(retCode);
  Printf(ret, name);
end;

destructor TCurlDownLoadCore.Destroy;
begin
  Self.Reset;
  curl_easy_cleanup(Self.m_handle);
  FreeAndNil(Self.m_header);
  FreeAndNil(Self.m_Content);
  inherited;
end;

function TCurlDownLoadCore.GetContent: String;
var
  buffer: array of Byte;
begin
  m_Content.Position := 0;
  SetLength(buffer, m_Content.size);
  m_Content.ReadBuffer(buffer[0], m_Content.size);
  SetString(Result, PAnsiChar(@buffer[0]), m_Content.size);
end;

function TCurlDownLoadCore.GetErrorStr: AnsiString;
begin
{$IFDEF DEBUG}
  Result := PAnsiChar(@(Self.m_ErrorBuffer[0]));
{$ELSE}
  Result := '';
{$ENDIF}
end;

function TCurlDownLoadCore.GetFileExtension(const content: AnsiString;
  out Extension: AnsiString): LongBool;
var
  reg: TPerlRegEx;
  index, ret: Cardinal;
  pContent: PAnsiChar;
begin
  Result := False;
  reg := TPerlRegEx.Create;
  try
    reg.Subject := content;
    reg.RegEx :=
      '((http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?)';
    if reg.Match then
    begin
      ret := 0;
     // index := 0;
      repeat
        pContent := @content[ret + 1];
        index := Pos('/', pContent);
        if index <> 0 then
          Inc(ret, index) until index = 0;
        if ret <> 0 then
        begin
          if Pos('.', pContent) <> 0 then
          begin
            Extension := pContent;
            Result := True;
          end;
        end;
      end;

      finally
        reg.Free;
      end;
    end;

    function TCurlDownLoadCore.GetHeader: string;
    begin
      m_header.Position := 0;
      SetString(Result, PAnsiChar(m_header.Memory), m_header.size);
    end;

    class function TCurlDownLoadCore.GetHttpMethodName
      (const method: THttpMethod): AnsiString;
    begin
      case method of
        HttpMethod.Get:
          Result := 'GET';
        HttpMethod.Put:
          Result := 'PUT';
        HttpMethod.Post:
          Result := 'POS';
      else
        Result := '';
      end;
    end;

    class function TCurlDownLoadCore.GetProtocolPrefix(const proto: TProtocol)
      : AnsiString;
    begin
      case proto of
        Protocol.Ftp:
          Result := 'ftp://';
        Protocol._File:
          Result := 'file://';
        Protocol.Http:
          Result := 'http://';
        Protocol.Https:
          Result := 'https://';
      else
        Result := '';
      end;
    end;

    function TCurlDownLoadCore.GetStatus: Integer;
    begin
      Result := m_Status;
    end;

    function TCurlDownLoadCore.GetStatusStr: AnsiString;
    begin
      case GetStatus of
        ResponseStatus.None:
          Result := 'None';
        ResponseStatus.Completed:
          Result := 'Completed';
        ResponseStatus.Error:
          Result := 'Error';
        ResponseStatus.TimedOut:
          Result := 'TimedOut';
        ResponseStatus.Aborted:
          Result := 'Aborted';
      else
        Result := 'Unknown';
      end;

    end;

    procedure TCurlDownLoadCore.Reset;
    begin
      if Self.m_Headers <> nil then
        curl_slist_free_all(Self.m_Headers);
      curl_easy_reset(Self.m_handle);
      SetCallBack;
    end;

    procedure TCurlDownLoadCore.ReTry;
    begin
      Reset;
      SetUrl(Self.m_Url);
      SetVerifyPeer(False);
      SetFollowLocation(True);
      SetUserAgent('curl/7.71.1');
     // SetTimeoutSec(30);
    end;

    procedure TCurlDownLoadCore.SetCallBack;
    begin
      curl_easy_set(CURLOPT_WRITEFUNCTION, @WriteCallback);
      curl_easy_set(CURLOPT_WRITEDATA, Self);
      curl_easy_set(CURLOPT_HEADERFUNCTION, @HeaderCallback);
      curl_easy_set(CURLOPT_HEADERDATA, Self);
{$IFDEF DEBUG}
      curl_easy_set(CURLOPT_ERRORBUFFER, @m_ErrorBuffer);
      Self.m_ErrorBuffer[0] := 0;
{$ENDIF}
    end;

    procedure TCurlDownLoadCore.SetFollowLocation(const enable: LongBool);
    begin
      curl_easy_set(CURLOPT_FOLLOWLOCATION, Integer(enable));
    end;

    procedure TCurlDownLoadCore.SetHeader(const field: AnsiString);
    var
      Temp: PCurl_slist;
    begin
      Assert(field <> '');
      Temp := curl_slist_append(Self.m_Headers, @field[1]);
      Self.m_Headers := Temp;
    end;

    procedure TCurlDownLoadCore.SaveFile(const fileFullPath: string);
    begin
      m_Content.SaveToFile(fileFullPath);
    end;

    procedure TCurlDownLoadCore.SetTimeoutSec(const timeout_sec: Integer);
    begin
      curl_easy_set(CURLOPT_TIMEOUT, timeout_sec);
    end;

    procedure TCurlDownLoadCore.SetUrl(const url: AnsiString);
    var
      tmp: AnsiString;
    begin
      Self.m_Url := Copy(url, 1, Length(url));
      GetFileExtension(url, tmp);
      if tmp <> '' then
        Self.m_FileName_Local := tmp;
      curl_easy_set(CURLOPT_URL, url);
    end;

    procedure TCurlDownLoadCore.UpdateStatus(CurlStatus: TCurlCode);
    var
      _ResponseStatus: Integer;
      retCode: TCurlCode;
    begin
      m_StatusCode := 0; // set easy the status to zero
      retCode := curl_easy_getinfo(m_handle, CURLINFO_RESPONSE_CODE,
        @_ResponseStatus); // get easy hande the status
      if retCode = CURLE_OK then
      begin
        m_StatusCode := _ResponseStatus; // copy the status to m_StatusCode
      end
      else
        Printf(Integer(retCode), 'curl_easy_getinfo <> ok,code: ');
      case CurlStatus of
        CURLE_OK:
          begin
            m_Status := ResponseStatus.Completed;
          end;
        CURLE_OPERATION_TIMEDOUT:
          begin
            m_Status := ResponseStatus.TimedOut;
          end;
        CURLE_ABORTED_BY_CALLBACK:
          begin
            m_Status := ResponseStatus.Aborted;
          end;
        CURLE_RECV_ERROR:
          begin
            m_Status := ResponseStatus.RecvError;
          end
        else
        begin
          m_Status := ResponseStatus.Error;
        end;

      end;
    end;

    class function TCurlDownLoadCore.WriteCallback(buffer: PAnsiChar;
      size, nitems: size_t; userdata: TCurlDownLoadCore): size_t;
    var
      Count: size_t;
    begin
      Count := size * nitems;
      Assert(Count / size = nitems);
      if Count / size = nitems then
      begin
        userdata.OnContent(buffer, Count);
      end;
      Result := Count;
    end;

    class function TCurlDownLoadCore.HeaderCallback(buffer: PAnsiChar;
      size, nitems: size_t; userdata: TCurlDownLoadCore): size_t;
    var
      Count: size_t;
    begin
      Count := size * nitems;
      Assert(Count / size = nitems);
      if Count / size = nitems then
      begin
        userdata.OnHeader(buffer, Count);
      end;
      Result := Count;

    end;

    procedure TCurlDownLoadCore.OnContent(const buffer: PAnsiChar;
      const Count: size_t);
    begin
      m_Content.Write(buffer^, Count);
    end;

    procedure TCurlDownLoadCore.OnHeader(const buffer: PAnsiChar;
      const Count: size_t);
    begin
      m_header.Write(buffer^, Count);
    end;

    procedure TCurlDownLoadCore.OnPerformed;
    begin

    end;

    function TCurlDownLoadCore.Perform: LongBool;
    var
      status: TCurlCode;
    begin
      Self.Clear;
      curl_easy_set(CURLOPT_HTTPHEADER, m_Headers);
      status := curl_easy_perform(Self.m_handle);
      UpdateStatus(status);
      Self.OnPerformed;
      Result := status = CURLE_OK;
    end;

    class function TCurlDownLoadCore.ReadBufferCallback(buffer: PAnsiChar;
      size, nitems: size_t; userdata: Pointer): size_t;
    begin

    end;

    class function TCurlDownLoadCore.ReadFileCallback(buffer: PAnsiChar;
      size, nitems: size_t; userdata: Pointer): size_t;
    begin

    end;

    class procedure CurlMulti.AddHandle(const client: TAsyncRestClient);
    var
      retCode: TCurlCode;
    begin
      Assert(client.m_MultiHandle = 0);
      retCode := curl_multi_add_handle(CurlMulti.m_handle, client.m_handle);
      Assert(retCode = CURLE_OK);
      if retCode = CURLE_OK then
        client.m_MultiHandle := CurlMulti.m_handle;
    end;

    class constructor CurlMulti.Create;
    begin
      CurlMulti.m_handle := 0;
    end;

    class destructor CurlMulti.Destroy;
    begin
      // Printf('CurlMulti.Destroy');
      // if CurlMulti.m_handle <> 0 then
      // curl_multi_cleanup(CurlMulti.m_handle);
    end;

    class function CurlMulti.Disable: LongBool;
    begin
      Assert(InitializeCount = 1);
      if CurlMulti.m_handle <> 0 then
      begin
        Result := curl_multi_cleanup(CurlMulti.m_handle) = CURLE_OK;
        CurlMulti.m_handle := 0;
      end;

    end;

    class function CurlMulti.enable: LongBool;
    begin
      Assert(InitializeCount > 0);
      CurlMulti.m_handle := Integer(curl_multi_init);
      Result := CurlMulti.m_handle <> 0;
    end;

    class function CurlMulti.GetHandle: Integer;
    begin
      Result := CurlMulti.m_handle;
    end;

    class procedure CurlMulti.Perform;
    var
      retCode: TCurlCode;
      running_handles: Integer;
    begin
      running_handles := 0;
      retCode := curl_multi_perform(CurlMulti.m_handle, running_handles);
      if retCode <> CURLE_OK then
        Printf(Integer(retCode), 'curl_multi_perform:');
    end;

    class function CurlMulti.ReadHandle(var msgsLeft: Integer): PCURLMsg;
    begin
      Result := curl_multi_info_read(CurlMulti.m_handle, msgsLeft)
    end;

    class procedure CurlMulti.RemoveHandle(const client: TAsyncRestClient);
    var
      retCode: Integer;
    begin
      Assert(client.m_handle <> 0);
      retCode := Integer(curl_multi_remove_handle(CurlMulti.m_handle, client.m_handle));
      Assert(retCode = 0);
      if retCode <> 0 then
        Printf(Integer(retCode), 'curl_multi_remove_handle:')
      else
        client.m_MultiHandle := 0;
    end;

    procedure TCurlDownLoadCore.SetVerifyPeer(const enable: LongBool);
    begin
      curl_easy_set(CURLOPT_SSL_VERIFYPEER, Integer(enable));
    end;

    procedure TCurlDownLoadCore.SetUserAgent(const user_agent: AnsiString);
    begin
      curl_easy_set(CURLOPT_USERAGENT, user_agent);
    end;

    procedure TCurlDownLoadCore.SetRanges(const ranges: AnsiString);
    begin
      curl_easy_set(CURLOPT_RANGE, ranges);
    end;

    { TAsyncRestClient }

    procedure TAsyncRestClient.Abort;
    begin
      if Self.IsPending then
      begin
        s_RestThread.Abort(Self);
        m_Event.SetDone;
      end;
    end;

    procedure TAsyncRestClient.Clear;
    begin
      Assert(Not Self.IsPending);
      inherited Clear;
    end;

    constructor TAsyncRestClient.Create;
    begin
      inherited Create;
      Self.m_Event := TCurlEvent.Create(True, True);
    end;

    destructor TAsyncRestClient.Destroy;
    begin
      Self.m_Event.Free;
      inherited Destroy;
    end;

    procedure TAsyncRestClient.ExecuteAsync;
    begin
      Self.Clear;
      Self.m_Event.Reset;
      s_RestThread.ExecuteTheTask(Self);
    end;

    procedure TAsyncRestClient.Free;
    begin
      if Self <> nil then
        Self.Destroy;
    end;

    function TAsyncRestClient.IsCompleted: LongBool;
    begin
      Result := (Not IsPending) and (m_Status <> ResponseStatus.None)
    end;

    function TAsyncRestClient.IsPending: LongBool;
    begin
      Result := not Self.Wait(0);
    end;

    procedure TAsyncRestClient.OnCompletion(status: TCurlCode);
    begin
      UpdateStatus(status);
      OnPerformed;
      m_Event.SetDone;
    end;

    procedure TAsyncRestClient.Wait;
    begin
      m_Event.WaitUntilDone;
    end;

    function TAsyncRestClient.Wait(timeoutMs: Cardinal): LongBool;
    begin
      Result := m_Event.WaitWithTimeout(timeoutMs);
    end;

    { TCurlEvent }

    constructor TCurlEvent.Create(const ManualReset, InitialState: LongBool;
      name: PAnsiChar = nil);
    begin
      inherited Create;
      Self.handle := CreateEventA(nil, ManualReset, InitialState, name);
    end;

    destructor TCurlEvent.Destroy;
    begin
      CloseHandle(Self.handle);
      inherited;
    end;

    procedure TCurlEvent.Pulse;
    begin
      PulseEvent(Self.handle);
    end;

    procedure TCurlEvent.Reset;
    begin
      ResetEvent(Self.handle);
    end;

    procedure TCurlEvent.SetDone;
    begin
      SetEvent(Self.handle);
    end;

    function TCurlEvent.TryWait: LongBool;
    begin
      Result := WaitForSingleObject(Self.handle, 0) = WAIT_OBJECT_0;
    end;

    class function TCurlEvent.TryWaitAll(const Events: TCurlEvent;
      const Count: size_t): LongBool;
    begin
      Result := WaitAllWithTimeout(Events, Count, 0);
    end;

    class function TCurlEvent.TryWaitAny(const Events: TCurlEvent;
      const Count: size_t; EventSignaled: PCurlEvent): LongBool;
    begin
      Result := WaitAnyWithTimeout(Events, Count, 0, EventSignaled);
    end;

    class procedure TCurlEvent.WaitAll(const Events: TCurlEvent; Count: size_t);
    begin
      WaitAllWithTimeout(Events, Count, INFINITE);
    end;

    class function TCurlEvent.WaitAllWithTimeout
      (const Events: array of TCurlEvent; const Count: size_t;
      const WaitMs: Cardinal): LongBool;
    var
      EventHandles: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle;
      I: size_t;
    begin
      Assert(Count <> 0);
      Assert(Count < MAXIMUM_WAIT_OBJECTS);
      for I := 0 to MAXIMUM_WAIT_OBJECTS - 1 do
      begin
        EventHandles[I] := Events[I].handle;
      end;
      Result := WaitForMultipleObjects(Count, @EventHandles, True, WaitMs) <> 0;
    end;

    class procedure TCurlEvent.WaitAny(const Events: TCurlEvent;
      const Count: size_t; const EventSignaled: PCurlEvent);
    begin
      WaitAnyWithTimeout(Events, Count, INFINITE, EventSignaled);
    end;

    class function TCurlEvent.WaitAnyWithTimeout
      (const Events: array of TCurlEvent; const Count: size_t;
      const WaitMs: Cardinal; const EventSignaled: PCurlEvent): LongBool;
    var
      EventHandles: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle;
      I: size_t;
      ret: Cardinal;
    begin
      Assert(Count <> 0);
      Assert(Count < MAXIMUM_WAIT_OBJECTS);
      for I := 0 to MAXIMUM_WAIT_OBJECTS - 1 do
      begin
        EventHandles[I] := Events[I].handle;
      end;
      ret := WaitForMultipleObjects(Count, @EventHandles, False, WaitMs);
      Result := (ret >= WAIT_OBJECT_0) and (ret < (WAIT_OBJECT_0 + Count));
      if Result and (EventSignaled <> nil) then
      begin
        EventSignaled^ := Events[ret - WAIT_OBJECT_0];
      end;

    end;

    procedure TCurlEvent.WaitUntilDone;
    begin
      WaitForSingleObject(Self.handle, INFINITE);
    end;

    function TCurlEvent.WaitWithTimeout(WaitMs: Cardinal): LongBool;
    begin
      Result := WaitForSingleObject(Self.handle, WaitMs) = WAIT_OBJECT_0;
    end;

    { TRestClient }

    constructor TRestClient.Create;
    begin
      Sleep(0);
      inherited;
    end;

    destructor TRestClient.Destroy;
    begin
      inherited Destroy;
    end;

    procedure TRestClient.Execute;
    begin
      Perform;
    end;

    procedure TRestClient.Free;
    begin
      if Self <> nil then
        Self.Destroy;
    end;

    function TRestClient.IsSuccessful: LongBool;
    begin
      Result := False;
      if (m_StatusCode < 200) or (300 <= m_StatusCode) then
        Exit;
      Result := m_Status = ResponseStatus.Completed;
    end;

    { TAsyncRestScopeInit }

    constructor TAsyncRestScopeInit.Create;
    begin
      inherited;
      Initialize;
      InitAsyncRest;
    end;

    destructor TAsyncRestScopeInit.Destroy;
    begin
      ShutdownAsyncRest;
      Terminate;
      inherited;
    end;

    { TRecursiveMutex }

    constructor TRecursiveMutex.Create;
    begin
      Self.mapMutex := TCriticalSection.Create;
      Self.recursiveMutex := TCriticalSection.Create;
      Self.lockNums := TDictionary<THandle, Integer>.Create;
    end;

    destructor TRecursiveMutex.Destroy;
    begin
      Self.mapMutex.Free;
      Self.recursiveMutex.Free;
      Self.lockNums.Free;
      inherited;
    end;

    procedure TRecursiveMutex.Enter;
    var
      threadID: THandle;
    begin
      mapMutex.Enter;
      threadID := GetCurrentThreadId;
      if lockNums.ContainsKey(threadID) then
      begin
        if lockNums[threadID] = 0 then
        begin
          lockNums[threadID] := 1;
          mapMutex.Leave;
          recursiveMutex.Enter;
        end
        else
        begin
          lockNums[threadID] := lockNums[threadID] + 1;
          mapMutex.Leave;
        end;
      end
      else
      begin
        lockNums.Add(threadID, 1);
        mapMutex.Leave;
        recursiveMutex.Enter;
      end;
    end;

    procedure TRecursiveMutex.Leave;
    var
      threadID: THandle;
    begin
      mapMutex.Enter;
      threadID := GetCurrentThreadId;
      if lockNums.ContainsKey(threadID) then
      begin
        if lockNums[threadID] = 0 then
        begin
          mapMutex.Leave;
          Assert('recursive_mutex lock and unlock Not In Matche');
        end
        else
        begin
          case lockNums[threadID] of
            1:
              begin
                lockNums.Remove(threadID);
                recursiveMutex.Leave;
              end
            else
              lockNums[threadID] := lockNums[threadID] - 1;
          end;
          mapMutex.Leave;
        end;
      end
      else
      begin
        mapMutex.Leave;
        Assert('recursive_mutex lock and unlock Not In Matche');
      end;
    end;

initialization

htLock := TRecursiveMutex.Create;
ScopeInit := TAsyncRestScopeInit.Create;

finalization

FreeAndNil(htLock);
ScopeInit.Free;

end.

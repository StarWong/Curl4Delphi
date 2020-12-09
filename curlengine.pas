unit curlengine;

interface


uses SysUtils,curl_h,Classes;

type
PChar = PAnsiChar;

type

 TCurlEngine = class (TComponent)
 private
  FStream:TStream;
  FUserName: string;
  FLastError: string;
  FPassword: string;
  FResultString: string;
 protected
  function DoDownload(Url,OutputFile:string): boolean;virtual;
  function DoUpload(URL:string): boolean;virtual;
 public
  constructor Create(Aowner:TComponent);override;
  destructor Destroy;override;
  function UploadFile(InputFile,URL:string):boolean;
  function UploadString(Data,URL:string):boolean;
  function Download(Url,OutputFile:string):boolean;
  procedure FreeResultString;
  property LastError:string read FLastError;
  property ResultString:string read FResultString;
 published
  property UserName:string read FUserName write FUserName;
  property Password:string read FPassword write FPassword;
 end;

procedure Register;


implementation

procedure Register;
begin
  RegisterComponents('Tekool', [TCurlEngine]);
end;

function WriteFunc(ptr:pointer;size,nmemb:longint;stream:TStream):longint; cdecl;
begin
  try
    Result:=stream.Write(ptr^,size*nmemb)
  except
     raise Exception.create('TCurlEngine : WriteFunc error');
  end;
end;

function ReadFunc(ptr:pointer;size,nmemb:longint;stream:TStream):longint; cdecl;
begin
  try
  if size*nmemb>stream.size then
   Result:=stream.Read(ptr^,stream.size)
  else
   Result:=stream.Read(ptr^,size*nmemb);
  except
   raise Exception.create('TCurlEngine : ReadFunc error');
  end;
end;

{ TCurlEngine }

constructor TCurlEngine.Create(Aowner: TComponent);
begin
  inherited;

end;

destructor TCurlEngine.Destroy;
begin
  inherited;
end;

function TCurlEngine.DoDownload(Url,OutputFile:string): boolean;
var
 HCurl:longint;
 rc:TCurlCode;
 s:string;
begin
 FResultString:='';
 Result:=false;
 try
 if OutputFile<>'' then
  FStream:=TFileStream.Create(OutputFile,fmCreate)
 else
 {$IFDEF FPC}
  FStream:=TFileStream.Create(inttostr(integer(self)),fmCreate) ;
 {$ELSE}
   FStream:=TStringStream.Create('');
 {$ENDIF}
  hCurl:= curl_easy_init;
  if UserName<>'' then
  curl_easy_set_pchar(hCurl, CURLOPT_USERPWD,Pchar(UserName+':'+PassWord));
  curl_easy_set_integer(HCurl,CURLOPT_TIMEOUT,1);
  curl_easy_set_pchar(HCurl, CURLOPT_URL, Pchar(URL));
  curl_easy_set_integer(HCurl,CURLOPT_FILE,integer(FStream));
  curl_easy_set_pointer(HCurl,CURLOPT_WRITEFUNCTION,@WriteFunc);
  rc:= curl_easy_perform(HCurl);
  if rc<>CURLE_OK then
   FLastError:=CurlCodeStrings[rc]
  else begin
   FLastError:='';
   Result:=true;
  end;
  curl_easy_cleanup(HCurl);
  if OutPutFile='' then begin
   FStream.Position := 0;
   SetLength(FResultString, FStream.size);
   FStream.ReadBuffer(Pointer(FResultString)^, FStream.size);
   DeleteFile(inttostr(integer(self)));
  end;
 finally
   DeleteFile(inttostr(integer(self)));
   FStream.free;
 end;
end;

function TCurlEngine.DoUpload(URL:string): boolean;
var
 HCurl:LongInt;
begin
 Result:=false;
 try
  if FStream=nil then
    raise EXception.create('TCurlEngine.DoUpload : FStream = nil !');
  hCurl:= curl_easy_init;
  if UserName<>'' then
    curl_easy_set_pchar(hCurl, CURLOPT_USERPWD,Pchar(UserName+':'+PassWord));
  if hCurl <> 0 then begin
    curl_easy_set_pchar(hCurl, CURLOPT_URL, PChar(URL));
    curl_easy_set_integer(hCurl,CURLOPT_UPLOAD, 1);
    curl_easy_set_pointer(hCurl,CURLOPT_READFUNCTION,@ReadFunc);
    curl_easy_set_pointer(hCurl, CURLOPT_INFILE, FStream);
    curl_easy_set_integer(hCurl, CURLOPT_INFILESIZE, longint(FStream.size));
    curl_easy_perform(hCurl);
    curl_easy_cleanup(hCurl);
  end;
 except
  raise;
 end;
end;


function TCurlEngine.UploadString(Data, URL: string): boolean;
begin
 FStream:= TStringStream. create(data);
 Result:=DoUpload(URL);
 FStream.Free;
end;


function TCurlEngine.Download(Url, OutputFile: string): boolean;
begin
 Result:=DoDownload(URL,OutputFile);
end;

procedure TCurlEngine.FreeResultString;
begin
 FResultString:='';
end;

function TCurlEngine.UploadFile(InputFile, URL: string): boolean;
begin
 FStream:=TFileStream.Create(InputFile,fmOpenWrite);
 Result:=DoUpload(URL);
 FStream.free;
end;

end.

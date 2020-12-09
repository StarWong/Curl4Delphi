unit RestClient;

interface
uses
CurlWrapper,Classes;
type

AsyncRestScopeInit = class

end;

TRestClient = class(CurlEasy)
public
procedure Execute;
function IsSuccessful:LongBool;
end;

TAsyncRestClient = class(TRestClient)
public
  procedure Clear;
  procedure Wait;overload;
  function Wait(TimeoutMs:Integer):LongBool;overload;
  function IsPending:LongBool;
  function IsCompleted:LongBool;
  procedure ExecuteAsync;
  procedure Abort;
  procedure OnCompletion(Status:Integer);
  strict private
  m_Event:THandle;
end;

TCurlMultiThread  = class(TThread)
  private
  m_pMulti:PCurlMulti;
  m_Running:LongBool;
  m_Mutex:THandle;
  protected
  procedure execute;override;
  constructor Create; overload;
end;

implementation




{ TRestClient }

procedure TRestClient.Execute;
begin

end;

function TRestClient.IsSuccessful: LongBool;
begin

end;

{ TAsyncRestClient }

procedure TAsyncRestClient.Abort;
begin

end;

procedure TAsyncRestClient.Clear;
begin

end;

procedure TAsyncRestClient.ExecuteAsync;
begin

end;

function TAsyncRestClient.IsCompleted: LongBool;
begin

end;

function TAsyncRestClient.IsPending: LongBool;
begin

end;

procedure TAsyncRestClient.OnCompletion(Status: Integer);
begin

end;

function TAsyncRestClient.Wait(TimeoutMs: Integer): LongBool;
begin

end;

procedure TAsyncRestClient.Wait;
begin

end;

{ TCurlMultiThread }

constructor TCurlMultiThread.Create;
begin
      m_pMulti:=nil;
end;

procedure TCurlMultiThread.execute;
begin
       FreeOnTerminate:=True;

end;

end.

unit Curl;

{$DEFINE STATIC}

{$IFNDEF STATIC}
{$IFNDEF DYNAMIC}
{$DEFINE ERROR}
{$ENDIF}
{$ELSE}
{$UNDEF DYNAMIC}
{$ENDIF}

interface

type
{$Z4}
TCURLcode =(
CURLE_OK = 0,                      //* 0 */
CURLE_UNSUPPORTED_PROTOCOL = 1,    //* 1 */
CURLE_FAILED_INIT = 2,             //* 2 */
CURLE_URL_MALFORMAT = 3,           //* 3 */
CURLE_NOT_BUILT_IN = 4,            //* 4 - [was obsoleted in August 2007 for
                                           //* 7.17.0, reused in April 2011 for 7.21.5] */
CURLE_COULDNT_RESOLVE_PROXY = 5,   //* 5 */
CURLE_COULDNT_RESOLVE_HOST =6,     //* 6 */
CURLE_COULDNT_CONNECT = 7,         //* 7 */
CURLE_WEIRD_SERVER_REPLY = 8,      //* 8 */
CURLE_REMOTE_ACCESS_DENIED = 9,    //* 9 a service was denied by the server
                                            //*due to lack of access - when login fails
                                            //*this is not returned. */
CURLE_FTP_ACCEPT_FAILED = 10,       //* 10 - [was obsoleted in April 2006 for
                                            //7.15.4, reused in Dec 2011 for 7.24.0]*/
CURLE_FTP_WEIRD_PASS_REPLY = 11,    //* 11 */
CURLE_FTP_ACCEPT_TIMEOUT = 12,      //* 12 - timeout occurred accepting server
                                            //[was obsoleted in August 2007 for 7.17.0,
                                             //reused in Dec 2011 for 7.24.0]*/
CURLE_FTP_WEIRD_PASV_REPLY = 13,    //* 13 */
CURLE_FTP_WEIRD_227_FORMAT = 14,    //* 14 */
CURLE_FTP_CANT_GET_HOST = 15 ,       //* 15 */
CURLE_HTTP2 = 16,                   //* 16 - A problem in the http2 framing layer.
                                             //[was obsoleted in August 2007 for 7.17.0,
                                             //reused in July 2014 for 7.38.0] */
CURLE_FTP_COULDNT_SET_TYPE = 17,    //* 17 */
CURLE_PARTIAL_FILE = 18,            //* 18 */
CURLE_FTP_COULDNT_RETR_FILE = 19,   //* 19 */
CURLE_OBSOLETE20 = 20,              //* 20 - NOT USED */
CURLE_QUOTE_ERROR = 21,             //* 21 - quote command failure */
CURLE_HTTP_RETURNED_ERROR = 22,     //* 22 */
CURLE_WRITE_ERROR = 23,             //* 23 */
CURLE_OBSOLETE24 = 24,              //* 24 - NOT USED */
CURLE_UPLOAD_FAILED = 25,           //* 25 - failed upload "command" */
CURLE_READ_ERROR =26 ,              //* 26 - couldn't open/read from file */
CURLE_OUT_OF_MEMORY = 27,           //* 27 */
  //* Note: const CURLE_OUT_OF_MEMORY may sometimes indicate a conversion error
  //         instead of a memory allocation error if CURL_DOES_CONVERSIONS
  ///         is defined
  //*/
CURLE_OPERATION_TIMEDOUT = 28,      //* 28 - the timeout time was reached */
CURLE_OBSOLETE29 = 29,              //* 29 - NOT USED */
CURLE_FTP_PORT_FAILED = 30,         //* 30 - FTP PORT operation failed */
CURLE_FTP_COULDNT_USE_REST = 31,    //* 31 - the REST command failed */
CURLE_OBSOLETE32 = 32,              //* 32 - NOT USED */
CURLE_RANGE_ERROR = 33,             //* 33 - RANGE "command" didn't work */
CURLE_HTTP_POST_ERROR = 34,         //* 34 */
CURLE_SSL_CONNECT_ERROR = 35,       //* 35 - wrong when connecting with SSL */
CURLE_BAD_DOWNLOAD_RESUME = 36,     //* 36 - couldn't resume download */
CURLE_FILE_COULDNT_READ_FILE = 37,  //* 37 */
CURLE_LDAP_CANNOT_BIND = 38,        //* 38 */
CURLE_LDAP_SEARCH_FAILED = 39,      //* 39 */
CURLE_OBSOLETE40 = 40,              //* 40 - NOT USED */
CURLE_FUNCTION_NOT_FOUND = 41,      //* 41 - NOT USED starting with 7.53.0 */
CURLE_ABORTED_BY_CALLBACK = 42,     //* 42 */
CURLE_BAD_FUNCTION_ARGUMENT = 43,   //* 43 */
CURLE_OBSOLETE44 = 44,              //* 44 - NOT USED */
CURLE_INTERFACE_FAILED = 45,        //* 45 - CURLOPT_INTERFACE failed */
CURLE_OBSOLETE46 = 46,              //* 46 - NOT USED */
CURLE_TOO_MANY_REDIRECTS = 47,      //* 47 - catch endless re-direct loops */
CURLE_UNKNOWN_OPTION = 48,          //* 48 - User specified an unknown option */
CURLE_TELNET_OPTION_SYNTAX = 49,    //* 49 - Malformed telnet option */
CURLE_OBSOLETE50 = 50,              //* 50 - NOT USED */
CURLE_OBSOLETE51 = 51,              //* 51 - NOT USED */
CURLE_GOT_NOTHING = 52,             //* 52 - when this is a specific error */
CURLE_SSL_ENGINE_NOTFOUND = 53,     //* 53 - SSL crypto engine not found */
CURLE_SSL_ENGINE_SETFAILED = 54,    //* 54 - can not set SSL crypto engine as
  //                                  default */
CURLE_SEND_ERROR = 55,              //* 55 - failed sending network data */
CURLE_RECV_ERROR = 56,              //* 56 - failure in receiving network data */
CURLE_OBSOLETE57 = 57,              //* 57 - NOT IN USE */
CURLE_SSL_CERTPROBLEM = 58,         //* 58 - problem with the local certificate */
CURLE_SSL_CIPHER = 59,              //* 59 - couldn't use specified cipher */
CURLE_PEER_FAILED_VERIFICATION = 60, //* 60 - peer's certificate or fingerprint
  //                                   wasn't verified fine */
CURLE_BAD_CONTENT_ENCODING = 61,    //* 61 - Unrecognized/bad encoding */
CURLE_LDAP_INVALID_URL = 62,        //* 62 - Invalid LDAP URL */
CURLE_FILESIZE_EXCEEDED = 63,       //* 63 - Maximum file size exceeded */
CURLE_USE_SSL_FAILED = 64,          //* 64 - Requested FTP SSL level failed */
CURLE_SEND_FAIL_REWIND = 65,        //* 65 - Sending the data requires a rewind
  //                                  that failed */
CURLE_SSL_ENGINE_INITFAILED = 66,   //* 66 - failed to initialise ENGINE */
CURLE_LOGIN_DENIED = 67,            //* 67 - user, password or similar was not
  //                                  accepted and we failed to login */
CURLE_TFTP_NOTFOUND = 68,           //* 68 - file not found on server */
CURLE_TFTP_PERM = 69,               //* 69 - permission problem on server */
CURLE_REMOTE_DISK_FULL = 70,        //* 70 - out of disk space on server */
CURLE_TFTP_ILLEGAL = 71,            //* 71 - Illegal TFTP operation */
CURLE_TFTP_UNKNOWNID = 72,          //* 72 - Unknown transfer ID */
CURLE_REMOTE_FILE_EXISTS = 73,      //* 73 - File already exists */
CURLE_TFTP_NOSUCHUSER = 74,         //* 74 - No such user */
CURLE_CONV_FAILED = 75,             //* 75 - conversion failed */
CURLE_CONV_REQD = 76,               //* 76 - caller must register conversion
  //                                  callbacks using curl_easy_setopt options
  //                                  CURLOPT_CONV_FROM_NETWORK_FUNCTION,
  //                                  CURLOPT_CONV_TO_NETWORK_FUNCTION, and
  //                                  CURLOPT_CONV_FROM_UTF8_FUNCTION */
CURLE_SSL_CACERT_BADFILE = 77,      //* 77 - could not load CACERT file, missing
  //                                  or wrong format */
CURLE_REMOTE_FILE_NOT_FOUND = 78,   //* 78 - remote file not found */
CURLE_SSH =79,                     //* 79 - error from the SSH layer, somewhat
  //                                  generic so the error message will be of
  //                                  interest when this has happened */
  //
CURLE_SSL_SHUTDOWN_FAILED = 80,     //* 80 - Failed to shut down the SSL
  //                                  connection */
CURLE_AGAIN = 81,                   //* 81 - socket is not ready for send/recv,
  //                                  wait till it's ready and try again (Added
  //                                 in 7.18.2) */
CURLE_SSL_CRL_BADFILE = 82,         //* 82 - could not load CRL file, missing or
  //                                  wrong format (Added in 7.19.0) */
CURLE_SSL_ISSUER_ERROR = 83,        //* 83 - Issuer check failed.  (Added in
  //                                  7.19.0) */
CURLE_FTP_PRET_FAILED = 84,         //* 84 - a PRET command failed */
CURLE_RTSP_CSEQ_ERROR = 85,         //* 85 - mismatch of RTSP CSeq numbers */
CURLE_RTSP_SESSION_ERROR = 86,      //* 86 - mismatch of RTSP Session Ids */
CURLE_FTP_BAD_FILE_LIST = 87,       //* 87 - unable to parse FTP file list */
CURLE_CHUNK_FAILED = 88,            //* 88 - chunk callback reported error */
CURLE_NO_CONNECTION_AVAILABLE = 89, //* 89 - No connection available, the
  //                                  session will be queued */
CURLE_SSL_PINNEDPUBKEYNOTMATCH = 90, //* 90 - specified pinned public key did not
  //                                   match */
CURLE_SSL_INVALIDCERTSTATUS = 91,   //* 91 - invalid certificate status */
CURLE_HTTP2_STREAM = 92,            //* 92 - stream error in HTTP/2 framing layer
  //                                  */
CURLE_RECURSIVE_API_CALL = 93,      //* 93 - an api function was called from
  //                                  inside a callback */
CURLE_AUTH_ERROR = 94,              //* 94 - an authentication function returned an
  //                                  error */
CURLE_HTTP3 = 95,                   //* 95 - An HTTP/3 layer problem */
CURLE_QUIC_CONNECT_ERROR = 96,      //* 96 - QUIC connection error */
CURLE_PROXY = 97,                   //* 97 - proxy handshake error */
CURL_LAST = 98                     //* never use! */
);
TCURLMcode =(
 CURLM_CALL_MULTI_PERFORM = -1, //* please call curl_multi_perform() or
                                    //curl_multi_socket*() soon */
 CURLM_OK=0,
 CURLM_BAD_HANDLE=1,      //* the passed-in handle is not a valid const CURLM handle */
 CURLM_BAD_EASY_HANDLE=2, //* an easy handle was not good/valid */
 CURLM_OUT_OF_MEMORY=3,   //* if you ever get this=, you're in deep sh*t */
 CURLM_INTERNAL_ERROR=4,  //* this is a libcurl bug */
 CURLM_BAD_SOCKET=5,      //* the passed in socket argument did not match */
 CURLM_UNKNOWN_OPTION=6,  //* curl_multi_setopt() with unsupported option */
 CURLM_ADDED_ALREADY=7,   //* an easy handle already added to a multi handle was
                            //attempted to get added - again */
 CURLM_RECURSIVE_API_CALL=8, //* an api function was called from inside a
                               //callback */
 CURLM_WAKEUP_FAILURE=9,  //* wakeup is unavailable or failed */
 CURLM_BAD_FUNCTION_ARGUMENT=10,  //* function called with a bad parameter */
 CURLM_LAST=11
);

type
  PCurl_Slist = ^TCurl_Slist;
  TCurl_Slist = record
    data : PAnsiChar;
    next : PCurl_Slist;
 end;

CURLMSG_ENUM = (CURLMSG_NONE,CURLMSG_DONE,CURLMSG_LAST);

PCURLMsg = ^TCURLMsg;
TCURLMsg = record
CURLMsg:CURLMSG_ENUM;
easy_handle:Integer;
data:record
case Integer of
0:(whatever:Pointer);
1:(result:TCurlCode)
end
end;

TCURLoption =(
  CURL_GLOBAL_SSL= (1 shl 0),
  CURL_GLOBAL_WIN32= (1 shl 1),
  CURL_GLOBAL_ALL =((1 shl 0) or (1 shl 1)),
  CURLOPT_TIMEOUT = 13,
  CURLOPT_FOLLOWLOCATION =52,
  CURLOPT_SSL_VERIFYPEER =64,
  CURLOPT_WRITEDATA = 10001,
  CURLOPT_URL = 10002,
  CURLOPT_RANGE = 10007,
  CURLOPT_ERRORBUFFER = 10010,
  CURLOPT_USERAGENT = 10018,
  CURLOPT_HTTPHEADER = 10023,
  CURLOPT_HEADERDATA = 10029,
  CURLOPT_WRITEFUNCTION = 20011,
  CURLOPT_READFUNCTION = 20012,
  CURLOPT_HEADERFUNCTION = 20079
);

CURLINFO =(
CURLINFO_RESPONSE_CODE = 2097154
);

{$IFDEF STATIC}
type
TCurl_Easy_Set_Integer =function(handle:LongInt; option:integer; value:LongInt):TCurlCode; cdecl;
TCurl_Easy_Set_Pointer =function(handle:LongInt; option:integer; value:Pointer):TCurlCode; cdecl;
TCurl_Easy_set_PAnsiChar =function(handle:LongInt; option:integer; value:PAnsiChar):TCurlCode; cdecl;
TCurl_Version = function:PAnsiChar;cdecl;
TCurl_Global_Cleanup = procedure;cdecl;
TCurl_Global_Init =procedure(flag:TCURLoption);cdecl;
TCurl_Easy_Init =function:LongInt; cdecl;
TCurl_Easy_Reset =procedure(handle:LongInt);cdecl;
TCurl_Easy_Cleanup =procedure(handle:LongInt);cdecl;
TCurl_Easy_Perform =function(handle:LongInt):TCurlCode;cdecl;
TCurl_Multi_Add_Handle =function(multi_handle:LongInt;easy_handle:LongInt):TCurlCode;cdecl;
TCurl_Easy_Getinfo =function(handle:LongInt; request:CURLINFO; return:pointer):TCurlCode;cdecl;
TCurl_Slist_Append =function(aList:pcurl_slist; aData:PChar):PCurl_Slist; cdecl;
TCurl_Slist_Free_All =procedure(aList:pcurl_slist); cdecl;
TCurl_Multi_Remove_Handle =function(multi_handle:Integer;curl_handle:Integer):TCurlCode;cdecl;
TCurl_Multi_Perform =function(multi_handle:Integer;var running_handles:Integer):TCurlCode;cdecl;
TCurl_Multi_Cleanup =function(multi_handle:Integer):TCurlCode;cdecl;
TCurl_Multi_Init =function:TCurlCode;cdecl;
TCurl_Multi_Info_Read =function(multi_handle:Integer;var msgs_in_queue:Integer):PCURLMsg;cdecl;
TCurl_Escape =function(str:PAnsiChar;length:Integer):PAnsiChar;cdecl;
TCurl_Free =procedure(pHandle:Pointer);cdecl;
const
{$J+}
Curl_Easy_Set_Integer :TCurl_Easy_Set_Integer =nil;
Curl_Easy_Set_Pointer :TCurl_Easy_Set_Pointer =nil;
Curl_Easy_set_PAnsiChar:TCurl_Easy_set_PAnsiChar =nil;
Curl_Version:TCurl_Version =nil;
Curl_Global_Cleanup:TCurl_Global_Cleanup =nil;
Curl_Global_Init:TCurl_Global_Init =nil;
Curl_Easy_Init:TCurl_Easy_Init =nil;
Curl_Easy_Reset:TCurl_Easy_Reset =nil;
Curl_Easy_Cleanup:TCurl_Easy_Cleanup =nil;
Curl_Easy_Perform:TCurl_Easy_Perform =nil;
Curl_Multi_Add_Handle:TCurl_Multi_Add_Handle =nil;
Curl_Easy_Getinfo:TCurl_Easy_Getinfo =nil;
Curl_Slist_Append:TCurl_Slist_Append =nil;
Curl_Slist_Free_All:TCurl_Slist_Free_All =nil;
Curl_Multi_Remove_Handle:TCurl_Multi_Remove_Handle =nil;
Curl_Multi_Perform:TCurl_Multi_Perform =nil;
Curl_Multi_Cleanup:TCurl_Multi_Cleanup =nil;
Curl_Multi_Init:TCurl_Multi_Init =nil;
Curl_Multi_Info_Read:TCurl_Multi_Info_Read =nil;
Curl_Escape:TCurl_Escape =nil;
Curl_Free:TCurl_Free =nil;
{$J-}
{$ENDIF}

{$IFDEF DYNAMIC}
const
LIB_CURL='libcurl.dll';
function Curl_Easy_Set_Integer(handle:LongInt; option:integer; value:LongInt):TCurlCode; cdecl;
external LIB_CURL name 'curl_easy_setopt';
function Curl_Easy_Set_Pointer(handle:LongInt; option:integer; value:Pointer):TCurlCode; cdecl;
external LIB_CURL name 'curl_easy_setopt';
function Curl_Easy_set_PAnsiChar(handle:LongInt; option:integer; value:PAnsiChar):TCurlCode; cdecl;
external LIB_CURL name 'curl_easy_setopt';
function Curl_Version:PAnsiChar;cdecl;
external LIB_CURL name 'curl_version';
procedure Curl_Global_Cleanup;cdecl;
external LIB_CURL name 'curl_global_cleanup';
procedure Curl_Global_Init(flag:TCURLoption);cdecl;
external LIB_CURL name 'curl_global_init';
function  Curl_Easy_Init:LongInt; cdecl;
external LIB_CURL name 'curl_easy_init';
procedure Curl_Easy_Reset(handle:LongInt);cdecl;
external LIB_CURL name 'curl_easy_reset';
procedure Curl_Easy_Cleanup(handle:LongInt);cdecl;
external LIB_CURL name 'curl_easy_cleanup';
function Curl_Easy_Perform(handle:LongInt):TCurlCode;cdecl;
external LIB_CURL name 'curl_easy_perform';
function Curl_Multi_Add_Handle(multi_handle:LongInt;easy_handle:LongInt):TCurlCode;cdecl;
external LIB_CURL name 'curl_multi_add_handle';
function Curl_Easy_Getinfo(handle:LongInt; request:CURLINFO; return:pointer):TCurlCode;cdecl;
external LIB_CURL name 'curl_easy_getinfo';
function Curl_Slist_Append(aList:pcurl_slist; aData:PChar):PCurl_Slist; cdecl;
external LIB_CURL name 'curl_slist_append';
procedure Curl_Slist_Free_All(aList:pcurl_slist); cdecl;
external LIB_CURL name 'curl_slist_free_all';
function Curl_Multi_Remove_Handle(multi_handle:Integer;curl_handle:Integer):TCurlCode;cdecl;
external LIB_CURL name 'curl_multi_remove_handle';
function Curl_Multi_Perform(multi_handle:Integer;var running_handles:Integer):TCurlCode;cdecl;
external LIB_CURL name 'curl_multi_perform';
function Curl_Multi_Cleanup(multi_handle:Integer):TCurlCode;cdecl;
external LIB_CURL name 'curl_multi_cleanup';
function Curl_Multi_Init:TCurlCode;cdecl;
external LIB_CURL name 'curl_multi_init';
function Curl_Multi_Info_Read(multi_handle:Integer;var msgs_in_queue:Integer):PCURLMsg;cdecl;
external LIB_CURL name 'curl_multi_info_read';
function Curl_Escape(str:PAnsiChar;length:Integer):PAnsiChar;cdecl;
external LIB_CURL name 'curl_escape';
procedure Curl_Free(pHandle:Pointer);cdecl;
external LIB_CURL name 'curl_free';
{$ENDIF}


implementation
{$IFDEF STATIC}
uses
Classes,MemLibrary,Logger;
{$R LibCurl.RES}
var
Caller:PBTMemoryModule;
Res:TResourceStream;
function GetResStream:Boolean;
begin
 Result:=True;
  try
    Res:=TResourceStream.Create(HInstance,'DllBin','DllData');
  except
  Result:=False;
  end;
end;

procedure FreeResStream;
begin
  if Assigned(Res) then
  begin
    Res.Free;
    Res:=nil;
  end;
end;

procedure RegisterFunctions;
procedure DoRegister(const name:PWideChar;var func:Pointer);inline;
begin
 func:=memGetProcAddress(Caller,name);
 {$IFDEF DEBUG}
 Assert(func <> nil);
 {$ENDIF}
end;
begin
Assert(Caller <> nil);
DoRegister('curl_easy_setopt',@Curl_Easy_Set_Integer);
DoRegister('curl_easy_setopt',@Curl_Easy_Set_Pointer);
DoRegister('curl_easy_setopt',@Curl_Easy_set_PAnsiChar);
DoRegister('curl_version',@Curl_Version);
DoRegister('curl_global_cleanup',@Curl_Global_Cleanup);
DoRegister('curl_global_init',@Curl_Global_Init);
DoRegister('curl_easy_init',@Curl_Easy_Init);
DoRegister('curl_easy_reset',@Curl_Easy_Reset);

DoRegister('curl_easy_cleanup',@Curl_Easy_Cleanup);
DoRegister('curl_easy_perform',@Curl_Easy_Perform);
DoRegister('curl_multi_add_handle',@Curl_Multi_Add_Handle);
DoRegister('curl_easy_getinfo',@Curl_Easy_Getinfo);
DoRegister('curl_slist_append',@Curl_Slist_Append);
DoRegister('curl_slist_free_all',@Curl_Slist_Free_All);
DoRegister('curl_multi_remove_handle',@Curl_Multi_Remove_Handle);
DoRegister('curl_multi_perform',@Curl_Multi_Perform);

DoRegister('curl_multi_cleanup',@Curl_Multi_Cleanup);
DoRegister('curl_multi_init',@Curl_Multi_Init);
DoRegister('curl_multi_info_read',@Curl_Multi_Info_Read);
DoRegister('curl_escape',@Curl_Escape);
DoRegister('curl_free',@Curl_Free);


end;
initialization
{$IFDEF ERROR}
Exit;
{$ENDIF}
Assert(GetResStream);
Caller:=memLoadLibrary(Res.Memory,Res.Size);
RegisterFunctions;
finalization
memFreeLibrary(Caller);
FreeResStream;
{$ENDIF}
end.

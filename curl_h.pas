unit Curl_h;

interface
 const
  {$IFDEF LINUX}
  LIB_CURL = 'libcurl.so';
  {$ENDIF}
  {$IFDEF WIN32}
  LIB_CURL='libcurl.dll';
  {$ENDIF}

  {Global_init flags constants}
  CURL_GLOBAL_SSL= (1 shl 0);
  CURL_GLOBAL_WIN32= (1 shl 1);
  CURL_GLOBAL_ALL =(CURL_GLOBAL_SSL or CURL_GLOBAL_WIN32);
  CURL_GLOBAL_NOTHING=0;
  CURL_GLOBAL_DEFAULT= CURL_GLOBAL_ALL;
  
 {Return codes for curl_easy_ functions}
 type
 PChar = PAnsiChar;


 type TCurlCode = (
   CURLE_OK, CURLE_UNSUPPORTED_PROTOCOL, CURLE_FAILED_INIT, CURLE_URL_MALFORMAT, CURLE_URL_MALFORMAT_USER,
   CURLE_COULDNT_RESOLVE_PROXY, CURLE_COULDNT_RESOLVE_HOST, CURLE_COULDNT_CONNECT, CURLE_FTP_WEIRD_SERVER_REPLY,
   CURLE_FTP_ACCESS_DENIED, CURLE_FTP_USER_PASSWORD_INCORRECT, CURLE_FTP_WEIRD_PASS_REPLY, CURLE_FTP_WEIRD_USER_REPLY,
   CURLE_FTP_WEIRD_PASV_REPLY, CURLE_FTP_WEIRD_227_FORMAT, CURLE_FTP_CANT_GET_HOST, CURLE_FTP_CANT_RECONNECT,
   CURLE_FTP_COULDNT_SET_BINARY, CURLE_PARTIAL_FILE, CURLE_FTP_COULDNT_RETR_FILE, CURLE_FTP_WRITE_ERROR,
   CURLE_FTP_QUOTE_ERROR, CURLE_HTTP_NOT_FOUND, CURLE_WRITE_ERROR, CURLE_MALFORMAT_USER, CURLE_FTP_COULDNT_STOR_FILE,
   CURLE_READ_ERROR, CURLE_OUT_OF_MEMORY, CURLE_OPERATION_TIMEOUTED, CURLE_FTP_COULDNT_SET_ASCII, CURLE_FTP_PORT_FAILED,
   CURLE_FTP_COULDNT_USE_REST, CURLE_FTP_COULDNT_GET_SIZE, CURLE_HTTP_RANGE_ERROR, CURLE_HTTP_POST_ERROR,
   CURLE_SSL_CONNECT_ERROR, CURLE_FTP_BAD_DOWNLOAD_RESUME, CURLE_FILE_COULDNT_READ_FILE, CURLE_LDAP_CANNOT_BIND,
   CURLE_LDAP_SEARCH_FAILED, CURLE_LIBRARY_NOT_FOUND, CURLE_FUNCTION_NOT_FOUND, CURLE_ABORTED_BY_CALLBACK,
   CURLE_BAD_FUNCTION_ARGUMENT, CURLE_BAD_CALLING_ORDER, CURLE_HTTP_PORT_FAILED, CURLE_BAD_PASSWORD_ENTERED,
   CURLE_TOO_MANY_REDIRECTS, CURLE_UNKNOWN_TELNET_OPTION, CURLE_TELNET_OPTION_SYNTAX, CURLE_OBSOLETE,
   CURLE_SSL_PEER_CERTIFICATE, CURLE_GOT_NOTHING, CURLE_SSL_ENGINE_NOTFOUND, CURLE_SSL_ENGINE_SETFAILED, CURL_LAST,
   CURLE_RECV_ERROR
 );

 { CurlCODE's as strings ... }
 const CurlCodeStrings : array[CURLE_OK..CURL_LAST] of string[33] = (
   'CURLE_OK', 'CURLE_UNSUPPORTED_PROTOCOL', 'CURLE_FAILED_INIT', 'CURLE_URL_MALFORMAT', 'CURLE_URL_MALFORMAT_USER',
   'CURLE_COULDNT_RESOLVE_PROXY', 'CURLE_COULDNT_RESOLVE_HOST', 'CURLE_COULDNT_CONNECT', 'CURLE_FTP_WEIRD_SERVER_REPLY',
   'CURLE_FTP_ACCESS_DENIED', 'CURLE_FTP_USER_PASSWORD_INCORRECT', 'CURLE_FTP_WEIRD_PASS_REPLY', 'CURLE_FTP_WEIRD_USER_REPLY',
   'CURLE_FTP_WEIRD_PASV_REPLY', 'CURLE_FTP_WEIRD_227_FORMAT', 'CURLE_FTP_CANT_GET_HOST', 'CURLE_FTP_CANT_RECONNECT',
   'CURLE_FTP_COULDNT_SET_BINARY', 'CURLE_PARTIAL_FILE', 'CURLE_FTP_COULDNT_RETR_FILE', 'CURLE_FTP_WRITE_ERROR',
   'CURLE_FTP_QUOTE_ERROR', 'CURLE_HTTP_NOT_FOUND', 'CURLE_WRITE_ERROR', 'CURLE_MALFORMAT_USER', 'CURLE_FTP_COULDNT_STOR_FILE',
   'CURLE_READ_ERROR', 'CURLE_OUT_OF_MEMORY', 'CURLE_OPERATION_TIMEOUTED', 'CURLE_FTP_COULDNT_SET_ASCII', 'CURLE_FTP_PORT_FAILED',
   'CURLE_FTP_COULDNT_USE_REST', 'CURLE_FTP_COULDNT_GET_SIZE', 'CURLE_HTTP_RANGE_ERROR', 'CURLE_HTTP_POST_ERROR',
   'CURLE_SSL_CONNECT_ERROR', 'CURLE_FTP_BAD_DOWNLOAD_RESUME', 'CURLE_FILE_COULDNT_READ_FILE', 'CURLE_LDAP_CANNOT_BIND',
   'CURLE_LDAP_SEARCH_FAILED', 'CURLE_LIBRARY_NOT_FOUND', 'CURLE_FUNCTION_NOT_FOUND', 'CURLE_ABORTED_BY_CALLBACK',
   'CURLE_BAD_FUNCTION_ARGUMENT', 'CURLE_BAD_CALLING_ORDER', 'CURLE_HTTP_PORT_FAILED', 'CURLE_BAD_PASSWORD_ENTERED',
   'CURLE_TOO_MANY_REDIRECTS', 'CURLE_UNKNOWN_TELNET_OPTION', 'CURLE_TELNET_OPTION_SYNTAX', 'CURLE_OBSOLETE',
   'CURLE_SSL_PEER_CERTIFICATE', 'CURLE_GOT_NOTHING', 'CURLE_SSL_ENGINE_NOTFOUND', 'CURLE_SSL_ENGINE_SETFAILED', 'CURL_LAST'
 );

 type
 { List type used by some curl functions ... }
  pcurl_slist = ^tcurl_slist;
  tcurl_slist = record
    data : PChar;
    next : pcurl_slist;
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

{Curl Base Functions}
 function curl_version: PChar; cdecl; external LIB_CURL;
 procedure curl_global_cleanup;stdcall; cdecl; external LIB_CURL name 'curl_global_cleanup';
 procedure curl_global_init(flag:longint);cdecl; external LIB_CURL name 'curl_global_init';
{Curl Easy Functions}
 function curl_easy_init:LongInt; cdecl; external LIB_CURL;
 procedure curl_easy_reset(handle:LongInt);cdecl; external LIB_CURL;
 procedure curl_easy_cleanup(handle:LongInt);cdecl; external LIB_CURL;
 function curl_easy_perform(handle:LongInt):TCurlCode;cdecl; external LIB_CURL;
 function curl_multi_add_handle(multi_handle:LongInt;easy_handle:LongInt):TCurlCode;stdcall; cdecl; external LIB_CURL;

 function curl_easy_getinfo(handle:LongInt; request:LongInt; return:pointer):TCurlCode;cdecl; external LIB_CURL;
 function curl_easy_set_integer(handle:LongInt; option:integer; value:LongInt):TCurlCode; cdecl; external LIB_CURL name 'curl_easy_setopt';
 function curl_easy_set_pointer(handle:LongInt; option:integer; value:pointer):TCurlCode; cdecl; external LIB_CURL name 'curl_easy_setopt';
 function curl_easy_set_pchar(handle:LongInt; option:integer; value:PChar):TCurlCode; cdecl; external LIB_CURL name 'curl_easy_setopt';
 {Curl List Functions}
 function curl_slist_append(aList:pcurl_slist; aData:PChar):pcurl_slist; cdecl; external LIB_CURL;
 procedure curl_slist_free_all(aList:pcurl_slist); cdecl; external LIB_CURL;
 {}
 function curl_multi_remove_handle(multi_handle:Integer;curl_handle:Integer):Integer;
 cdecl; external LIB_CURL;

 function curl_multi_perform(multi_handle:Integer;var running_handles:Integer):TCurlCode;
 cdecl; external LIB_CURL;

 function curl_multi_cleanup(multi_handle:Integer):Integer;
 cdecl; external LIB_CURL;

 function curl_multi_init:Integer;
 cdecl; external LIB_CURL;

 function curl_multi_info_read(multi_handle:Integer;var msgs_in_queue:Integer):PCURLMsg;
 cdecl; external LIB_CURL;

 function curl_escape(str:PAnsiChar;length:Integer):PAnsiChar;
 cdecl; external LIB_CURL;

 procedure curl_free(p:Pointer);
 cdecl; external LIB_CURL;

const

 CURL_ERROR_SIZE = 256; { -- Maximum size of error strings returned by libcurl }

 CURLCLOSEPOLICY_OLDEST = 1;
 CURLCLOSEPOLICY_LEAST_RECENTLY_USED = 2;
 CURL_HTTP_VERSION_NONE = 0;
 CURL_HTTP_VERSION_1_0 = 1;
 CURL_HTTP_VERSION_1_1 = 2;

{Curl Options}
 {boolean options}
 CURLOPT_NOTHING = 0;
 CURLOPT_CRLF = 27;
 CURLOPT_VERBOSE = 41;
 CURLOPT_HEADER = 42;

 CURLOPT_NOPROGRESS = 43;
 CURLOPT_NOBODY = 44;
 CURLOPT_FAILONERROR = 45;
 CURLOPT_UPLOAD = 46;
 CURLOPT_POST = 47;
 CURLOPT_FTPLISTONLY = 48;
 CURLOPT_FTPAPPEND = 50;
 CURLOPT_NETRC = 51;
 CURLOPT_FOLLOWLOCATION = 52;
 CURLOPT_TRANSFERTEXT = 53;
 CURLOPT_PUT = 54;
 CURLOPT_HTTPPROXYTUNNEL = 61;
 CURLOPT_SSL_VERIFYPEER = 64;
 CURLOPT_FRESH_CONNECT = 74;
 CURLOPT_FORBID_REUSE = 75;
 CURLOPT_HTTPGET = 80;
 CURLOPT_FTP_USE_EPSV = 85;
 CURLOPT_AUTOREFERER = 58;

 { integer Options }
 CURLOPT_PORT = 3;
 CURLOPT_TIMEOUT =13;
 CURLOPT_LOW_SPEED_LIMIT = 19;
 CURLOPT_LOW_SPEED_TIME = 20;
 CURLOPT_RESUME_FROM = 21;
 CURLOPT_SSLVERSION = 32;
 CURLOPT_TIMECONDITION = 33;
 CURLOPT_TIMEVALUE = 34;
 CURLOPT_PROXYPORT = 59;
 CURLOPT_POSTFIELDSIZE = 60;
 CURLOPT_MAXREDIRS = 68;
 CURLOPT_MAXCONNECTS = 71;
 CURLOPT_CONNECTTIMEOUT = 78;

 { integer constants ... }
 CURLOPT_CLOSEPOLICY = 72; { CURLCLOSEPOLICY_LEAST_RECENTLY_USED; CURLCLOSEPOLICY_OLDEST }
 CURLOPT_SSL_VERIFYHOST = 81; { 1:check existence; 2:ensure match }
 CURLOPT_HTTP_VERSION = 84; { CURL_HTTP_VERSION_NONE; CURL_HTTP_VERSION_1_0; CURL_HTTP_VERSION_1_1 }

 { PChar parameters ... }
 CURLOPT_URL = 10002;
 CURLOPT_PROXY = 10004;
 CURLOPT_USERPWD = 10005;
 CURLOPT_PROXYUSERPWD = 10006;
 CURLOPT_RANGE = 10007;
 CURLOPT_ERRORBUFFER = 10010;
 CURLOPT_POSTFIELDS = 10015;
 CURLOPT_REFERER = 10016;
 CURLOPT_FTPPORT = 10017;
 CURLOPT_USERAGENT = 10018;
 CURLOPT_COOKIE = 10022;
 CURLOPT_SSLCERT = 10025;
 CURLOPT_SSLCERTPASSWD = 10026;
 CURLOPT_COOKIEFILE = 10031;
 CURLOPT_CUSTOMREQUEST = 10036;
 CURLOPT_INTERFACE = 10062;
 CURLOPT_KRB4LEVEL = 10063;
 CURLOPT_CAINFO = 10065;
 CURLOPT_RANDOM_FILE = 10076;
 CURLOPT_EGDSOCKET = 10077;
 CURLOPT_COOKIEJAR = 10082;
 CURLOPT_SSL_CIPHER_LIST = 10083;

 { linked-lists ... }
 CURLOPT_HTTPHEADER = 10023;
 CURLOPT_QUOTE = 10028;
 CURLOPT_POSTQUOTE = 10039;
 CURLOPT_TELNETOPTIONS = 10070;
 CURLOPT_HTTPPOST = 10024; {linked-list of tHttpPost records}

 CURLOPT_HTTPREQUEST = 10035; { -- Obsolete}

 { Files (100nn) and callbacks (200nn) ... }
 CURLOPT_FILE = 10001;
 CURLOPT_WRITEDATA = CURLOPT_FILE;
 CURLOPT_WRITEFUNCTION = 20011;

 CURLOPT_INFILE = 10009;
 CURLOPT_INFILESIZE = 14; { -- this one is actually a LongInt, but it wants to be here }
 CURLOPT_READFUNCTION = 20012;

 CURLOPT_WRITEHEADER = 10029;
 CURLOPT_HEADERDATA = CURLOPT_WRITEHEADER;
 CURLOPT_HEADERFUNCTION = 20079;

 CURLOPT_PROGRESSDATA = 10057;
 CURLOPT_PROGRESSFUNCTION = 20056;

 CURLOPT_PASSWDDATA = 10067;
 CURLOPT_PASSWDFUNCTION = 20066;

 CURLOPT_CLOSEFUNCTION = 20073;

{
 These are documented on the curl website, but not defined in my copy of curl.h:
 - Maybe because I do not have an ssl engine installed ?
    CURLOPT_SSLCERT
    CURLOPT_SSLCERTTYPE
    CURLOPT_SSLCERTPASSWD
    CURLOPT_SSLKEY
    CURLOPT_SSLKEYTYPE
    CURLOPT_SSLKEYASSWD
    CURLOPT_SSL_ENGINE
    CURLOPT_SSL_ENGINEDEFAULT
}



{ "var" style parameters - these get modified}

{ CURLOPT_STDERR: Buffer to receive error messages in, must be at least CURL_ERROR_SIZE
  bytes big. If this is not used, error messages go to stderr instead: }
CURLOPT_STDERR = 10037;

{ CURLOPT_FILETIME: Pass a pointer to a time_t to get a possible date of the requested
document! Pass a NULL to shut it off. }
CURLOPT_FILETIME = 10069;


{Other strange things...}

{ CURLOPT_FTPASCII: same value as CURLOPT_TRANSFERTEXT - is this one obsolete? }
CURLOPT_FTPASCII = 53;

{ CURLOPT_MUTE: obsolete option, removed in 7.8  }
CURLOPT_MUTE = 55;


{ CURLOPT_WRITEINFO:
curl.h says: "Pass a pointer to string of the output using full variable-replacement as described elsewhere."
jeff.p says:   "huh?"  :-}
CURLOPT_WRITEINFO = 10040;


{ constants passed to curl_easy_getinfo }
CURLINFO_EFFECTIVE_URL = 1048577;
CURLINFO_CONTENT_TYPE = 1048594; { - added in 7.9.4, bug-fixed in 7.9.5 }

CURLINFO_HTTP_CODE = 2097154;
CURLINFO_RESPONSE_CODE = CURLINFO_HTTP_CODE;
CURLINFO_HEADER_SIZE = 2097163;
CURLINFO_REQUEST_SIZE = 2097164;
CURLINFO_SSL_VERIFYRESULT = 2097165;
CURLINFO_FILETIME = 2097166;

CURLINFO_TOTAL_TIME = 3145731;
CURLINFO_NAMELOOKUP_TIME = 3145732;
CURLINFO_CONNECT_TIME = 3145733;
CURLINFO_PRETRANSFER_TIME = 3145734;
CURLINFO_SIZE_UPLOAD = 3145735;
CURLINFO_SIZE_DOWNLOAD = 3145736;
CURLINFO_SPEED_DOWNLOAD = 3145737;
CURLINFO_SPEED_UPLOAD = 3145738;
CURLINFO_CONTENT_LENGTH_DOWNLOAD = 3145743;
CURLINFO_CONTENT_LENGTH_UPLOAD = 3145744;
CURLINFO_STARTTRANSFER_TIME = 3145745;

CURLINFO_LASTONE = 18;

{ curl.h defines "true" and "false" as integers, so I renamed them ( for obvious reasons ) }
CURL_TRUE = 1;
CURL_FALSE = 0;

{my added}
CURLOPT_NOSIGNAL = 99;
CURLOPT_CONNECTTIMEOUT_MS = 156;
CURLOPT_TIMEOUT_MS = 155;
CURLOPT_PROTOCOLS = 181;
CURLOPT_XFERINFOFUNCTION = 20219;//ver 7.39
CURLOPT_XFERINFODATA = 10057;// ver 7.39
{CURLE_OPERATION}
CURLE_OPERATION_TIMEDOUT = 28;


{ Http post data structure and constants ...  }

type
  ppHttpPost = ^pHttpPost;
  pHttpPost = ^tHttpPost;
  THttpPost = record
    next : pHttpPost;  { next entry in the list  }
    name : PChar; { pointer to allocated name  }
    namelength : LongInt;  { length of name length  }
    contents : PChar;  { pointer to allocated data contents  }
    contentslength : LongInt;  { length of contents field  }
    contenttype : PChar;  { Content-Type  }
    contentheader : pcurl_slist;   { list of extra headers for this form  }
    more : pHttpPost;   { if one field name has more than one file, this should link to following files }
    flags : LongInt;   { as defined below }
end;

const
  HTTPPOST_FILENAME     =  1;  { specified content is a file name, sent as an "attachment" }
  HTTPPOST_READFILE     =  2;  { specified content is a file name, sent as raw data }
  HTTPPOST_PTRNAME      =  4;  { name is only stored pointer do not free in formfree }
  HTTPPOST_PTRCONTENTS  =  8;  { contents is only stored pointer do not free in formfree }


type tCURLformoption = (
  CURLFORM_NOTHING,
  CURLFORM_COPYNAME,
  CURLFORM_PTRNAME,
  CURLFORM_NAMELENGTH,
  CURLFORM_COPYCONTENTS,
  CURLFORM_PTRCONTENTS,
  CURLFORM_CONTENTSLENGTH,
  CURLFORM_FILECONTENT,
  CURLFORM_ARRAY,
  CURLFORM_ARRAY_START,
  CURLFORM_FILE,
  CURLFORM_CONTENTTYPE,
  CURLFORM_CONTENTHEADER,
  CURLFORM_END,
  CURLFORM_ARRAY_END,
  CURLFORM_LASTENTRY
);




procedure curl_formfree( form: pHttpPost ); cdecl; external LIB_CURL;
{
  "curl_formadd" wants a "va_list" as its third parameter,
  but FPC does not support this type of function call.
  It appears that *usually* the number of arguments is an odd number between 5 and 13.
  So this VERY_UGLY workaround should work in most cases ...
}

function curl_formadd_5( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1:  tCURLformoption;  Val1:   LongInt;
   Option_End: tCURLformoption
): LongInt; cdecl; external LIB_CURL name 'curl_formadd';


function curl_formadd_7( httppost: ppHttpPost; last_post:ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   OptN: tCURLformoption
): LongInt; cdecl; external LIB_CURL name 'curl_formadd';


function curl_formadd_9( httppost: ppHttpPost; last_post:  ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   Opt3: tCURLformoption;  Val3: LongInt;
   OptN: tCURLformoption
): LongInt; cdecl; external LIB_CURL name 'curl_formadd';


function curl_formadd_11( httppost: ppHttpPost; last_post:  ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   Opt3: tCURLformoption;  Val3: LongInt;
   Opt4: tCURLformoption;  Val4: LongInt;
   Option_End: tCURLformoption
): LongInt; cdecl; external LIB_CURL name 'curl_formadd';

function curl_formadd_13( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   Opt3: tCURLformoption;  Val3: LongInt;
   Opt4: tCURLformoption;  Val4: LongInt;
   Opt5: tCURLformoption;  Val5: LongInt;
   Option_End: tCURLformoption
): LongInt; cdecl; external LIB_CURL name 'curl_formadd';



{ Now we can declare overloaded "aliases" for the "real" curl_formadd ... }

function curl_formadd( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Option_End: tCURLformoption
): LongInt;overload; {5}

function curl_formadd( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   Option_End: tCURLformoption
): LongInt;overload; {7}

function curl_formadd( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   Opt3: tCURLformoption;  Val3: LongInt;
   Option_End: tCURLformoption
): LongInt;overload; {9}

function curl_formadd( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   Opt3: tCURLformoption;  Val3: LongInt;
   Opt4: tCURLformoption;  Val4: LongInt;
   Option_End: tCURLformoption
): LongInt;overload; {11}

function curl_formadd( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption;  Val1: LongInt;
   Opt2: tCURLformoption;  Val2: LongInt;
   Opt3: tCURLformoption;  Val3: LongInt;
   Opt4: tCURLformoption;  Val4: LongInt;
   Opt5: tCURLformoption;  Val5: LongInt;
   Option_End: tCURLformoption
): LongInt;overload; {13}


implementation

function curl_formadd( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption; Val1: LongInt;
   Option_End: tCURLformoption
): LongInt;
begin
  curl_formadd:=curl_formadd_5(httppost, last_post, Opt1, Val1, Option_End);
end;

function curl_formadd( httppost: ppHttpPost; last_post: ppHttpPost;
   Opt1: tCURLformoption; Val1: LongInt;
   Opt2: tCURLformoption; Val2: LongInt;
   Option_End: tCURLformoption
): LongInt;
begin
  curl_formadd:=curl_formadd_7( httppost, last_post, Opt1, Val1, Opt2, Val2, Option_End );
end;

function curl_formadd( httppost: ppHttpPost; last_post:  ppHttpPost;
   Opt1: tCURLformoption; Val1: LongInt;
   Opt2: tCURLformoption; Val2: LongInt;
   Opt3: tCURLformoption; Val3: LongInt;
   Option_End: tCURLformoption
): LongInt;
begin
  curl_formadd:=curl_formadd_9( httppost, last_post, Opt1, Val1, Opt2, Val2, Opt3, Val3, Option_End );
end;

function curl_formadd( httppost: ppHttpPost; last_post:  ppHttpPost;
   Opt1: tCURLformoption; Val1: LongInt;
   Opt2: tCURLformoption; Val2: LongInt;
   Opt3: tCURLformoption; Val3: LongInt;
   Opt4: tCURLformoption; Val4: LongInt;
   Option_End: tCURLformoption
): LongInt;
begin
  curl_formadd:=curl_formadd_11(
    httppost, last_post, Opt1, Val1, Opt2, Val2, Opt3, Val3, Opt4, Val4, Option_End );
end;

function curl_formadd( httppost: ppHttpPost; last_post:  ppHttpPost;
   Opt1: tCURLformoption; Val1: LongInt;
   Opt2: tCURLformoption; Val2: LongInt;
   Opt3: tCURLformoption; Val3: LongInt;
   Opt4: tCURLformoption; Val4: LongInt;
   Opt5: tCURLformoption; Val5: LongInt;
   Option_End: tCURLformoption
): LongInt;
begin
  curl_formadd:=curl_formadd_13(
    httppost, last_post, Opt1, Val1, Opt2, Val2, Opt3, Val3, Opt4, Val4, Opt5, Val5, Option_End );
end;

end.



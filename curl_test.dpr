program curl_test;

uses
 {$IFNDEF DEBUG}
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  {$ENDIF}
  Forms,
  main in 'main.pas' {mainform},
  sevenzip in 'sevenzip.pas',
  CurlDownLoadCore in 'CurlDownLoadCore.pas',
  Download in 'Download.pas' {Form1},
  Curl in 'Curl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

program
  AcrylicConsole;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

{$APPTYPE CONSOLE}

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Classes,
  SysUtils,
  Windows,
  AcrylicVersionInfo in 'AcrylicVersionInfo.pas',
  AddressCache in 'AddressCache.pas',
  CommonUtils in 'CommonUtils.pas',
  CommunicationChannels in 'CommunicationChannels.pas',
  Configuration in 'Configuration.pas',
  ConsoleTracerAgent in 'ConsoleTracerAgent.pas',
  DnsForwarder in 'DnsForwarder.pas',
  DnsOverHttpsCache in 'DnsOverHttpsCache.pas',
  DnsProtocol in 'DnsProtocol.pas',
  DnsResolver in 'DnsResolver.pas',
  Environment in 'Environment.pas',
  EnvironmentVariables in 'EnvironmentVariables.pas',
  FileIO in 'FileIO.pas',
  FileStreamLineEx in 'FileStreamLineEx.pas',
  FileTracerAgent in 'FileTracerAgent.pas',
  HitLogger in 'HitLogger.pas',
  HostsCache in 'HostsCache.pas',
  HostsCacheBinaryTrees in 'HostsCacheBinaryTrees.pas',
  IPUtils in 'IPUtils.pas',
  MD5 in 'MD5.pas',
  MemoryManager in 'MemoryManager.pas',
  MemoryStore in 'MemoryStore.pas',
  PatternMatching in 'PatternMatching.pas',
  PCRE in 'PCRE.pas',
  PerlRegEx in 'PerlRegEx.pas',
  SessionCache in 'SessionCache.pas',
  Tracer in 'Tracer.pas',
  WinHttp in 'WinHttp.pas',
  WinSock in 'WinSock.pas';

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  i: Integer;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  NoLog: Boolean;
  NoBanner: Boolean;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

begin

  FormatSettings.DecimalSeparator := '.';

  SetConsoleCtrlHandler(nil, True);

  if ((ParamCount = 1) and (ParamStr(1) = '/?')) then begin

    WriteLn('==============================================================================');
    WriteLn('Acrylic DNS Proxy Console');
    WriteLn('==============================================================================');
    WriteLn;
    WriteLn('Usage:');
    WriteLn('  AcrylicConsole.exe [/NoBanner] [/NoLog]');
    WriteLn;
    WriteLn('Options:');
    WriteLn('  /NoBanner');
    WriteLn('    Does not write the application banner to the console.');
    WriteLn('  /NoLog');
    WriteLn('    Does not write the application log to the console.');
    WriteLn;
    WriteLn('Examples:');
    WriteLn('  AcrylicConsole.exe');
    WriteLn('  AcrylicConsole.exe /NoBanner /NoLog');

    Exit;

  end;

  NoLog := False;
  NoBanner := False;

  for i := 1 to ParamCount do begin

    if (ParamStr(i) = '/NoLog') then NoLog := True else if (ParamStr(i) = '/NoBanner') then NoBanner := True;

  end;

  if not(NoBanner) then begin

    WriteLn('==============================================================================');
    WriteLn('Acrylic DNS Proxy Console                                  Press ENTER To Quit');
    WriteLn('==============================================================================');

  end;

  TConfiguration.Initialize; TTracer.Initialize; if not(NoLog) then TTracer.SetTracerAgent(TConsoleTracerAgent.Create);

  if TTracer.IsEnabled then TTracer.Trace(TracePriorityInfo, 'Acrylic version is ' + AcrylicVersionNumber + ' released on ' + AcrylicReleaseDate + '.');

  TDnsResolver.StartResolver;

  ReadLn; // Wait until the ENTER key is pressed

  TDnsResolver.StopResolver;

  TTracer.Finalize; TConfiguration.Finalize;

end.
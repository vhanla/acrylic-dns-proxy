// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

unit
  AcrylicUIUtils;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

interface

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

const
  SERVICE_NAME = 'AcrylicDNSProxySvc';
  LOCAL_MACHINE = ''; //empty is current machine

type
  NBoolean = (NTrue, NFalse, NUnspecified);

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function  AcrylicServiceIsInstalled: Boolean;
function  InstallAcrylicService: Boolean;
function  UninstallAcrylicService: Boolean;

function  AcrylicServiceIsRunning: Boolean;
function  StartAcrylicService: Boolean;
function  StopAcrylicService: Boolean;

procedure RemoveAcrylicCacheFile;

function  AcrylicServiceDebugLogIsEnabled: Boolean;
procedure CreateAcrylicServiceDebugLog;
procedure RemoveAcrylicServiceDebugLog;

function  GetAcrylicDirectoryPath: String;

function  GetAcrylicUIExeFilePath: String;
function  GetAcrylicUIIniFilePath: String;

function  GetAcrylicConfigurationFilePath: String;
function  GetAcrylicHostsFilePath: String;
function  GetAcrylicCacheFilePath: String;

function  GetAcrylicDebugLogFilePath: String;

function  TestRegEx(Subject: String; RegEx: String): Boolean;
function  TestDomainNameAffinityMask(Subject: String; AffinityMaskText: String): Boolean;

function  GetAcrylicWelcomeString: String;
function  GetAcrylicDescriptionString: String;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Classes,
  Windows,
  SysUtils,
  Registry,
  TlHelp32,
  ShellApi,
  AcrylicVersionInfo,
  PatternMatching,
  PerlRegEx,
  Winapi.WinSvc;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  AcrylicDirectoryPath: String;
  AcrylicUIExeFilePath: String;
  AcrylicUIIniFilePath: String;
  AcrylicServiceExeFilePath: String;
  AcrylicConfigurationFilePath: String;
  AcrylicHostsFilePath: String;
  AcrylicCacheFilePath: String;
  AcrylicDebugLogFilePath: String;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetServiceState(AMachine: string; AServiceName: string) : DWORD;

var
  serviceControlManagerHandle: SC_HANDLE;
  serviceHandle: SC_HANDLE;
  serviceStatus: TServicestatus;
  currentSvcStatus: DWORD;
begin
  currentSvcStatus := 0;

  serviceControlManagerHandle := OpenSCManager(
    PChar(AMachine), nil, SC_MANAGER_CONNECT);

  if serviceControlManagerHandle > 0 then
  begin
    serviceHandle := OpenService(
      serviceControlManagerHandle,
      PChar(AServiceName),
      SERVICE_QUERY_STATUS);

    if serviceHandle > 0 then
    begin
      FillChar(serviceStatus, SizeOf(TServiceStatus), 0); // Initialize serviceStatus
      if QueryServiceStatus(serviceHandle, serviceStatus) then
      begin
        currentSvcStatus := serviceStatus.dwCurrentState;
      end;

      CloseServiceHandle(serviceHandle);

    end;

    CloseServiceHandle(serviceControlManagerHandle);

  end;

  Result := currentSvcStatus;

end;


// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function MakeAbsolutePath(Path: String): String;

begin

  if (Pos('\', Path) > 0) then Result := Path else Result := ExtractFilePath(ParamStr(0)) + Path;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function TouchFile(FileName: String): Boolean;

var
  Handle: THandle;

begin

  Result := False;

  Handle := CreateFile(PChar(FileName), GENERIC_WRITE, 0, nil, CREATE_NEW, FILE_ATTRIBUTE_ARCHIVE, 0);

  if (Handle <> INVALID_HANDLE_VALUE) then begin

    CloseHandle(Handle);

    Result := True;

    Exit;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function ProcessExists(ExeFileName: String): Boolean;

var
  Handle: THandle; ProcessEntry32: TProcessEntry32; ContinueLoop: LongBool;

begin

  Result := False;

  Handle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  ProcessEntry32.dwSize := SizeOf(ProcessEntry32);

  ContinueLoop := Process32First(Handle, ProcessEntry32);

  while ContinueLoop do begin

    if (AnsiCompareText(ProcessEntry32.szExeFile, ExeFileName) = 0) then begin

      CloseHandle(Handle);

      Result := True;

      Exit;

    end;

    ContinueLoop := Process32Next(Handle, ProcessEntry32);

  end;

  CloseHandle(Handle);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function ExecuteCommand(CommandLine: String): Cardinal;

var
  StartupInfo: TStartupInfo; ProcessInfo: TProcessInformation; ExitCode: Cardinal;

begin

  ExitCode := 255;

  FillChar(StartupInfo, Sizeof(StartupInfo), #0);

  StartupInfo.cb := Sizeof(StartupInfo);

  if CreateProcess(nil, PChar(CommandLine), nil, nil, false, CREATE_NO_WINDOW or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then begin

    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

    GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

    CloseHandle(ProcessInfo.hProcess);

    CloseHandle(ProcessInfo.hThread);

  end;

  Result := ExitCode;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function AcrylicServiceIsInstalled: Boolean;

var
  serviceControlManagerHandle: SC_HANDLE;
  serviceHandle: SC_HANDLE;

begin

  Result := False;

  serviceControlManagerHandle := OpenSCManager(
    PChar(LOCAL_MACHINE), nil, SC_MANAGER_CONNECT);

  if serviceControlManagerHandle > 0 then
  begin
    serviceHandle := OpenService(
      serviceControlManagerHandle,
      PChar(SERVICE_NAME),
      SERVICE_QUERY_CONFIG);

    if serviceHandle > 0 then
    begin
      Result := True;
      CloseServiceHandle(serviceHandle);
    end;

    CloseServiceHandle(serviceControlManagerHandle);
  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function InstallAcrylicService: Boolean;

begin

  Result := ExecuteCommand('"' + AcrylicServiceExeFilePath + '" /INSTALL /SILENT') = 0;

  ExecuteCommand('ICACLS.exe "' + AcrylicServiceExeFilePath + '" /inheritance:d');
  ExecuteCommand('ICACLS.exe "' + AcrylicServiceExeFilePath + '" /remove:g "Authenticated Users"');

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function UninstallAcrylicService: Boolean;

begin

  StopAcrylicService;

  Result := ExecuteCommand('"' + AcrylicServiceExeFilePath + '" /UNINSTALL /SILENT') = 0;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function AcrylicServiceIsRunning: Boolean;

begin

  Result := SERVICE_RUNNING = GetServiceState(LOCAL_MACHINE, SERVICE_NAME);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function StartAcrylicService: Boolean;

var
  serviceControlManagerHandle, serviceHandle: SC_HANDLE;
  serviceStatus: TServiceStatus;
  tempCharPointer: PChar;
  checkpoint: DWORD;

begin

  serviceStatus.dwCurrentState := 0;

  serviceControlManagerHandle := OpenSCManager(
    PChar(LOCAL_MACHINE), nil, SC_MANAGER_CONNECT);

  if serviceControlManagerHandle > 0 then
  begin
    serviceHandle := OpenService(
      serviceControlManagerHandle,
      PChar(SERVICE_NAME),
      SERVICE_START or SERVICE_QUERY_STATUS);

    if serviceHandle > 0 then
    begin
      tempCharPointer := nil;
      if StartService(serviceHandle, 0, tempCharPointer) then
      begin
        if QueryServiceStatus(serviceHandle, serviceStatus) then
        begin
          while SERVICE_RUNNING <> serviceStatus.dwCurrentState do
          begin
            checkpoint := serviceStatus.dwCheckPoint;

            Sleep(serviceStatus.dwWaitHint);

            if not QueryServiceStatus(serviceHandle, serviceStatus) then
              break;

            if serviceStatus.dwCheckPoint < checkpoint then
              break;

          end;
        end;
      end;

      CloseServiceHandle(serviceHandle);
    end;

    CloseServiceHandle(serviceControlManagerHandle);
  end;

  Result := SERVICE_RUNNING = serviceStatus.dwCurrentState;
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function StopAcrylicService: Boolean;

var
  serviceControlManagerHandle, serviceHandle: SC_HANDLE;
  serviceStatus: TServiceStatus;
  tempCharPointer: PChar;
  checkPoint: DWORD;

begin

  serviceStatus.dwCurrentState := 0;

  serviceControlManagerHandle := OpenSCManager(
    PChar(LOCAL_MACHINE), nil, SC_MANAGER_CONNECT);

  if serviceControlManagerHandle > 0 then
  begin
    serviceHandle := OpenService(
      serviceControlManagerHandle,
      PChar(SERVICE_NAME),
      SERVICE_STOP or SERVICE_QUERY_STATUS);

    if serviceHandle > 0 then
    begin
      tempCharPointer := nil;
      if ControlService(serviceHandle, SERVICE_CONTROL_STOP, serviceStatus) then
      begin
        while SERVICE_STOPPED <> serviceStatus.dwCurrentState do
        begin
          checkPoint := serviceStatus.dwCheckPoint;

          Sleep(serviceStatus.dwWaitHint);

          if not QueryServiceStatus(serviceHandle, serviceStatus) then
            break;

          if serviceStatus.dwCheckPoint < checkPoint then
            break;
        end;
      end;

      CloseServiceHandle(serviceHandle);
    end;

    CloseServiceHandle(serviceControlManagerHandle);
  end;

  Result := SERVICE_STOPPED = serviceStatus.dwCurrentState;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function AcrylicServiceDebugLogIsEnabled: Boolean;

begin

  Result := FileExists(AcrylicDebugLogFilePath);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure RemoveAcrylicCacheFile;

begin

  DeleteFile(PChar(AcrylicCacheFilePath));

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure CreateAcrylicServiceDebugLog;

begin

  TouchFile(PChar(AcrylicDebugLogFilePath));

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure RemoveAcrylicServiceDebugLog;

begin

  DeleteFile(PChar(AcrylicDebugLogFilePath));

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicDirectoryPath: String;

begin

  Result := AcrylicDirectoryPath;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicUIExeFilePath: String;

begin

  Result := AcrylicUIExeFilePath;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicUIIniFilePath: String;

begin

  Result := AcrylicUIIniFilePath;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicConfigurationFilePath: String;

begin

  Result := AcrylicConfigurationFilePath;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicHostsFilePath: String;

begin

  Result := AcrylicHostsFilePath;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicCacheFilePath: String;

begin

  Result := AcrylicCacheFilePath;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicDebugLogFilePath: String;

begin

  Result := AcrylicDebugLogFilePath;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function TestRegEx(Subject: String; RegEx: String): Boolean;

var
  RE: TPerlRegEx;

begin

  RE := nil; try

    RE := TPerlRegEx.Create;

    RE.RegEx := RegEx; RE.Options := [preCaseLess]; RE.Subject := Subject;

    Result := RE.Match;

  finally

    if (RE <> nil) then RE.Free;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function InternalTestDomainNameAffinityMask(const DomainName: String; DomainNameAffinityMask: TStringList): Boolean;

var
  i: Integer; S: String;

begin

  if (DomainNameAffinityMask <> nil) then begin

    for i := 0 to (DomainNameAffinityMask.Count - 1) do begin

      S := DomainNameAffinityMask[i];

      if (S[1] = '^') then begin
        if TPatternMatching.Match(PChar(DomainName), PChar(Copy(S, 2, Length(S) - 1))) then begin Result := False; Exit; end;
      end else begin
        if TPatternMatching.Match(PChar(DomainName), PChar(S)) then begin Result := True; Exit; end;
      end;

    end;

    Result := False;

  end else begin

    Result := True;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function TestDomainNameAffinityMask(Subject: String; AffinityMaskText: String): Boolean;

var
  AffinityMask: TStringList;

begin

  AffinityMask := TStringList.Create; AffinityMask.Delimiter := ';'; AffinityMask.DelimitedText := AffinityMaskText;

  Result := InternalTestDomainNameAffinityMask(Subject, AffinityMask);

  AffinityMask.Free;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicWelcomeString: String;

begin

  Result := 'Welcome to Acrylic version ' + AcrylicVersionNumber + ' released on ' + AcrylicReleaseDate + '.';

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function GetAcrylicDescriptionString: String;

begin

  Result := 'Acrylic is a local DNS proxy which improves the performance of your computer by caching the responses coming from your DNS servers and helps you fight unwanted ads through the use of a custom HOSTS file with support for wildcards and regular expressions.' + #13#10 + #13#10 + 'For more information please use the "Acrylic Home Page" item available from the "Help" menu, or go directly to:' + #13#10 + #13#10 + 'https://mayakron.altervista.org/support/acrylic/Home.htm' + #13#10 + #13#10 + 'Installed version is:' + #13#10 + AcrylicVersionNumber + ' released on ' + AcrylicReleaseDate + '.';

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

begin

  AcrylicDirectoryPath := ExtractFilePath(ParamStr(0));
  AcrylicUIExeFilePath := ParamStr(0);
  AcrylicUIIniFilePath := MakeAbsolutePath('AcrylicUI.ini');
  AcrylicServiceExeFilePath := MakeAbsolutePath('AcrylicService.exe');
  AcrylicConfigurationFilePath := MakeAbsolutePath('AcrylicConfiguration.ini');
  AcrylicHostsFilePath := MakeAbsolutePath('AcrylicHosts.txt');
  AcrylicCacheFilePath := MakeAbsolutePath('AcrylicCache.dat');
  AcrylicDebugLogFilePath := MakeAbsolutePath('AcrylicDebug.txt');

end.

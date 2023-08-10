// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

unit
  AcrylicUIMain;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

interface

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Menus,
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  ShellApi,
  Dialogs,
  AcrylicUIUtils,
  AcrylicUISettings,
  AcrylicUIRegExTester,
  AcrylicUIDomainNameAffinityMaskTester, SynEditHighlighter, SynEditCodeFolding,
  SynHighlighterCpp, SynHighlighterIni, SynEdit, SynHostFile, VirtualTrees;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

type
  TMainForm = class(TForm)

    Timer: TTimer;

    MainMenu: TMainMenu;
    StatusBar: TStatusBar;

    OpenDialog: TOpenDialog;
    FontDialog: TFontDialog;

    FileMainMenuItem: TMenuItem;
    FileOpenMainMenuItem: TMenuItem;
    FileOpenAcrylicConfigurationMainMenuItem: TMenuItem;
    FileOpenAcrylicHostsMainMenuItem: TMenuItem;
    FileSaveMainMenuItem: TMenuItem;
    FileExitMainMenuItem: TMenuItem;

    ActionsMainMenuItem: TMenuItem;
    ActionsInstallAcrylicServiceMainMenuItem: TMenuItem;
    ActionsUninstallAcrylicServiceMainMenuItem: TMenuItem;
    ActionsStartAcrylicServiceMainMenuItem: TMenuItem;
    ActionsStopAcrylicServiceMainMenuItem: TMenuItem;
    ActionsRestartAcrylicServiceMainMenuItem: TMenuItem;
    ActionsPurgeAcrylicCacheDataMainMenuItem: TMenuItem;
    ActionsActivateAcrylicDebugLogMainMenuItem: TMenuItem;
    ActionsDeactivateAcrylicDebugLogMainMenuItem: TMenuItem;
    ActionsViewCurrentAcrylicDebugLogMainMenuItem: TMenuItem;
    ActionsOpenAcrylicFolderinFileExplorerMainMenuItem: TMenuItem;

    SettingsMainMenuItem: TMenuItem;
    SettingsSetEditorFontMainMenuItem: TMenuItem;

    ToolsMainMenuItem: TMenuItem;
    ToolsRegExTesterMainMenuItem: TMenuItem;
    ToolsDomainNameAffinityMaskTesterMainMenuItem: TMenuItem;

    HelpMainMenuItem: TMenuItem;
    HelpAcrylicHomePageMainMenuItem: TMenuItem;
    HelpAboutAcrylicMainMenuItem: TMenuItem;
    Memo: TSynEdit;
    SynIniSyn1: TSynIniSyn;
    vstINI: TVirtualStringTree;
    Splitter1: TSplitter;

    procedure TimerTimer(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure FileOpenMainMenuItemClick(Sender: TObject);
    procedure FileOpenAcrylicConfigurationMainMenuItemClick(Sender: TObject);
    procedure FileOpenAcrylicHostsMainMenuItemClick(Sender: TObject);
    procedure FileSaveMainMenuItemClick(Sender: TObject);
    procedure FileExitMainMenuItemClick(Sender: TObject);

    procedure ActionsInstallAcrylicServiceMainMenuItemClick(Sender: TObject);
    procedure ActionsUninstallAcrylicServiceMainMenuItemClick(Sender: TObject);
    procedure ActionsStartAcrylicServiceMainMenuItemClick(Sender: TObject);
    procedure ActionsStopAcrylicServiceMainMenuItemClick(Sender: TObject);
    procedure ActionsRestartAcrylicServiceMainMenuItemClick(Sender: TObject);
    procedure ActionsPurgeAcrylicCacheDataMainMenuItemClick(Sender: TObject);
    procedure ActionsActivateAcrylicDebugLogMainMenuItemClick(Sender: TObject);
    procedure ActionsDeactivateAcrylicDebugLogMainMenuItemClick(Sender: TObject);
    procedure ActionsViewCurrentAcrylicDebugLogMainMenuItemClick(Sender: TObject);
    procedure ActionsOpenAcrylicFolderinFileExplorerMainMenuItemClick(Sender: TObject);

    procedure SettingsSetEditorFontMainMenuItemClick(Sender: TObject);

    procedure ToolsRegExTesterMainMenuItemClick(Sender: TObject);
    procedure ToolsDomainNameAffinityMaskTesterMainMenuItemClick(Sender: TObject);

    procedure HelpAcrylicHomePageMainMenuItemClick(Sender: TObject);
    procedure HelpAboutAcrylicMainMenuItemClick(Sender: TObject);
    procedure vstINIBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure vstINIChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstINIFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstINIGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstINIInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var ChildCount: Cardinal);
    procedure vstINIInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstININewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
    procedure vstININodeDblClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
    procedure MemoChange(Sender: TObject);

  private

    MemoFilePath: String;

    AcrylicServiceIsRunning: NBoolean;
    AcrylicServiceIsInstalled: NBoolean;
    AcrylicServiceDebugLogIsEnabled: NBoolean;

    SynHost: TSynHostsSyn;
    IniText: TStrings;
    IniBuff: string;
    procedure ParseINI(text: string);

  private

    procedure UpdateStatusInfo(Text: String);
    procedure UpdateStatusError(Text: String);

  end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  MainForm: TMainForm;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

  type
    PIniData = ^TIniData;
    TIniData = record
      key: string;
      value: string;
      savedValue: string;
      enabled: Boolean;
      sectionChanges: string;
      line: Integer;
      OtherNode: PVirtualNode;
    end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

{$R *.dfm}

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.TimerTimer(Sender: TObject);

begin

  try

    if AcrylicUIUtils.AcrylicServiceIsInstalled then Self.AcrylicServiceIsInstalled := NTrue else Self.AcrylicServiceIsInstalled := NFalse;

  except

    Self.AcrylicServiceIsInstalled := NUnspecified;

  end;

  if (Self.AcrylicServiceIsInstalled = NTrue) then begin

    Self.ActionsInstallAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsUninstallAcrylicServiceMainMenuItem.Enabled := True;

  end else if (Self.AcrylicServiceIsInstalled = NFalse) then begin

    Self.ActionsInstallAcrylicServiceMainMenuItem.Enabled := True;
    Self.ActionsUninstallAcrylicServiceMainMenuItem.Enabled := False;

  end else begin

    Self.ActionsInstallAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsUninstallAcrylicServiceMainMenuItem.Enabled := False;

  end;

  try

    if AcrylicUIUtils.AcrylicServiceIsRunning then Self.AcrylicServiceIsRunning := NTrue else Self.AcrylicServiceIsRunning := NFalse;

  except

    Self.AcrylicServiceIsRunning := NUnspecified;

  end;

  if (Self.AcrylicServiceIsRunning = NTrue) then begin

    Self.ActionsStopAcrylicServiceMainMenuItem.Enabled := True;
    Self.ActionsStartAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsRestartAcrylicServiceMainMenuItem.Enabled := True;
    Self.ActionsPurgeAcrylicCacheDataMainMenuItem.Enabled := True;

  end else if (Self.AcrylicServiceIsRunning = NFalse) then begin

    Self.ActionsStopAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsStartAcrylicServiceMainMenuItem.Enabled := True;
    Self.ActionsRestartAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsPurgeAcrylicCacheDataMainMenuItem.Enabled := True;

  end else begin

    Self.ActionsStopAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsStartAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsRestartAcrylicServiceMainMenuItem.Enabled := False;
    Self.ActionsPurgeAcrylicCacheDataMainMenuItem.Enabled := False;

  end;

  if (Self.AcrylicServiceIsInstalled = NTrue) then begin

    if (Self.AcrylicServiceIsRunning = NTrue) then begin

      Self.Text := Application.Title + ' (Service Installed & Running)';

    end else if (Self.AcrylicServiceIsRunning = NFalse) then begin

      Self.Text := Application.Title + ' (Service Installed & Not Running)';

    end else begin

      Self.Text := Application.Title + ' (Service Installed)';

    end;

  end else if (Self.AcrylicServiceIsInstalled = NFalse) then begin

    if (Self.AcrylicServiceIsRunning = NTrue) then begin

      Self.Text := Application.Title + ' (Service Not Installed & Running)';

    end else if (Self.AcrylicServiceIsRunning = NFalse) then begin

      Self.Text := Application.Title + ' (Service Not Installed & Not Running)';

    end else begin

      Self.Text := Application.Title + ' (Service Not Installed)';

    end;

  end else begin

    if (Self.AcrylicServiceIsRunning = NTrue) then begin

      Self.Text := Application.Title + ' (Service Running)';

    end else if (Self.AcrylicServiceIsRunning = NFalse) then begin

      Self.Text := Application.Title + ' (Service Not Running)';

    end else begin

      Self.Text := Application.Title;

    end;

  end;

  try

    if AcrylicUIUtils.AcrylicServiceDebugLogIsEnabled then Self.AcrylicServiceDebugLogIsEnabled := NTrue else Self.AcrylicServiceDebugLogIsEnabled := NFalse;

  except

    Self.AcrylicServiceDebugLogIsEnabled := NUnspecified;

  end;

  if (Self.AcrylicServiceDebugLogIsEnabled = NTrue) then begin

    Self.ActionsActivateAcrylicDebugLogMainMenuItem.Enabled := False;
    Self.ActionsDeactivateAcrylicDebugLogMainMenuItem.Enabled := True;
    Self.ActionsViewCurrentAcrylicDebugLogMainMenuItem.Enabled := True;

  end else if (Self.AcrylicServiceDebugLogIsEnabled = NFalse) then begin

    Self.ActionsActivateAcrylicDebugLogMainMenuItem.Enabled := True;
    Self.ActionsDeactivateAcrylicDebugLogMainMenuItem.Enabled := False;
    Self.ActionsViewCurrentAcrylicDebugLogMainMenuItem.Enabled := False;

  end else begin

    Self.ActionsActivateAcrylicDebugLogMainMenuItem.Enabled := False;
    Self.ActionsDeactivateAcrylicDebugLogMainMenuItem.Enabled := False;
    Self.ActionsViewCurrentAcrylicDebugLogMainMenuItem.Enabled := False;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);

var
  MainForm: TForm; EditorFont: TFont;

begin

  Self.Caption := Application.Title;

  try

    MainForm := Self;

    EditorFont := Self.Memo.Font;

    if AcrylicUISettings.Load(MainForm, EditorFont) then begin

      Self.Memo.Font := EditorFont;

    end;

  except

  end;

  SynHost := TSynHostsSyn.Create(Self);
  Memo.Highlighter := SynHost;
  vstINI.NodeDataSize := SizeOf(TIniData);

  Self.UpdateStatusInfo(AcrylicUIUtils.GetAcrylicWelcomeString);

  if (ParamStr(1) = 'OpenAcrylicConfigurationFile') then begin

    Self.FileOpenAcrylicConfigurationMainMenuItemClick(Sender);

    Exit;

  end;

  if (ParamStr(1) = 'OpenAcrylicHostsFile') then begin

    Self.FileOpenAcrylicHostsMainMenuItemClick(Sender);

    Exit;

  end;

  if (ParamStr(1) = 'About') or (ParamStr(1) = 'Help') or (ParamStr(1) = '/?') or (ParamStr(1) = '--help') then begin

    Self.HelpAboutAcrylicMainMenuItemClick(Sender);

    Exit;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

begin

  if Self.Memo.Visible and (Self.MemoFilePath <> '') and Self.Memo.Modified then begin

    if (MessageBox(0, PChar(Self.MemoFilePath + #13#10 + #13#10 + 'There are unsaved changes in the editor.' + #13#10 + #13#10 + 'Are you sure that you want to exit?'), 'Exit Confirmation Request', MB_ICONQUESTION or MB_YESNO) = IDYES) then begin

      CanClose := True;

    end else begin

      CanClose := False;

    end;

  end else begin

    CanClose := True;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);

begin

  SynHost.Free;

  try

    AcrylicUISettings.Save(Self, Self.Memo.Font);

  except

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.UpdateStatusInfo(Text: String);

begin

  Self.StatusBar.SimpleText := Text; Application.ProcessMessages;

end;

procedure TMainForm.vstINIBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  Level: Integer;
  Data: PIniData;
begin

  Level := Sender.GetNodeLevel(Node);
  case Level of
    0:
    begin
      TargetCanvas.Brush.Color := $efefef;
      TargetCanvas.FillRect(CellRect);

      Data := Sender.GetNodeData(Node);
      if Trim(Data^.sectionchanges) <> '' then
      begin
        TargetCanvas.Brush.Color := $76BFFB;
        TargetCanvas.FillRect(CellRect);
      end;
    end;
    1:
    begin
      Data := Sender.GetNodeData(Node);

      if (Node.Index and 1) = 1 then
      begin
        TargetCanvas.Brush.Color := $f1f1f1;
        TargetCanvas.FillRect(CellRect);
      end;

      if Node.CheckState = csCheckedNormal then
      begin
        if not Data^.enabled then // to highlight if changed from original state
        begin
          TargetCanvas.Brush.Color := $76BFFB;
          TargetCanvas.FillRect(CellRect);
        end
        else
          TargetCanvas.Brush.Color := $A3D491;

        TargetCanvas.FillRect(CellRect);
      end
      else if Node.CheckState = csUncheckedNormal then
      begin
        if Data^.enabled then // to highlight if changed from original state
        begin
          TargetCanvas.Brush.Color := $76BFFB;
          TargetCanvas.FillRect(CellRect);
        end;
      end;

      if Data^.savedvalue <> Data^.value then
      begin
        TargetCanvas.Brush.Color := $12ddea;
        TargetCanvas.FillRect(CellRect);
      end;

    end;
  end;
end;

procedure TMainForm.vstINIChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Level: Integer;
  Data: Pinidata;
  ParentData: Pinidata;
  Nodo: PVirtualNode;
  I: Integer;
begin
//  Node := Sender.FocusedNode;
  Level := Sender.GetNodeLevel(Node);
  if Level > 0 then // just to act if subnode is clicked specially for changes on checkbox
  begin
    ParentData := Sender.GetNodeData(Node.Parent);
    Nodo := Sender.GetFirstChild(Node.Parent);

    ParentData^.sectionchanges := '';

    I := 0;

    while Assigned(Nodo) do
    begin

      Data := Sender.GetNodeData(Nodo);

      if Nodo.CheckState = csCheckedNormal then
      begin
        if not Data^.enabled then Inc(I);
      end
      else if Nodo.CheckState = csUncheckedNormal then
      begin
        if Data^.enabled then Inc(I);
      end;

      if Data^.savedvalue <> Data^.value then
        Inc(I);

      if I > 0 then
      ParentData^.sectionchanges:= I.ToString;

      Nodo := Sender.GetNextSibling(Nodo);
    end;

    vstINI.RepaintNode(Node.Parent);

    // Let's update the line in its source code
    Data := Sender.GetNodeData(Node);
    if Node.CheckState = csCheckedNormal then
      Memo.Lines[Data^.line] := Data^.key + ' = ' + Data^.value
    else if Node.CheckState = csUnCheckedNormal then
      Memo.Lines[Data^.line] := ';'+Data^.key + ' = ' + Data^.value;

//#FIX THIS

  end;
end;

procedure TMainForm.vstINIFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  data: PIniData;
begin
  data := vstINI.GetNodeData(Node);

  if Assigned(data) then
    begin
      data^.key := '';
      data^.value := '';
      data^.savedvalue := '';
      data^.sectionchanges := '';
    end;
end;

procedure TMainForm.vstINIGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Level: Integer;
  Data: PInidata;
begin
  Data := Sender.GetNodeData(Node);
  Level := Sender.GetNodeLevel(Node);
  case Column of
    0: CellText := Data.key;
    1:
    begin
      if Level = 0 then
      begin
        if Trim(Data.sectionchanges) <> '' then
          CellText := 'Changes : '+Data.sectionchanges
        else
          CellText := '';
      end
      else
        CellText := Data.value;
    end;
    2: CellText := Data.value;
  end;
end;

procedure TMainForm.vstINIInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
begin
  ChildCount := Sender.GetNodeLevel(Node) + 2;
end;

procedure TMainForm.vstINIInitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  Level: Integer;
begin
  Level := Sender.GetNodeLevel(Node);
//  Include(InitialStates, ivsHasChildren);
  if Level = 0 then
    Node.CheckType := ctNone;
  if Level = 1 then
    Node.CheckType := ctCheckBox;
end;

procedure TMainForm.vstININewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; NewText: string);
var
  Level: Integer;
  Data: PInidata;
begin
  Level := Sender.GetNodeLevel(Node);
  if Level = 0 then Exit;

  if Column = 1 then
  begin
    Data := Sender.GetNodeData(Node);
    Data^.value := NewText;

    vstINIChecked(Sender, Node);
  end;
end;

procedure TMainForm.vstININodeDblClick(Sender: TBaseVirtualTree;
  const HitInfo: THitInfo);
var
  Data: PInidata;
  Node: PVirtualNode;
begin
  Node := Sender.FocusedNode;
  Data := Sender.GetNodeData(Node);
  if Assigned(Node) then
  begin
    if (Data^.line+1 >=1) and (Data^.line+1 < Memo.Lines.Count) then
    begin
      Memo.GotoLineAndCenter(Data^.line+1);
      //PageControl1.SelectNextPage(True);
    end;
  end;
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.UpdateStatusError(Text: String);

begin

  Self.StatusBar.SimpleText := Text; Application.ProcessMessages;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FileOpenMainMenuItemClick(Sender: TObject);

begin

  OpenDialog.Title := 'Open...';
  OpenDialog.Filter := 'All files|*.*';
  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));

  if OpenDialog.Execute then begin

    Self.MemoFilePath := OpenDialog.FileName;

    Self.Memo.Lines.LoadFromFile(OpenDialog.FileName);
    Self.Memo.Modified := False;
    Self.Memo.Visible := True;

    Self.FileSaveMainMenuItem.Enabled := True;

    Self.UpdateStatusInfo('You are now editing the file "' + OpenDialog.FileName + '".');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FileOpenAcrylicConfigurationMainMenuItemClick(Sender: TObject);

var
  AcrylicConfigurationFilePath: String;

begin

  AcrylicConfigurationFilePath := AcrylicUIUtils.GetAcrylicConfigurationFilePath;

  if FileExists(AcrylicConfigurationFilePath) then begin

    Self.MemoFilePath := AcrylicConfigurationFilePath;

    Self.Memo.Lines.LoadFromFile(AcrylicConfigurationFilePath);
    Self.Memo.Modified := False;
    Self.Memo.Highlighter := SynIniSyn1;
    Self.Memo.Visible := True;
    ParseINI('');

    Self.FileSaveMainMenuItem.Enabled := True;

    Self.UpdateStatusInfo('You are now editing the file "' + AcrylicConfigurationFilePath + '".');

  end else begin

    Self.UpdateStatusError('An error occurred while opening the file "' + AcrylicConfigurationFilePath + '".');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FileOpenAcrylicHostsMainMenuItemClick(Sender: TObject);

var
  AcrylicHostsFilePath: String;

begin

  AcrylicHostsFilePath := AcrylicUIUtils.GetAcrylicHostsFilePath;

  if FileExists(AcrylicHostsFilePath) then begin

    Self.MemoFilePath := AcrylicHostsFilePath;

    Self.Memo.Lines.LoadFromFile(AcrylicHostsFilePath);
    Self.Memo.Modified := False;
    Self.Memo.Highlighter := SynHost;
    Self.Memo.Visible := True;

    Self.FileSaveMainMenuItem.Enabled := True;

    Self.UpdateStatusInfo('You are now editing the file "' + AcrylicHostsFilePath + '".');

  end else begin

    Self.UpdateStatusError('An error occurred while opening the file "' + AcrylicHostsFilePath + '".');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FileSaveMainMenuItemClick(Sender: TObject);

begin

  if Self.Memo.Visible and (Self.MemoFilePath <> '') then begin

    Self.UpdateStatusInfo('Saving changes to file "' + Self.MemoFilePath + '"...');

    try

      Self.Memo.Lines.SaveToFile(Self.MemoFilePath);
      Self.Memo.Modified := False;

    except

      Self.UpdateStatusError('An error occurred while saving changes to file "' + Self.MemoFilePath + '".');

      Exit;

    end;

    Self.UpdateStatusInfo('Changes saved to file "' + Self.MemoFilePath + '" successfully.');

    if (Self.AcrylicServiceIsRunning = NTrue) then begin

      if (MessageBox(0, 'After the changes you need to restart the Acrylic service in order to see their effects.' + #13#10 + #13#10 + 'Do you want to do it now?', 'Acrylic Service Restart Needed', MB_ICONQUESTION or MB_YESNO) = IDYES) then begin

        Self.UpdateStatusInfo('Stopping the Acrylic service...');

        if not AcrylicUIUtils.StopAcrylicService then begin

          Self.UpdateStatusError('An error occurred while restarting the Acrylic service.');

          Exit;

        end;

        Self.UpdateStatusInfo('Starting the Acrylic service...');

        if not AcrylicUIUtils.StartAcrylicService then begin

          Self.UpdateStatusError('An error occurred while restarting the Acrylic service.');

          Exit;

        end;

        Self.UpdateStatusInfo('The Acrylic service has been restarted successfully.');

      end;

    end;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.FileExitMainMenuItemClick(Sender: TObject);

begin

  Self.Close;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsInstallAcrylicServiceMainMenuItemClick(Sender: TObject);

begin

  if (Self.AcrylicServiceIsInstalled = NFalse) then begin

    Self.UpdateStatusInfo('Installing the Acrylic service...');

    if not AcrylicUIUtils.InstallAcrylicService then begin

       Self.UpdateStatusError('An error occurred while installing the Acrylic service.');

       Exit;

    end;

    Self.UpdateStatusInfo('The Acrylic service has been installed successfully.');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsUninstallAcrylicServiceMainMenuItemClick(Sender: TObject);

begin

  if (Self.AcrylicServiceIsInstalled = NTrue) then begin

    Self.UpdateStatusInfo('Uninstalling the Acrylic service...');

    if not AcrylicUIUtils.UninstallAcrylicService then begin

      Self.UpdateStatusError('An error occurred while uninstalling the Acrylic service.');

      Exit;

    end;

    Self.UpdateStatusInfo('The Acrylic service has been uninstalled successfully.');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsStartAcrylicServiceMainMenuItemClick(Sender: TObject);

begin

  if (Self.AcrylicServiceIsRunning = NFalse) then begin

    Self.UpdateStatusInfo('Starting the Acrylic service...');

    if not AcrylicUIUtils.StartAcrylicService then begin

       Self.UpdateStatusError('An error occurred while starting the Acrylic service.');

       Exit;

    end;

    Self.UpdateStatusInfo('The Acrylic service has been started successfully.');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsStopAcrylicServiceMainMenuItemClick(Sender: TObject);

begin

  if (Self.AcrylicServiceIsRunning = NTrue) then begin

    Self.UpdateStatusInfo('Stopping the Acrylic service...');

    if not AcrylicUIUtils.StopAcrylicService then begin

      Self.UpdateStatusError('An error occurred while stopping the Acrylic service.');

      Exit;

    end;

    Self.UpdateStatusInfo('The Acrylic service has been stopped successfully.');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsRestartAcrylicServiceMainMenuItemClick(Sender: TObject);

begin

  if (Self.AcrylicServiceIsRunning = NTrue) then begin

    Self.UpdateStatusInfo('Stopping the Acrylic service...');

    if not AcrylicUIUtils.StopAcrylicService then begin

      Self.UpdateStatusError('An error occurred while restarting the Acrylic service.');

      Exit;

    end;

    Self.UpdateStatusInfo('Starting the Acrylic service...');

    if not AcrylicUIUtils.StartAcrylicService then begin

       Self.UpdateStatusError('An error occurred while restarting the Acrylic service.');

      Exit;

    end;

    Self.UpdateStatusInfo('The Acrylic service has been restarted successfully.');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsPurgeAcrylicCacheDataMainMenuItemClick(Sender: TObject);

var
  AcrylicCacheFilePath: String;

begin

  AcrylicCacheFilePath := AcrylicUIUtils.GetAcrylicCacheFilePath;

  if (Self.AcrylicServiceIsRunning = NTrue) then begin

    Self.UpdateStatusInfo('Stopping the Acrylic service...');

    if not AcrylicUIUtils.StopAcrylicService then begin

      Self.UpdateStatusError('An error occurred while purging Acrylic cache data.');

      Exit;

    end;

    if FileExists(AcrylicCacheFilePath) then begin

      Self.UpdateStatusInfo('Removing the Acrylic cache file...');

      AcrylicUIUtils.RemoveAcrylicCacheFile;

    end;

    Self.UpdateStatusInfo('Starting the Acrylic service...');

    if not AcrylicUIUtils.StartAcrylicService then begin

       Self.UpdateStatusError('An error occurred while purging Acrylic cache data.');

       Exit;

    end;

    Self.UpdateStatusInfo('Acrylic cache data has been purged successfully.');

  end else if (Self.AcrylicServiceIsRunning = NFalse) then begin

    if FileExists(AcrylicCacheFilePath) then begin

      Self.UpdateStatusInfo('Removing the Acrylic cache file...');

      AcrylicUIUtils.RemoveAcrylicCacheFile;

    end;

    Self.UpdateStatusInfo('Acrylic cache data has been purged successfully.');

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsActivateAcrylicDebugLogMainMenuItemClick(Sender: TObject);

begin

  if (Self.AcrylicServiceDebugLogIsEnabled = NFalse) then begin

    if (Self.AcrylicServiceIsRunning = NTrue) then begin

      Self.UpdateStatusInfo('Stopping the Acrylic service...');

      if not AcrylicUIUtils.StopAcrylicService then begin

        Self.UpdateStatusError('An error occurred while activating the Acrylic debug log.');

        Exit;

      end;

      Self.UpdateStatusInfo('Touching the Acrylic debug log...');

      AcrylicUIUtils.CreateAcrylicServiceDebugLog;

      Self.UpdateStatusInfo('Starting the Acrylic service...');

      if not AcrylicUIUtils.StartAcrylicService then begin

        Self.UpdateStatusError('An error occurred while activating the Acrylic debug log.');

        Exit;

      end;

      Self.UpdateStatusInfo('The Acrylic debug log has been activated successfully.');

    end else if (Self.AcrylicServiceIsRunning = NFalse) then begin

      Self.UpdateStatusInfo('Touching the Acrylic debug log...');

      AcrylicUIUtils.CreateAcrylicServiceDebugLog;

      Self.UpdateStatusInfo('The Acrylic debug log has been activated successfully.');

    end;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsDeactivateAcrylicDebugLogMainMenuItemClick(Sender: TObject);

begin

  if (Self.AcrylicServiceDebugLogIsEnabled = NTrue) then begin

    if (Self.AcrylicServiceIsRunning = NTrue) then begin

      Self.UpdateStatusInfo('Stopping the Acrylic service...');

      if not AcrylicUIUtils.StopAcrylicService then begin

        Self.UpdateStatusError('An error occurred while deactivating the Acrylic debug log.');

        Exit;

      end;

      Self.UpdateStatusInfo('Removing the Acrylic debug log...');

      AcrylicUIUtils.RemoveAcrylicServiceDebugLog;

      Self.UpdateStatusInfo('Starting the Acrylic service...');

      if not AcrylicUIUtils.StartAcrylicService then begin

        Self.UpdateStatusError('An error occurred while deactivating the Acrylic debug log.');

        Exit;

      end;

      Self.UpdateStatusInfo('The Acrylic debug log has been deactivated successfully.');

    end else if (Self.AcrylicServiceIsRunning = NFalse) then begin

      Self.UpdateStatusInfo('Removing the Acrylic debug log...');

      AcrylicUIUtils.RemoveAcrylicServiceDebugLog;

      Self.UpdateStatusInfo('The Acrylic debug log has been deactivated successfully.');

    end;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsViewCurrentAcrylicDebugLogMainMenuItemClick(Sender: TObject);

var
  AcrylicDebugLogFilePath: String;

begin

  if (Self.AcrylicServiceDebugLogIsEnabled = NTrue) then begin

    AcrylicDebugLogFilePath := AcrylicUIUtils.GetAcrylicDebugLogFilePath;

    WinExec(PAnsiChar('Notepad.exe "' + AcrylicDebugLogFilePath + '"'), SW_NORMAL);

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ActionsOpenAcrylicFolderinFileExplorerMainMenuItemClick(Sender: TObject);

var
  AcrylicDirectoryPath: String;

begin

  AcrylicDirectoryPath := AcrylicUIUtils.GetAcrylicDirectoryPath;

  WinExec(PAnsiChar('Explorer.exe "' + AcrylicDirectoryPath + '"'), SW_NORMAL);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.SettingsSetEditorFontMainMenuItemClick(Sender: TObject);

begin

  FontDialog.Font := Self.Memo.Font;

  if FontDialog.Execute then begin

    Self.Memo.Font := FontDialog.Font;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ToolsRegExTesterMainMenuItemClick(Sender: TObject);

var
  MyForm: TRegExTesterForm;

begin

  MyForm := TRegExTesterForm.Create(nil);
  MyForm.ShowModal;
  MyForm.Free;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ToolsDomainNameAffinityMaskTesterMainMenuItemClick(Sender: TObject);

var
  MyForm: TDomainNameAffinityMaskTesterForm;

begin

  MyForm := TDomainNameAffinityMaskTesterForm.Create(nil);
  MyForm.ShowModal;
  MyForm.Free;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.HelpAcrylicHomePageMainMenuItemClick(Sender: TObject);

begin

  ShellExecute(Self.Handle, 'open', 'https://mayakron.altervista.org/support/acrylic/Home.htm', nil, nil, SW_NORMAL);

end;

procedure TMainForm.MemoChange(Sender: TObject);
begin

  //#TODO Do something with changes e.g. if IniBuff <> Memo.Text then

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.ParseINI(text: string);
var
  lines: TStrings;
  I: Integer;
  node, subnode, extnode, _node: PVirtualNode;
  data: PIniData;
  parser: TStringList;

begin

  lines := TStringList.Create;
  try
    lines.Text := Memo.Text;

    vstINI.DeleteChildren(vstINI.RootNode);

    // First section will be the GlobalSection'
//    extnode := vstINI.AddChild(nil);
//    data := vstINI.GetNodeData(extnode);
//    data^.key := 'GlobalSection';
//    data^.line := 0;
//    data^.sectionchanges := '';

    for i := 0 to lines.Count - 1 do
      begin
        if Pos('[',Trim(lines[i])) = 1 then
        begin
          node := vstINI.AddChild(nil);
          data := vstINI.GetNodeData(node);
          data^.key := Trim(lines[i]);
          data^.line := i;
          data^.sectionchanges := ''; //defaults to no changes
        end
        // comments out
        else
        if Pos(';',Trim(lines[i])) = 1 then
        begin
          // find out if is a valid commented/disabled value
          parser := TStringList.Create;
          try
            parser.Text := StringReplace(lines[i], '=',#13#10'#'#13#10,[]);
            if Pos(' ', Trim(parser[0]))> 0 then
            begin
              // is not a valid key value
            end
            else if parser.Count > 1 then
            begin
              if Assigned(node) then
              begin
                _node := nil;

                subnode := vstINI.AddChild(node);
                data := vstINI.GetNodeData(subnode);
                data^.key := Copy(parser[0],2);
                if parser.Count > 2 then
                begin
                  data^.value := parser[2];
                  data^.savedvalue := parser[2];
                end;
                data^.line := i;
                data^.enabled := False;
                subnode.CheckState := csUncheckedNormal;

                if _node <> nil then node := _node;
              end;
            end;

          finally
            parser.Free;
          end;
        end
        else if Trim(lines[i]) = '' then
        begin
          //empty line
        end
        else
        begin
          parser := TStringList.Create;
          try
            parser.Text := StringReplace(lines[i], '=',#13#10'#'#13#10,[]);
            if Pos(' ', Trim(parser[0]))> 0 then
            begin
              // is not a valid key value
            end
            else if parser.Count > 1 then
            begin
              if Assigned(node) then
              begin
                _node := nil;

                subnode := vstINI.AddChild(node);
                data := vstINI.GetNodeData(subnode);
                data^.key := parser[0];
                if parser.Count > 2 then
                begin
                  data^.value := parser[2];
                  data^.savedvalue := parser[2];
                end;
                data^.line := i;
                data^.enabled := True;
                subnode.CheckState := csCheckedNormal;

                if _node <> nil then node := _node;

              end;
            end;

          finally
            parser.Free;
          end;
        end;
      end;
  finally
    lines.Free;
  end;
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TMainForm.HelpAboutAcrylicMainMenuItemClick(Sender: TObject);

begin

  MessageBox(0, PChar(AcrylicUIUtils.GetAcrylicDescriptionString), 'About Acrylic', MB_ICONINFORMATION or MB_OK);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

end.

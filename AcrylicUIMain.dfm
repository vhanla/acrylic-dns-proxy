object MainForm: TMainForm
  Left = 298
  Top = 136
  Caption = 'Acrylic DNS Proxy UI'
  ClientHeight = 417
  ClientWidth = 788
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  Position = poDefault
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 420
    Top = 0
    Height = 394
    ExplicitLeft = 616
    ExplicitTop = -6
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 394
    Width = 788
    Height = 23
    Panels = <>
    SimplePanel = True
    SizeGrip = False
    ExplicitTop = 385
    ExplicitWidth = 782
  end
  object Memo: TSynEdit
    Left = 423
    Top = 0
    Width = 365
    Height = 394
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Consolas'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    TabOrder = 1
    Visible = False
    UseCodeFolding = False
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -13
    Gutter.Font.Name = 'Consolas'
    Gutter.Font.Style = []
    Gutter.Bands = <
      item
        Kind = gbkMarks
        Width = 13
      end
      item
        Kind = gbkLineNumbers
      end
      item
        Kind = gbkFold
      end
      item
        Kind = gbkTrackChanges
      end
      item
        Kind = gbkMargin
        Width = 3
      end>
    Lines.Strings = (
      'Memo')
    SelectedColor.Alpha = 0.400000005960464500
    WantTabs = True
    OnChange = MemoChange
    ExplicitLeft = 0
    ExplicitWidth = 359
    ExplicitHeight = 385
  end
  object vstINI: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 420
    Height = 394
    Align = alLeft
    Colors.BorderColor = 15987699
    Colors.DisabledColor = clGray
    Colors.DropMarkColor = 15385233
    Colors.DropTargetColor = 15385233
    Colors.DropTargetBorderColor = 15385233
    Colors.FocusedSelectionColor = 15385233
    Colors.FocusedSelectionBorderColor = 15385233
    Colors.GridLineColor = 15987699
    Colors.HeaderHotColor = clBlack
    Colors.HotColor = clBlack
    Colors.SelectionRectangleBlendColor = 15385233
    Colors.SelectionRectangleBorderColor = 15385233
    Colors.SelectionTextColor = clBlack
    Colors.TreeLineColor = 9471874
    Colors.UnfocusedColor = clGray
    Colors.UnfocusedSelectionColor = clWhite
    Colors.UnfocusedSelectionBorderColor = clWhite
    Header.AutoSizeIndex = 0
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 2
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoTristateTracking]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toEditable, toInitOnSave, toWheelPanning, toEditOnDblClick]
    TreeOptions.PaintOptions = [toHideFocusRect, toShowBackground, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toRightClickSelect]
    OnBeforeCellPaint = vstINIBeforeCellPaint
    OnChecked = vstINIChecked
    OnFreeNode = vstINIFreeNode
    OnGetText = vstINIGetText
    OnInitChildren = vstINIInitChildren
    OnInitNode = vstINIInitNode
    OnNewText = vstININewText
    OnNodeDblClick = vstININodeDblClick
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    ExplicitLeft = 368
    Columns = <
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 0
        Text = 'Key'
        Width = 197
      end
      item
        Position = 1
        Text = 'Value'
        Width = 231
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus, coEditable]
        Position = 2
        Text = 'Description'
        Width = 244
      end>
  end
  object MainMenu: TMainMenu
    AutoHotkeys = maManual
    Left = 3
    Top = 4
    object FileMainMenuItem: TMenuItem
      Caption = '&File'
      object FileOpenMainMenuItem: TMenuItem
        Caption = '&Open...'
        ShortCut = 16463
        OnClick = FileOpenMainMenuItemClick
      end
      object FileOpenAcrylicConfigurationMainMenuItem: TMenuItem
        Caption = 'Open Acrylic &Configuration'
        ShortCut = 16496
        OnClick = FileOpenAcrylicConfigurationMainMenuItemClick
      end
      object FileOpenAcrylicHostsMainMenuItem: TMenuItem
        Caption = 'Open Acrylic &Hosts'
        ShortCut = 16497
        OnClick = FileOpenAcrylicHostsMainMenuItemClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object FileSaveMainMenuItem: TMenuItem
        Caption = '&Save'
        Enabled = False
        ShortCut = 16467
        OnClick = FileSaveMainMenuItemClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object FileExitMainMenuItem: TMenuItem
        Caption = 'E&xit'
        ShortCut = 32883
        OnClick = FileExitMainMenuItemClick
      end
    end
    object ActionsMainMenuItem: TMenuItem
      Caption = '&Actions'
      object ActionsInstallAcrylicServiceMainMenuItem: TMenuItem
        Caption = '&Install Acrylic Service'
        OnClick = ActionsInstallAcrylicServiceMainMenuItemClick
      end
      object ActionsUninstallAcrylicServiceMainMenuItem: TMenuItem
        Caption = '&Uninstall Acrylic Service'
        OnClick = ActionsUninstallAcrylicServiceMainMenuItemClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object ActionsStartAcrylicServiceMainMenuItem: TMenuItem
        Caption = 'St&art Acrylic Service'
        Enabled = False
        OnClick = ActionsStartAcrylicServiceMainMenuItemClick
      end
      object ActionsStopAcrylicServiceMainMenuItem: TMenuItem
        Caption = 'St&op Acrylic Service'
        Enabled = False
        OnClick = ActionsStopAcrylicServiceMainMenuItemClick
      end
      object ActionsRestartAcrylicServiceMainMenuItem: TMenuItem
        Caption = '&Restart Acrylic Service'
        Enabled = False
        OnClick = ActionsRestartAcrylicServiceMainMenuItemClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object ActionsPurgeAcrylicCacheDataMainMenuItem: TMenuItem
        Caption = '&Purge Acrylic Cache Data'
        OnClick = ActionsPurgeAcrylicCacheDataMainMenuItemClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object ActionsActivateAcrylicDebugLogMainMenuItem: TMenuItem
        Caption = 'A&ctivate Acrylic Debug Log'
        Enabled = False
        OnClick = ActionsActivateAcrylicDebugLogMainMenuItemClick
      end
      object ActionsDeactivateAcrylicDebugLogMainMenuItem: TMenuItem
        Caption = 'D&eactivate Acrylic Debug Log'
        Enabled = False
        OnClick = ActionsDeactivateAcrylicDebugLogMainMenuItemClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object ActionsViewCurrentAcrylicDebugLogMainMenuItem: TMenuItem
        Caption = 'View Current Acrylic De&bug Log'
        Enabled = False
        OnClick = ActionsViewCurrentAcrylicDebugLogMainMenuItemClick
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object ActionsOpenAcrylicFolderinFileExplorerMainMenuItem: TMenuItem
        Caption = 'Open Acrylic &Folder in File Explorer'
        OnClick = ActionsOpenAcrylicFolderinFileExplorerMainMenuItemClick
      end
    end
    object SettingsMainMenuItem: TMenuItem
      Caption = '&Settings'
      object SettingsSetEditorFontMainMenuItem: TMenuItem
        Caption = 'Set Editor &Font...'
        OnClick = SettingsSetEditorFontMainMenuItemClick
      end
    end
    object ToolsMainMenuItem: TMenuItem
      Caption = '&Tools'
      object ToolsRegExTesterMainMenuItem: TMenuItem
        Caption = '&RegEx Tester'
        OnClick = ToolsRegExTesterMainMenuItemClick
      end
      object ToolsDomainNameAffinityMaskTesterMainMenuItem: TMenuItem
        Caption = '&Domain Name Affinity Mask Tester'
        OnClick = ToolsDomainNameAffinityMaskTesterMainMenuItemClick
      end
    end
    object HelpMainMenuItem: TMenuItem
      Caption = '&Help'
      object HelpAcrylicHomePageMainMenuItem: TMenuItem
        Caption = 'Acrylic &Home Page'
        OnClick = HelpAcrylicHomePageMainMenuItemClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object HelpAboutAcrylicMainMenuItem: TMenuItem
        Caption = '&About Acrylic'
        OnClick = HelpAboutAcrylicMainMenuItemClick
      end
    end
  end
  object Timer: TTimer
    Interval = 500
    OnTimer = TimerTimer
    Left = 33
    Top = 4
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 63
    Top = 4
  end
  object OpenDialog: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 93
    Top = 4
  end
  object SynIniSyn1: TSynIniSyn
    Left = 456
    Top = 160
  end
end

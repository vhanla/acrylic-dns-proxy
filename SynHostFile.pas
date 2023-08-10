unit SynHostFile;

{$I SynEdit.inc}

interface

uses
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynUnicode,
  Classes;

type
  TtkTokenKind = (tkComment, tkHost, tkDescription, tkUnknown);

type
  TSynHostsSyn = class(TSynCustomHighlighter)
  private
    FTokenID: TtkTokenKind;
    fCommentAttri: TSynHighlighterAttributes;
    fHostAttri: TSynHighlighterAttributes;
    fDescriptionAttri: TSynHighlighterAttributes;
    procedure HostProc;
    procedure CommentProc;
    procedure TextProc;
    procedure NullProc;
    procedure SpaceProc;
  protected
    function GetSampleSource: string; override;
    function IsFilterStored: Boolean; override;
  public
    class function GetLanguageName: string; override;
    class function GetFriendlyLanguageName: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
      override;
    function GetEol: Boolean; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    procedure Next; override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri
      write fCommentAttri;
    property HostAttri: TSynHighlighterAttributes read fHostAttri
      write fHostAttri;
    property DescriptionAttri: TSynHighlighterAttributes read fDescriptionAttri
      write fDescriptionAttri;
  end;

implementation

uses
  SynEditStrConst;

constructor TSynHostsSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment, SYNS_FriendlyAttrComment);
  fCommentAttri.Style := [fsItalic];
  fCommentAttri.Foreground := clGreen;
  AddAttribute(fCommentAttri);
  fHostAttri := TSynHighlighterAttributes.Create('IPAddress', 'IPAddress');
  AddAttribute(fHostAttri);
  fDescriptionAttri := TSynHighlighterAttributes.Create(SYNS_AttrReservedWord, SYNS_FriendlyAttrReservedWord);
  AddAttribute(fDescriptionAttri);
  SetAttributesOnChange(DefHighlightChange);

  fDefaultFilter := SYNS_FilterINI;
end; { Create }

procedure TSynHostsSyn.HostProc;
begin
  fTokenID := tkHost;
  while not IsLineEnd(Run) do
    case FLine[Run] of
      #0..#32: break;
    else
      inc(Run);
    end;
end;

procedure TSynHostsSyn.CommentProc;
begin
  fTokenID := tkComment;
  inc(Run);
  while FLine[Run] <> #0 do
    case FLine[Run] of
      #10: break;
      #13: break;
      else inc(Run);
    end;
end;

procedure TSynHostsSyn.TextProc;
begin
  fTokenID := tkUnknown;
  inc(Run);
end;

procedure TSynHostsSyn.NullProc;
begin
  fTokenID := tkUnknown;
  inc(Run);
end;

procedure TSynHostsSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
  while (FLine[Run] <= #32) and not IsLineEnd(Run) do inc(Run);
end;

procedure TSynHostsSyn.Next;
begin
  fTokenPos := Run;
  case fLine[Run] of
    #0: NullProc;
    #35: CommentProc; // #
    #1..#9, #11, #12, #14..#32: SpaceProc;
    else HostProc;
  end;
  inherited;
end;

function TSynHostsSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := fCommentAttri;
    SYN_ATTR_KEYWORD: Result := fHostAttri;
//    SYN_ATTR_RESERVEDWORD: Result := fDescriptionAttri;
  else
    Result := nil;
  end;
end;

function TSynHostsSyn.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

function TSynHostsSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TSynHostsSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkHost: Result := fHostAttri;
    tkDescription: Result := fDescriptionAttri;
//    tkUnknown: Result := fTextAttri;
    else Result := nil;
  end;
end;

function TSynHostsSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenId);
end;

function TSynHostsSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterINI;
end;

class function TSynHostsSyn.GetLanguageName: string;
begin
  Result := 'Hosts';
end;

function TSynHostsSyn.GetSampleSource: string;
begin
  Result := '# Sample Hosts File'#13#10+
            '127.0.0.1  localhost # Loopback address';
end;

class function TSynHostsSyn.GetFriendlyLanguageName: string;
begin
  Result := 'Hosts File';
end;

initialization
  RegisterPlaceableHighlighter(TSynHostsSyn);
end.


// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

unit
  AcrylicUIRegExTester;

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
  Classes,
  Controls,
  Forms,
  StdCtrls,
  AcrylicUIUtils;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

type
  TRegExTesterForm = class(TForm)

    lblDomainName: TLabel;
    txtDomainName: TEdit;
    lblRegEx: TLabel;
    txtRegEx: TEdit;
    lblResult: TLabel;
    btnTest: TButton;

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure btnTestClick(Sender: TObject);

  end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  RegExTesterForm: TRegExTesterForm;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

{$R *.dfm}

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TRegExTesterForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

begin

  if (Key = 27) then Self.ModalResult := mrCancel;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TRegExTesterForm.btnTestClick(Sender: TObject);

begin

  try

    if AcrylicUIUtils.TestRegEx(txtDomainName.Text, txtRegEx.Text) then begin

      lblResult.Caption := 'Match: YES.';

    end else begin

      lblResult.Caption := 'Match: NO.';

    end;

  except

    lblResult.Caption := 'Invalid regular expression specified.';

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

end.

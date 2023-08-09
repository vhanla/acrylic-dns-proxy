// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

unit
  MemoryManager;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

interface

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Classes,
  SysUtils;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

type
  TMemoryManager = class
    public
      class function  GetMemory(Size: Integer): Pointer;
      class procedure FreeMemory(Address: Pointer; Size: Integer);
  end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

class function TMemoryManager.GetMemory(Size: Integer): Pointer;

var
  Address: Pointer;

begin

  GetMem(Address, Size); Result := Address;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

class procedure TMemoryManager.FreeMemory(Address: Pointer; Size: Integer);

begin

  FreeMem(Address, Size);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

end.
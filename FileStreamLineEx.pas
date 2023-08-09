// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

unit
  FileStreamLineEx;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

interface

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Classes;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

type
  TFileStreamLineEx = class
    private
      Stream: TStream;
      CurrentLine: String;
    public
      constructor Create(Stream: TStream);
    public
      function    ReadLine(var OutputLine: String): Boolean;
    private
      function    TryFindLineTerminator(const CurrentLine: String; var Position, Length: Integer): Boolean;
  end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

const
  LINE_READ_CHUNK = 2048;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

constructor TFileStreamLineEx.Create(Stream: TStream);

begin

  Self.Stream := Stream; SetLength(Self.CurrentLine, 0);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function TFileStreamLineEx.TryFindLineTerminator(const CurrentLine: String; var Position, Length: Integer): Boolean;

var
  i: Integer;

begin

  i := Pos(#13#10, CurrentLine);

  if (i > 0) then begin
    Position := i; Length := 2; Result := True; Exit;
  end;

  i := Pos(#10, CurrentLine);

  if (i > 0) then begin
    Position := i; Length := 1; Result := True; Exit;
  end;

  Result := False;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function TFileStreamLineEx.ReadLine(var OutputLine: String): Boolean;

var
  ChunkData: String; ChunkSize: Integer; LineTerminatorFound: Boolean; LineTerminatorPosition, LineTerminatorLength: Integer;

begin

  LineTerminatorFound := Self.TryFindLineTerminator(Self.CurrentLine, LineTerminatorPosition, LineTerminatorLength); while not LineTerminatorFound do begin

    SetLength(ChunkData, LINE_READ_CHUNK); ChunkSize := Stream.Read(ChunkData[1], LINE_READ_CHUNK); if (ChunkSize > 0) then begin

      Self.CurrentLine := Self.CurrentLine + Copy(ChunkData, 1, ChunkSize);

      LineTerminatorFound := Self.TryFindLineTerminator(Self.CurrentLine, LineTerminatorPosition, LineTerminatorLength);

    end else begin

      Break;

    end;

  end; if LineTerminatorFound then begin

    OutputLine := Copy(Self.CurrentLine, 1, LineTerminatorPosition - 1); Delete(Self.CurrentLine, 1, LineTerminatorPosition + LineTerminatorLength - 1);

    Result := True;

  end else begin

    OutputLine := Self.CurrentLine; SetLength(Self.CurrentLine, 0);

    Result := False;

  end;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

end.
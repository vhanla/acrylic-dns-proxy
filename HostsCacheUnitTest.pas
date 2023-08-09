// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

type
  THostsCacheUnitTest = class(TAbstractUnitTest)
    private
      HostsItems: Integer;
    public
      constructor Create;
      procedure   ExecuteTest; override;
      destructor  Destroy; override;
    private
      function    InternalGetRandomString: String;
  end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

constructor THostsCacheUnitTest.Create;

begin

  inherited Create;

  Self.HostsItems := 1000000;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure THostsCacheUnitTest.ExecuteTest;

var
  TimeStamp: TDateTime; InitSeed: Integer; HostsStream: TBufferedSequentialWriteStream; i: Integer; H: String; IPv4Address: TIPv4Address; IPv6Address: TIPv6Address; HostsEntryIPv4Address: TIPv4Address; HostsEntryIPv6Address: TIPv6Address;

begin

  TimeStamp := Now;

  InitSeed := Round(Frac(TimeStamp) * 8640000.0);

  THostsCache.Initialize;

  TTracer.Trace(TracePriorityInfo, Self.ClassName + ': ' + IntToStr(Self.HostsItems) + ' hosts items.');

  TTracer.Trace(TracePriorityInfo, Self.ClassName + ': Starting massive insertion...');

  HostsStream := TBufferedSequentialWriteStream.Create(Self.ClassName + '.tmp', False, BUFFERED_SEQUENTIAL_STREAM_256KB_BUFFER_SIZE);

  RandSeed := InitSeed;

  for i := 0 to (Self.HostsItems - 1) do begin

    H := FormatCurr('000000000', i);

    // IPv4 address

    IPv4Address := Random(256) or (Random(256) shl 8) or (Random(256) shl 16) or (Random(128) shl 24);

    // IPv4 entries (1)

    HostsStream.WriteString(TIPv4AddressUtility.ToString(IPv4Address) + #32 + 'IPV4DOMAIN1-' + InternalGetRandomString + '-' + H + '-A' + #32 + 'IPV4DOMAIN1-' + InternalGetRandomString + '-' + H + '-B' + #32 + 'IPV4DOMAIN1-' + InternalGetRandomString + '-' + H + '-C' + #13#10);

    // IPv6 address

    IPv6Address[00] := Random(256);
    IPv6Address[01] := Random(256);
    IPv6Address[02] := Random(256);
    IPv6Address[03] := Random(256);
    IPv6Address[04] := Random(256);
    IPv6Address[05] := Random(256);
    IPv6Address[06] := Random(256);
    IPv6Address[07] := Random(256);
    IPv6Address[08] := Random(256);
    IPv6Address[09] := Random(256);
    IPv6Address[10] := Random(256);
    IPv6Address[11] := Random(256);
    IPv6Address[12] := Random(256);
    IPv6Address[13] := Random(256);
    IPv6Address[14] := Random(256);
    IPv6Address[15] := Random(256);

    // IPv6 entries (1)

    HostsStream.WriteString(TIPv6AddressUtility.ToString(IPv6Address) + #32 + 'IPV6DOMAIN1-' + InternalGetRandomString + '-' + H + '-A' + #32 + 'IPV6DOMAIN1-' + InternalGetRandomString + '-' + H + '-B' + #32 + 'IPV6DOMAIN1-' + InternalGetRandomString + '-' + H + '-C' + #13#10);

    // FW entries (1)

    HostsStream.WriteString('FW' + #32 + 'FWDOMAIN1-' + InternalGetRandomString + '-' + H + '-A' + #32 + 'FWDOMAIN1-' + InternalGetRandomString + '-' + H + '-B' + #32 + 'FWDOMAIN1-' + InternalGetRandomString + '-' + H + '-C' + #13#10);

    // NX entries (1)

    HostsStream.WriteString('NX' + #32 + 'NXDOMAIN1-' + InternalGetRandomString + '-' + H + '-A' + #32 + 'NXDOMAIN1-' + InternalGetRandomString + '-' + H + '-B' + #32 + 'NXDOMAIN1-' + InternalGetRandomString + '-' + H + '-C' + #13#10);

  end;

  // IPv4 entries (2)

  HostsStream.WriteString('127.0.0.1 >IPV4DOMAIN2-127-0-0-1' + #13#10);

  // IPv6 entries (2)

  HostsStream.WriteString('::1 >IPV6DOMAIN2-LOCALHOST' + #13#10);

  // FW entries (2)

  HostsStream.WriteString('FW >FWDOMAIN2' + #13#10);

  // NX entries (2)

  HostsStream.WriteString('NX >NXDOMAIN2' + #13#10);

  // IPv4 entries (3)

  HostsStream.WriteString('127.0.0.1 >IPV4DOMAIN3-127-0-0-1.*' + #13#10);

  // IPv6 entries (3)

  HostsStream.WriteString('::1 >IPV6DOMAIN3-LOCALHOST.*' + #13#10);

  // FW entries (3)

  HostsStream.WriteString('FW >FWDOMAIN3.*' + #13#10);

  // NX entries (3)

  HostsStream.WriteString('NX >NXDOMAIN3.*' + #13#10);

  // IPv4 entries (4)

  HostsStream.WriteString('127.0.0.1 *.IPV4DOMAIN4-127-0-0-1.*' + #13#10);

  // IPv6 entries (4)

  HostsStream.WriteString('::1 *.IPV6DOMAIN4-LOCALHOST.*' + #13#10);

  // FW entries (4)

  HostsStream.WriteString('FW *.FWDOMAIN4.*' + #13#10);

  // NX entries (4)

  HostsStream.WriteString('NX *.NXDOMAIN4.*' + #13#10);

  // IPv4 entries (5)

  HostsStream.WriteString('127.0.0.1 /^.*\.IPV4DOMAIN5-127-0-0-1\..*$' + #13#10);

  // IPv6 entries (5)

  HostsStream.WriteString('::1 /^.*\.IPV6DOMAIN5-LOCALHOST\..*$' + #13#10);

  // FW entries (5)

  HostsStream.WriteString('FW /^.*\.FWDOMAIN5\..*$' + #13#10);

  // NX entries (5)

  HostsStream.WriteString('NX /^.*\.NXDOMAIN5\..*$' + #13#10);

  HostsStream.Flush;

  HostsStream.Free;

  TTracer.Trace(TracePriorityInfo, Self.ClassName + ': Done.');

  TTracer.Trace(TracePriorityInfo, Self.ClassName + ': Starting loading from file...');

  THostsCache.LoadFromFile(Self.ClassName + '.tmp');

  TTracer.Trace(TracePriorityInfo, Self.ClassName + ': Done.');

  TTracer.Trace(TracePriorityInfo, Self.ClassName + ': Starting massive search...');

  RandSeed := InitSeed;

  for i := 0 to (Self.HostsItems - 1) do begin

    H := FormatCurr('000000000', i);

    // IPv4 address

    IPv4Address := Random(256) or (Random(256) shl 8) or (Random(256) shl 16) or (Random(128) shl 24);

    // IPv4 entries (1)

    if not(THostsCache.FindIPv4Item('IPV4DOMAIN1-' + InternalGetRandomString + '-' + H + '-A', HostsEntryIPv4Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, IPv4Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindIPv4Item('IPV4DOMAIN1-' + InternalGetRandomString + '-' + H + '-B', HostsEntryIPv4Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, IPv4Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindIPv4Item('IPV4DOMAIN1-' + InternalGetRandomString + '-' + H + '-C', HostsEntryIPv4Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, IPv4Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    // IPv6 address

    IPv6Address[00] := Random(256);
    IPv6Address[01] := Random(256);
    IPv6Address[02] := Random(256);
    IPv6Address[03] := Random(256);
    IPv6Address[04] := Random(256);
    IPv6Address[05] := Random(256);
    IPv6Address[06] := Random(256);
    IPv6Address[07] := Random(256);
    IPv6Address[08] := Random(256);
    IPv6Address[09] := Random(256);
    IPv6Address[10] := Random(256);
    IPv6Address[11] := Random(256);
    IPv6Address[12] := Random(256);
    IPv6Address[13] := Random(256);
    IPv6Address[14] := Random(256);
    IPv6Address[15] := Random(256);

    // IPv6 entries (1)

    if not(THostsCache.FindIPv6Item('IPV6DOMAIN1-' + InternalGetRandomString + '-' + H + '-A', HostsEntryIPv6Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, IPv6Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindIPv6Item('IPV6DOMAIN1-' + InternalGetRandomString + '-' + H + '-B', HostsEntryIPv6Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, IPv6Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindIPv6Item('IPV6DOMAIN1-' + InternalGetRandomString + '-' + H + '-C', HostsEntryIPv6Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, IPv6Address)) then begin
      raise FailedUnitTestException.Create;
    end;

    // FW entries (1)

    if not(THostsCache.FindFWItem('FWDOMAIN1-' + InternalGetRandomString + '-' + H + '-A')) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindFWItem('FWDOMAIN1-' + InternalGetRandomString + '-' + H + '-B')) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindFWItem('FWDOMAIN1-' + InternalGetRandomString + '-' + H + '-C')) then begin
      raise FailedUnitTestException.Create;
    end;

    // NX entries (1)

    if not(THostsCache.FindNXItem('NXDOMAIN1-' + InternalGetRandomString + '-' + H + '-A')) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindNXItem('NXDOMAIN1-' + InternalGetRandomString + '-' + H + '-B')) then begin
      raise FailedUnitTestException.Create;
    end;

    if not(THostsCache.FindNXItem('NXDOMAIN1-' + InternalGetRandomString + '-' + H + '-C')) then begin
      raise FailedUnitTestException.Create;
    end;

  end;

  // IPv4 entries (2)

  if not(THostsCache.FindIPv4Item('IPV4DOMAIN2-127-0-0-1', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('ipv4domain2-127-0-0-1', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('MATCH.IPV4DOMAIN2-127-0-0-1', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('match.ipv4domain2-127-0-0-1', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv6 entries (2)

  if not(THostsCache.FindIPv6Item('IPV6DOMAIN2-LOCALHOST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('ipv6domain2-LOCALHOST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('MATCH.IPV6DOMAIN2-LOCALHOST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('match.ipv6domain2-LOCALHOST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // FW entries (2)

  if not(THostsCache.FindFWItem('FWDOMAIN2')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('fwdomain2')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('MATCH.FWDOMAIN2')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('match.fwdomain2')) then begin
    raise FailedUnitTestException.Create;
  end;

  // NX entries (2)

  if not(THostsCache.FindNXItem('NXDOMAIN2')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('nxdomain2')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('MATCH.NXDOMAIN2')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('match.nxdomain2')) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv4 entries (3)

  if not(THostsCache.FindIPv4Item('IPV4DOMAIN3-127-0-0-1.TEST', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('ipv4domain3-127-0-0-1.test', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('MATCH.IPV4DOMAIN3-127-0-0-1.TEST', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('match.ipv4domain3-127-0-0-1.test', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv6 entries (3)

  if not(THostsCache.FindIPv6Item('IPV6DOMAIN3-LOCALHOST.TEST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('ipv6domain3-LOCALHOST.test', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('MATCH.IPV6DOMAIN3-LOCALHOST.TEST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('match.ipv6domain3-LOCALHOST.test', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // FW entries (3)

  if not(THostsCache.FindFWItem('FWDOMAIN3.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('fwdomain3.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('MATCH.FWDOMAIN3.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('match.fwdomain3.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  // NX entries (3)

  if not(THostsCache.FindNXItem('NXDOMAIN3.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('nxdomain3.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('MATCH.NXDOMAIN3.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('match.nxdomain3.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv4 entries (4)

  if not(THostsCache.FindIPv4Item('MATCH.IPV4DOMAIN4-127-0-0-1.TEST', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('match.ipv4domain4-127-0-0-1.test', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv6 entries (4)

  if not(THostsCache.FindIPv6Item('MATCH.IPV6DOMAIN4-LOCALHOST.TEST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('match.ipv6domain4-LOCALHOST.test', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // FW entries (4)

  if not(THostsCache.FindFWItem('MATCH.FWDOMAIN4.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('match.fwdomain4.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  // NX entries (4)

  if not(THostsCache.FindNXItem('MATCH.NXDOMAIN4.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('match.nxdomain4.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv4 entries (5)

  if not(THostsCache.FindIPv4Item('MATCH.IPV4DOMAIN5-127-0-0-1.TEST', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv4Item('match.ipv4domain5-127-0-0-1.test', HostsEntryIPv4Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv4AddressUtility.AreEqual(HostsEntryIPv4Address, LOCALHOST_IPV4_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv6 entries (5)

  if not(THostsCache.FindIPv6Item('MATCH.IPV6DOMAIN5-LOCALHOST.TEST', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindIPv6Item('match.ipv6domain5-LOCALHOST.test', HostsEntryIPv6Address)) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(TIPv6AddressUtility.AreEqual(HostsEntryIPv6Address, LOCALHOST_IPV6_ADDRESS)) then begin
    raise FailedUnitTestException.Create;
  end;

  // FW entries (4)

  if not(THostsCache.FindFWItem('MATCH.FWDOMAIN5.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindFWItem('match.fwdomain5.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  // NX entries (4)

  if not(THostsCache.FindNXItem('MATCH.NXDOMAIN5.TEST')) then begin
    raise FailedUnitTestException.Create;
  end;

  if not(THostsCache.FindNXItem('match.nxdomain5.test')) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv4 nonexistant entry

  if THostsCache.FindIPv4Item('IPV4NONEXISTANTDOMAIN', HostsEntryIPv4Address) then begin
    raise FailedUnitTestException.Create;
  end;

  // IPv6 nonexistant entry

  if THostsCache.FindIPv6Item('IPV6NONEXISTANTDOMAIN', HostsEntryIPv6Address) then begin
    raise FailedUnitTestException.Create;
  end;

  // FW nonexistant entry

  if THostsCache.FindFWItem('FWNONEXISTANTDOMAIN') then begin
    raise FailedUnitTestException.Create;
  end;

  // NX nonexistant entry

  if THostsCache.FindNXItem('NXNONEXISTANTDOMAIN') then begin
    raise FailedUnitTestException.Create;
  end;

  TTracer.Trace(TracePriorityInfo, Self.ClassName + ': Done.');

  THostsCache.Finalize;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function THostsCacheUnitTest.InternalGetRandomString: String;

begin

  Result := Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26)) + Char(65 + Random(26));

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

destructor THostsCacheUnitTest.Destroy;

begin

  inherited Destroy;

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------
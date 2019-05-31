{ Knihovna pozic }
unit Uknih;

interface

uses
  SysUtils,

  CoTy,
  uSxRandomGenerator;

const
  MaxTahu = 5; // Defined in file
  NoMove = 255; // Defined in file

type
  TKnihData = record
    Pozice: TPozice;
    Tahy: array [1 .. MaxTahu] of ttah1; { je-li p1=NoMove, tah "není zadán" }
    Nazev: string30;
  end;

  PKnihStrom = ^TKnihStrom;

  TKnihStrom = record
    L, R: PKnihStrom;
    Data: TKnihData;
  end;

  TTahy1 = array of TTah1;

  TKnihovna = class
  private
    FNodeCount: Integer;
    FRandomGenerator: TSxRandomGenerator;
    Procedure SmazKnihStrom; { Dealokuje pamìt, smaže své údaje. }
  public
    Zmeneno: boolean;
    KnihStrom: PKnihStrom;
    { Tady si to všechno pamatuji. }
//    function PocetPozic: LongInt;
    function HloubkaStromu: LongInt;
    Constructor Create;
    Destructor Destroy; override;
    Procedure PridejData(var Data: TKnihData);
    { Pøidá pozici s údaji do knihovny. Je-li už pozice v knihovnì,
      pøepíše se. }
    Procedure PridejTah(T1: ttah1; var Pozice: TPozice; text: string30);
    { Pøidá tah z pozice do knihovny.
      Je-li už pozice v knihovnì:
      a) je-li už uveden tento tah jako jeden z možných,
      nestane se nic
      b) není-li uveden
      b1) Je-li volné místo, pøipíše se (jednou)
      b2) Není-li volné místo
      b2I) Je-li tam nejèetnìjší tah více než jednou,
      pøepíše jeden jeho výskyt
      b2II) Je-li tam každý tah jednou, nestane se nic }
    Procedure DejData(var Pozice: TPozice; out Data: PKnihStrom);
    { Vrátí v Data pointer na záznam s tahy z Pozice nebo Nil. }
    function DejTahy(var Pozice: TPozice; out Name: string): TTahy1;
    { To hlavní... Vrací false, není-li pozice v knihovnì }
    procedure DejNTaData(n: LongInt; var Data: PKnihStrom);
    { Èíslováno od 1, je-li tam ménì záznamù, vrací nil }
    procedure mazej(var co: TPozice);
    // procedure uloz;
    procedure otevri(const AFileName: TFileName);

    property NodeCount: Integer read FNodeCount;
  end;

implementation

uses
  rychle,
  uFile,
  Windows;

Procedure TKnihovna.DejData(var Pozice: TPozice; out Data: PKnihStrom);
var
  pom: PKnihStrom;
  i: integer;
begin
  Data := nil;
  if KnihStrom = nil then
    exit;
  pom := KnihStrom;
  repeat
    i := CMPPozice(pom^.Data.Pozice, Pozice);
    case i of
      0:
        Data := pom;
      1:
        pom := pom^.L;
      -1:
        pom := pom^.R;
    end;
  until (pom = nil) or (i = 0);
end;

function TKnihovna.DejTahy(var Pozice: TPozice; out Name: string): TTahy1;
var
  PodStrom: PKnihStrom;
  i, tahu, offset: integer;
  Tah1, LTah1: TTah1;
begin
  DejData(Pozice, PodStrom);
  SetLength(result, 0);
  if PodStrom <> nil then
  begin
    Name := string(PodStrom^.Data.Nazev);
    tahu := 0;
    FillChar(LTah1, SizeOf(LTah1), 0);
    for i := 1 to MaxTahu do
    begin
      Tah1 := PodStrom^.Data.Tahy[i];
      if (Tah1.P1 <> NoMove) then
      begin
        inc(tahu);
      end;
      LTah1 := Tah1;
    end;
    SetLength(Result, tahu);
    if tahu > 0 then
    begin
      offset := FRandomGenerator.RangeU4(0, tahu - 1);
      for i := 1 to MaxTahu do
        if PodStrom^.Data.Tahy[i].P1 <> NoMove then
        begin
          Result[offset mod tahu] := PodStrom^.Data.Tahy[i];
          Inc(offset);
        end
    end;
  end
end;

Procedure TKnihovna.PridejData(var Data: TKnihData);
  procedure pripoj(var kam: PKnihStrom);
  begin
    new(kam);
    kam^.L := nil;
    kam^.R := nil;
    kam^.Data := Data
  end;

var
  pom: PKnihStrom;
  i: integer;
begin
  Zmeneno := true;
  Inc(FNodeCount);
  if KnihStrom = nil then
  begin
    new(KnihStrom);
    KnihStrom^.L := Nil;
    KnihStrom^.R := Nil;
    KnihStrom^.Data := Data
  end
  else
  begin
    pom := KnihStrom;
    repeat
      i := CMPPozice(pom^.Data.Pozice, Data.Pozice);
      case i of
        0:
          begin
            pom^.Data := Data;
            break
          end;
        { Tyhle brejky by asi céèkaø nepochopil... }
        1:
          if pom^.L <> nil then
            pom := pom^.L
          else
          begin
            pripoj(pom^.L);
            break
          end;
        -1:
          if pom^.R <> nil then
            pom := pom^.R
          else
          begin
            pripoj(pom^.R);
            break
          end;
      end
    until false;
  end
end;

Procedure TKnihovna.PridejTah(T1: ttah1; var Pozice: TPozice; text: string30);
  function rovno(ta, tb: ttah1): boolean;
  begin
    if (ta.P1 = tb.P1) and (ta.P2 = tb.P2) and (ta.promena = tb.promena) then
      result := true
    else
      result := false
  end;

var
  Strom: PKnihStrom;
  Data: TKnihData;
  i, j: integer;
  volno: boolean;
begin
  Zmeneno := true;
  DejData(Pozice, Strom);
  if Strom = nil then
  begin
    Data.Nazev := text;
    Data.Pozice := Pozice;
    Data.Tahy[1] := T1;
    for i := 2 to 5 do
      Data.Tahy[i].P1 := NoMove;
    PridejData(Data)
  end
  else
  begin { už tam ta pozice je }
    volno := false;
    for i := 1 to 5 do
      if Strom^.Data.Tahy[i].P1 = NoMove then
        volno := true;
    if volno then { je tam ještì volno }
    begin
      for i := 1 to 5 do
        if Strom^.Data.Tahy[i].P1 = NoMove then
        begin
          Strom^.Data.Tahy[i] := T1;
          break
        end;
    end
    else
    begin { není tam místo }
      for i := 1 to 4 do
        for j := i + 1 to 5 do
          if rovno(Strom^.Data.Tahy[i], Strom^.Data.Tahy[j]) then
          begin
            Strom^.Data.Tahy[j] := T1;
            exit
          end
    end
  end
end;

Procedure TKnihovna.SmazKnihStrom;
  procedure mazej(co: PKnihStrom);
  begin
    if co <> Nil then
    begin
      mazej(co^.L);
      mazej(co^.R);
      dispose(co)
    end
  end;

begin
  mazej(KnihStrom);
  FNodeCount := 0;
  KnihStrom := nil;
end;

procedure TKnihovna.DejNTaData(n: LongInt; var Data: PKnihStrom);
  procedure jedem(kde: PKnihStrom);
  begin
    if kde = nil then
      exit;
    jedem(kde^.L);
    if n > 0 then
    begin
      n := n - 1;
      if n = 0 then
        Data := kde
      else
        jedem(kde^.R);
    end;
  end;

begin
  Data := nil;
  jedem(KnihStrom);
end;

Type
  P_PknihStrom = ^PKnihStrom;

procedure TKnihovna.mazej(var co: TPozice);
  Procedure Jednoduse(var co: PKnihStrom);
  var
    pom: PKnihStrom;
  begin { Je-li vpravo nebo vlevo nil. Musí být, už se nekontroluje. }
    pom := co;
    if (co^.R = nil) then
      co := co^.L
    else
      co := co^.R;
    dispose(pom)
  end;
  Function LevicovyPravicak(Odkud: PKnihStrom): P_PknihStrom;
  begin
    result := @Odkud^.R;
    while result^^.L <> nil do
      result := @result^^.L;
  end;

var
  i: integer;
  pom, pom2: P_PknihStrom;
begin
  pom := @KnihStrom;
  while pom^ <> nil do
  begin
    i := CMPPozice(pom^^.Data.Pozice, co);
    case i of
      - 1:
        pom := @pom^^.R;
      1:
        pom := @pom^^.L;
      0:
        break;
    end
  end; { while }
  if pom^ = nil then
    exit;
  Zmeneno := true;
  if (pom^^.R = nil) or (pom^^.L = nil) then
    Jednoduse(pom^)
  else
  begin
    pom2 := LevicovyPravicak(pom^);
    pom^^.Data := pom2^^.Data;
    Jednoduse(pom2^);
    pom2^ := nil
  end
end;

(* procedure TKnihovna.uloz;
  var
  f: file of TKnihData;
  procedure ukladej(co: PKnihStrom);
  begin
  if co <> nil then
  begin
  ukladej(co^.L);
  write(f, co^.Data);
  ukladej(co^.R);
  end;
  end;

  begin
  assign(f, JmenoSouboruKnihovny);
  rewrite(f);
  ukladej(KnihStrom);
  close(f);
  Zmeneno := false;
  end; *)

procedure TKnihovna.otevri(const AFileName: TFileName);
var
  f: TFile;
  procedure otvirej(a, b: LongInt);
  var
    s: LongInt;
    Data: TKnihData;
  begin
    if a > b then
      exit;
    s := (a + b) div 2;
    f.seek(s * SizeOf(TKnihData));
    f.BlockRead(Data, SizeOf(Data));
    PridejData(Data);
    otvirej(a, s - 1);
    otvirej(s + 1, b);
  end;

begin
  SmazKnihStrom;
  f := TFile.Create;
  try
    if f.Open(AFileName, fmReadOnly, FILE_FLAG_RANDOM_ACCESS) then
    begin
      otvirej(0, f.FileSize div SizeOf(TKnihData) - 1);
    end;
  finally
    f.Close;
    f.Free;
  end;
  Zmeneno := false
end;
{
function TKnihovna.PocetPozic: LongInt;
  function PP(kde: PKnihStrom): LongInt;
  begin
    if kde = nil then
      result := 0
    else
      result := 1 + PP(kde^.L) + PP(kde^.R)
  end;

begin
  result := PP(KnihStrom)
end;
}
function TKnihovna.HloubkaStromu: LongInt;
  function HS(kde: PKnihStrom): LongInt;
  var
    i, j: LongInt;
  begin
    if kde = nil then
      result := 0
    else
    begin
      i := HS(kde^.L);
      j := HS(kde^.R);
      if i < j then
        result := j
      else
        result := i;
      result := result + 1
    end
  end;

begin
  result := HS(KnihStrom)
end;

Destructor TKnihovna.Destroy;
begin
  try
    SmazKnihStrom;
    FRandomGenerator.Free;
  finally
    inherited;
  end;
end;

Constructor TKnihovna.Create;
begin
  inherited;

  FRandomGenerator := TSxRandomGenerator.Create;
end;

end.

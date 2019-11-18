unit seznam;

interface

uses coty;
function Load(var pos: tpozice; var kam: ppartie; filename: string): boolean;
function SaveAs(pos: tpozice; co: ppartie; filename: string): boolean;
procedure mazejvpravo(var odkud: ppartie); { maže se vèetnì, nastaví se na nil }
procedure pridej(kam: ppartie; t2: ttah2); { pøepíše ocas novým tahem }
procedure uberkonec(var ceho: ppartie);
procedure initppartie(var co: ppartie);
procedure doneppartie(var co: ppartie);

implementation

uses rutiny;

procedure initppartie(var co: ppartie);
begin
  new(co);
  co^.l := nil;
  co^.r := nil;
end;

procedure doneppartie(var co: ppartie);
begin
  while co^.l <> nil do
    co := co^.l;
  mazejvpravo(co);
end;

procedure pridej(kam: ppartie; t2: ttah2);
var
  pom1: ppartie;
begin
  new(pom1);
  pom1^.t2 := t2;
  pom1^.l := kam;
  pom1^.r := nil;
  mazejvpravo(kam^.r); { smazání ocasu }
  kam^.r := pom1;
end;

procedure mazejvpravo(var odkud: ppartie); { maže se vèetnì }
var
  pom1: ppartie;
begin
  while odkud <> nil do
  begin
    pom1 := odkud^.r;
    dispose(odkud);
    odkud := pom1
  end
end;

function SaveAs(pos: tpozice; co: ppartie; filename: string): boolean;
var
  f: file; { ne var - ono ji to mìní }
begin
  if co <> nil then
  begin
    while co^.l <> nil do
    begin
      tahni_zpet(pos, co^.t2);
      co := co^.l
    end;
  end;
  SaveAs := false;
{$I-}
  assign(f, filename);
  rewrite(f, 1);
  if IOResult = 0 then
  begin
    { blockwrite(f,bily.jmeno,16); }
    { blockwrite(f,cerny.jmeno,16); }
    blockwrite(f, pos, sizeof(pos));
    while co <> nil do
    begin
      blockwrite(f, co^.t2, sizeof(co^.t2));
      co := co^.r;
    end;
    close(f);
    if IOResult = 0 then
      SaveAs := true
  end
{$I+}
end;

function Load(var pos: tpozice; var kam: ppartie; filename: string): boolean;
var
  f: file;
  t2: ttah2;
begin
  kam := nil;
  Load := false;
{$I-}
  assign(f, filename);
  reset(f, 1);
  if IOResult = 0 then
  begin
    blockread(f, pos, sizeof(pos));
    while not eof(f) do
    begin
      blockread(f, t2, sizeof(t2));
      pridej(kam, t2)
    end;
    if kam <> nil then
      while kam^.l <> nil do
        kam := kam^.l;
    close(f);
    if IOResult = 0 then
      Load := true
  end;
{$I+}
end;

procedure uberkonec(var ceho: ppartie);
var
  pom1: ppartie;
begin
  if ceho <> nil then
  begin
    pom1 := ceho^.l;
    mazejvpravo(ceho);
    ceho := pom1
  end
end;

end.

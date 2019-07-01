unit uPartie;

interface

uses
  CoTy;

type
  PJednoPartie = ^TJednoPartie;

  TJednoPartie = record
    t2: ttah2;
    l: PJednoPartie end;
    { Jednosmìrný spoják partie základní_postavení<-tah1 <- tah2 <- .... <- mat
      nemá (narozdíl od TPartie) nevyužitý nejlevìjší èlen }

    function CopyKusPartie(Kde: TPozice; Odkud: PJednoPartie;
      var Kam: PJednoPartie): Integer;
    procedure DonePJednoPartie(var p: PJednoPartie);
    procedure PridejTah(var Kam: PJednoPartie; co: ttah2);
    procedure UberTah(var Odkud: PJednoPartie);
    function PoloRemis(Partie: PJednoPartie; var Pozice: TPozice): Boolean;

  var
    ClaimMoves: Integer;

implementation

uses
  Rutiny,
  Rychle;

{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
{ !!!                  Procedury pro práci s PJednoPartie               !!! }
{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
function CopyKusPartie(Kde: TPozice; Odkud: PJednoPartie;
  var Kam: PJednoPartie): Integer;
{ Zkopíruje èást partie. Jde od souèasného stavu doleva až po první tah
  pìšcem nebo braní. Budoucnost tj. to, co je vpravo nezkopíruje.
  Je-li poslední tah braní nebo tah pìšcem bude Kam Nil. }
var
  pom, pom2: PJednoPartie;
begin
  Result := 0;
  Kam := Nil;
  if (Odkud <> nil) then
  begin
    while (Odkud^.l <> nil) and not trvalaa_zmena(Kde, Odkud^.t2) do
    begin
      Inc(Result);
      new(pom);

      pom^.l := Kam;
      pom^.t2 := Odkud^.t2;
      Kam := pom;
      Odkud := Odkud^.l;
      tahni_zpet(Kde, Kam^.t2);
    end; { Teï mám spoják v kam, ale je tøeba ho otoèit }
    pom := nil;
    while Kam <> nil do
    begin
      pom2 := Kam^.l;
      Kam^.l := pom;
      pom := Kam;
      Kam := pom2;
    end;
    Kam := pom;
    { Otoèení dokonèeno }
  end;
end;

procedure DonePJednoPartie(var p: PJednoPartie);
{ Dealokace celého spojáku }
var
  pom: PJednoPartie;
begin
  while p <> nil do
  begin
    pom := p^.l;
    dispose(p);

    p := pom;
  end
end;

procedure PridejTah(var Kam: PJednoPartie; co: ttah2);
var
  pom: PJednoPartie;
begin
  new(pom);

  pom^.t2 := co;
  pom^.l := Kam;
  Kam := pom
end;

procedure UberTah(var Odkud: PJednoPartie);
var
  pom: PJednoPartie;
begin
  if Odkud <> nil then
  begin
    pom := Odkud^.l;
    dispose(Odkud);

    Odkud := pom
  end
end;

function PoloRemis(Partie: PJednoPartie; var Pozice: TPozice): Boolean;
{ Dochází v Partii k opakování poslední Pozice nebo aspoò k 50 tichým tahùm ? }
var
  th: shortint;
  pompos: TPozice;
begin
  th := ClaimMoves;
  Result := false;
  pompos := Pozice;
  while (Partie <> nil) and (th > 0) do
  begin
    dec(th);
    if trvalaa_zmena(pompos, Partie^.t2) then
      break;
    tahni_zpet(pompos, Partie^.t2);
    if stejnepos(Pozice, pompos) then
    begin
      Result := true;
      break
    end;
    Partie := Partie^.l;
  end;
  if th = 0 then
    Result := true;
end;

end.

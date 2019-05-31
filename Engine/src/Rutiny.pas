{ Šachové rutiny 20. 7. 1998 Jan Nìmec
  1) Problém v Naleztahy. Je-li v pozici víc než maxtah tahù nehlásí chybu,
  ale "pøebyteèné" tahy nenajde.
}
unit rutiny;

interface

uses
  uTypes,
  coty;

procedure doplntah(t1: ttah1; var pos: tpozice; var t2: ttah2);
{ Provede konverzi ttah1 -> ttah2 }
procedure osekejtah(t2: ttah2; var t1: ttah1);
{ Provede konverzi ttah2 -> ttah1 }
procedure tahni(var pos: tpozice; t1: ttah1);
{ V pozici pos táhne }
procedure tahni_zpet(var pos: tpozice; t2: ttah2);
function ohrozeno(x, y: shortint; bilym: boolean; var sch: tsch): boolean;
{ Napadá bílý políèko [x,y] ? }
procedure naleztahy(var pos:tpozice;var tahy:ttahy);
{ Najde pøípustné tahy v pozici pos }
function jetam(tah1: ttah1; var tahy: ttahy): boolean;
{ obsahují tahy tah1 ? }
function jetam1(odkud: byte; var tahy: ttahy): boolean;
{ obsahují tahy tah z pole odkud ? }
function jetam2(kam: byte; kym: shortint; var tahy: ttahy; var pozice: tpozice;
  var tah1: ttah1): integer;
{ kolik tam je tahù kym na pole kam }
function jetam3(kam, Sloupec: byte; kym: shortint; var tahy: ttahy;
  var pozice: tpozice; var tah1: ttah1): integer;
{ kolik tam je tahù kym ze Sloupce na pole kam }
function jetam4(kam, Radek: byte; kym: shortint; var tahy: ttahy;
  var pozice: tpozice; var tah1: ttah1): integer;
{ kolik tam je tahù kym z Radku na pole kam }
function sach(var sch: tsch; bily: boolean): boolean;
{ dostal bily šach ? }
{ function pripustna_pozice(pos:tpozice):boolean; }
//function remis(var pos: tpozice; partie: PJednoPartie): boolean;
function trvalaa_zmena(var pos: tpozice; t2: ttah2): boolean;
{ Je právì zahraný tah t2 v pozici pos braní nebo tah pìšcem ? }
function TTah1ToLongInt(co: ttah1): LongInt;
function LongIntToTTah1(co: LongInt): ttah1;
//function TTah1ToStr(tah1: ttah1; var kde: TPozice): string;
function TTah1ToLongStr(tah1: ttah1): string10;
function StrToTTah1(const AText: string; const ASideToMove: SG): TTah1;
function StrToPozice(const Line: string; var pos: tpozice): string;

implementation

uses
  uPartie, // ClaimMoves
  uStrings,
  uOutputFormat,
  uCharTable,
  SysUtils;

procedure doplntah(t1: ttah1; var pos: tpozice; var t2: ttah2);
begin
  t2.p1 := t1.p1;
  t2.p2 := t1.p2;
  t2.promena := t1.promena;
  with t2 do
  begin
    bere := pos.sch[p2 and 15, p2 shr 4];
    stav := pos.stav
  end
end;

procedure osekejtah(t2: ttah2; var t1: ttah1);
begin
  t1.p1 := t2.p1;
  t1.p2 := t2.p2;
  t1.promena := t2.promena;
end;

procedure tahni(var pos: tpozice; t1: ttah1);
var
  x1, y1, x2, y2: byte;
begin
  with t1 do
  begin
    x1 := p1 and 15;
    y1 := p1 shr 4;
    x2 := p2 and 15;
    y2 := p2 shr 4;
  end;
  pos.stav.mimoch := ne_mimochodem;
  if hb in pos.stav.b then
  begin { hraje bílý }
    if (y2 = 7) then
    begin { pokud táhne bílý na pole èerné vìže pøed rošádou,
        èerný tam nebude už nikdy rochovat }
      if x2 = 0 then
        pos.stav.b := pos.stav.b - [vrc]
      else if x2 = 7 then
        pos.stav.b := pos.stav.b - [mrc]
    end;
    if (y1 = 1) and (y2 = 3) and (pos.sch[x1, y1] = 1) then
      pos.stav.mimoch := x1;
    { èerný bude moci brát mimochodem }
    if (y1 = 4) and (pos.sch[x1, y1] = 1) and (pos.sch[x2, y2] = 0) and
      (abs(x2 - x1) = 1) then
      { braní mimochodem } pos.sch[x2, y1] := 0;
    if (y1 = 0) then
    begin { rošády a nièení rošád }
      if (x1 = 4) then
      begin { rošády }
        pos.stav.b := pos.stav.b - [vrb, mrb];
        { Už si nezarochuje, hejbnul s figurou na e1 }
        if (x2 = 2) and (y2 = 0) and (pos.sch[4, 0] = 6) then
        begin
          pos.sch[0, 0] := 0;
          pos.sch[3, 0] := 4
        end; { velk  ro¨ da }
        if (x2 = 6) and (y2 = 0) and (pos.sch[4, 0] = 6) then
        begin
          pos.sch[7, 0] := 0;
          pos.sch[5, 0] := 4
        end; { mal  ro¨ da }
      end
      else if (x1 = 0) then
        pos.stav.b := pos.stav.b - [vrb]
      else if (x1 = 7) then
        pos.stav.b := pos.stav.b - [mrb]
    end;
    pos.stav.b := pos.stav.b - [hb]
  end
  else { hraje èerný }
  begin
    if (y2 = 0) then
    begin { pokud táhne èerný na pole bílé vìže pøed rošádou,
        bílý tam nebude už nikdy rochovat }
      if x2 = 0 then
        pos.stav.b := pos.stav.b - [vrb]
      else if x2 = 7 then
        pos.stav.b := pos.stav.b - [mrb]
    end;
    if (y1 = 6) and (y2 = 4) and (pos.sch[x1, y1] = -1) then
      pos.stav.mimoch := x1; { bílej bude moci brát mimochodem }
    if (y1 = 3) and (pos.sch[x1, y1] = -1) and (pos.sch[x2, y2] = 0) and
      (abs(x2 - x1) = 1) then
      { braní mimochodem } pos.sch[x2, y1] := 0;
    if (y1 = 7) then
    begin { rošády a nièení rošád }
      if (x1 = 4) then
      begin { rošády }
        pos.stav.b := pos.stav.b - [vrc, mrc];
        { Už si nezarochuje, hejbnul s figurou na e8 }
        if (x2 = 2) and (y2 = 7) and (pos.sch[4, 7] = -6) then
        begin
          pos.sch[0, 7] := 0;
          pos.sch[3, 7] := -4
        end; { velk  ro¨ da }
        if (x2 = 6) and (y2 = 7) and (pos.sch[4, 7] = -6) then
        begin
          pos.sch[7, 7] := 0;
          pos.sch[5, 7] := -4
        end; { mal  ro¨ da }
      end
      else if (x1 = 0) then
        pos.stav.b := pos.stav.b - [vrc]
      else if (x1 = 7) then
        pos.stav.b := pos.stav.b - [mrc]
    end;
    pos.stav.b := pos.stav.b + [hb];
  end;
  if t1.promena <> 0 then
    pos.sch[x2, y2] := t1.promena
  else
    pos.sch[x2, y2] := pos.sch[x1, y1];
  pos.sch[x1, y1] := 0;
end;

procedure tahni_zpet(var pos: tpozice; t2: ttah2);
var
  x1, y1, x2, y2: byte;
begin
  with t2 do
  begin
    x1 := p1 and 15;
    y1 := p1 shr 4;
    x2 := p2 and 15;
    y2 := p2 shr 4;
  end;
  if not(hb in pos.stav.b) then
  Begin { vracím tah bílého }
    if (y1 = 4) and (pos.sch[x2, y2] = 1) and (abs(x2 - x1) = 1) and
      (t2.bere = 0) then
      { braní mimochodem } pos.sch[x2, y1] := -1;
    if (y1 = 0) and (x1 = 4) and (pos.sch[x2, y2] = 6) then { vracím rošádu }
    bEgin
      if (x2 = 2) then
      beGin
        pos.sch[0, 0] := 4;
        pos.sch[3, 0] := 0
      end { velká rošáda }
      else if (x2 = 6) then
      beGin
        pos.sch[7, 0] := 4;
        pos.sch[5, 0] := 0
      end; { malá rošáda }
    eNd;
    if t2.promena = 0 then
      pos.sch[t2.p1 and 15, t2.p1 shr 4] := pos.sch[t2.p2 and 15, t2.p2 shr 4]
    else
      pos.sch[t2.p1 and 15, t2.p1 shr 4] := 1
  end
  else { Begin {vracím tah èerného }
  begin
    if (y1 = 3) and (pos.sch[x2, y2] = -1) and (abs(x2 - x1) = 1) and
      (t2.bere = 0) then
      { braní mimochodem } pos.sch[x2, y1] := 1;
    if (y1 = 7) and (x1 = 4) and (pos.sch[x2, y2] = -6) then { vracím rošádu }
    bEgin
      if (x2 = 2) then
      beGin
        pos.sch[0, 7] := -4;
        pos.sch[3, 7] := 0
      end { velká rošáda }
      else if (x2 = 6) then
      beGin
        pos.sch[7, 7] := -4;
        pos.sch[5, 7] := 0
      end; { malá  rošáda }
    end;
    if t2.promena = 0 then
      pos.sch[t2.p1 and 15, t2.p1 shr 4] := pos.sch[t2.p2 and 15, t2.p2 shr 4]
    else
      pos.sch[t2.p1 and 15, t2.p1 shr 4] := -1
  eNd; { a tadyto jak pro bílého, tak pro èerného }
  pos.sch[t2.p2 and 15, t2.p2 shr 4] := t2.bere;
  pos.stav := t2.stav;
end;

{ !!!!!!!!!!!!!!!!!!!!!!!!! NALEZTAHY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
procedure naleztahy(var pos: tpozice; var tahy: ttahy);
  procedure zarad(np1, np2: byte; npromena: shortint);
  var
    t1: ttah1;
    t2: ttah2;
  begin
    with t1 do
    begin
      p1 := np1;
      p2 := np2;
      promena := npromena;
    end;
    doplntah(t1, pos, t2);
    tahni(pos, t1);
    if not sach(pos.sch, not(hb in pos.stav.b)) then
      if tahy.poctah < maxtah then
      begin
        inc(tahy.poctah);
        tahy.t[tahy.poctah] := t1
      end; { else matpatdlg('Chyba, moc tah– !');{Víc tahù než je možné‚ }
    tahni_zpet(pos, t2)
  end;
  procedure jed(x, y, dx, dy: shortint; bily: boolean);
  var
    x1, y1: shortint;
    konec: boolean;
  begin
    x1 := x;
    y1 := y;
    konec := false;
    while (x + dx > -1) and (y + dy > -1) and (x + dx < 8) and (y + dy < 8) and
      ((bily and (pos.sch[x + dx, y + dy] < 1)) or
      ((not bily) and (pos.sch[x + dx, y + dy] > -1))) and (not konec)
    { Dù - vyjadøete podmínku pouze pomocí negace a implikace } do
    begin
      x := x + dx;
      y := y + dy;
      zarad(x1 + y1 * 16, x + y * 16, 0);
      if pos.sch[x, y] <> 0 then
        konec := true
        { Narazil na soupeøovu figuru. Mùže ji sebrat, ale za ni už táhnout nesmí }
    end
  end;

var
  x, y, i, j: shortint;
begin
  { zaèátek tìla naleztahy }
  tahy.poctah := 0;
  if hb in pos.stav.b then { na tahu je bílý }
  begin
    for x := 0 to 7 do
      for y := 0 to 7 do
        case pos.sch[x, y] of
          1:
            begin
              if (y < 6) then
              begin
                if (y = 1) and (pos.sch[x, y + 1] = 0) and
                  (pos.sch[x, y + 2] = 0) then
                  zarad(x + 16 * y, x + 16 * (y + 2), 0);
                if (pos.sch[x, y + 1] = 0) then
                  zarad(x + 16 * y, x + 16 * (y + 1), 0);
                if (x < 7) and (pos.sch[x + 1, y + 1] < 0) then
                  zarad(x + 16 * y, x + 1 + 16 * (y + 1), 0);
                if (x > 0) and (pos.sch[x - 1, y + 1] < 0) then
                  zarad(x + 16 * y, x - 1 + 16 * (y + 1), 0);
                if (abs(pos.stav.mimoch - x) = 1) and (y = 4) then
                  zarad(x + 16 * y, pos.stav.mimoch + 16 * (y + 1), 0);
                { braní mimochodem }
              end
              else { tj. if y=6 then promìna pìšce }
              begin
                for i := 2 to 5 do { od konì do dámy }
                begin
                  if (pos.sch[x, 7] = 0) then
                    zarad(x + 16 * 6, x + 16 * 7, i);
                  if (x < 7) and (pos.sch[x + 1, 7] < 0) then
                    zarad(x + 16 * 6, x + 1 + 16 * 7, i);
                  if (x > 0) and (pos.sch[x - 1, 7] < 0) then
                    zarad(x + 16 * 6, x - 1 + 16 * 7, i);
                end
              end;
            end;
          2:
            begin { Kùò }
              if (x < 6) and (y < 7) and (pos.sch[x + 2, y + 1] < 1) then
                zarad(x + 16 * y, (x + 2) + 16 * (y + 1), 0);
              if (x < 6) and (y > 0) and (pos.sch[x + 2, y - 1] < 1) then
                zarad(x + 16 * y, (x + 2) + 16 * (y - 1), 0);
              if (x < 7) and (y < 6) and (pos.sch[x + 1, y + 2] < 1) then
                zarad(x + 16 * y, (x + 1) + 16 * (y + 2), 0);
              if (x < 7) and (y > 1) and (pos.sch[x + 1, y - 2] < 1) then
                zarad(x + 16 * y, (x + 1) + 16 * (y - 2), 0);
              if (x > 1) and (y < 7) and (pos.sch[x - 2, y + 1] < 1) then
                zarad(x + 16 * y, (x - 2) + 16 * (y + 1), 0);
              if (x > 1) and (y > 0) and (pos.sch[x - 2, y - 1] < 1) then
                zarad(x + 16 * y, (x - 2) + 16 * (y - 1), 0);
              if (x > 0) and (y < 6) and (pos.sch[x - 1, y + 2] < 1) then
                zarad(x + 16 * y, (x - 1) + 16 * (y + 2), 0);
              if (x > 0) and (y > 1) and (pos.sch[x - 1, y - 2] < 1) then
                zarad(x + 16 * y, (x - 1) + 16 * (y - 2), 0);
            end; { konec konì }
          3:
            begin { støelec }
              jed(x, y, -1, -1, true);
              jed(x, y, -1, 1, true);
              jed(x, y, 1, -1, true);
              jed(x, y, 1, 1, true);
            end;
          4:
            begin { vìž }
              jed(x, y, -1, 0, true);
              jed(x, y, 0, -1, true);
              jed(x, y, 0, 1, true);
              jed(x, y, 1, 0, true);
            end;
          5:
            begin { dáma }
              jed(x, y, -1, -1, true);
              jed(x, y, -1, 1, true);
              jed(x, y, 1, -1, true);
              jed(x, y, 1, 1, true);
              jed(x, y, -1, 0, true);
              jed(x, y, 0, -1, true);
              jed(x, y, 0, 1, true);
              jed(x, y, 1, 0, true);
            end;
          6:
            begin
              for i := x - 1 to x + 1 do
                for j := y - 1 to y + 1 do
                  if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
                    ((i <> x) or (j <> y)) and (pos.sch[i, j] < 1) then
                    zarad(x + 16 * y, i + 16 * j, 0);
              { a teï rošáda }
              if (x = 4) and (y = 0) then
              begin
                if (vrb in pos.stav.b) and (pos.sch[3, 0] = 0) and
                  (pos.sch[2, 0] = 0) and (pos.sch[1, 0] = 0) and
                  (not(ohrozeno(x, 0, false, pos.sch) or ohrozeno(x - 1, 0,
                  false, pos.sch))) then
                  zarad(4 + 0 * 16, 2 + 0 * 16, 0);
                if (mrb in pos.stav.b) and (pos.sch[5, 0] = 0) and
                  (pos.sch[6, 0] = 0) and
                  (not(ohrozeno(x, 0, false, pos.sch) or ohrozeno(x + 1, 0,
                  false, pos.sch))) then
                  zarad(4 + 0 * 16, 6 + 0 * 16, 0)
              end
            end;
        end { od case }
  end { od hraje bílý }
  else { hraje èerný }
  begin
    for x := 0 to 7 do
      for y := 0 to 7 do
        case pos.sch[x, y] of
          - 1:
            begin
              if (y > 1) then
              begin
                if (y = 6) and (pos.sch[x, y - 1] = 0) and
                  (pos.sch[x, y - 2] = 0) then
                  zarad(x + 16 * y, x + 16 * (y - 2), 0);
                if (pos.sch[x, y - 1] = 0) then
                  zarad(x + 16 * y, x + 16 * (y - 1), 0);
                if (x < 7) and (pos.sch[x + 1, y - 1] > 0) then
                  zarad(x + 16 * y, x + 1 + 16 * (y - 1), 0);
                if (x > 0) and (pos.sch[x - 1, y - 1] > 0) then
                  zarad(x + 16 * y, x - 1 + 16 * (y - 1), 0);
                if (abs(pos.stav.mimoch - x) = 1) and (y = 3) then
                  zarad(x + 16 * y, pos.stav.mimoch + 16 * (y - 1), 0);
                { žraní mimochodem }
              end
              else { tj. if y=1 then promìna pìšce }
              begin
                for i := -2 downto -5 do { od konì do dámy }
                begin
                  if (pos.sch[x, 0] = 0) then
                    zarad(x + 16 * 1, x + 16 * 0, i);
                  if (x < 7) and (pos.sch[x + 1, 0] > 0) then
                    zarad(x + 16 * 1, x + 1 + 16 * 0, i);
                  if (x > 0) and (pos.sch[x - 1, 0] > 0) then
                    zarad(x + 16 * 1, x - 1 + 16 * 0, i);
                end
              end;
            end;

          -2:
            begin { Kùò }
              if (x < 6) and (y < 7) and (pos.sch[x + 2, y + 1] > -1) then
                zarad(x + 16 * y, (x + 2) + 16 * (y + 1), 0);
              if (x < 6) and (y > 0) and (pos.sch[x + 2, y - 1] > -1) then
                zarad(x + 16 * y, (x + 2) + 16 * (y - 1), 0);
              if (x < 7) and (y < 6) and (pos.sch[x + 1, y + 2] > -1) then
                zarad(x + 16 * y, (x + 1) + 16 * (y + 2), 0);
              if (x < 7) and (y > 1) and (pos.sch[x + 1, y - 2] > -1) then
                zarad(x + 16 * y, (x + 1) + 16 * (y - 2), 0);
              if (x > 1) and (y < 7) and (pos.sch[x - 2, y + 1] > -1) then
                zarad(x + 16 * y, (x - 2) + 16 * (y + 1), 0);
              if (x > 1) and (y > 0) and (pos.sch[x - 2, y - 1] > -1) then
                zarad(x + 16 * y, (x - 2) + 16 * (y - 1), 0);
              if (x > 0) and (y < 6) and (pos.sch[x - 1, y + 2] > -1) then
                zarad(x + 16 * y, (x - 1) + 16 * (y + 2), 0);
              if (x > 0) and (y > 1) and (pos.sch[x - 1, y - 2] > -1) then
                zarad(x + 16 * y, (x - 1) + 16 * (y - 2), 0);
            end; { konec konì }
          -3:
            begin { støelec }
              jed(x, y, -1, -1, false);
              jed(x, y, -1, 1, false);
              jed(x, y, 1, -1, false);
              jed(x, y, 1, 1, false);
            end;
          -4:
            begin { vìž }
              jed(x, y, -1, 0, false);
              jed(x, y, 0, -1, false);
              jed(x, y, 0, 1, false);
              jed(x, y, 1, 0, false);
            end;
          -5:
            begin { dáma }
              jed(x, y, -1, -1, false);
              jed(x, y, -1, 1, false);
              jed(x, y, 1, -1, false);
              jed(x, y, 1, 1, false);
              jed(x, y, -1, 0, false);
              jed(x, y, 0, -1, false);
              jed(x, y, 0, 1, false);
              jed(x, y, 1, 0, false);
            end;
          -6:
            begin
              for i := x - 1 to x + 1 do
                for j := y - 1 to y + 1 do
                  if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
                    ((i <> x) or (j <> y)) and (pos.sch[i, j] > -1) then
                    zarad(x + 16 * y, i + 16 * j, 0);
              { rošáda }
              if (x = 4) and (y = 7) then
              begin
                if (vrc in pos.stav.b) and (pos.sch[3, 7] = 0) and
                  (pos.sch[2, 7] = 0) and (pos.sch[1, 7] = 0) and
                  (not(ohrozeno(x, 7, true, pos.sch) or ohrozeno(x - 1, 7, true,
                  pos.sch))) then
                  zarad(4 + 7 * 16, 2 + 7 * 16, 0);
                if (mrc in pos.stav.b) and (pos.sch[5, 7] = 0) and
                  (pos.sch[6, 7] = 0) and
                  (not(ohrozeno(x, 7, true, pos.sch) or ohrozeno(x + 1, 7, true,
                  pos.sch))) then
                  zarad(4 + 7 * 16, 6 + 7 * 16, 0)
              end
            end;
        end { od case }
  end
end;

function ohrozeno(x, y: shortint; bilym: boolean; var sch: tsch): boolean;
var
  oh: boolean;
  procedure jed(x, y, dx, dy, f1, f2: shortint);
  begin
    x := x + dx;
    y := y + dy;
    while (x > -1) and (y > -1) and (x < 8) and (y < 8) and (sch[x, y] = 0) do
    begin
      x := x + dx;
      y := y + dy;
    end;
    if (x > -1) and (y > -1) and (x < 8) and (y < 8) and
      ((sch[x, y] = f1) or (sch[x, y] = f2)) then
      oh := true;
  end;

var
  i, j: shortint;
begin
  oh := false;
  if bilym then
  begin
    if (x < 6) and (y < 7) and (sch[x + 2, y + 1] = 2) then
      oh := true
    else if (x < 6) and (y > 0) and (sch[x + 2, y - 1] = 2) then
      oh := true
    else if (x < 7) and (y < 6) and (sch[x + 1, y + 2] = 2) then
      oh := true
    else if (x < 7) and (y > 1) and (sch[x + 1, y - 2] = 2) then
      oh := true
    else if (x > 1) and (y < 7) and (sch[x - 2, y + 1] = 2) then
      oh := true
    else if (x > 1) and (y > 0) and (sch[x - 2, y - 1] = 2) then
      oh := true
    else if (x > 0) and (y < 6) and (sch[x - 1, y + 2] = 2) then
      oh := true
    else if (x > 0) and (y > 1) and (sch[x - 1, y - 2] = 2) then
      oh := true
    else if (x > 0) and (y > 0) and (sch[x - 1, y - 1] = 1) then
      oh := true
    else if (x < 7) and (y > 0) and (sch[x + 1, y - 1] = 1) then
      oh := true
    else
      for i := x - 1 to x + 1 do
        for j := y - 1 to y + 1 do
          if (i > -1) and (i < 8) and (j > -1) and (j < 8) and (sch[i, j] = 6)
          then
            if (i <> x) or (j <> y) then
              oh := true;
    if not oh then
    begin
      jed(x, y, -1, -1, 3, 5);
      jed(x, y, -1, 1, 3, 5);
      jed(x, y, 1, -1, 3, 5);
      jed(x, y, 1, 1, 3, 5);
      jed(x, y, -1, 0, 4, 5);
      jed(x, y, 0, -1, 4, 5);
      jed(x, y, 0, 1, 4, 5);
      jed(x, y, 1, 0, 4, 5);
    end
  end
  else
  begin
    if (x < 6) and (y < 7) and (sch[x + 2, y + 1] = -2) then
      oh := true
    else if (x < 6) and (y > 0) and (sch[x + 2, y - 1] = -2) then
      oh := true
    else if (x < 7) and (y < 6) and (sch[x + 1, y + 2] = -2) then
      oh := true
    else if (x < 7) and (y > 1) and (sch[x + 1, y - 2] = -2) then
      oh := true
    else if (x > 1) and (y < 7) and (sch[x - 2, y + 1] = -2) then
      oh := true
    else if (x > 1) and (y > 0) and (sch[x - 2, y - 1] = -2) then
      oh := true
    else if (x > 0) and (y < 6) and (sch[x - 1, y + 2] = -2) then
      oh := true
    else if (x > 0) and (y > 1) and (sch[x - 1, y - 2] = -2) then
      oh := true
    else if (x > 0) and (y < 7) and (sch[x - 1, y + 1] = -1) then
      oh := true
    else if (x < 7) and (y < 7) and (sch[x + 1, y + 1] = -1) then
      oh := true
    else
      for i := x - 1 to x + 1 do
        for j := y - 1 to y + 1 do
          if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
            ((i <> x) or (j <> y)) and (sch[i, j] = -6) then
            oh := true;
    if not oh then
    begin
      jed(x, y, -1, -1, -3, -5);
      jed(x, y, -1, 1, -3, -5);
      jed(x, y, 1, -1, -3, -5);
      jed(x, y, 1, 1, -3, -5);
      jed(x, y, -1, 0, -4, -5);
      jed(x, y, 0, -1, -4, -5);
      jed(x, y, 0, 1, -4, -5);
      jed(x, y, 1, 0, -4, -5);
    end
  end;
  ohrozeno := oh
end;

function sach(var sch: tsch; bily: boolean): boolean;
var
  kx, ky, y, x: shortint;
begin
  Result := False;
  if bily then
  begin
    for x := 0 to 7 do
      for y := 0 to 7 do
        if sch[x, y] = 6 then
        begin
          kx := x;
          ky := y;
          Result := Result or ohrozeno(kx, ky, not bily, sch)
        end;
  end
  else
  begin
    for x := 0 to 7 do
      for y := 0 to 7 do
        if sch[x, y] = -6 then
        begin
          kx := x;
          ky := y;
          Result := Result or ohrozeno(kx, ky, not bily, sch)
        end;
  end;
end;

function jetam(tah1: ttah1; var tahy: ttahy): boolean;
var
  i: byte;
begin
  jetam := false;
  for i := 1 to tahy.poctah do
    with tahy.t[i] do
      if (tah1.p1 = p1) and (tah1.p2 = p2) and (tah1.promena = promena) then
        jetam := true
end;

function jetam1(odkud: byte; var tahy: ttahy): boolean;
var
  i: byte;
begin
  jetam1 := false;
  for i := 1 to tahy.poctah do
    with tahy.t[i] do
      if p1 = odkud then
        jetam1 := true
end;

function jetam2(kam: byte; kym: shortint; var tahy: ttahy; var pozice: tpozice;
  var tah1: ttah1): integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to tahy.poctah do
    if (tahy.t[i].p2 = kam) and
      (pozice.sch[tahy.t[i].p1 and 15, tahy.t[i].p1 shr 4] = kym) then
    begin
      inc(result);
      tah1 := tahy.t[i]
    end
end;

function jetam3(kam, Sloupec: byte; kym: shortint; var tahy: ttahy;
  var pozice: tpozice; var tah1: ttah1): integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to tahy.poctah do
    if (tahy.t[i].p2 = kam) and (tahy.t[i].p1 and 15 = Sloupec) and
      (pozice.sch[tahy.t[i].p1 and 15, tahy.t[i].p1 shr 4] = kym) then
    begin
      inc(result);
      tah1 := tahy.t[i]
    end
end;

function jetam4(kam, Radek: byte; kym: shortint; var tahy: ttahy;
  var pozice: tpozice; var tah1: ttah1): integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to tahy.poctah do
    if (tahy.t[i].p2 = kam) and (tahy.t[i].p1 shr 4 = Radek) and
      (pozice.sch[tahy.t[i].p1 and 15, tahy.t[i].p1 shr 4] = kym) then
    begin
      inc(result);
      tah1 := tahy.t[i]
    end
end;

{ function pripustna_pozice(pos:tpozice):boolean;
  var
  f:array[-6..6] of shortint;
  x,y,pocbil,poccer:shortint;
  pp:boolean;
  begin
  pp:=true;
  poccer:=0;pocbil:=0;
  for x:=-6 to 6 do f[x]:=0;
  for x:=0 to 7 do
  for y:=0 to 7 do
  begin
  if (pos.sch[x,y]<7) and (pos.sch[x,y]>-7)then inc(f[pos.sch[x,y]]);
  if pos.sch[x,y]<0 then inc(poccer);if pos.sch[x,y]>0 then inc(pocbil);
  end;
  if ((f[-6]<>1)or(f[6]<>1))or((f[1]>8)or(f[-1]>8))or((f[-5]>9)or(f[5]>9))
  or((f[2]>10)or(f[-2]>10))or((f[3]>10)or(f[-3]>10))or((f[4]>10)or(f[-4]>10))
  or (pocbil>16)or (poccer>16)
  then pp:=false;
  if pp then
  begin
  if sach(pos.sch,not (hb in pos.stav.b)) then pp:=false;
  for x:=0 to 7 do if (pos.sch[x,0]=1)or(pos.sch[x,7]=1)or
  (pos.sch[x,7]=-1)or(pos.sch[x,0]=-1) then pp:=false;
  end;
  pripustna_pozice:=pp;
  end; }
function rovna_se(pos1, pos2: tpozice): boolean;
var
  x, y: shortint;
begin
  rovna_se := false;
  if (pos1.stav.b = pos2.stav.b) and (pos1.stav.mimoch = pos2.stav.mimoch) then
  begin
    rovna_se := true;
    for x := 0 to 7 do
      for y := 0 to 7 do
        if pos1.sch[x, y] <> pos2.sch[x, y] then
          rovna_se := false;
  end
end;

function trvalaa_zmena(var pos: tpozice; t2: ttah2): boolean;
begin
  if (t2.bere <> 0) or (t2.promena <> 0) or
    (abs(pos.sch[t2.p2 and 15, t2.p2 shr 4]) = 1) then
    trvalaa_zmena := true
  else
    trvalaa_zmena := false
end;

(*
function remis(var pos: tpozice; partie: PJednoPartie): boolean;
var
  tahy: ttahy;
  pompos: tpozice;
  poc, stejne: byte;
  pompartie: ppartie;
begin
  remis := false;
  naleztahy(pos, tahy);
  if tahy.poctah = 0 then
  begin
    if not sach(pos.sch, hb in pos.stav.b) then
      remis := true
  end
  else
  begin
    pompos := pos;
    pompartie := partie;
    poc := 0;
    stejne := 0;
    while (pompartie^.l <> nil) and (poc < 100) and (stejne < 2) do
    begin
      inc(poc);
      if poc = 100 then
        remis := true
      else
      begin
        if trvalaa_zmena(pompos, pompartie^.t2) then
        begin
          poc := 100
        end;
        tahni_zpet(pompos, pompartie^.t2);
        if rovna_se(pos, pompos) then
        begin
          inc(stejne) { ;write(#7) } end;
        pompartie := pompartie^.l
      end
    end;
    if stejne = 2 then
      remis := true
  end;
end;
*)

function TTah1ToLongInt(co: ttah1): LongInt;
begin
  result := co.p1;
  result := result shl 8;
  result := result + co.p2;
  result := result shl 8;
  result := result + byte(co.promena);
  { Pøetypovýní je dùležité !!! Promena je shortint }
end;

function LongIntToTTah1(co: LongInt): ttah1;
begin
  result.promena := shortint(co and $FF);
  co := co shr 8;
  result.p2 := co and $FF;
  co := co shr 8;
  result.p1 := co and $FF;
end;

function PoleToStr(X, Y: byte): string2;
begin
  result := AnsiChar(byte('a') + X) + AnsiChar(byte('1') + Y)
end;

function jednoznacnost(tah1: ttah1; var Pozice: TPozice): byte;
{ vrací  0 až 3
  pøíklad chci napsat krátkou notací De1-e2
  0 staèí    De2
  1 je tøeba Dee2
  2 je tøeba D1e2
  3 je tøeba De1e2
  v pøípadì 1, 2 a 3 by nebyla žádná vyšší možnost jednoznaèná (víc dam)
}
var
  tahy: ttahy;
  figura: shortint;
  X, Y: Byte;
  i: Integer;
  celkem, radka, sloupec: boolean;
begin
  naleztahy(Pozice, tahy);
  X := tah1.p1 and 15;
  Y := tah1.p1 shr 4;
  figura := Pozice.sch[X, Y];
  celkem := false;
  radka := false;
  sloupec := false;
  for i := 1 to tahy.poctah do
    if (tahy.t[i].p1 <> tah1.p1) and (tahy.t[i].p2 = tah1.p2) and
      (Pozice.sch[tahy.t[i].p1 and 15, tahy.t[i].p1 shr 4] = figura)
    then { tah jinou figurou téhož typu na stejné pole }
    begin
      celkem := true;
      if (tahy.t[i].p1 and 15) = X then
        sloupec := true;
      if (tahy.t[i].p1 shr 4) = Y then
        radka := true;
    end;
  if not celkem then
    result := 0
  else if not sloupec then
    result := 1
  else if not radka then
    result := 2
  else
    result := 3
end;
(*
function TTah1ToStr(tah1: ttah1; var kde: TPozice): string;
const
  nazvy: array [1 .. 6] of AnsiChar = ('P', 'N', 'B', 'R', 'Q', 'K');
var
  x1, y1, x2, y2: byte;
  t2: ttah2;
  jednoz: byte;
begin
  x1 := tah1.p1 and 15;
  y1 := tah1.p1 shr 4;
  x2 := tah1.p2 and 15;
  y2 := tah1.p2 shr 4;
  result := '';
  case abs(kde.sch[x1, y1]) of
    1:
      begin
        if x1 = x2 then
          result := PoleToStr(x2, y2)
        else
        begin
          result := AnsiChar(byte('a') + x1) + AnsiChar('x') + PoleToStr(x2, y2);
          if kde.sch[x2, y2] = 0 then
            result := result + ' e.p.'
        end;
        if tah1.promena <> 0 then
          result := result + nazvy[abs(tah1.promena)]
      end;
    2 .. 5:
      begin
        result := nazvy[abs(kde.sch[x1, y1])];
        jednoz := jednoznacnost(tah1, kde);
        case jednoz of
          0:
            ;
          1:
            result := result + AnsiChar(byte('a') + x1);
          2:
            result := result + AnsiChar(byte('1') + y1);
          3:
            result := result + PoleToStr(x1, y1);
        end;
        if kde.sch[x2, y2] <> 0 then
          result := result + 'x';
        result := result + PoleToStr(x2, y2)
      end;
    6:
      begin
        if abs(x1 - x2) > 1 then
          if x2 = 2 then
            result := 'O-O-O'
          else
            result := 'O-O'
        else
        begin
          result := 'K';
          if kde.sch[x2, y2] <> 0 then
            result := result + 'x';
          result := result + PoleToStr(x2, y2);
        end
      end;
  end;
  doplntah(tah1, kde, t2);
  tahni(kde, tah1);
  if sach(kde.sch, hb in kde.Stav.b) then
    result := result + '+';
  tahni_zpet(kde, t2)
end;
*)
function TTah1ToLongStr(tah1: ttah1): string10;
const
  nazvy: array [1 .. 6] of AnsiChar = ('p', 'n', 'b', 'r', 'q', 'k');
var
  x1, y1, x2, y2: byte;
begin
  x1 := tah1.p1 and 15;
  y1 := tah1.p1 shr 4;
  x2 := tah1.p2 and 15;
  y2 := tah1.p2 shr 4;
  result := PoleToStr(x1, y1) + PoleToStr(x2, y2);
  if tah1.promena <> 0 then
    result := result + nazvy[abs(tah1.promena)];
end;

function FToS(const AFigure: Char): Shortint;
begin
  case AFigure of
  'q', 'Q': Result := dama;
  'r', 'R': Result := vez;
  'b', 'B': Result := strelec;
  'n', 'N': Result := jezdec;
  'p', 'P': Result := pesec;
  'k', 'K': Result := kral;
  else
    raise Exception.Create('Invalid figure letter (' + AFigure + ').');
  end;
end;

function StrToTTah1(const AText: string; const ASideToMove: SG): TTah1;
begin
  if Length(AText) < 4 then
  begin
    raise Exception.Create('Invalid move format:' + AText);
  end;
  Result.p1 := Ord(UpCase(AText[1])) - Ord(Char('A')) + 16 * (Ord(UpCase(AText[2])) - Ord(Char('1')));
  Result.p2 := Ord(UpCase(AText[3])) - Ord(Char('A')) + 16 * (Ord(UpCase(AText[4])) - Ord(Char('1')));

  if Length(AText) >= 5 then
  begin
    Result.promena := FToS(AText[5]);
    if ASideToMove <> 0 then
      Result.promena := -Result.promena;
  end
  else
    Result.promena := 0;
end;

function StrToPozice(const Line: string; var pos: tpozice): string;

	procedure AddError(const s: string);
	begin
		Result := Result + s + LineSep;
	end;
const
	MaxX = 8;
var
	X, Y: SG;
	Num: SG;
	s: string;
	Piece: S1;
  InLineIndex: SG;
begin
	Result := '';
  InLineIndex := 1;
  FillChar(pos, Sizeof(pos), 0);
  pos.stav.mimoch := ne_mimochodem;
  ClaimMoves := 100;

  SkipSpace(Line, InLineIndex);
  if InLineIndex + 1 > Length(Line) then
    Exit;

  X := 0;
  Y := 7;
  while InLineIndex <= Length(Line) do
  begin
    if CharInSet(Line[InLineIndex], [CharTab, CharSpace]) then
    begin
      Break;
    end;
    if CharType(Line[InLineIndex], StdCharTable) = ctNumber then
    begin
      Inc(X, ReadSGFast(Line, InLineIndex))
    end
    else if Line[InLineIndex] = '/' then
    begin
      // New row
      s := '';
      if X < MaxX then
      begin
        s :=  'too short';
      end
      else if X > MaxX then
      begin
        s := 'too long';
      end;
      if s <> '' then
        AddError('Row ' + NToS(Y + 1) + ' ' + s);

      if Y > 0 then
      begin
        Dec(Y);
      end
      else
      begin
        AddError('Too many rows.');
      end;

      X := 0;
      Inc(InLineIndex);
    end
    else if (Line[InLineIndex] = '?') or (Line[InLineIndex] = '-') then
    begin
      if (X < MaxX) then
      begin
        pos.sch[X, Y] := 0;
      end;
      Inc(X);
      Inc(InLineIndex);
    end
    else if CharType(Line[InLineIndex], StdCharTable) = ctLetter then
    begin
      Piece := FToS(Line[InLineIndex]);
      if UpperCase(Line[InLineIndex]) <> Line[InLineIndex] then
        Piece := -Piece; // Black

      if Piece = 0 then
      begin
        AddError('Unknown Piece ' + Line[InLineIndex]);
      end
      else
      begin
        if (X < MaxX) then
        begin
          pos.sch[X, Y] := Piece;
        end;
      end;
      Inc(InLineIndex);
      Inc(X);
    end
    else
    begin
      AddError('Piece, integer or ''/'' expected but ' + Line[InLineIndex] + ' found');
      Inc(InLineIndex, 1);
    end;
  end;
  if MaxX < 2 then
  begin
    AddError('First row too short')
  end;
  if Y > 0 then
  begin
    AddError('Less that 8 rows');
  end;

  SkipSpace(Line, InLineIndex);
  if InLineIndex > Length(Line) then Exit;

  if Line[InLineIndex] = 'w' then
  begin
    pos.stav.b := pos.stav.b + [hb];
    Inc(InLineIndex);
  end
  else if Line[InLineIndex] = 'b' then
  begin
    pos.stav.b := pos.stav.b - [hb];
    Inc(InLineIndex);
  end
  else
    AddError('Side specification w or b required.');

  if InLineIndex > Length(Line) then Exit;
  SkipSpace(Line, InLineIndex);
  while InLineIndex < Length(Line) do
  begin
    // Castling
    case Line[InLineIndex] of
    'q':
      pos.stav.b := pos.stav.b + [vrc];
    'Q':
      pos.stav.b := pos.stav.b + [vrb];
    'k':
      pos.stav.b := pos.stav.b + [mrc];
    'K':
      pos.stav.b := pos.stav.b + [mrb];
    '-':
      // None
    else
      Break;
      //AddError('Castle specification -, q, Q, k or K required.');
    end;
    Inc(InLineIndex);
  end;

  if InLineIndex > Length(Line) then Exit;
  // EP
  SkipSpace(Line, InLineIndex);
  if Line[InLineIndex] = '-' then

  else if CharType(Line[InLineIndex], StdCharTable) = ctLetter then
  begin
    if InLineIndex >= Length(Line) then Exit;
    pos.stav.mimoch := Ord(UpCase(Line[InLineIndex])) - Ord(Char('A'));
    Inc(InLineIndex);
  end
  else
    AddError('ep square expected');
  Inc(InLineIndex); if InLineIndex > Length(Line) then Exit;

  SkipSpace(Line, InLineIndex);
  if InLineIndex > Length(Line) then Exit;

  if CharType(Line[InLineIndex], StdCharTable) = ctNumber then
  begin
    ClaimMoves := 100 - ReadSGFast(Line, InLineIndex);
    Inc(InLineIndex);
  end
  else
  SkipSpace(Line, InLineIndex);
  if InLineIndex > Length(Line) then Exit;
  if CharType(Line[InLineIndex], StdCharTable) = ctNumber then
  begin
    Num := ReadSGFast(Line, InLineIndex);
    if Num < 1 then
    begin
      AddError('Game offset out of range');
    end;
  end;
end;

end.

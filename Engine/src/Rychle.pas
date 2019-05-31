unit rychle;
{$ifopt d+}
{$DEFINE LADIM}
{$endif}

{ obsahuje rychl� rutiny pro mysl�c� algoritmus }
interface

uses coty;

{$IFDEF LADIM}var
  BachaRekurze: boolean = false; {$ENDIF}
function naleztahy(var pos: Tpozice; var tahy: ttahy): boolean;
{ 6 kr�t rychlej�� obdoba rutiny.naleztahy, nav�c vrac�
  vrahy (ne �pln� v�echny) na za��tku.
  Vrac� true, je-li hr��, jeho� tahy hled�me v �achu. }
function nalezvrahy(var pos: Tpozice; var tahy: ttahy): boolean;
{ Vrac� true, je-li hr��, jeho� tahy hled�me v �achu. }
function nalezbrani(var pos: Tpozice; var tahy: ttahy): boolean;
{ Obdoba nalezvrahy, ale hled� jen bran� a prom�ny p�ce v d�mu
  (tj. ne v�echny vrahy) }
function stejne(var ta, tb: ttahy): boolean;
function podmnoz(var ta, tb: ttahy): boolean;
function stejnepos(var pa, pb: Tpozice): boolean;
function SameTah1(const A, B: TTah1): Boolean;
function CMPPozice(var P1, P2: TPozice): integer;

implementation

uses
  SysUtils,
  rutiny;

procedure NapadVezi(x, y: shortint; var sch, vz: tsch);
{ ozna�� pol��ka, z nich� by v� napadala [x,y] }
var
  i: shortint;
begin
  fillchar(vz, sizeof(vz), 0);
  for i := x + 1 to 7 do
  begin
    vz[i, y] := 1;
    if sch[i, y] <> 0 then
      break
  end;
  for i := x - 1 downto 0 do
  begin
    vz[i, y] := 1;
    if sch[i, y] <> 0 then
      break
  end;
  for i := y + 1 to 7 do
  begin
    vz[x, i] := 1;
    if sch[x, i] <> 0 then
      break
  end;
  for i := y - 1 downto 0 do
  begin
    vz[x, i] := 1;
    if sch[x, i] <> 0 then
      break
  end;
end;

procedure NapadStrelcem(x, y: shortint; var sch, vz: tsch);
var
  i, j: shortint;
begin
  fillchar(vz, sizeof(vz), 0);
  i := x + 1;
  j := y + 1;
  while (i <= 7) and (j <= 7) do
  begin
    vz[i, j] := 1;
    if sch[i, j] <> 0 then
      break;
    inc(i);
    inc(j);
  end;
  i := x + 1;
  j := y - 1;
  while (i <= 7) and (j >= 0) do
  begin
    vz[i, j] := 1;
    if sch[i, j] <> 0 then
      break;
    inc(i);
    dec(j);
  end;
  i := x - 1;
  j := y + 1;
  while (i >= 0) and (j <= 7) do
  begin
    vz[i, j] := 1;
    if sch[i, j] <> 0 then
      break;
    dec(i);
    inc(j);
  end;
  i := x - 1;
  j := y - 1;
  while (i >= 0) and (j >= 0) do
  begin
    vz[i, j] := 1;
    if sch[i, j] <> 0 then
      break;
    dec(i);
    dec(j);
  end;
end;

procedure NapadJezdcem(x, y: shortint; var vz: tsch);
begin
  fillchar(vz, sizeof(vz), 0);
  if (x - 2 >= 0) and (y - 1 >= 0) then
    vz[x - 2, y - 1] := 1;
  if (x - 2 >= 0) and (y + 1 <= 7) then
    vz[x - 2, y + 1] := 1;
  if (x - 1 >= 0) and (y - 2 >= 0) then
    vz[x - 1, y - 2] := 1;
  if (x - 1 >= 0) and (y + 2 <= 7) then
    vz[x - 1, y + 2] := 1;
  if (x + 1 <= 7) and (y - 2 >= 0) then
    vz[x + 1, y - 2] := 1;
  if (x + 1 <= 7) and (y + 2 <= 7) then
    vz[x + 1, y + 2] := 1;
  if (x + 2 <= 7) and (y - 1 >= 0) then
    vz[x + 2, y - 1] := 1;
  if (x + 2 <= 7) and (y + 1 <= 7) then
    vz[x + 2, y + 1] := 1;
end;

procedure vazby(x, y: shortint; var sch, vz: tsch);
{ Zjist�, pozice figur v�zan�ch soupe�em. V pozici sch na [x,y] stoj�
  d�le�it� kr�l. (Hlavn� motivace: zrychlen� funkc� typu naleztahy
  v d�sledku �spory p�i testov�n� �achu) }
var
  i, j, k, l, vx, vy: shortint;
  v, dal: boolean;
begin
  fillchar(vz, sizeof(vz), 0);
  if sch[x, y] > 0 then
  begin
    for i := -1 to 1 do
      for j := -1 to 1 do
        if (i <> 0) or (j <> 0) then
        begin
          k := x + i;
          l := y + j;
          v := false;
          dal := true;
          while (k >= 0) and (k <= 7) and (l >= 0) and (l <= 7) and dal do
          begin
            if sch[k, l] > 0 then
              if v then
                dal := false
              else
              begin
                v := true;
                vx := k;
                vy := l
              end
            else if sch[k, l] < 0 then
            begin
              if v and ((sch[k, l] = -5) { d�mou }
                or (abs(j) + abs(i) = 2) and (sch[k, l] = -3) { st�elcem }
                or (abs(j) + abs(i) = 1) and (sch[k, l] = -4)) { v�� }
              then
                vz[vx, vy] := 1;
              dal := false
            end;
            k := k + i;
            l := l + j;
          end { od while }
        end { od if (i<>0) or (j<>0) }
  end
  else
    for i := -1 to 1 do
      for j := -1 to 1 do
        if (i <> 0) or (j <> 0) then
        begin
          k := x + i;
          l := y + j;
          v := false;
          dal := true;
          while (k >= 0) and (k <= 7) and (l >= 0) and (l <= 7) and dal do
          begin
            if sch[k, l] < 0 then
              if v then
                dal := false
              else
              begin
                v := true;
                vx := k;
                vy := l
              end
            else if (sch[k, l] > 0) then
            begin
              if v and ((sch[k, l] = 5) { d�mou }
                or (abs(j) + abs(i) = 2) and (sch[k, l] = 3) { st�elcem }
                or (abs(j) + abs(i) = 1) and (sch[k, l] = 4)) { v�� }
              then
                vz[vx, vy] := 1;
              dal := false
            end;
            k := k + i;
            l := l + j;
          end { od while }
        end { od if (i<>0) or (j<>0) }
end;

{ ************************************************************************
  *                                                                      *
  *!!!!!!!!!!!!!!!!!!!!!!!!!!!! NALEZTAHY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
  *                                                                      *
  ************************************************************************ }
function naleztahy(var pos: Tpozice; var tahy: ttahy): boolean;
var
  x, y, kx, ky: shortint;
  vz: tsch;
  vrahu: integer;
  { !!!!!!!!!!!!!!!!!! Za�azovac� rutiny pro naleztahy !!!!!!!!!!!!!!!!!!!!! }
  procedure ZarS(np1, np2: byte; npromena: shortint);
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
    if not ohrozeno(kx, ky, { ne not, zat�hl jsem } hb in pos.stav.b, pos.sch)
    then
      if tahy.poctah < maxtah then
        if (abs(npromena) = 5) or (pos.sch[np2 and 15, np2 shr 4] <> 0) and
          (tahy.poctah > 0) then
        { je to vrah, ty d�v�m na za��tek }
        begin
          inc(vrahu);
          inc(tahy.poctah);
          tahy.t[tahy.poctah] := tahy.t[vrahu];
          with tahy.t[vrahu] do
          begin
            p1 := np1;
            p2 := np2;
            promena := npromena;
          end;
        end
        else
        begin
          inc(tahy.poctah);
          with tahy.t[tahy.poctah] do
          begin
            p1 := np1;
            p2 := np2;
            promena := npromena;
          end;
        end
      else
        raise Exception.Create('Moc tah� v pozici');
    tahni_zpet(pos, t2)
  end;

  procedure ZarBez(np1, np2: byte; npromena: shortint);
  begin
    if (vz[np1 and 15, np1 shr 4] = 0) { figura nebyla v�zan� } or
      (((np2 and 15) - kx) * ((np1 shr 4) - ky) = ((np1 and 15) - kx) *
      ((np2 shr 4) - ky))
    { nebo sice byla v�zan�, ale z�stala na p��mce kr�l, p�vodn� pole,
      v�zaj�c� figura
      (vypad� to zr�dn�, ale je to jen jednoduch� geometrie) }
    then { je to tah podle pravidel }
      if tahy.poctah < maxtah then
        if (abs(npromena) = 5) or (pos.sch[np2 and 15, np2 shr 4] <> 0) and
          (tahy.poctah > 0) then
        { je to vrah, ty d�v�m na za��tek }
        begin
          inc(vrahu);
          inc(tahy.poctah);
          tahy.t[tahy.poctah] := tahy.t[vrahu];
          with tahy.t[vrahu] do
          begin
            p1 := np1;
            p2 := np2;
            promena := npromena;
          end;
        end
        else
        begin
          inc(tahy.poctah);
          with tahy.t[tahy.poctah] do
          begin
            p1 := np1;
            p2 := np2;
            promena := npromena;
          end;
        end
      else
        raise Exception.Create('Moc tah� v pozici');
  end;
{ !!!!!!!!!!!!!!!!!!!!!! Jezd�c� rutiny pro naleztahy !!!!!!!!!!!!!!!!!!!!! }
  procedure JedS(dx, dy: shortint; bily: boolean);
  var
    x1, y1: shortint;
  begin
    x1 := x;
    y1 := y;
    while (x1 + dx > -1) and (y1 + dy > -1) and (x1 + dx < 8) and (y1 + dy < 8)
      and ((bily and (pos.sch[x1 + dx, y1 + dy] < 1)) or
      ((not bily) and (pos.sch[x1 + dx, y1 + dy] > -1))) do
    begin
      x1 := x1 + dx;
      y1 := y1 + dy;
      ZarS(x + y shl 4, x1 + y1 shl 4, 0);
      if pos.sch[x1, y1] <> 0 then
        break
        { Narazil na soupe�ovu figuru. M��e ji sebrat, ale za ni u� t�hnout nesm� }
    end
  end;
  procedure JedBez(dx, dy: shortint; bily: boolean);
  var
    x1, y1: shortint;
  begin
    x1 := x;
    y1 := y;
    while (x1 + dx > -1) and (y1 + dy > -1) and (x1 + dx < 8) and (y1 + dy < 8)
      and ((bily and (pos.sch[x1 + dx, y1 + dy] < 1)) or
      ((not bily) and (pos.sch[x1 + dx, y1 + dy] > -1))) do
    begin
      x1 := x1 + dx;
      y1 := y1 + dy;
      ZarBez(x + y shl 4, x1 + y1 shl 4, 0);
      if pos.sch[x1, y1] <> 0 then
        break
        { Narazil na soupe�ovu figuru. M��e ji sebrat, ale za ni u� t�hnout nesm� }
    end
  end;
{ !!!!!!!!!!!!!!!!!! Rutiny pro pro b�l� figury s kontrolou !!!!!!!!!!!!!!! }
  procedure BPS;
  var
    i: shortint;
  begin
    if (y < 6) then
    begin
      if (y = 1) and (pos.sch[x, y + 1] = 0) and (pos.sch[x, y + 2] = 0) then
        ZarS(x + y shl 4, x + (y + 2) shl 4, 0);
      if (pos.sch[x, y + 1] = 0) then
        ZarS(x + y shl 4, x + (y + 1) shl 4, 0);
      if (x < 7) and (pos.sch[x + 1, y + 1] < 0) then
        ZarS(x + y shl 4, x + 1 + (y + 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y + 1] < 0) then
        ZarS(x + y shl 4, x - 1 + (y + 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 4) then
        ZarS(x + y shl 4, pos.stav.mimoch + (y + 1) shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=6 then prom�na p�ce }
    begin
      for i := 5 downto 2 do { od d�my do kon� }
      begin
        if (pos.sch[x, 7] = 0) then
          ZarS(x + 6 shl 4, x + 7 shl 4, i);
        if (x < 7) and (pos.sch[x + 1, 7] < 0) then
          ZarS(x + 6 shl 4, x + 1 + 7 shl 4, i);
        if (x > 0) and (pos.sch[x - 1, 7] < 0) then
          ZarS(x + 6 shl 4, x - 1 + 7 shl 4, i);
      end
    end;
  end;
  procedure BJS;
  begin
    if (x < 6) and (y < 7) and (pos.sch[x + 2, y + 1] < 1) then
      ZarS(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and (pos.sch[x + 2, y - 1] < 1) then
      ZarS(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and (pos.sch[x + 1, y + 2] < 1) then
      ZarS(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and (pos.sch[x + 1, y - 2] < 1) then
      ZarS(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and (pos.sch[x - 2, y + 1] < 1) then
      ZarS(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and (pos.sch[x - 2, y - 1] < 1) then
      ZarS(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and (pos.sch[x - 1, y + 2] < 1) then
      ZarS(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and (pos.sch[x - 1, y - 2] < 1) then
      ZarS(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  procedure BSS;
  begin
    JedS(-1, -1, true);
    JedS(-1, 1, true);
    JedS(1, -1, true);
    JedS(1, 1, true);
  end;
  procedure BVS;
  begin
    JedS(-1, 0, true);
    JedS(0, -1, true);
    JedS(0, 1, true);
    JedS(1, 0, true);
  end;
  procedure BKS;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] < 1) then
        begin
          pos.sch[x, y] := 0; { Jedin� z�pis do pozice, hned ho zase odstran�m.
            Neb�t t�to zr�dnosti, mohl by kr�l ustoupit na pol��ko kter� nebylo
            ohro�en� jen proto, �e ho kr�l "odst�nil". }
          if not ohrozeno(i, j, false, pos.sch) then
          begin
            pos.sch[x, y] := 6;
            ZarBez(x + y shl 4, i + j shl 4, 0);
          end
          else
            pos.sch[x, y] := 6;
        end
  end;
{ !!!!!!!!!!!!!!!!! Rutiny pro pro b�l� figury bez kontroly !!!!!!!!!!!!!! }
  Procedure BPBez;
  var
    i: shortint;
  begin
    if (y < 6) then
    begin
      if (y = 1) and (pos.sch[x, y + 1] = 0) and (pos.sch[x, y + 2] = 0) then
        ZarBez(x + y shl 4, x + (y + 2) shl 4, 0);
      if (pos.sch[x, y + 1] = 0) then
        ZarBez(x + y shl 4, x + (y + 1) shl 4, 0);
      if (x < 7) and (pos.sch[x + 1, y + 1] < 0) then
        ZarBez(x + y shl 4, x + 1 + (y + 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y + 1] < 0) then
        ZarBez(x + y shl 4, x - 1 + (y + 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 4) then
        ZarBez(x + y shl 4, pos.stav.mimoch + (y + 1) shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=6 then prom�na p�ce }
    begin
      for i := 5 downto 2 do { do kon� od d�my }
      begin
        if (pos.sch[x, 7] = 0) then
          ZarBez(x + 6 shl 4, x + 7 shl 4, i);
        if (x < 7) and (pos.sch[x + 1, 7] < 0) then
          ZarBez(x + 6 shl 4, x + 1 + 7 shl 4, i);
        if (x > 0) and (pos.sch[x - 1, 7] < 0) then
          ZarBez(x + 6 shl 4, x - 1 + 7 shl 4, i);
      end
    end;
  end;
  Procedure BJBez;
  begin
    if (x < 6) and (y < 7) and (pos.sch[x + 2, y + 1] < 1) then
      ZarBez(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and (pos.sch[x + 2, y - 1] < 1) then
      ZarBez(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and (pos.sch[x + 1, y + 2] < 1) then
      ZarBez(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and (pos.sch[x + 1, y - 2] < 1) then
      ZarBez(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and (pos.sch[x - 2, y + 1] < 1) then
      ZarBez(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and (pos.sch[x - 2, y - 1] < 1) then
      ZarBez(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and (pos.sch[x - 1, y + 2] < 1) then
      ZarBez(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and (pos.sch[x - 1, y - 2] < 1) then
      ZarBez(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  Procedure BSBez;
  begin
    JedBez(-1, -1, true);
    JedBez(-1, 1, true);
    JedBez(1, -1, true);
    JedBez(1, 1, true);
  end;
  Procedure BVBez;
  begin
    JedBez(-1, 0, true);
    JedBez(0, -1, true);
    JedBez(0, 1, true);
    JedBez(1, 0, true);
  end;
  procedure BKBez;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] < 1) then
          if not ohrozeno(i, j, false, pos.sch) then
            ZarBez(x + y shl 4, i + j shl 4, 0);
    { a te� ro��da }
    if (x = 4) and (y = 0) then
    begin
      if (vrb in pos.stav.b) and (pos.sch[3, 0] = 0) and (pos.sch[2, 0] = 0) and
        (pos.sch[1, 0] = 0) and
        (not(ohrozeno(x, 0, false, pos.sch) or ohrozeno(x - 1, 0, false,
        pos.sch) or ohrozeno(x - 2, 0, false, pos.sch))) then
        ZarBez(4, 2, 0);
      if (mrb in pos.stav.b) and (pos.sch[5, 0] = 0) and (pos.sch[6, 0] = 0) and
        (not(ohrozeno(x, 0, false, pos.sch) or ohrozeno(x + 1, 0, false,
        pos.sch) or ohrozeno(x + 2, 0, false, pos.sch))) then
        ZarBez(4, 6, 0)
    end
  end;
{ !!!!!!!!!!!!!!!!!! Rutiny pro pro �ern� figury s kontrolou !!!!!!!!!!!!!!! }
  procedure CPS;
  var
    i: shortint;
  begin
    if (y > 1) then
    begin
      if (y = 6) and (pos.sch[x, 5] = 0) and (pos.sch[x, 4] = 0) then
        ZarS(x + 6 shl 4, x + 4 shl 4, 0);
      if (pos.sch[x, y - 1] = 0) then
        ZarS(x + y shl 4, x + (y - 1) shl 4, 0);
      if (x < 7) and (pos.sch[x + 1, y - 1] > 0) then
        ZarS(x + y shl 4, x + 1 + (y - 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y - 1] > 0) then
        ZarS(x + y shl 4, x - 1 + (y - 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 3) then
        ZarS(x + 3 shl 4, pos.stav.mimoch + 2 shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=1 then prom�na p�ce }
    begin
      for i := -5 to -2 do { do kon� od d�my }
      begin
        if (pos.sch[x, 0] = 0) then
          ZarS(x + 1 shl 4, x, i);
        if (x < 7) and (pos.sch[x + 1, 0] > 0) then
          ZarS(x + 1 shl 4, x + 1, i);
        if (x > 0) and (pos.sch[x - 1, 0] > 0) then
          ZarS(x + 1 shl 4, x - 1, i);
      end
    end;
  end;
  procedure CJS;
  begin
    if (x < 6) and (y < 7) and (pos.sch[x + 2, y + 1] > -1) then
      ZarS(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and (pos.sch[x + 2, y - 1] > -1) then
      ZarS(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and (pos.sch[x + 1, y + 2] > -1) then
      ZarS(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and (pos.sch[x + 1, y - 2] > -1) then
      ZarS(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and (pos.sch[x - 2, y + 1] > -1) then
      ZarS(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and (pos.sch[x - 2, y - 1] > -1) then
      ZarS(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and (pos.sch[x - 1, y + 2] > -1) then
      ZarS(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and (pos.sch[x - 1, y - 2] > -1) then
      ZarS(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  procedure CSS;
  begin
    JedS(-1, -1, false);
    JedS(-1, 1, false);
    JedS(1, -1, false);
    JedS(1, 1, false);

  end;
  procedure CVS;
  begin
    JedS(-1, 0, false);
    JedS(0, -1, false);
    JedS(0, 1, false);
    JedS(1, 0, false);
  end;
  procedure CKS;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] > -1) then
        begin
          pos.sch[x, y] := 0; { Jedin� z�pis do pozice, hned ho zase odstran�m.
            Neb�t t�to zr�dnosti, mohl by kr�l ustoupit na pol��ko kter� nebylo
            ohro�en� jen proto, �e ho kr�l "odst�nil". }
          if not ohrozeno(i, j, true, pos.sch) then
          begin
            pos.sch[x, y] := -6;
            ZarBez(x + y shl 4, i + j shl 4, 0);
          end
          else
            pos.sch[x, y] := -6;
        end
  end;
{ !!!!!!!!!!!!!!!!! Rutiny pro pro �ern� figury bez kontroly !!!!!!!!!!!!!! }
  Procedure CPBez;
  var
    i: shortint;
  begin
    if (y > 1) then
    begin
      if (y = 6) and (pos.sch[x, 5] = 0) and (pos.sch[x, 4] = 0) then
        ZarBez(x + 6 shl 4, x + 4 shl 4, 0);
      if (pos.sch[x, y - 1] = 0) then
        ZarBez(x + y shl 4, x + (y - 1) shl 4, 0);
      if (x < 7) and (pos.sch[x + 1, y - 1] > 0) then
        ZarBez(x + y shl 4, x + 1 + (y - 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y - 1] > 0) then
        ZarBez(x + y shl 4, x - 1 + (y - 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 3) then
        ZarBez(x + 3 shl 4, pos.stav.mimoch + 2 shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=1 then prom�na p�ce }
    begin
      for i := -5 to -2 do { od d�my do kon� }
      begin
        if (pos.sch[x, 0] = 0) then
          ZarBez(x + 1 shl 4, x, i);
        if (x < 7) and (pos.sch[x + 1, 0] > 0) then
          ZarBez(x + 1 shl 4, x + 1, i);
        if (x > 0) and (pos.sch[x - 1, 0] > 0) then
          ZarBez(x + 1 shl 4, x - 1, i);
      end
    end;
  end;
  Procedure CJBez;
  begin
    if (x < 6) and (y < 7) and (pos.sch[x + 2, y + 1] > -1) then
      ZarBez(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and (pos.sch[x + 2, y - 1] > -1) then
      ZarBez(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and (pos.sch[x + 1, y + 2] > -1) then
      ZarBez(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and (pos.sch[x + 1, y - 2] > -1) then
      ZarBez(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and (pos.sch[x - 2, y + 1] > -1) then
      ZarBez(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and (pos.sch[x - 2, y - 1] > -1) then
      ZarBez(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and (pos.sch[x - 1, y + 2] > -1) then
      ZarBez(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and (pos.sch[x - 1, y - 2] > -1) then
      ZarBez(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  Procedure CSBez;
  begin
    JedBez(-1, -1, false);
    JedBez(-1, 1, false);
    JedBez(1, -1, false);
    JedBez(1, 1, false);
  end;
  Procedure CVBez;
  begin
    JedBez(-1, 0, false);
    JedBez(0, -1, false);
    JedBez(0, 1, false);
    JedBez(1, 0, false);
  end;
  procedure CKBez;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] > -1) then
          if not ohrozeno(i, j, true, pos.sch) then
            ZarBez(x + y shl 4, i + j shl 4, 0);
    { a te� ro��da }
    if (x = 4) and (y = 7) then
    begin
      if (vrc in pos.stav.b) and (pos.sch[3, 7] = 0) and (pos.sch[2, 7] = 0) and
        (pos.sch[1, 7] = 0) and
        (not(ohrozeno(4, 7, true, pos.sch) or ohrozeno(3, 7, true, pos.sch) or
        ohrozeno(2, 7, true, pos.sch))) then
        ZarBez(4 + 7 shl 4, 2 + 7 shl 4, 0);
      if (mrc in pos.stav.b) and (pos.sch[5, 7] = 0) and (pos.sch[6, 7] = 0) and
        (not(ohrozeno(4, 7, true, pos.sch) or ohrozeno(5, 7, true, pos.sch) or
        ohrozeno(6, 7, true, pos.sch))) then
        ZarBez(4 + 7 shl 4, 6 + 7 shl 4, 0)
    end
  end;

label NalBilKral, NalCerKral;
{ !!!!!!!!!!!!!!!!!!!!!!!!! ZA��TEK T�LA NALEZTAHY !!!!!!!!!!!!!!!!!!!!!!!! }
{$IFDEF LADIM}var
  tahy2: ttahy;
  pompos: Tpozice; {$ENDIF}
BEGIN
{$IFDEF LADIM}rutiny.naleztahy(pos, tahy2);
  pompos := pos; {$ENDIF}
  tahy.poctah := 0;
  vrahu := 0;
  if hb in pos.stav.b then { na tahu je b�l� }
  begin
    for x := 0 to 7 do
      for y := 0 to 7 do
        if pos.sch[x, y] = 6 then
        begin
          kx := x;
          ky := y;
          goto NalBilKral
        end;
  NalBilKral:
    if ohrozeno(kx, ky, false, pos.sch) then
    begin
      result := true;
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            1:
              BPS;
            2:
              BJS;
            3:
              BSS;
            4:
              BVS;
            5:
              begin
                BVS;
                BSS
              end;
            6:
              BKS
          end { od case }
    end { od kr�l hraj�c� strany je v �achu }
    else
    begin { m�m to jednodu��� s �achem }
      result := false;
      vazby(kx, ky, pos.sch, vz);
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            1:
              BPBez;
            2:
              BJBez;
            3:
              BSBez;
            4:
              BVBez;
            5:
              begin
                BVBez;
                BSBez
              end;
            6:
              BKBez;
          end { od case }
    end { od kr�l nen� v �achu }
  end { od hraje b�l� }
  else
  begin { Hraje �ern� }
    for x := 0 to 7 do
      for y := 0 to 7 do
        if pos.sch[x, y] = -6 then
        begin
          kx := x;
          ky := y;
          goto NalCerKral
        end;
  NalCerKral:
    if ohrozeno(kx, ky, true, pos.sch) then
    begin
      result := true;
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            - 1:
              CPS;
            -2:
              CJS;
            -3:
              CSS;
            -4:
              CVS;
            -5:
              begin
                CSS;
                CVS
              end;
            -6:
              CKS
          end { od case }
    end { od kr�l hraj�c� strany je v �achu }
    else
    begin { m�m to jednodu��� s �achem }
      result := false;
      vazby(kx, ky, pos.sch, vz);
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            - 1:
              CPBez;
            -2:
              CJBez;
            -3:
              CSBez;
            -4:
              CVBez;
            -5:
              begin
                CSBez;
                CVBez
              end;
            -6:
              CKBez;
          end { od case }
    end { od kr�l nen� v �achu }
  end { Od hraje �ern� }
{$IFDEF LADIM};
  if not(stejnepos(pos, pompos)) then
    raise Exception.Create('procerure rychle.naleztahy m�n� pozici');

  if not(stejne(tahy, tahy2)) then
    raise Exception.Create('procerure rychle.naleztahy, na�la je jinak ne� rutiny.naleztahy');
  if not BachaRekurze then
  begin
    nalezvrahy(pos, tahy2);
    if not(podmnoz(tahy2, tahy)) then
      raise Exception.Create('procerure rychle.nalezvrahy, na�la jich v�c ne� rychle.naleztahy');
  end;
  x := 1
{$ENDIF}
END;
{ !!!!!!!!!!!!!!!!!!!!!!!! KONEC ��LA NALEZTAHY !!!!!!!!!!!!!!!!!!!!!!!!!!! }

{ ************************************************************************
  *                                                                      *
  *!!!!!!!!!!!!!!!!!!!!!!!!!!! NALEZVRAHY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
  *                                                                      *
  ************************************************************************ }
function nalezvrahy(var pos: Tpozice; var tahy: ttahy): boolean;
var
  x, y, kx, ky, kdx, kdy: shortint; { sou�adnice ciz�ho kr�le }
  vezi, jezdcem, strelcem, vz: tsch; { odkud bychom mohli d�t �ach }
  { !!!!!!!!!!!!!!!!!! Za�azovac� rutiny pro nalezvrahy !!!!!!!!!!!!!!!!!!!!! }
  procedure Zar(np1, np2: byte; npromena: shortint);
  begin
    if (vz[np1 and 15, np1 shr 4] = 0) { figura nebyla v�zan� } or
      (((np2 and 15) - kx) * ((np1 shr 4) - ky) = ((np1 and 15) - kx) *
      ((np2 shr 4) - ky))
    { nebo sice byla v�zan�, ale z�stala na p��mce kr�l, p�vodn� pole,
      v�zaj�c� figura
      (vypad� to zr�dn�, ale je to jen jednoduch� geometrie) }
    then { je to tah podle pravidel }
      if tahy.poctah < maxtah then
      begin
        inc(tahy.poctah);
        with tahy.t[tahy.poctah] do
        begin
          p1 := np1;
          p2 := np2;
          promena := npromena;
        end;
      end { else V�c tah� ne� je mo�n� }
  end;
{ !!!!!!!!!!!!!!!!! Rutiny pro pro b�l� figury bez kontroly !!!!!!!!!!!!!! }
  Procedure BP;
  begin
    if (y < 6) then
    begin
      if (y = 1) and (pos.sch[x, 2] = 0) and (pos.sch[x, 3] = 0) and
        ((x < 7) and (pos.sch[x + 1, 4] = -6) or (x > 0) and
        (pos.sch[x - 1, 4] = -6)) then
        Zar(x + y shl 4, x + (y + 2) shl 4, 0);
      if (pos.sch[x, y + 1] = 0) and
        ((x < 7) and (pos.sch[x + 1, y + 2] = -6) or (x > 0) and
        (pos.sch[x - 1, y + 2] = -6)) then
        Zar(x + y shl 4, x + (y + 1) shl 4, 0);
      { Zat�m to nebylo bran�, jen �ach soupe�i }
      if (x < 7) and (pos.sch[x + 1, y + 1] < 0) then
        Zar(x + y shl 4, x + 1 + (y + 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y + 1] < 0) then
        Zar(x + y shl 4, x - 1 + (y + 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 4) then
        Zar(x + y shl 4, pos.stav.mimoch + (y + 1) shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=6 then prom�na p�ce }
    begin { M�nit p�ce v n�co jin�ho ne� d�mu nen� vrah }
      if (pos.sch[x, 7] = 0) then
        Zar(x + 6 shl 4, x + 7 shl 4, 5);
      if (x < 7) and (pos.sch[x + 1, 7] < 0) then
        Zar(x + 6 shl 4, x + 1 + 7 shl 4, 5);
      if (x > 0) and (pos.sch[x - 1, 7] < 0) then
        Zar(x + 6 shl 4, x - 1 + 7 shl 4, 5);
    end
  end;
  Procedure BJ;
  begin
    if (x < 6) and (y < 7) and ((pos.sch[x + 2, y + 1] < 0) or
      (pos.sch[x + 2, y + 1] = 0) and (jezdcem[x + 2, y + 1] = 1)) then
      Zar(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and ((pos.sch[x + 2, y - 1] < 0) or
      (pos.sch[x + 2, y - 1] = 0) and (jezdcem[x + 2, y - 1] = 1)) then
      Zar(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and ((pos.sch[x + 1, y + 2] < 0) or
      (pos.sch[x + 1, y + 2] = 0) and (jezdcem[x + 1, y + 2] = 1)) then
      Zar(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and ((pos.sch[x + 1, y - 2] < 0) or
      (pos.sch[x + 1, y - 2] = 0) and (jezdcem[x + 1, y - 2] = 1)) then
      Zar(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and ((pos.sch[x - 2, y + 1] < 0) or
      (pos.sch[x - 2, y + 1] = 0) and (jezdcem[x - 2, y + 1] = 1)) then
      Zar(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and ((pos.sch[x - 2, y - 1] < 0) or
      (pos.sch[x - 2, y - 1] = 0) and (jezdcem[x - 2, y - 1] = 1)) then
      Zar(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and ((pos.sch[x - 1, y + 2] < 0) or
      (pos.sch[x - 1, y + 2] = 0) and (jezdcem[x - 1, y + 2] = 1)) then
      Zar(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and ((pos.sch[x - 1, y - 2] < 0) or
      (pos.sch[x - 1, y - 2] = 0) and (jezdcem[x - 1, y - 2] = 1)) then
      Zar(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  Procedure BS;
  var
    i, j: shortint;
  begin
    i := x;
    j := y;
    while (i < 7) and (j < 7) do
    begin
      inc(i);
      inc(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i < 7) and (j > 0) do
    begin
      inc(i);
      dec(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j < 7) do
    begin
      dec(i);
      inc(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j > 0) do
    begin
      dec(i);
      dec(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end
  end;
  Procedure BV;
  var
    i: shortint;
  begin
    for i := x + 1 to 7 do
      if pos.sch[i, y] > 0 then
        break
      else if pos.sch[i, y] < 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if vezi[i, y] = 1 then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := x - 1 downto 0 do
      if pos.sch[i, y] > 0 then
        break
      else if pos.sch[i, y] < 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if vezi[i, y] = 1 then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := y + 1 to 7 do
      if pos.sch[x, i] > 0 then
        break
      else if pos.sch[x, i] < 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if vezi[x, i] = 1 then
        Zar(x + y shl 4, x + i shl 4, 0);
    for i := y - 1 downto 0 do
      if pos.sch[x, i] > 0 then
        break
      else if pos.sch[x, i] < 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if vezi[x, i] = 1 then
        Zar(x + y shl 4, x + i shl 4, 0);
  end;
  procedure BD;
  { nejde napsat BS;BV, proto�e d�ma m��e t�hout jako st�elec a t�m tahem
    d�t �ach jako v� (nebo obr�cen�) }
  var
    i, j: shortint;
  begin
    for i := x + 1 to 7 do
      if pos.sch[i, y] > 0 then
        break
      else if pos.sch[i, y] < 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if (vezi[i, y] = 1) or (strelcem[i, y] = 1) then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := x - 1 downto 0 do
      if pos.sch[i, y] > 0 then
        break
      else if pos.sch[i, y] < 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if (vezi[i, y] = 1) or (strelcem[i, y] = 1) then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := y + 1 to 7 do
      if pos.sch[x, i] > 0 then
        break
      else if pos.sch[x, i] < 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if (vezi[x, i] = 1) or (strelcem[x, i] = 1) then
        Zar(x + y shl 4, x + i shl 4, 0);
    for i := y - 1 downto 0 do
      if pos.sch[x, i] > 0 then
        break
      else if pos.sch[x, i] < 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if (vezi[x, i] = 1) or (strelcem[x, i] = 1) then
        Zar(x + y shl 4, x + i shl 4, 0);
    i := x;
    j := y;
    while (i < 7) and (j < 7) do
    begin
      inc(i);
      inc(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i < 7) and (j > 0) do
    begin
      inc(i);
      dec(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j < 7) do
    begin
      dec(i);
      inc(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j > 0) do
    begin
      dec(i);
      dec(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end
  end;
  procedure BK;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] < 0) then
          if not ohrozeno(i, j, false, pos.sch) then
            Zar(x + y shl 4, i + j shl 4, 0);
  end;
{ !!!!!!!!!!!!!!!!! Rutiny pro pro �ern� figury bez kontroly !!!!!!!!!!!!!! }
  Procedure CP;
  begin
    if (y > 1) then
    begin
      if (y = 6) and (pos.sch[x, 5] = 0) and (pos.sch[x, 4] = 0) and
        ((x < 7) and (pos.sch[x - 1, 3] = 6) or (x > 0) and
        (pos.sch[x - 1, 3] = 6)) then
        Zar(x + 6 shl 4, x + 4 shl 4, 0);
      if (pos.sch[x, y - 1] = 0) and ((x < 7) and (pos.sch[x - 1, y - 2] = 6) or
        (x > 0) and (pos.sch[x - 1, y - 2] = 6)) then
        Zar(x + y shl 4, x + (y - 1) shl 4, 0);
      if (x < 7) and (pos.sch[x + 1, y - 1] > 0) then
        Zar(x + y shl 4, x + 1 + (y - 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y - 1] > 0) then
        Zar(x + y shl 4, x - 1 + (y - 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 3) then
        Zar(x + 3 shl 4, pos.stav.mimoch + 2 shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=1 then prom�na p�ce }
    begin
      if (pos.sch[x, 0] = 0) then
        Zar(x + 1 shl 4, x, -5);
      if (x < 7) and (pos.sch[x + 1, 0] > 0) then
        Zar(x + 1 shl 4, x + 1, -5);
      if (x > 0) and (pos.sch[x - 1, 0] > 0) then
        Zar(x + 1 shl 4, x - 1, -5);
    end;
  end;
  Procedure CJ;
  begin
    if (x < 6) and (y < 7) and ((pos.sch[x + 2, y + 1] > 0) or
      (pos.sch[x + 2, y + 1] = 0) and (jezdcem[x + 2, y + 1] = 1)) then
      Zar(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and ((pos.sch[x + 2, y - 1] > 0) or
      (pos.sch[x + 2, y - 1] = 0) and (jezdcem[x + 2, y - 1] = 1)) then
      Zar(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and ((pos.sch[x + 1, y + 2] > 0) or
      (pos.sch[x + 1, y + 2] = 0) and (jezdcem[x + 1, y + 2] = 1)) then
      Zar(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and ((pos.sch[x + 1, y - 2] > 0) or
      (pos.sch[x + 1, y - 2] = 0) and (jezdcem[x + 1, y - 2] = 1)) then
      Zar(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and ((pos.sch[x - 2, y + 1] > 0) or
      (pos.sch[x - 2, y + 1] = 0) and (jezdcem[x - 2, y + 1] = 1)) then
      Zar(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and ((pos.sch[x - 2, y - 1] > 0) or
      (pos.sch[x - 2, y - 1] = 0) and (jezdcem[x - 2, y - 1] = 1)) then
      Zar(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and ((pos.sch[x - 1, y + 2] > 0) or
      (pos.sch[x - 1, y + 2] = 0) and (jezdcem[x - 1, y + 2] = 1)) then
      Zar(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and ((pos.sch[x - 1, y - 2] > 0) or
      (pos.sch[x - 1, y - 2] = 0) and (jezdcem[x - 1, y - 2] = 1)) then
      Zar(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  Procedure CS;
  var
    i, j: shortint;
  begin
    i := x;
    j := y;
    while (i < 7) and (j < 7) do
    begin
      inc(i);
      inc(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if strelcem[i, j] = 1 then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i < 7) and (j > 0) do
    begin
      inc(i);
      dec(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if strelcem[i, j] = 1 then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j < 7) do
    begin
      dec(i);
      inc(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if strelcem[i, j] = 1 then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j > 0) do
    begin
      dec(i);
      dec(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if strelcem[i, j] = 1 then
        Zar(x + y shl 4, i + j shl 4, 0);
    end
  end;
  Procedure CV;
  var
    i: shortint;
  begin
    for i := x + 1 to 7 do
      if pos.sch[i, y] < 0 then
        break
      else if pos.sch[i, y] > 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if vezi[i, y] = 1 then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := x - 1 downto 0 do
      if pos.sch[i, y] < 0 then
        break
      else if pos.sch[i, y] > 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if vezi[i, y] = 1 then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := y + 1 to 7 do
      if pos.sch[x, i] < 0 then
        break
      else if pos.sch[x, i] > 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if vezi[x, i] = 1 then
        Zar(x + y shl 4, x + i shl 4, 0);
    for i := y - 1 downto 0 do
      if pos.sch[x, i] < 0 then
        break
      else if pos.sch[x, i] > 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if vezi[x, i] = 1 then
        Zar(x + y shl 4, x + i shl 4, 0);
  end;
  procedure CD;
  { nejde napsat CS;CV, proto�e d�ma m��e t�hout jako st�elec a t�m tahem
    d�t �ach jako v� (nebo obr�cen�) }
  var
    i, j: shortint;
  begin
    for i := x + 1 to 7 do
      if pos.sch[i, y] < 0 then
        break
      else if pos.sch[i, y] > 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if (vezi[i, y] = 1) or (strelcem[i, y] = 1) then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := x - 1 downto 0 do
      if pos.sch[i, y] < 0 then
        break
      else if pos.sch[i, y] > 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end
      else if (vezi[i, y] = 1) or (strelcem[i, y] = 1) then
        Zar(x + y shl 4, i + y shl 4, 0);
    for i := y + 1 to 7 do
      if pos.sch[x, i] < 0 then
        break
      else if pos.sch[x, i] > 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if (vezi[x, i] = 1) or (strelcem[x, i] = 1) then
        Zar(x + y shl 4, x + i shl 4, 0);
    for i := y - 1 downto 0 do
      if pos.sch[x, i] < 0 then
        break
      else if pos.sch[x, i] > 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end
      else if (vezi[x, i] = 1) or (strelcem[x, i] = 1) then
        Zar(x + y shl 4, x + i shl 4, 0);

    i := x;
    j := y;
    while (i < 7) and (j < 7) do
    begin
      inc(i);
      inc(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i < 7) and (j > 0) do
    begin
      inc(i);
      dec(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j < 7) do
    begin
      dec(i);
      inc(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end;
    i := x;
    j := y;
    while (i > 0) and (j > 0) do
    begin
      dec(i);
      dec(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
      else if (strelcem[i, j] = 1) or (vezi[i, j] = 1) then
        Zar(x + y shl 4, i + j shl 4, 0);
    end
  end;
  procedure CK;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] > 0) then
          if not ohrozeno(i, j, true, pos.sch) then
            Zar(x + y shl 4, i + j shl 4, 0);
  end;

{ !!!!!!!!!!!!!!!!!!!!!!!!! ZA��TEK T�LA nalezvrahy !!!!!!!!!!!!!!!!!!!!!!!! }
BEGIN
{$IFDEF LADIM}
  BachaRekurze := true;
{$ENDIF}
  tahy.poctah := 0;
  if hb in pos.stav.b then { na tahu je b�l� }
  begin
    for x := 0 to 7 do
      for y := 0 to 7 do
      begin
        if pos.sch[x, y] = 6 then
        begin
          kx := x;
          ky := y
        end
        else if pos.sch[x, y] = -6 then
        begin
          kdx := x;
          kdy := y
        end;
      end;
    if ohrozeno(kx, ky, false, pos.sch) then
    begin
      naleztahy(pos, tahy); { M�m-li �ach, je ka�d� m�j tah vrahem }
      result := true;
    end
    else
    begin { nejsem v �achu }
      result := false;
      vazby(kx, ky, pos.sch, vz);
      NapadJezdcem(kdx, kdy, jezdcem);
      NapadStrelcem(kdx, kdy, pos.sch, strelcem);
      NapadVezi(kdx, kdy, pos.sch, vezi);
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            1:
              BP;
            2:
              BJ;
            3:
              BS;
            4:
              BV;
            5:
              BD;
            6:
              BK;
          end { od case }
    end { od kr�l nen� v �achu }
  end { od hraje b�l� }
  else
  begin { Hraje �ern� }
    for x := 0 to 7 do
      for y := 0 to 7 do
      begin
        if pos.sch[x, y] = -6 then
        begin
          kx := x;
          ky := y
        end
        else if pos.sch[x, y] = 6 then
        begin
          kdx := x;
          kdy := y
        end;
      end;
    if ohrozeno(kx, ky, true, pos.sch) then
    begin
      naleztahy(pos, tahy); { M�m-li �ach, je ka�d� m�j tah vrahem }
      result := true;
    end
    else
    begin { Nejsem v �achu }
      result := false;
      vazby(kx, ky, pos.sch, vz);
      NapadJezdcem(kdx, kdy, jezdcem);
      NapadStrelcem(kdx, kdy, pos.sch, strelcem);
      NapadVezi(kdx, kdy, pos.sch, vezi);
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            - 1:
              CP;
            -2:
              CJ;
            -3:
              CS;
            -4:
              CV;
            -5:
              CD;
            -6:
              CK;
          end { od case }
    end { od kr�l nen� v �achu }
  end { Od hraje �ern� }
{$IFDEF LADIM}
    ;
  BachaRekurze := false;
{$ENDIF}
END;

{ !!!!!!!!!!!!!!!!!!!!!!!! KONEC ��LA nalezvrahy !!!!!!!!!!!!!!!!!!!!!!!!!!! }
{ ************************************************************************
  *                                                                      *
  *!!!!!!!!!!!!!!!!!!!!!!!!!!! NALEZBRANI !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
  *                                                                      *
  ************************************************************************ }
function nalezbrani(var pos: Tpozice; var tahy: ttahy): boolean;
var
  x, y, kx, ky: shortint; { sou�adnice ciz�ho kr�le }
  vz: tsch; { odkud bychom mohli d�t �ach }
  { !!!!!!!!!!!!!!!!!! Za�azovac� rutiny pro nalezvrahy !!!!!!!!!!!!!!!!!!!!! }
  procedure Zar(np1, np2: byte; npromena: shortint);
  begin
    if (vz[np1 and 15, np1 shr 4] = 0) { figura nebyla v�zan� } or
      (((np2 and 15) - kx) * ((np1 shr 4) - ky) = ((np1 and 15) - kx) *
      ((np2 shr 4) - ky))
    { nebo sice byla v�zan�, ale z�stala na p��mce kr�l, p�vodn� pole,
      v�zaj�c� figura
      (vypad� to zr�dn�, ale je to jen jednoduch� geometrie) }
    then { je to tah podle pravidel }
      if tahy.poctah < maxtah then
      begin
        inc(tahy.poctah);
        with tahy.t[tahy.poctah] do
        begin
          p1 := np1;
          p2 := np2;
          promena := npromena;
        end;
      end { else V�c tah� ne� je mo�n� }
  end;
{ !!!!!!!!!!!!!!!!! Rutiny pro pro b�l� figury bez kontroly !!!!!!!!!!!!!! }
  Procedure BP;
  begin
    if (y < 6) then
    begin
      if (x < 7) and (pos.sch[x + 1, y + 1] < 0) then
        Zar(x + y shl 4, x + 1 + (y + 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y + 1] < 0) then
        Zar(x + y shl 4, x - 1 + (y + 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 4) then
        Zar(x + y shl 4, pos.stav.mimoch + (y + 1) shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=6 then prom�na p�ce }
    begin { M�nit p�ce v n�co jin�ho ne� d�mu nen� vrah }
      if (pos.sch[x, 7] = 0) then
        Zar(x + 6 shl 4, x + 7 shl 4, 5);
      if (x < 7) and (pos.sch[x + 1, 7] < 0) then
        Zar(x + 6 shl 4, x + 1 + 7 shl 4, 5);
      if (x > 0) and (pos.sch[x - 1, 7] < 0) then
        Zar(x + 6 shl 4, x - 1 + 7 shl 4, 5);
    end
  end;
  Procedure BJ;
  begin
    if (x < 6) and (y < 7) and ((pos.sch[x + 2, y + 1] < 0)) then
      Zar(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and ((pos.sch[x + 2, y - 1] < 0)) then
      Zar(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and ((pos.sch[x + 1, y + 2] < 0)) then
      Zar(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and ((pos.sch[x + 1, y - 2] < 0)) then
      Zar(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and ((pos.sch[x - 2, y + 1] < 0)) then
      Zar(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and ((pos.sch[x - 2, y - 1] < 0)) then
      Zar(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and ((pos.sch[x - 1, y + 2] < 0)) then
      Zar(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and ((pos.sch[x - 1, y - 2] < 0)) then
      Zar(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  Procedure BS;
  var
    i, j: shortint;
  begin
    i := x;
    j := y;
    while (i < 7) and (j < 7) do
    begin
      inc(i);
      inc(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end;
    i := x;
    j := y;
    while (i < 7) and (j > 0) do
    begin
      inc(i);
      dec(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end;
    i := x;
    j := y;
    while (i > 0) and (j < 7) do
    begin
      dec(i);
      inc(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end;
    i := x;
    j := y;
    while (i > 0) and (j > 0) do
    begin
      dec(i);
      dec(j);
      if pos.sch[i, j] > 0 then
        break
      else if pos.sch[i, j] < 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end
  end;
  Procedure BV;
  var
    i: shortint;
  begin
    for i := x + 1 to 7 do
      if pos.sch[i, y] > 0 then
        break
      else if pos.sch[i, y] < 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end;
    for i := x - 1 downto 0 do
      if pos.sch[i, y] > 0 then
        break
      else if pos.sch[i, y] < 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end;
    for i := y + 1 to 7 do
      if pos.sch[x, i] > 0 then
        break
      else if pos.sch[x, i] < 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end;
    for i := y - 1 downto 0 do
      if pos.sch[x, i] > 0 then
        break
      else if pos.sch[x, i] < 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end;
  end;
  procedure BD;
  begin
    BS;
    BV
  end;
  procedure BK;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] < 0) then
          if not ohrozeno(i, j, false, pos.sch) then
            Zar(x + y shl 4, i + j shl 4, 0);
  end;
{ !!!!!!!!!!!!!!!!! Rutiny pro pro �ern� figury bez kontroly !!!!!!!!!!!!!! }
  Procedure CP;
  begin
    if (y > 1) then
    begin
      if (x < 7) and (pos.sch[x + 1, y - 1] > 0) then
        Zar(x + y shl 4, x + 1 + (y - 1) shl 4, 0);
      if (x > 0) and (pos.sch[x - 1, y - 1] > 0) then
        Zar(x + y shl 4, x - 1 + (y - 1) shl 4, 0);
      if (abs(pos.stav.mimoch - x) = 1) and (y = 3) then
        Zar(x + 3 shl 4, pos.stav.mimoch + 2 shl 4, 0);
      { bran� mimochodem }
    end
    else { tj. if y=1 then prom�na p�ce }
    begin
      if (pos.sch[x, 0] = 0) then
        Zar(x + 1 shl 4, x, -5);
      if (x < 7) and (pos.sch[x + 1, 0] > 0) then
        Zar(x + 1 shl 4, x + 1, -5);
      if (x > 0) and (pos.sch[x - 1, 0] > 0) then
        Zar(x + 1 shl 4, x - 1, -5);
    end;
  end;
  Procedure CJ;
  begin
    if (x < 6) and (y < 7) and ((pos.sch[x + 2, y + 1] > 0)) then
      Zar(x + y shl 4, (x + 2) + (y + 1) shl 4, 0);
    if (x < 6) and (y > 0) and ((pos.sch[x + 2, y - 1] > 0)) then
      Zar(x + y shl 4, (x + 2) + (y - 1) shl 4, 0);
    if (x < 7) and (y < 6) and ((pos.sch[x + 1, y + 2] > 0)) then
      Zar(x + y shl 4, (x + 1) + (y + 2) shl 4, 0);
    if (x < 7) and (y > 1) and ((pos.sch[x + 1, y - 2] > 0)) then
      Zar(x + y shl 4, (x + 1) + (y - 2) shl 4, 0);
    if (x > 1) and (y < 7) and ((pos.sch[x - 2, y + 1] > 0)) then
      Zar(x + y shl 4, (x - 2) + (y + 1) shl 4, 0);
    if (x > 1) and (y > 0) and ((pos.sch[x - 2, y - 1] > 0)) then
      Zar(x + y shl 4, (x - 2) + (y - 1) shl 4, 0);
    if (x > 0) and (y < 6) and ((pos.sch[x - 1, y + 2] > 0)) then
      Zar(x + y shl 4, (x - 1) + (y + 2) shl 4, 0);
    if (x > 0) and (y > 1) and ((pos.sch[x - 1, y - 2] > 0)) then
      Zar(x + y shl 4, (x - 1) + (y - 2) shl 4, 0);
  end;
  Procedure CS;
  var
    i, j: shortint;
  begin
    i := x;
    j := y;
    while (i < 7) and (j < 7) do
    begin
      inc(i);
      inc(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end;
    i := x;
    j := y;
    while (i < 7) and (j > 0) do
    begin
      inc(i);
      dec(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end;
    i := x;
    j := y;
    while (i > 0) and (j < 7) do
    begin
      dec(i);
      inc(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end;
    i := x;
    j := y;
    while (i > 0) and (j > 0) do
    begin
      dec(i);
      dec(j);
      if pos.sch[i, j] < 0 then
        break
      else if pos.sch[i, j] > 0 then
      begin
        Zar(x + y shl 4, i + j shl 4, 0);
        break
      end
    end
  end;
  Procedure CV;
  var
    i: shortint;
  begin
    for i := x + 1 to 7 do
      if pos.sch[i, y] < 0 then
        break
      else if pos.sch[i, y] > 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end;
    for i := x - 1 downto 0 do
      if pos.sch[i, y] < 0 then
        break
      else if pos.sch[i, y] > 0 then
      begin
        Zar(x + y shl 4, i + y shl 4, 0);
        break
      end;
    for i := y + 1 to 7 do
      if pos.sch[x, i] < 0 then
        break
      else if pos.sch[x, i] > 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end;
    for i := y - 1 downto 0 do
      if pos.sch[x, i] < 0 then
        break
      else if pos.sch[x, i] > 0 then
      begin
        Zar(x + y shl 4, x + i shl 4, 0);
        break
      end;
  end;
  procedure CD;
  begin
    CS;
    CV
  end;
  procedure CK;
  var
    i, j: shortint;
  begin
    for i := x - 1 to x + 1 do
      for j := y - 1 to y + 1 do
        if (i > -1) and (i < 8) and (j > -1) and (j < 8) and
          ((i <> x) or (j <> y)) and (pos.sch[i, j] > 0) then
          if not ohrozeno(i, j, true, pos.sch) then
            Zar(x + y shl 4, i + j shl 4, 0);
  end;

{ !!!!!!!!!!!!!!!!!!!!!!!!! ZA��TEK T�LA nalezbrani !!!!!!!!!!!!!!!!!!!!!!!! }
BEGIN
{$IFDEF LADIM}
  BachaRekurze := true;
{$ENDIF}
  tahy.poctah := 0;
  if hb in pos.stav.b then { na tahu je b�l� }
  begin
    for x := 0 to 7 do
      for y := 0 to 7 do
      begin
        if pos.sch[x, y] = 6 then
        begin
          kx := x;
          ky := y
        end;
{        else if pos.sch[x, y] = -6 then
        begin
          kdx := x;
          kdy := y
        end;}
      end;
    if ohrozeno(kx, ky, false, pos.sch) then
    begin
      naleztahy(pos, tahy); { M�m-li �ach, je ka�d� m�j tah vrahem }
      result := true; { !!!!!!!!!!!!!!!!!!!!! ale ne bran�m !!!!!!!!!!!!!!!! }
    end
    else
    begin { nejsem v �achu }
      result := false;
      vazby(kx, ky, pos.sch, vz);
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            1:
              BP;
            2:
              BJ;
            3:
              BS;
            4:
              BV;
            5:
              BD;
            6:
              BK;
          end { od case }
    end { od kr�l nen� v �achu }
  end { od hraje b�l� }
  else
  begin { Hraje �ern� }
    for x := 0 to 7 do
      for y := 0 to 7 do
      begin
        if pos.sch[x, y] = -6 then
        begin
          kx := x;
          ky := y
        end;
{        else if pos.sch[x, y] = 6 then
        begin
          kdx := x;
          kdy := y
        end;}
      end;
    if ohrozeno(kx, ky, true, pos.sch) then
    begin
      naleztahy(pos, tahy); { M�m-li �ach, je ka�d� m�j tah vrahem }
      result := true;
    end
    else
    begin { Nejsem v �achu }
      result := false;
      vazby(kx, ky, pos.sch, vz);
      for x := 0 to 7 do
        for y := 0 to 7 do
          case pos.sch[x, y] of
            - 1:
              CP;
            -2:
              CJ;
            -3:
              CS;
            -4:
              CV;
            -5:
              CD;
            -6:
              CK;
          end { od case }
    end { od kr�l nen� v �achu }
  end { Od hraje �ern� }
{$IFDEF LADIM}
    ;
  BachaRekurze := false;
{$ENDIF}
END;
{ !!!!!!!!!!!!!!!!!!!!!!!! KONEC ��LA nalezbrani !!!!!!!!!!!!!!!!!!!!!!!!!!! }

function stejne(var ta, tb: ttahy): boolean;
var
  i: integer;
begin
  result := True;
  if ta.poctah <> tb.poctah then
    result := false
  else
  begin
    for i := 1 to ta.poctah do
      if not jetam(ta.t[i], tb) then
      begin
        result := false;
        break
      end
  end;
end;

function podmnoz(var ta, tb: ttahy): boolean;
var
  i: integer;
begin
  result := True;
  if ta.poctah > tb.poctah then
    result := false
  else
  begin
    for i := 1 to ta.poctah do
      if not jetam(ta.t[i], tb) then
      begin
        result := false;
        break
      end
  end;
end;

function stejnepos(var pa, pb: Tpozice): boolean;
var
  i, j: integer;
begin
  result := false;
  if pa.stav.mimoch <> pb.stav.mimoch then
    exit;
  if pa.stav.b <> pb.stav.b then
    exit;
  for i := 0 to 7 do
    for j := 0 to 7 do
      if pa.sch[i, j] <> pb.sch[i, j] then
        exit;
  result := true;
end;

function SameTah1(const A, B: TTah1): Boolean;
begin
  Result := (A.p1 = B.p1) and (A.p2 = B.p2) and (A.promena = B.promena);
end;

function CMPPozice(var P1, P2: TPozice): integer;
type
  TPosPole = array [0 .. SizeOf(TPozice) - 1] of byte;
var
  i: integer; { vrac� 1: P1>P2; 0: P1=P2; -1: P1<P2 }
begin
  for i := 0 to SizeOf(TPozice) - 1 do
  begin
    if TPosPole(P1)[i] > TPosPole(P2)[i] then
    begin
      result := 1;
      exit
    end
    else if TPosPole(P1)[i] < TPosPole(P2)[i] then
    begin
      result := -1;
      exit
    end;
  end;
  result := 0
end;

end.

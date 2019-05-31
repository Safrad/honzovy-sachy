unit Ohodnoc;

interface

uses Coty;

function HodnotaPozice(const pos: tpozice): longint;

implementation

uses myslitel;
{ Typy vybavení materiálem

  1) Hráè má alespoò
  a) Dámu a lehkou figuru nebo vìž
  b) Dvì vìže a lehkou figuru
  c) Vìž a dvì lehké figury
  d) Ètyøi lehké figury

  2) Hráè má alespoò
  a) Dámu
  b) Vìž
  c) Dvì lehké figury

  3) Hráè má nejvýše jednu lehkou figuru

  Typy pozic

  A) Zahájení a støední hra (1x1)
  Heuristiky pozic figur (zde a nikde jinde),
  všechny "ostatní" heuristiky.

  B) Pøechod do koncovky (1x2 nebo 2x2)
  "ostatní" heuristiky kromì rošády.
  Dùraz na postouplost pìšcù.

  C) Matící útok (1x3 nebo 2x3)
  Vzdálenost krále slabší strany od rohu
  a vzdálenost soupeøova krále od nìj,
  "ostatní" heuristiky kromì rošády. Dùraz na postouplost pìšcù.

  D) Koncovka (3x3)
  Dùraz na postouplost pìšcù, z "ostatních" heuristik jen ty pìšcové.
}

function HodnotaPozice(const pos: tpozice): longint;
var
  x, y, b, i, j, c, kbx, kby, kcx, kcy: integer;
  bm, cm, pom: longint;
  pesci: array [0 .. 1, 0 .. 7] of byte;
  figury: array [0 .. 1, 1 .. 5] of byte;
  volny, kryty: boolean;
begin
  result := 0;
  fillchar(pesci, sizeof(pesci), 0);
  fillchar(figury, sizeof(figury), 0);
  { Nejprve si jenom zpoèítam figury a zjistím pozici obou králù }
  for x := 0 to 7 do
    for y := 0 to 7 do
      if pos.sch[x, y] > 0 then
      begin
        if pos.sch[x, y] < 6 then
        begin
          if pos.sch[x, y] = 1 then
            inc(pesci[0, x]);
          inc(figury[0, pos.sch[x, y]])
        end
        else
        begin
          kbx := x;
          kby := y
        end
      end
      else if pos.sch[x, y] < 0 then
      begin
        if pos.sch[x, y] > -6 then
        begin
          if pos.sch[x, y] = -1 then
            inc(pesci[1, x]);
          inc(figury[1, -pos.sch[x, y]])
        end
        else
        begin
          kcx := x;
          kcy := y
        end
      end;
  { Teï urèím o jaký typ pozice se jedná (nebo napø. v koncovce jsou
    významné jiné vlastnosti pozice než ve støední høe) }
  if (figury[0, 5] > 0) and ((figury[0, 4] > 0) or (figury[0, 3] > 0) or
    (figury[0, 2] > 0)) or (figury[0, 4] > 1) and
    ((figury[0, 3] > 0) or (figury[0, 2] > 0)) or (figury[0, 4] > 0) and
    (figury[0, 3] + figury[0, 2] > 1) or (figury[0, 3] + figury[0, 2] > 3) then
    b := 1 { má hodnì figur }
  else if (figury[0, 5] > 0) or (figury[0, 4] > 0) or
    (figury[0, 3] + figury[0, 2] > 1) then
    b := 2 { má støednì figur }
  else
    b := 3; { má málo figur }
  if (figury[1, 5] > 0) and ((figury[1, 4] > 0) or (figury[1, 3] > 0) or
    (figury[1, 2] > 0)) or (figury[1, 4] > 1) and
    ((figury[1, 3] > 0) or (figury[1, 2] > 0)) or (figury[1, 4] > 0) and
    (figury[1, 3] + figury[1, 2] > 1) or (figury[1, 3] + figury[1, 2] > 3) then
    c := 1 { má hodnì figur }
  else if (figury[1, 5] > 0) or (figury[1, 4] > 0) or
    (figury[1, 3] + figury[1, 2] > 1) then
    c := 2 { má støednì figur }
  else
    c := 3; { má málo figur }
  for x := 0 to 7 do
    for y := 0 to 7 do
      case pos.sch[x, y] of
        0:
          ; { aby se case rychle opustilo, je-li políèko prázdné }
        -6:
          begin
            if (b = 1) and (c = 1) then
              result := result - AlgCfg.kral[x, 7 - y]
            else if c = 3 then
            begin
              result := result - AlgCfg.KralOdStredu *
                ((abs(7 - 2 * kcx) shr 1) + (abs(7 - 2 * kcy) shr 1));
              if (b < 3) then
              begin
                i := abs(kbx - kcx) - 2;
                if i < 0 then
                  i := 0;
                j := abs(kby - kcy) - 2;
                if j < 0 then
                  j := 0;
                result := result - AlgCfg.KralOdKrale * (i + j);
                if (kcx = 7) and (kbx = 5) then
                  result := result + 100
                else if (kcx = 0) and (kbx = 2) then
                  result := result + 100
                else if (kcy = 7) and (kby = 5) then
                  result := result + 100
                else if (kcy = 0) and (kby = 2) then
                  result := result + 100;
              end
            end
          end;
        -5:
          begin
            if (b = 3) then
            begin
              if (kbx = 0) and (x = 1) then
                dec(result, AlgCfg.MaticiDama)
              else if (kbx = 7) and (x = 6) then
                dec(result, AlgCfg.MaticiDama)
              else if (kby = 0) and (y = 1) then
                dec(result, AlgCfg.MaticiDama)
              else if (kby = 7) and (y = 6) then
                dec(result, AlgCfg.MaticiDama);
            end
          end;
        -4:
          begin
            if pesci[0, x] + pesci[1, x] = 0 then
              result := result - AlgCfg.veznasloupci
          end;
        -3:
          begin
            if (b = 1) and (c = 1) then
              result := result - AlgCfg.strelci[x, 7 - y]
          end;
        -2:
          begin
            if (b = 1) and (c = 1) then
              result := result - AlgCfg.Jezdci[x, 7 - y]
          end;
        -1:
          begin
            if (b = 1) and (c = 1) then
              result := result - AlgCfg.pesci[x, 7 - y];
            volny := true;
            kryty := false;
            case x of
              0:
                begin
                  if (pos.sch[1, y] = -1) then
                    dec(result, AlgCfg.VedleKolegy);
                  if pos.sch[1, y + 1] = -1 then
                    kryty := true;
                  for i := y - 1 downto 1 do
                    if (pos.sch[0, i] = 1) or (pos.sch[1, i] = 1) then
                    begin
                      volny := false;
                      break
                    end
                end;
              7:
                begin
                  if (pos.sch[6, y] = -1) then
                    dec(result, AlgCfg.VedleKolegy);
                  if pos.sch[6, y + 1] = -1 then
                    kryty := true;
                  for i := y - 1 downto 1 do
                    if (pos.sch[7, i] = 1) or (pos.sch[6, i] = 1) then
                    begin
                      volny := false;
                      break
                    end
                end
            else
              begin
                if (pos.sch[x - 1, y] = -1) or (pos.sch[x + 1, y] = -1) then
                  dec(result, AlgCfg.VedleKolegy);
                if (pos.sch[x + 1, y + 1] = -1) or (pos.sch[x - 1, y + 1] = -1)
                then
                  kryty := true;
                for i := y - 1 downto 1 do
                  if (pos.sch[x - 1, i] = 1) or (pos.sch[x, i] = 1) or
                    (pos.sch[x + 1, i] = 1) then
                  begin
                    volny := false;
                    break
                  end
              end
            end; { od case }
            if volny then
              if kryty then
                result := result - AlgCfg.VolnyAKryty
              else
                result := result - AlgCfg.volny
            else { tj. if not volny }
              if kryty then
                result := result - AlgCfg.kryty;
            if (b > 1) or (c > 1) then
            begin
              if volny then
                if kryty then
                  result := result - AlgCfg.VolniAKrytiPesciVePredu[7 - y]
                else
                  result := result - AlgCfg.VolniPesciVePredu[7 - y]
              else
                { tj. if not volny }
                if kryty then
                  result := result - AlgCfg.KrytiPesciVePredu[7 - y]
                else
                  result := result - AlgCfg.NormalniPesciVePredu[7 - y]
            end
          end; { od èerného pìšce }
        6:
          begin
            if (b = 1) and (c = 1) then
              result := result + AlgCfg.kral[x, y]
            else if (b = 3) then
            begin
              result := result + AlgCfg.KralOdStredu *
                ((abs(7 - 2 * kbx) shr 1) + (abs(7 - 2 * kby) shr 1));
              if (c < 3) then { Jsem matìn }
              begin
                i := abs(kbx - kcx) - 2;
                if i < 0 then
                  i := 0;
                j := abs(kby - kcy) - 2;
                if j < 0 then
                  j := 0;
                result := result + AlgCfg.KralOdKrale * (i + j);
                if (kbx = 7) and (kcx = 5) then
                  result := result - 100
                else if (kbx = 0) and (kcx = 2) then
                  result := result - 100
                else if (kby = 7) and (kcy = 5) then
                  result := result - 100
                else if (kby = 0) and (kcy = 2) then
                  result := result - 100;
              end
            end
          end;
        5:
          begin
            if (c = 3) then
            begin
              if (kcx = 0) and (x = 1) then
                inc(result, AlgCfg.MaticiDama)
              else if (kcx = 7) and (x = 6) then
                inc(result, AlgCfg.MaticiDama)
              else if (kcy = 0) and (y = 1) then
                inc(result, AlgCfg.MaticiDama)
              else if (kcy = 7) and (y = 6) then
                inc(result, AlgCfg.MaticiDama);
            end
          end;
        4:
          begin
            if pesci[0, x] + pesci[1, x] = 0 then
              result := result + AlgCfg.veznasloupci
          end;
        3:
          begin
            if (b = 1) and (c = 1) then
              result := result + AlgCfg.strelci[x, y]
          end;
        2:
          begin
            if (b = 1) and (c = 1) then
              result := result + AlgCfg.Jezdci[x, y]
          end;
        1:
          begin
            if (b = 1) and (c = 1) then
              result := result + AlgCfg.pesci[x, y];
            volny := true;
            kryty := false;
            case x of
              0:
                begin
                  if pos.sch[1, y] = 1 then
                    inc(result, AlgCfg.VedleKolegy);
                  if pos.sch[1, y - 1] = 1 then
                    kryty := true;
                  for i := y + 1 to 6 do
                    if (pos.sch[0, i] = -1) or (pos.sch[1, i] = -1) then
                    begin
                      volny := false;
                      break
                    end
                end;
              7:
                begin
                  if pos.sch[6, y] = 1 then
                    inc(result, AlgCfg.VedleKolegy);
                  if pos.sch[6, y - 1] = 1 then
                    kryty := true;
                  for i := y + 1 to 6 do
                    if (pos.sch[7, i] = -1) or (pos.sch[6, i] = -1) then
                    begin
                      volny := false;
                      break
                    end
                end
            else
              begin
                if (pos.sch[x - 1, y] = 1) or (pos.sch[x + 1, y] = 1) then
                  inc(result, AlgCfg.VedleKolegy);
                if (pos.sch[x - 1, y - 1] = 1) or (pos.sch[x + 1, y - 1] = 1)
                then
                  kryty := true;
                for i := y + 1 to 6 do
                  if (pos.sch[x - 1, i] = -1) or (pos.sch[x, i] = -1) or
                    (pos.sch[x + 1, i] = -1) then
                  begin
                    volny := false;
                    break
                  end
              end
            end; { od case }
            if volny then
              if kryty then
                result := result + AlgCfg.VolnyAKryty
              else
                result := result + AlgCfg.volny
            else { tj. if not volny }
              if kryty then
                result := result + AlgCfg.kryty;
            if (b > 1) or (c > 1) then
            begin
              if volny then
                if kryty then
                  result := result + AlgCfg.VolniAKrytiPesciVePredu[y]
                else
                  result := result + AlgCfg.VolniPesciVePredu[y]
              else { tj. if not volny }
                if kryty then
                  result := result + AlgCfg.KrytiPesciVePredu[y]
                else
                  result := result + AlgCfg.NormalniPesciVePredu[y]
            end
          end { od bílého pìšce }
      end; { konec hlavního cyklu pøes políèka šachovnice }
  { Teï zapoèítám izolované pìšce. }
  { Bílého }
  if pesci[0, 1] = 0 then
    result := result + AlgCfg.Izolant * pesci[0, 0]; { izolant na sloupci a }
  if pesci[0, 6] = 0 then
    result := result + AlgCfg.Izolant * pesci[0, 7]; { izolant na sloupci h }
  for j := 1 to 6 do
    if (pesci[0, j - 1] = 0) and (pesci[0, j + 1] = 0) then
      result := result + AlgCfg.Izolant * pesci[0, j]; { izolant jinde }
  { Èerného }
  if pesci[1, 1] = 0 then
    result := result - AlgCfg.Izolant * pesci[1, 0]; { izolant na sloupci a }
  if pesci[1, 6] = 0 then
    result := result - AlgCfg.Izolant * pesci[1, 7]; { izolant na sloupci h }
  for j := 1 to 6 do
    if (pesci[1, j - 1] = 0) and (pesci[1, j + 1] = 0) then
      result := result - AlgCfg.Izolant * pesci[1, j]; { izolant jinde }
  { Znièené právo rošády }
  if (b = 1) and (c = 1) then
  begin
    if not((mrb in pos.stav.b) or (vrb in pos.stav.b)) then
      result := result + AlgCfg.ZnicenaRosada;
    if not((mrc in pos.stav.b) or (vrc in pos.stav.b)) then
      result := result - AlgCfg.ZnicenaRosada
  end;
  { Dvojice støelcù }
  if figury[0, 3] > 1 then
    result := result + AlgCfg.DvojiceStrelcu;
  if figury[1, 3] > 1 then
    result := result - AlgCfg.DvojiceStrelcu;
  { Materiál }
  bm := 0;
  cm := 0;
  for i := 2 to 5 do
  begin
    pom := figury[0, i]; { Pozor, tady mi pøetékal integer pøi násobení,
      proto ty èachry s pom (to je totiž Longint) }
    pom := pom * AlgCfg.CenyFigur[i];
    bm := bm + pom;
    pom := figury[1, i];
    pom := pom * AlgCfg.CenyFigur[i];
    cm := cm + pom

  end;
  if bm - cm > 2500 then
    cm := cm + cm div 100
  else if cm - bm > 2500 then
    bm := bm + bm div 100;
  { To aby se silnìjší strana snažila mìnit (nikoliv ale pìšce) }
  result := result + (figury[0, 1] - figury[1, 1]) * AlgCfg.CenyFigur[1]
    + bm - cm;
  { Teï dvojpìchy }
  for x := 0 to 7 do
  begin
    if pesci[0, x] > 0 then
      dec(pesci[0, x]);
    if pesci[1, x] > 0 then
      dec(pesci[1, x]);
    result := result + pesci[0, x] * AlgCfg.Dvojpech - pesci[1, x] *
      AlgCfg.Dvojpech;
  end;
end;

end.

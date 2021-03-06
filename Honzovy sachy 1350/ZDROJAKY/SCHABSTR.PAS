unit Schabstr;

interface

uses coty, graphics;

Type
  TschAbstrakt = class
  public
    pozice: tpozice;
    x0, y0: integer; { pozice lev�ho horn�ho rohu �achovnice na canvasu }
    canvas: tcanvas;
    Bily_hraje_nahoru: boolean;
    oznaceno: byte; { Jak� pol��ko je ozna�eno (x+y*16). Je-li 255 => ��dn�. }
    constructor create(fx0, fy0: integer; ncanvas: tcanvas);
    procedure otoc;
    function klik(x, y: integer; var i, j: integer): boolean;
    { Na kanvasu bylo kliknuto na [x,y]. Na jak� pol��ko na �achovnici to
      kliknul a bylo to v�bec na �achovnici ? }
    procedure zobraz_pole(i: byte); { x+y*16 }
    procedure paint;
  end;

procedure kresli_figuru(jakou: shortint; x, y: integer; kam: tcanvas);
procedure kresli_pole(bile, oznacene: boolean; x, y: integer; kam: tcanvas);

implementation

uses form, classes;

procedure kresli_figuru(jakou: shortint; x, y: integer; kam: tcanvas);
{ Nen� vhodn� pro viditeln� canvasy, proto�e kresl� and a pak or masku
  p��mo do kam (ne p�es pomocn� obr�zek v pam�ti), tak�e to trochu blikne. }
var
  x0: integer;
begin
  x0 := (abs(jakou) - 1) * 36;
  kam.copymode := cmSrcAnd;
  kam.copyrect(rect(x, y, x + 36, y + 36), form1.figuryimg.canvas,
    rect(x0, 0, x0 + 36, 36));
  kam.copymode := cmSrcPaint;
  if jakou > 0 then
    kam.copyrect(rect(x, y, x + 36, y + 36), form1.figuryimg.canvas,
      rect(x0, 36, x0 + 35, 71))
  else
    kam.copyrect(rect(x, y, x + 36, y + 36), form1.figuryimg.canvas,
      rect(x0, 72, x0 + 36, 108))
    { Vypad� to asi nejasn�, tat�e vysv�tlen�:
      v TImage form1.figuryimg m�m obr�zek 216*108 bod� vytvo�en� z 6*3
      mal�ch obr�zk� v n�sleduj�c� struktu�e
      p�ec jezdec st�elec v� d�ma kr�l
      and maska
      or maska b�l�ho
      or maska �ern�ho

      a proto�e jsem si vhodn� zvolil konstanty pro figury (-6 a� -1 �ern�
      a 1 a� 6 b�l�), vyhnul jsem se odporn�mu "case jakou of ..."
    }
end;

procedure kresli_pole(bile, oznacene: boolean; x, y: integer; kam: tcanvas);
var
  x0: integer;
begin
  x0 := 0;
  if not bile then
    inc(x0, 40);
  if oznacene then
    inc(x0, 80);
  kam.copymode := cmSrcCopy;
  kam.copyrect(rect(x, y, x + 40, y + 40), form1.poleimg.canvas,
    rect(x0, 0, x0 + 40, 40))
end;

constructor TschAbstrakt.create(fx0, fy0: integer; ncanvas: tcanvas);
begin
  inherited create;
  pozice := zakladni_postaveni;
  oznaceno := 255; { nen� ozna�eno ��dn� pol��ko }
  x0 := fx0;
  y0 := fy0;
  canvas := ncanvas;
  Bily_hraje_nahoru := true;
end;

procedure TschAbstrakt.otoc;
begin
  Bily_hraje_nahoru := not Bily_hraje_nahoru;
  paint;
end;

function TschAbstrakt.klik(x, y: integer; var i, j: integer): boolean;
begin
  if (x >= x0) and (y >= y0) and (x < 320 + x0) and (y < 320 + y0) then
  begin { kliknul na �achovnici }
    i := (x - x0) div 40;
    j := (y - y0) div 40;
    if Bily_hraje_nahoru then
      j := 7 - j
    else
      i := 7 - i;
    result := true
  end
  else
    result := false
end;

procedure TschAbstrakt.zobraz_pole(i: byte);
var
  pompole: tbitmap;
  k, l: byte;
begin
  pompole := tbitmap.create;
  pompole.width := 40;
  pompole.height := 40;
  k := i and 15;
  l := i shr 4;
  if oznaceno = i then
    kresli_pole(odd(k + l), true, 0, 0, pompole.canvas)
  else
    kresli_pole(odd(k + l), false, 0, 0, pompole.canvas);
  kresli_figuru(pozice.sch[k, l], 2, 2, pompole.canvas);
  if Bily_hraje_nahoru then
    canvas.draw(x0 + 40 * k, y0 + 40 * (7 - l), pompole)
  else
    canvas.draw(x0 + 40 * (7 - k), y0 + 40 * l, pompole);
  pompole.free;
end;

procedure TschAbstrakt.paint;
var
  i, j: byte;
begin
  for i := 0 to 7 do
    for j := 0 to 7 do
      zobraz_pole(i + j shl 4)
end;

end.

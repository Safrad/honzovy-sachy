unit Schabstr;
interface    
 uses coty,graphics;
 Type
  TschAbstrakt = class
   public
   pozice:tpozice;
   x0,y0:integer; {pozice levého horního rohu šachovnice na canvasu}
   canvas:tcanvas;
   Bily_hraje_nahoru:boolean;
   oznaceno:byte; {Jaké políèko je oznaèeno (x+y*16). Je-li 255 => ádné.}
   constructor create(fx0,fy0:integer;ncanvas:tcanvas);
   procedure otoc;
   function klik(x,y:integer;var i,j:integer):boolean;
    {Na kanvasu bylo kliknuto na [x,y]. Na jaké políèko na šachovnici to
     kliknul a bylo to vùbec na šachovnici ? }
   procedure zobraz_pole(i:byte);{x+y*16}
   procedure paint;
  end;
 procedure kresli_figuru(jakou:shortint; x,y:integer; kam:tcanvas);
 procedure kresli_pole(bile, oznacene:boolean; x,y:integer; kam:tcanvas);
implementation
uses form,classes;
procedure kresli_figuru(jakou:shortint; x,y:integer; kam:tcanvas);
{Není vhodné pro viditelné canvasy, protoe kreslí and a pak or masku
pøímo do kam (ne pøes pomocnı obrázek v pamìti), take to trochu blikne.}
 var x0:integer;
 begin
  x0:=(abs(jakou)-1)*36;
  kam.copymode:=cmSrcAnd;
  kam.copyrect(rect(x,y,x+36,y+36),form1.figuryimg.canvas,rect(x0,0,x0+36,36));
  kam.copymode:=cmSrcPaint;
  if jakou>0 then  kam.copyrect(rect(x,y,x+36,y+36),
                   form1.figuryimg.canvas,rect(x0,36,x0+35,71)) else
  kam.copyrect(rect(x,y,x+36,y+36),form1.figuryimg.canvas,rect(x0,72,x0+36,108))
{Vypadá to asi nejasnì, tate vysvìtlení:
  v TImage form1.figuryimg mám obrázek 216*108 bodù vytvoøenı z 6*3
  malıch obrázkù v následující struktuøe
                     pìšec jezdec støelec vì dáma král
   and maska
   or maska bílého
   or maska èerného

   a protoe jsem si vhodnì zvolil konstanty pro figury (-6 a -1 èernı
   a 1 a 6 bílı), vyhnul jsem se odpornému "case jakou of ..."
   }
 end;
procedure kresli_pole(bile, oznacene:boolean; x,y:integer; kam:tcanvas);
var x0:integer;
 begin
  x0:=0;
  if not bile then inc(x0,40);
  if oznacene then inc(x0,80);
  kam.copymode:=cmSrcCopy;
  kam.copyrect(rect(x,y,x+40,y+40),form1.poleimg.canvas,rect(x0,0,x0+40,40))
 end;
 constructor TSchAbstrakt.create(fx0,fy0:integer;ncanvas:tcanvas);
  begin
   inherited create;
   pozice:=zakladni_postaveni;
   oznaceno:=255; {není oznaèeno ádné políèko}
   x0:=fx0;
   y0:=fy0;
   Canvas:=nCanvas;
   bily_hraje_nahoru:=true;
  end;
 procedure TSchAbstrakt.otoc;
  begin
   bily_hraje_nahoru:=not bily_hraje_nahoru; paint;
  end;
 function TSchAbstrakt.Klik(x,y:integer;var i,j:integer):boolean;
  begin
   if (X>=X0) and (Y>=Y0) and (X<320+X0) and (Y<320+Y0) then
    begin {kliknul na šachovnici}
     i:=(X-X0) div 40;
     j:=(Y-Y0) div 40;
     if bily_hraje_nahoru then j:=7-j else i:=7-i;
     result:=true
    end
   else result:=false
  end;
 procedure TSchAbstrakt.zobraz_pole(i:byte);
 var pompole:tbitmap;
     k,l:byte;
 begin
  pompole:=tbitmap.create;
  pompole.width:=40;
  pompole.height:=40;
  k:=i and 15;
  l:=i shr 4;
  if oznaceno=i then
    kresli_pole(odd(k+l),true,0,0,pompole.canvas)
   else
   kresli_pole(odd(k+l),false,0,0,pompole.canvas);
   kresli_figuru(pozice.sch[k,l],2,2,pompole.canvas);
   if bily_hraje_nahoru then
   canvas.draw(x0+40*k,y0+40*(7-l),pompole)
  else
   canvas.draw(x0+40*(7-k),y0+40*l,pompole);
  pompole.free;
 end;
procedure TSchAbstrakt.paint;
 var i,j:byte;
 begin
  for i:=0 to 7 do for j:=0 to 7 do zobraz_pole(i+j shl 4)
 end;
end.

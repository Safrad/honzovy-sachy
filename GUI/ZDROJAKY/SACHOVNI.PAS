unit Sachovni;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, {A teï moje knihovny}CoTy, Myslitel, SchAbstr;
type
  THrac=(clovek,pocitac);
  TSchStav=(normal,KnihEdit,KnihEditZProhl,KnihProhl);
  Tsachovnice = class(TSchAbstrakt)
  private
   fbily,fcerny:thrac;{pomocné promìnné pro proprty}
   CisloProhlizenePozice:longint;
   JmenoSouboru:string80;
   tahy:ttahy;    {sem si ukládám pøípustné tahy (napø. pro kontrolu hráèe)}
   procedure setbily(hodnota:thrac);
   procedure setcerny(hodnota:thrac);
   Procedure NactiAlgCfg(b:boolean);
  public
  cinkat:boolean;
  partie:ppartie;
  StaraPozice:TPozice;
  Stav:TSchStav;
  TahUzivatele:ttah1;{sem si uložím tah hráèe po jeho zadání}
  CernyAlg,BilyAlg:TMyslitel;
property bily:thrac read fbily write setbily;
property cerny:thrac read fcerny write setcerny;
   constructor create(fx0,fy0:integer;nCanvas:TCanvas);
   procedure prerus;
{Pøeruší partii poèítaè - poèítaè tím, že nastaví èlovìka jako bytost
 hrající za barvu, která teï není na tahu. Program tedy ještì dopoèítá
 a zahraje právì promýšlený tah.}
   procedure HrajTed;{Pøinutí algoritmus okamžitì táhnout.}
   function HrajeClovek:boolean;
   procedure pripravtah;
   procedure ProgrameTahni;
{Uživatel zadal pøíkaz algotitmu, aby táhnul místo nìho}
   procedure MouseButtonDown(Button: TMouseButton;Shift: TShiftState;
                             X, Y: Integer);
   procedure tahni_a_zobraz(t1:ttah1);
   {Zatáhne v pozici tah t1 a zobrazí ho. Modifikuje pouze pozici.}
   procedure tahni_zpet_a_zobraz(t2:ttah2);
   {Vrátí v pozici tah t2 a zobrazí ho. Modifikuje pouze pozici.}
   procedure BeznyTah(t1:ttah1);
    {Zatáhne, zobrazí, pøípadnì umaže konec partie, pøidá se na konec partie,
     vyvolá další posláním zprávy pøípravu dalšího tahu}
   procedure zpet;
    {Vrátí poslední tah}
   procedure znovu;
    {vrátí vrácení tahu}
   procedure predvedvrahy;
   procedure predvedrychle;
   procedure predvedtahy(var t:ttahy);
   procedure predvedhp;
   destructor destroy;override;
   procedure nova_hra(var nPozice:TPozice);
   procedure uloz;
   procedure ulozjako;
   procedure otevri;
 {  procedure test;ladìní}
   procedure ZastavMysleniDopredu; {Zastaví myšlení dopøedu (návrat hned)}
   procedure nastavE2E4;
   procedure PridejPoziciDoKnihovny;
   procedure OKPoziciDoKnihovny;
   procedure PridejPartiiDoKnihovny;
   procedure ProhledniKnihovnu;
   procedure SmazpozicivKnihovne;
   procedure ProhledniPozici(dn:LongInt);
  end;
{Globální procedury}
 procedure cekej(ms:longint);
 function TTah1ToStr(tah1:ttah1;var kde:tpozice):string10;
 procedure UlozPartii(JmenoSouboru:string80;Partie:ppartie;Pozice:tpozice);
implementation
uses form,rutiny,seznam,promena,rychle,ohodnoc,uschedit,uknih,
     stdctrls, uPPDLG, Partiar, VypForm;
procedure PosliWMDokMysDop;far;
begin
 postmessage(form1.handle,wm_DokMysDop,0,0);
end;
const nazvy:array[1..6]of char=('P','J','S','V','D','K');
function PoleToStr(x,y:byte):string2;
  begin
   result:=char(byte('a')+x)+char(byte('1')+y)
  end;
function jednoznacnost(tah1:ttah1;var pozice:tpozice):byte;
{vrací  0 až 3
 pøíklad chci napsat krátkou notací De1-e2
       0 staèí    De2
       1 je tøeba Dee2
       2 je tøeba D1e2
       3 je tøeba De1e2
  v pøípadì 1, 2 a 3 by nebyla žádná vyšší možnost jednoznaèná (víc dam)
       }
  var tahy:ttahy;
   figura,x,y,i:shortint;
   celkem,radka,sloupec:boolean;
  begin
   rychle.naleztahy(pozice,tahy);
   x:=tah1.p1 and 15;
   y:=tah1.p1 shr 4;
   figura:=pozice.sch[x,y];
   celkem:=false;radka:=false;sloupec:=false;
   for i:=1 to tahy.poctah do
    if (tahy.t[i].p1<>tah1.p1)and(tahy.t[i].p2=tah1.p2)and
     (pozice.sch[tahy.t[i].p1 and 15,tahy.t[i].p1 shr 4]=figura)
     then {tah jinou figurou téhož typu na stejné pole}
       begin
        celkem:=true;
        if (tahy.t[i].p1 and 15)=x then sloupec:=true;
        if (tahy.t[i].p1 shr 4)=y then radka:=true;
       end;
   if not celkem then result:=0 else
    if not sloupec then result:=1 else
     if not radka then result:=2 else
      result:=3
  end;
function TTah1ToStr(tah1:ttah1;var kde:tpozice):string10;
 var x1,y1,x2,y2:byte;
     t2:ttah2;
     jednoz:byte;
 begin
  x1:=tah1.p1 and 15;
  y1:=tah1.p1 shr 4;
  x2:=tah1.p2 and 15;
  y2:=tah1.p2 shr 4;
  result:='';
  case abs(kde.sch[x1,y1]) of
   1:begin
      if x1=x2 then result:=PoleToStr(x2,y2)
       else
        begin
         result:=char(byte('a')+x1)+'x'+PoleToStr(x2,y2);
         if kde.sch[x2,y2]=0 then result:=result+' e.p.'
        end;
       if tah1.promena<>0 then result:=result+nazvy[abs(tah1.promena)]
     end;
2..5:begin
      result:=nazvy[abs(kde.sch[x1,y1])];
      jednoz:=jednoznacnost(tah1,kde);
      case jednoz of
       0:;
       1:result:=result+char(byte('a')+x1);
       2:result:=result+char(byte('1')+y1);
       3:result:=result+PoleToStr(x1,y1);
      end;
      if kde.sch[x2,y2]<>0 then result:=result+'x';
      result:=result+PoleToStr(x2,y2)
     end;
   6:begin
      if abs(x1-x2)>1 then
       if x2=2 then result:='O-O-O' else result:='O-O'
      else
       begin
        result:='K';
        if kde.sch[x2,y2]<>0 then result:=result+'x';
        result:=result+PoleToStr(x2,y2);
       end
     end;
    end;
  doplntah(tah1,kde,t2);
  tahni(kde,tah1);
  if sach(kde.sch,hb in kde.stav.b) then result:=result+'+';
  tahni_zpet(kde,t2)
 end;
function CharToFgr(c:char):shortint;
 begin
  case c of
   'P':result:=1;
   'J':result:=2;
   'S':result:=3;
   'V':result:=4;
   'D':result:=5;
   'K':result:=6;
  else result:=0
 end
end;
const
 VPoradku=0;
 NejdeOtevrit=1;
 FatalniChyba=2;
 VelkaChyba=3;
 ChybaPostaveni=4;
 ChybnyTah=5;
 NejednoznacnyTah=6;
ChybyOtevreni:array[1..6] of pchar=
('Soubor nejde otevøít.',
'Hned první øádek souboru je chybný. Nejspíš se pokoušíte otevøít soubor neznámého typu.',
'Soubor je narušený. Zaèíná správnì, ale obsahuje chyby.',
'Poèáteèní postavení uložené partie je chybné.',
'Uložená partie obsahuje nepøípustné tahy',
'Uložená partie obsahuje nejednoznaèné tahy'
);
{!!!!!!!!!!!!!!!!!!!!!!!!!!!! OTEVRIPARTII !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
function OtevriPartii(filename:String80;var Pozice:TPozice;var Partie:PPartie):integer;
{Naète ze souboru Pozici a Partii. Vrací VPoradku nebo nìco jiného. V druhém
 pøípadì po sobì smaže Partii.}
 var f:textfile;
 radek:string;
 function NactiTahy:integer;
  procedure SpravnyTah(tah1:ttah1);
   var pom:ppartie;
   begin
    new(pom);
    partie^.r:=pom;
    pom^.r:=nil;
    pom^.l:=partie;
    doplnTah(tah1,pozice,pom^.t2);
    tahni(pozice,tah1);
    partie:=pom;
   end; {správný tah}
  function PrectiTah(i:integer{pozice v radku}):integer{Chybový kód};
   var p1,p2,promena:shortint;
   fgr:shortint;
   tahy:ttahy;
   tah1:ttah1;
   pocet:integer;
   label vch,ChT,NT,VP;
   begin
    rychle.naleztahy(pozice,tahy);
    if (radek[i]>='a') and (radek[i]<='h') then
     begin {Tah pìšcem}
      if radek[i+1]='x' then
       begin {Braní pìšcem}
        p1:=byte(radek[i])-byte('a');
        inc(i,2);
        if length(radek)<i+1 then goto vch;
        if (radek[i]>='a') and (radek[i]<='h') and
           (radek[i+1]>='1') and (radek[i+1]<='8') then
         begin
          p2:=byte(radek[i])-byte('a')+(byte(radek[i+1])-byte('1'))shl 4;
          if hb in pozice.stav.b then
            p1:=p1+(byte(radek[i+1])-byte('1')-1)shl 4
          else
            p1:=p1+(byte(radek[i+1])-byte('1')+1)shl 4;
         end else goto vch; {Chyba braní}
       end
      else {není tam "x"}
       if (byte(radek[i+1])>=byte('1')) and (byte(radek[i+1])<=byte('8')) then
        begin {tah pìšcem, který není braní}
         p2:=byte(radek[i])-byte('a')+(byte(radek[i+1])-byte('1'))shl 4;
         if hb in pozice.stav.b then p1:=p2-16 else p1:=p2+16;
         if pozice.sch[p1 and 15,p1 shr 4]=0 then {pìšcem o 2}
         if hb in pozice.stav.b then dec(p1,16) else inc(p1,16);
        end{od tahu pìšcem, který není braní}
       else {ani braní, ani nebraní (napø. "a9" nebo "af")}goto vch;
      if (p2 shr 4 = 0) or (p2 shr 4 = 7) then {promìna}
       begin
        inc(i,2);
        if length(radek)<i then goto vch;
        promena:=CharToFgr(radek[i]);
        if not( hb in pozice.stav.b) then promena:=-promena;
        if promena=0 then goto vch;
       end
      else promena:=0;
      tah1.promena:=promena;
      tah1.p1:=p1;
      tah1.p2:=p2;
      if jetam(tah1,tahy) then goto VP else goto ChT;
     end
    else {není to tah pìšcem}
     begin
      if radek[i]='O' then
       begin {rošáda}
        tah1.promena:=0;
        if copy(radek,i,5)='O-O-O' then
         begin
          if hb in pozice.stav.b then
           begin
            tah1.p1:=4+0 shl 4;
            tah1.p2:=2+0 shl 4;
           end
          else
           begin
            tah1.p1:=4+7 shl 4;
            tah1.p2:=2+7 shl 4;
           end
         end else
        if copy(radek,i,3)='O-O' then
         begin
          if hb in pozice.stav.b then
           begin
            tah1.p1:=4+0 shl 4;
            tah1.p2:=6+0 shl 4;
           end
          else
           begin
            tah1.p1:=4+7 shl 4;
            tah1.p2:=6+7 shl 4;
           end
         end
        else goto vch; {zaèíná to na "O", ale není to ani "O-O" ani "O-O-O"}
        if jetam(tah1,tahy) then goto VP else goto Cht;
       end
      else {není to rošáda}
       begin
        fgr:=CharToFgr(radek[i]);
        if fgr<2 then goto vch;
        if not(hb in pozice.stav.b) then fgr:=-fgr;
        inc(i);
        if (radek[i]>='1') and (radek[i]<='8') then
         begin {Notace typu D8a1 nebo D8xa1}
          p1:=byte(radek[i])-byte('1');
          if radek[i+1]='x' then inc(i);
          p2:=byte(radek[i+1])-byte('a')+(byte(radek[i+2])-byte('1')) shl 4;
          pocet:=jetam4(p2,p1,fgr,tahy,pozice,tah1);
          case pocet of
           0:goto ChT;
           1:goto VP;
           else goto NT;
          end
         end else
       begin
        if (radek[i]='x') then inc(i);
        if (radek[i]>='a') and (radek[i]<='h') then
         begin {Notace typu Da1 nebo Dha1 nebo Dh8a1 nebo Dhxa1 nebo Dh8xa1}
         {a nebo i Dxa1, to 'x' jsem už ale pøeskoèil}
          if (radek[i+1]>='a') and (radek[i+1]<='h') or (radek[i+1]='x')then
           begin {Notace typu Dha1 nebo Dhxa1}
            p1:=byte(radek[i])-byte('a');
            if radek[i+1]='x' then inc(i);
            p2:=byte(radek[i+1])-byte('a')+(byte(radek[i+2])-byte('1')) shl 4;
            pocet:=jetam3(p2,p1,fgr,tahy,pozice,tah1);
            case pocet of
             0:goto ChT;
             1:goto VP;
             else goto NT;
            end{od Case}
           end{od Notace typu Dha1 nebo Dhxa1}
          else
           if (radek[i+1]>='1') and (radek[i+1]<='8') then
            begin {Notace typu Da1 nebo Dh8a1 nebo i Dxa1 nebo Dh8xa1}
             if (length(radek)>=i+2) and (radek[i+2]>='a') and (radek[i+2]<='h')
                or (length(radek)>=i+3) and (radek[i+3]>='a') and (radek[i+3]<='h')
                 and (radek[i+2]='x')  then
              begin {Notace typu Dh8a1 nebo Dh8xa1}
               tah1.p1:=byte(radek[i])-byte('a')+(byte(radek[i+1])-byte('1'))shl 4;
                 if (radek[i+2]='x') then inc(i);
               tah1.p2:=byte(radek[i+2])-byte('a')+(byte(radek[i+3])-byte('1'))shl 4;
                tah1.promena:=0;
               if jetam(tah1,tahy) then goto VP else goto Cht
              end {od Notace typu Dh8a1}
             else
              begin {Notace typu Da1 nebo i Dxa1, to x je ale už pøeskoèené }
               p2:=byte(radek[i])-byte('a')+(byte(radek[i+1])-byte('1')) shl 4;
               pocet:=jetam2(p2,fgr,tahy,pozice,tah1);
               case pocet of
                0:goto ChT;
                1:goto VP;
                else goto NT;
               end {od case}
              end {od Notace typu Da1}
            end {od Notace typu Da1 nebo Dh8a1}
          else goto vch;
         end {od Notace typu Da1 nebo Dha1 nebo Dh8a1 nebo Dhxa1 nebo Dh8xa1}
          else goto vch;
         end
       end
     end;
{$define ladim1}
{$ifdef ladim1}
ZpravovaKrabice('Chyba programu','ladim1',mb_ok);
{$endif}
{$undef ladim1}
    VP:;
    spravnytah(Tah1);result:=VPoradku;exit;
    vch:;
    doneppartie(partie);
    result:=VelkaChyba;exit;
    ChT:;
    doneppartie(partie);
    result:=ChybnyTah;exit;
    NT:;
    doneppartie(partie);
    result:=NejednoznacnyTah;exit;
   end;{PrectiTah}
  var stav,i,chyba:integer;
  label ch,konec;
  begin
   stav:=0;
   initppartie(partie);
   while not seekeof(f) do
    begin
     readln(f,radek);
     case stav of
      0:if radek<>'Prùbìh partie:' then
         begin ch:;result:=velkachyba; exit end
        else if hb in pozice.stav.b then stav:=2 else stav:=1;
      1:{Ètu první osamocený tah èerného (èerný zaèínal)}
        begin
         i:=pos('1...',radek);
         if i=0 then goto konec;
         if (length(radek)<6+i) then goto ch;
         chyba:=PrectiTah(i+5);
         if Chyba <> VPoradku then begin result:=chyba; exit end;
         stav:=2
        end;
      2:{Ètu tah bílého a èerného}
        begin
         i:=pos('.',radek);
         if i=0 then goto konec;
         if(length(radek)<3+i) then goto ch;
         chyba:=PrectiTah(i+2);
         if Chyba <> VPoradku then begin result:=chyba; exit end;
         i:=pos(',',radek);
         if i=0 then goto konec;
         if(length(radek)<3+i) then goto ch;
         chyba:=PrectiTah(i+2);
         if Chyba <> VPoradku then begin result:=chyba; exit end;
        end;
     end;
    end;
   konec:;
   result:=VPoradku;
  end; {NactiTahy}
 function NactiPostaveni:integer;{lokální}
  function NactiFigury(Bile:boolean):integer;{Ještì lokálnìjší}
   var i,fgr:integer;
   label VCH;
   begin
    i:=0;
    while i<length(radek)-3 do {nebo se naète i #13#10}
     begin
      inc(i);
      if radek[i]<>' ' then
       begin
        case radek[i] of
         'P','J','S','V','D','K':
           begin
            case radek[i] of
             'P':fgr:=1;
             'J':fgr:=2;
             'S':fgr:=3;
             'V':fgr:=4;
             'D':fgr:=5;
             'K':fgr:=6;
            end;
            if not bile then fgr:=-fgr;
            inc(i);
            if (byte(radek[i])>=byte('a')) and (byte(radek[i])<=byte('h'))
            and(byte(radek[i+1])>=byte('1')) and (byte(radek[i+2])<=byte('8'))
             then
              begin
               pozice.sch[byte(radek[i])-byte('a'),byte(radek[i+1])-byte('1')]:=fgr;
               inc(i,2);
              end
             else goto VCH;
           end;
          else begin VCH:; result:=VelkaChyba;exit end
         end {od vnìjšího case}
       end
     end;
    result:=VPoradku;
   end;
  var stav,ch:integer;
  label VCH;
  begin
   stav:=0;
   fillchar(pozice,sizeof(pozice),0);
   pozice.stav.mimoch:=ne_mimochodem;
   while not seekeof(f) and (stav<10)do
    begin
     readln(f,radek);
     case stav of
       0:if radek<>'Poèáteèní postavení:' then
            begin result:=fatalnichyba;exit end else stav:=1;
       1:if radek<>'Bílý:'then
            begin VCH:;result:=VelkaChyba;exit end else stav:=2;
       2:begin ch:=NactiFigury(true); if ch<>VPoradku then
           begin result:=ch;exit end else stav:=3;
         end;
       3:if pos('Malá rošáda',radek)=0 then goto VCH else
          begin
           if pos('Ano',radek)>0 then pozice.stav.b:=pozice.stav.b+[mrb];
           stav:=4;
          end;
       4:if pos('Velká rošáda',radek)=0 then goto VCH else
          begin
           if pos('Ano',radek)>0 then pozice.stav.b:=pozice.stav.b+[vrb];
           stav:=5;
          end;
       5:if radek<>'Èerný:'then
            begin result:=VelkaChyba;exit end else stav:=6;
       6:begin ch:=NactiFigury(false); if ch<>VPoradku then
           begin result:=ch;exit end else stav:=7;
         end;
       7:if pos('Malá rošáda',radek)=0 then goto VCH else
          begin
           if pos('Ano',radek)>0 then pozice.stav.b:=pozice.stav.b+[mrc];
           stav:=8;
          end;
       8:if pos('Velká rošáda',radek)=0 then goto VCH else
          begin
           if pos('Ano',radek)>0 then pozice.stav.b:=pozice.stav.b+[vrc];
           stav:=9;
          end;
       9:if pos('Na tahu je:',radek)=0 then goto VCH else
          begin
           if pos('Bílý',radek)>0 then pozice.stav.b:=pozice.stav.b+[hb];
           stav:=10;
          end;
     end  {Od case}
    end; {Od while cyklu}
   result:=VPoradku;
  end;{Od NactiPostaveni}
 var chyba:integer;
 label ch;
 begin
  assign(f,filename);
  {$I-}
  reset(f);
  {$I+}
  if ioresult<>0 then begin result:=NejdeOtevrit;exit end;
  chyba:=NactiPostaveni;
  if Chyba<>VPoradku then begin ch:;result:=chyba;exit end;
  chyba:=NactiTahy;
  if Chyba<>VPoradku then goto ch;
  close(f);
  while partie^.l<>nil do
   begin
    tahni_zpet(pozice,partie^.t2);
    partie:=partie^.l
   end;
  result:=VPoradku;
 end;
procedure UlozPartii(JmenoSouboru:string80;Partie:ppartie;Pozice:tpozice);
  procedure NaZacatek(var Partie:ppartie; var Pozice: tpozice);
   begin
    while partie^.l<>nil do
     begin
      tahni_zpet(pozice,partie^.t2);
      partie:=partie^.l
     end
   end;
  var f:textfile;
  i,x,y,cislo:integer;
  t1:ttah1;
 begin
  NaZacatek(Partie,Pozice);
  assign(f,JmenoSouboru);
  rewrite(f);
  writeln(f,'Poèáteèní postavení:');
  writeln(f,'Bílý:');
  for i:=1 to 6 do
   for x:=0 to 7 do
    for y:=0 to 7 do
     if pozice.sch[x,y]=i then write(f,nazvy[i]+PoleToStr(x,y)+' ');
  writeln(f);
  write(f,'Malá rošáda: ');if mrb in pozice.stav.b then writeln(f,'Ano')
   else writeln(f,'Ne');
  write(f,'Velká rošáda: ');if vrb in pozice.stav.b then writeln(f,'Ano')
   else writeln(f,'Ne');
  writeln(f,'Èerný:');
  for i:=1 to 6 do
   for x:=0 to 7 do
    for y:=0 to 7 do
     if pozice.sch[x,y]=-i then write(f,nazvy[i]+PoleToStr(x,y)+' ');
  writeln(f);
  write(f,'Malá rošáda: ');if mrc in pozice.stav.b then writeln(f,'Ano')
   else writeln(f,'Ne');
  write(f,'Velká rošáda: ');if vrc in pozice.stav.b then writeln(f,'Ano')
   else writeln(f,'Ne');
  write(f,'Na tahu je: ');
  if hb in pozice.stav.b then writeln(f,'Bílý') else writeln(f,'Èerný');
  writeln(f,'Prùbìh partie:');
  partie:=partie^.r;
  cislo:=1;
  if not(hb in pozice.stav.b) then
   begin
    osekejtah(partie^.t2,t1);
    writeln(f,'     1... '+TTah1ToStr(t1,pozice));
    tahni(pozice,t1);
    partie:=partie^.r;
    inc(cislo);
   end;
  while partie<>nil do
   begin
    osekejtah(partie^.t2,t1);
    write(f,inttostr(cislo)+'. '+TTah1ToStr(t1,Pozice));
    tahni(pozice,t1);
    partie:=partie^.r;
    if partie<>nil then
     begin
      osekejtah(partie^.t2,t1);
      writeln(f,', '+TTah1ToStr(t1,Pozice));
      tahni(pozice,t1);
      partie:=partie^.r;
      inc(cislo);
     end
   end;
  close(f)
 end;
procedure zatahl(tah1:ttah1);far;
 begin
  postmessage(form1.handle,wm_hrajtah,0,TTah1ToLongInt(tah1));
 end;
procedure cekej(ms:longint);
 var t:longint;
 begin
  t:=gettickcount;
  while gettickcount<t+ms do;
 end;
Procedure TSachovnice.NactiAlgCfg(b:boolean);
 var f:file;w:word;
 begin
  if b then assign(f,JS_BAlgCfg) else assign(f,JS_CAlgCfg);
  {$I-}
  reset(f,1);
  {$I+}
  if IOResult<>0 then
   if b then BilyAlg.AlgCfg:=DefAlgCfg else CernyAlg.AlgCfg:=DefAlgCfg
  else
   begin
    if b then BlockRead(f,BilyAlg.AlgCfg,sizeof(TAlgCfg),w) else
     BlockRead(f,CernyAlg.AlgCfg,sizeof(TAlgCfg),w);
    if w<>sizeof(TAlgCfg) then
     begin
      if b then
       begin
ZpravovaKrabice('Budou použity standardní hodnoty nastavení',
 'Chyba souboru '+JS_BAlgCfg,mb_ok or mb_iconstop);
        BilyAlg.AlgCfg:=DefAlgCfg
       end
      else
       begin
ZpravovaKrabice('Budou použity standardní hodnoty nastavení',
 'Chyba souboru '+JS_CAlgCfg,mb_ok or mb_iconstop);
        CernyAlg.AlgCfg:=DefAlgCfg
       end
     end
   end
 end;
constructor TSachovnice.create(fx0,fy0:integer;nCanvas:TCanvas);
 var b:boolean;
 begin
  inherited create(fx0,fy0,nCanvas);
  cinkat:=true;
  Stav:=normal;
  Knihovna:=TKnihovna.create;
  BilyAlg:=TMyslitel.Create(Zatahl);
  CernyAlg:=TMyslitel.Create(Zatahl);
  for b:=false to true do NactiAlgCfg(b);
  initppartie(partie);
  JmenoSouboru:='';
  bily_hraje_nahoru:=true;
  bily:=clovek;
  fcerny:=pocitac;
  nastavE2E4;
  postmessage(form1.handle,wm_pripravtah,0,0);
 end;
procedure TSachovnice.predvedhp;
 var l:longint;
  s:string[20];
 begin
  if hb in pozice.stav.b then l:=HodnotaPozice(pozice,BilyAlg.AlgCfg) else
   l:=HodnotaPozice(pozice,CernyAlg.AlgCfg);
  s:=inttostr(l)+#0;
  ZpravovaKrabice(@(s[1]),'',mb_ok)
 end;
procedure TSachovnice.predvedtahy(var t:ttahy);
 var i:integer;t2:ttah2;
 begin
  for i:=1 to t.poctah do
   begin
    doplntah(t.t[i],pozice,t2);
    tahni_a_zobraz(t.t[i]);
    cekej(500);
    tahni_zpet_a_zobraz(t2);
    cekej(300);
   end
 end;
procedure TSachovnice.predvedvrahy;
 var t:ttahy;
 begin
  rychle.nalezvrahy(pozice,t);
  predvedtahy(t)
 end;
procedure TSachovnice.predvedrychle;
 var t:ttahy;
 begin
  rychle.naleztahy(pozice,t);
  predvedtahy(t)
 end;
function TSachovnice.HrajeClovek:boolean;
 begin
  if (hb in pozice.stav.b) and (bily=clovek) or
  not(hb in pozice.stav.b) and (cerny=clovek) then
   result:=true else result:=false
 end;
procedure TSachovnice.setbily(hodnota:thrac);
 begin
  fbily:=hodnota;
  if fbily=clovek then
   begin
    form1.lovk1.checked:=true;
    form1.pota1.checked:=false;
    form1.Pttahlovk1.enabled:=false;
   end else
   begin
    form1.lovk1.checked:=false;
    form1.pota1.checked:=true;
    if fcerny=pocitac then form1.Pttahlovk1.enabled:=true;
   end;
  nastavE2E4;
 end;
procedure TSachovnice.setcerny(hodnota:thrac);
 begin
  fcerny:=hodnota;
  if fcerny=clovek then
   begin
    form1.lovk2.checked:=true;
    form1.pota2.checked:=false;
    form1.Pttahlovk1.enabled:=false;
   end else
   begin
    form1.lovk2.checked:=false;
    form1.pota2.checked:=true;
    if fbily=pocitac then form1.Pttahlovk1.enabled:=true;
   end;
   nastavE2E4;
 end;
procedure TSachovnice.prerus;
 begin
  if (bily=clovek) or (cerny=clovek) then  ZpravovaKrabice(
  'procedure tsachovnice.prerus','Chyba programu !',mb_ok or mb_iconhand)
   else
    if hb in pozice.stav.b then cerny:=clovek else bily:=clovek;
 end;
procedure TSachovnice.ProgrameTahni;
 begin
  if hb in pozice.stav.b then
    begin bily:=pocitac; cerny:=clovek end else
    begin bily:=clovek; cerny:=pocitac end;
  postmessage(form1.handle,wm_pripravtah,0,0);
 end;
procedure TSachovnice.pripravtah;
 var KnihStrom:PKnihStrom;
 begin
  if remis(pozice,partie) then
   begin
    form1.caption:=FormCaption+' - Remíza';
    ZpravovaKrabice('Remíza','Partie skonèila',mb_ok);
    tahy.poctah:=0
   end
   else
   begin
    {rutiny}rychle.naleztahy(pozice,tahy);
    if tahy.poctah=0 then
     begin
      {ZastavMysleniDopredu;}
      if sach(pozice.sch,true) then
       begin
        form1.caption:=FormCaption+' - Èerný vyhrál';
        ZpravovaKrabice('Èerný vyhrál','Partie skonèila',mb_ok);
       end
        else
         begin
          form1.caption:=FormCaption+' - Bílý vyhrál';
          ZpravovaKrabice('Bílý vyhrál','Partie skonèila',mb_ok);
         end
     end else
     begin
      {Tedy partie neskonèila}
      Knihovna.DejData(Pozice,KnihStrom);
      if KnihStrom=nil then form1.caption:=FormCaption
       else form1.caption:=FormCaption+' - '+KnihStrom^.Data.Nazev;
      if (hb in pozice.stav.b) and (bily=clovek) or
      not(hb in pozice.stav.b) and (cerny=clovek) then
         begin {hraje èlovìk}
         if ((bily=pocitac) xor (cerny=pocitac)) and
  ((hb in pozice.stav.b)and (bily=clovek) or
   not(hb in pozice.stav.b)and (cerny=clovek)) then {budeme myslet dopøedu}
    begin
     if hb in pozice.stav.b then
      begin
       if CernyAlg.Algcfg.MysletDopredu then
        CernyAlg.MysliOTahDopredu(pozice,partie)
      end
      else
       if BilyAlg.Algcfg.MysletDopredu then
        BilyAlg.MysliOTahDopredu(pozice,partie);
    end
         end {od hraje èloveìk}
        else
       begin
{Hraje-li poèítaè, zùstanu v metodì}
        form1.menu:=form1.mainmenu2;
{je tøeba zmìnit menu}
        form1.cursor:=crHourGlass;
{a zakázat pohyb po partii}
        PartiarForm.Speedbutton1.enabled:=false;
        PartiarForm.Speedbutton2.enabled:=false;
{Nestavit pøesýpací hodiny jako kursor}
        if hb in pozice.stav.b then BilyAlg.dejtah(pozice,partie)
         else CernyAlg.dejtah(pozice,partie);
{Tady poèítaè myslí}
        form1.cursor:=crDefault;
{Vrátí se pùvodní kursor...}
        form1.menu:=form1.mainmenu1;
{...a menu}
 {a pohyb po partii (ovšem jen zpátky)}
        PartiarForm.Speedbutton1.enabled:=true;
       end
     end
   end
 end;
procedure TSachovnice.HrajTed;
 begin
  if hb in pozice.stav.b then
   BilyAlg.HrajTed else CernyAlg.HrajTed
 end;
procedure TSachovnice.MouseButtonDown(Button: TMouseButton;
          Shift: TShiftState;X, Y: Integer);
  var i,j,zmackl,pom:integer;
      tah1:ttah1;
  label uspora;
  begin {zaèátek tìla procedury}
   if VypisForm.Stojim then
    begin
     ZpravovaKrabice('Ukonèete nejprve režim krokování výpisù (napøíklad tlaèítkem rozjeï).',
      'Teï nelze táhnout',mb_ok);
     exit
    end;
   if (stav<>normal) then
    begin
     ZpravovaKrabice('Ukonèete nejprve režim práce s knihovnou '+
     '(tlaèítkem Ukonèit pøi prohlížení a tlaèítkem Zrušit pøi editaci).',
      'Teï nelze táhnout',mb_ok);
     exit
    end;
     if (stav=normal)and(button=mbLeft) and HrajeClovek and klik(x,y,i,j) then
     begin
     if oznaceno=255 then
       begin
   {Ještì nebylo nic oznaèeno, zadává se tedy pole, odkud se táhne.}
        if pozice.sch[i,j]=0 then
{ZpravovaKrabice('Prázdným políèkem nejde táhnout','Upozornìní',mb_ok)
 Tenhle dialog byl jen pro zlost...
}
         else
        begin {kliknul na figuru}
         if (hb in pozice.stav.b) and (pozice.sch[i,j]<0) or
          not(hb in pozice.stav.b) and (pozice.sch[i,j]>0) then
{ZpravovaKrabice('Soupeøovou figurkou nejde táhnout','Upozornìní',mb_ok)
 Tenhle dialog byl jen pro zlost...
}
        else
         begin {Hraje sice figurkou své barvy...}
          if not jetam1(i+j shl 4,tahy) then
{...jenže to ještì neznamená, že tato figurka má pøípusný tah.}
uspora:
ZpravovaKrabice('Touto figurkou nejde táhnout','Upozornìní',mb_ok)
         else
          begin{koneènì korektní zadání prvního pole}
           oznaceno:=i + (j shl 4);
           zobraz_pole(oznaceno);
          end {od korektního zadání}
         end {od hraje figurkou své barvy}
        end {od kliknul na figuru}
       end {od první kliknutí} else
       begin {Zadává se políèko, kam se má táhnout}
        if (hb in pozice.stav.b) and (pozice.sch[i,j]>0) or
          not(hb in pozice.stav.b) and (pozice.sch[i,j]<0) then
{Nìjakou figurku si oznaèil, že s ní bude táhnout, ale teï znovu kliknul
 na figurku svojí barvy}
          begin
{Kliknul na nìjakou jinou svojí figuru, program to chápe jako zrušení
 pùvodního oznaèení a zadání nové figury, s níž má být táhnuto, pokud
 ovšem novì oznaèená figura má tah.}
             if jetam1(i + j shl 4,tahy) then
              begin
               pom:=oznaceno;
               oznaceno:=i + j shl 4;
               zobraz_pole(pom);
               zobraz_pole(oznaceno)
              end
             else
              begin
               pom:=oznaceno;
               oznaceno:=255;
               zobraz_pole(pom);
               goto uspora;
              end
          end {od kliknul opìt na figuru svojí barvy}
        else
        begin{Druhým kliknutím zadává tah...}
         tah1.p1:=oznaceno;
         tah1.p2:=i + j shl 4;
         if ((j=7) and (pozice.sch[oznaceno and 15,oznaceno shr 4]=1))
         or ((j=0) and (pozice.sch[oznaceno and 15,oznaceno shr 4]=-1)) then
          begin
           {Uživatel zadává promìnu pìšce.}
           if j=7 then
            begin
             tah1.promena:=5;
             promenadlg.bily:=true
            end
           else
           begin
            tah1.promena:=-5;
            promenadlg.bily:=false;
           end; 
           if jetam(tah1,tahy) then promenadlg.showmodal;
{Neboli mohl-li si promìnit pìšce v dámu své barvy, zeptáme se ho,
 v jakou figuru si ho chce promìnit. Pokud ne, nemùže si ho promìnit
 ani v nic jiného, a tak uživatele seøveme rovnou.}
          end else promenadlg.prm:=0;
         tah1.promena:=promenadlg.prm;
         {Zrušíme pùvodní oznaèení.}
         pom:=oznaceno; oznaceno:=255;
         zobraz_pole(pom);
         if not jetam(tah1,tahy) then
ZpravovaKrabice('Tohle není pøípustný tah','Upozornìní',mb_ok)
         else
         {Koneènì prošel tah všemi testy}
          begin
           TahUzivatele:=tah1;
           if hb in pozice.stav.b then
           CernyAlg.PrestanDopredu(PosliWMDokMysDop) else
            BilyAlg.PrestanDopredu(PosliWMDokMysDop);
           {XXXAlg mi pak pošle zprávu, že mùžu hrát.
Poznámka: XXXAlg nemusel vùbec myslet, ale to nevadí, i tak mi pošle zprávu}
          end
         end
       end; {od druhé kliknutí}
    end {od kliknul na šachovnici}
  end; {konec procedury}
procedure tsachovnice.tahni_a_zobraz(t1:ttah1);
   var x1,y1,x2,y2:byte;
   begin
    with t1 do
     begin
      x1:=p1 and 15;
      y1:=p1 shr 4;
      x2:=p2 and 15;
      y2:=p2 shr 4;
     end;
    pozice.stav.mimoch:=100;
    if hb in pozice.stav.b then
     begin {hraje bílý}
 if (y2=7)then
  begin {pokud táhne bílý na pole èerné vìže pøed rošádou, èerný tam nebude
   už nikdy rochovat}
   if x2=0 then pozice.stav.b:=pozice.stav.b-[vrc] else
    if x2=7 then pozice.stav.b:=pozice.stav.b-[mrc]
  end;
 if (y1=1)and(y2=3)and(pozice.sch[x1,y1]=1) then pozice.stav.mimoch:=x1;{èerný bude moci žrát mimochodem}
 if (y1=4)and(pozice.sch[x1,y1]=1)and(pozice.sch[x2,y2]=0)and (abs(x2-x1)=1) then
  {braní mimochodem}begin pozice.sch[x2,y1]:=0;zobraz_pole(x2+y1 shl 4)end;
      if (y1=0) then
       begin {rošády a nièení rošád}
        if (x1=4) then
         begin {rošády}
pozice.stav.b:=pozice.stav.b-[vrb,mrb];
{Už si nezarochuje, hejbnul s figurou na e1}
if  (x2=2)and(y2=0)and (pozice.sch[4,0]=6) then
 begin pozice.sch[0,0]:=0;zobraz_pole(0);pozice.sch[3,0]:=4;zobraz_pole(3); end;{velká rošáda}
if  (x2=6)and(y2=0)and (pozice.sch[4,0]=6) then
 begin pozice.sch[7,0]:=0;zobraz_pole(7);pozice.sch[5,0]:=4;zobraz_pole(5); end;{mal  rošáda}
        end else
        if (x1=0)then pozice.stav.b:=pozice.stav.b-[vrb] else
        if (x1=7)then pozice.stav.b:=pozice.stav.b-[mrb]
        end;
      pozice.stav.b:=pozice.stav.b-[hb]
     end
     else {hraje èerný}
      begin
        if (y2=0)then
  begin {pokud táhne èerný na pole bílé vìže pøed rošádou, bílý tam nebude
   už nikdy rochovat}
   if x2=0 then pozice.stav.b:=pozice.stav.b-[vrb] else
    if x2=7 then pozice.stav.b:=pozice.stav.b-[mrb]
  end;
       if (y1=6)and(y2=4)and(pozice.sch[x1,y1]=-1) then pozice.stav.mimoch:=x1;{b¡lej bude moci ‘r t mimochodem}
        if (y1=3)and(pozice.sch[x1,y1]=-1)and(pozice.sch[x2,y2]=0)and (abs(x2-x1)=1) then
  {braní mimochodem}begin pozice.sch[x2,y1]:=0;zobraz_pole(x2 + y1 shl 4)end;
       if (y1=7) then
       begin {rošády a nièení rošád}
        if (x1=4) then
         begin {rošády}
pozice.stav.b:=pozice.stav.b-[vrc,mrc];{Už si nezarochuje, hejbnul s figurou na e8}
if  (x2=2)and(y2=7)and (pozice.sch[4,7]=-6) then
 begin pozice.sch[0,7]:=0;zobraz_pole(0+7 shl 4);pozice.sch[3,7]:=-4;zobraz_pole(3+7 shl 4); end;{velká rošáda}
if  (x2=6)and(y2=7)and (pozice.sch[4,7]=-6) then
 begin pozice.sch[7,7]:=0;zobraz_pole(7+7 shl 4);pozice.sch[5,7]:=-4;zobraz_pole(5+7 shl 4); end;{malá rošáda}
         end else
        if (x1=0)then pozice.stav.b:=pozice.stav.b-[vrc] else
        if (x1=7)then pozice.stav.b:=pozice.stav.b-[mrc]
        end;
       pozice.stav.b:=pozice.stav.b+[hb];
      end;
 {a na závìr po všech rošádách a braních mimochodem ještì normální tah}
 if t1.promena<>0 then pozice.sch[x2,y2]:=t1.promena else pozice.sch[x2,y2]:=pozice.sch[x1,y1];
    pozice.sch[x1,y1]:=0;
    zobraz_pole(t1.p1);zobraz_pole(t1.p2);
  end;
 procedure TSachovnice.tahni_zpet_a_zobraz(t2:ttah2);
   var x1,y1,x2,y2:byte;
   begin
    with t2 do
     begin
      x1:=p1 and 15;
      y1:=p1 shr 4;
      x2:=p2 and 15;
      y2:=p2 shr 4;
     end;
    if not(hb in pozice.stav.b) then
     Begin {vracím tah bílého}
 if (y1=4)and(pozice.sch[x2,y2]=1)and(abs(x2-x1)=1)and(t2.bere=0)then
{braní mimochodem} begin pozice.sch[x2,y1]:=-1;zobraz_pole(x2+y1 shl 4) end;
      if (y1=0)and(x1=4)and(pozice.sch[x2,y2]=6) then{vracím rošádu}
       bEgin
if (x2=2) then beGin pozice.sch[0,0]:=4;zobraz_pole(0);pozice.sch[3,0]:=0;zobraz_pole(3) end{velká  rošáda} else
if (x2=6) then beGin pozice.sch[7,0]:=4;zobraz_pole(7);pozice.sch[5,0]:=0;zobraz_pole(5); end;{malá rošáda}
       eNd;
if t2.promena=0then pozice.sch[t2.p1 and 15,t2.p1 shr 4]:=pozice.sch[t2.p2 and 15,t2.p2 shr 4]
        else pozice.sch[t2.p1 and 15,t2.p1 shr 4]:=1
       end
     else
     begin {vracím tah èerného}
       if (y1=3)and(pozice.sch[x2,y2]=-1)and(abs(x2-x1)=1)and(t2.bere=0)then
  {braní mimochodem} begin pozice.sch[x2,y1]:=1;zobraz_pole(x2 + y1 shl 4); end;
      if (y1=7)and(x1=4)and(pozice.sch[x2,y2]=-6) then{vracím rošádu}
       bEgin
if (x2=2) then beGin pozice.sch[0,7]:=-4;zobraz_pole(7 shl 4);pozice.sch[3,7]:=0;zobraz_pole(3+7 shl 4); end{velk  ro¨ da} else
if (x2=6) then beGin pozice.sch[7,7]:=-4;zobraz_pole(7+7 shl 4);pozice.sch[5,7]:=0;zobraz_pole(5+7 shl 4); end;{mal  ro¨ da}
      end;
        if t2.promena=0then pozice.sch[t2.p1 and 15,t2.p1 shr 4]:=pozice.sch[t2.p2 and 15,t2.p2 shr 4]
        else pozice.sch[t2.p1 and 15,t2.p1 shr 4]:=-1
       eNd;{a tadyto jak pro bílého, tak pro èerného}
       pozice.sch[t2.p2 and 15,t2.p2 shr 4]:=t2.bere;pozice.stav:=t2.stav;
       zobraz_pole(x1+y1 shl 4);zobraz_pole(x2+y2 shl 4);
   end;{Konec procedury}
procedure TSachovnice.zpet;
 begin
  if partie^.l<>nil then
   begin
    if (partie^.l^.l=nil) then
     begin
      form1.zpt1.enabled:=false;
      PartiarForm.SpeedButton1.enabled:=False;
     end;
{To aby nebylo možné táhnout zpìt, když už je základní postavení.}
    form1.znovu1.enabled:=true;
    PartiarForm.SpeedButton2.enabled:=true;
{To aby bylo možné znovu zahrát vrácený tah.}
    tahni_zpet_a_zobraz(partie^.t2);
    partie:=partie^.l;
    PartiarForm.NakresliTahy(Partie,Pozice);
    if (hb in pozice.stav.b) and (bily=pocitac) then
     begin
      cerny:=pocitac; bily:=clovek;
     end
    else if not(hb in pozice.stav.b) and (cerny=pocitac) then
     begin
      bily:=pocitac; cerny:=clovek;
     end;
    postmessage(form1.handle,wm_pripravtah,0,0);
   end
  else {nemìlo by nastat, ale kdo ví...}
  ZpravovaKrabice('procedure Tsachovnice.zpet','Chyba programu !',mb_ok or mb_iconhand)
 end;
procedure TSachovnice.znovu;
 var tah1:ttah1;
 begin
  if partie^.r<>nil then
   begin
    osekejtah(partie^.r^.t2,tah1);
    tahni_a_zobraz(tah1);
    partie:=partie^.r;
    PartiarForm.NakresliTahy(Partie,Pozice);
    form1.zpt1.enabled:=true;
    PartiarForm.SpeedButton1.enabled:=true;
    if partie^.r=nil then
     begin
      form1.znovu1.enabled:=false;
      PartiarForm.SpeedButton2.enabled:=False;
     end;
    if (hb in pozice.stav.b) and (bily=pocitac) then
     begin
      cerny:=pocitac; bily:=clovek;
     end
    else if not(hb in pozice.stav.b) and (cerny=pocitac) then
     begin
      bily:=pocitac; cerny:=clovek;
     end;
    postmessage(form1.handle,wm_pripravtah,0,0);
   end
  else ZpravovaKrabice('procedure Tsachovnice.zpet','Chyba programu !',mb_ok or mb_iconhand)
 end;
procedure tsachovnice.BeznyTah(t1:ttah1);
 var t2:ttah2;
 begin
 if cinkat then messagebeep(0);
 form1.zpt1.enabled:=true;
 PartiarForm.SpeedButton1.enabled:=true;
{To aby bylo možné táhnout zpìt}
 form1.znovu1.enabled:=false;
 PartiarForm.SpeedButton2.enabled:=False;
{To aby nebylo možné znovu zahrát vrácený tah. Stará varianta se totiž
 pøepisuje teï právì hraným tahem.}
 doplntah(t1,pozice,t2);
 pridej(partie,t2);
 partie:=partie^.r;
 tahni_a_zobraz(t1);
 PartiarForm.NakresliTahy(Partie,Pozice);
 nastavE2E4;
 postmessage(form1.handle,wm_pripravtah,0,0);
 end;
destructor TSachovnice.destroy;
 begin
  knihovna.free;
  doneppartie(partie);
  inherited destroy;
 end;
procedure tsachovnice.nova_hra(var nPozice:TPozice);
 begin
  ZastavMysleniDopredu;
  doneppartie(partie);
  initppartie(partie);
  pozice:=npozice;
  jmenosouboru:='';
  form1.zpt1.enabled:=false;{Nelze vrátit nezahraný tah}
  form1.znovu1.enabled:=false;{Nelze vrátit vrácení nezahraného a tím pádem
  i nevráceného tahu.}
  PartiarForm.SpeedButton1.Enabled:=False;
  PartiarForm.SpeedButton2.Enabled:=False;
  PartiarForm.NakresliTahy(Partie,Pozice);
  paint;
  postmessage(form1.handle,wm_pripravtah,0,0);
 end;
procedure tsachovnice.uloz;
 begin
  if JmenoSouboru='' then ulozjako else UlozPartii(JmenoSouboru,Partie,Pozice)
 end;
procedure tsachovnice.UlozJako;
 var v:TViditelnost;
 begin
  form1.SaveDialog1.FileName:='';
  UlozStavFormu(v);
  SkryjFormy;
  Form1.SaveDialog1.Execute;
  ObnovStavFormu(v);
  if form1.SaveDialog1.FileName<>'' then
   begin
    JmenoSouboru:=form1.SaveDialog1.FileName;
    UlozPartii(JmenoSouboru,Partie,Pozice)
   end
 end;
procedure tsachovnice.otevri;
 var filename:string80;
  nPartie:PPartie;
  nPozice:Tpozice;
  Chyba:integer;
  v:TViditelnost;
 begin
  form1.OpenDialog1.FileName:='';
  UlozStavFormu(v);
  SkryjFormy;
  Form1.OpenDialog1.Execute;
  ObnovStavFormu(v);
  filename:=form1.OpenDialog1.filename;
  if filename<>'' then
   begin
    nPartie:=nil;
    Chyba:=OtevriPartii(filename,nPozice,nPartie);
    if chyba = VPoradku then
     begin
     doneppartie(partie);
     partie:=nPartie;
     pozice:=npozice;
     jmenosouboru:=filename;
     form1.zpt1.enabled:=false;
     Partiarform.Speedbutton1.enabled:=false;
     if partie^.r=nil then
      begin
       form1.znovu1.enabled:=false;
       Partiarform.Speedbutton2.enabled:=false
      end
        else
      begin
       form1.znovu1.enabled:=true;
       Partiarform.Speedbutton2.enabled:=true
      end;
     paint;
     PartiarForm.NakresliTahy(Partie,Pozice);
     Bily:=Clovek;
     Cerny:=Clovek;
     postmessage(form1.handle,wm_pripravtah,0,0)
    end
    else ZpravovaKrabice(ChybyOtevreni[chyba],'Pokus o otevøení neúspìšný'
    ,mb_ok or mb_iconstop)
   end
  end;
procedure tsachovnice.ZastavMysleniDopredu;
 begin
  if BilyAlg.MyslimDopredu then BilyAlg.prestandopredu(nil);
  if CernyAlg.MyslimDopredu then CernyAlg.prestandopredu(nil);
 end;
procedure tsachovnice.nastavE2E4;
 begin
 { with form1.label2 do
   if hb in pozice.stav.b then caption:='bílý' else caption:='èerný';
  with form1.label4 do
   if (hb in pozice.stav.b)and(bily=pocitac) or
   not(hb in pozice.stav.b)and(cerny=pocitac) then
    caption:='Jsem na tahu.' else caption:='Èekám na Váš tah.';}
 end;
 Procedure TSachovnice.PridejPoziciDoKnihovny;
  procedure PridejString(jaky:String10);
   begin
    with form1 do
     begin
      ListBox1.Items.Add(Jaky);
      ListBox2.Items.Add(Jaky);
      ListBox3.Items.Add(Jaky);
      ListBox4.Items.Add(Jaky);
      ListBox5.Items.Add(Jaky);
     end
   end;
  var tahy:ttahy;
   s:string10;
   i:integer;
   KnihStrom:PKnihStrom;
   KnihData:TKnihData;
  procedure Nastav(Co:tlistbox;Cislo:byte);
   var i:integer;
   begin
    if KnihData.Tahy[Cislo].p1=255 then Co.ItemIndex:=0 else
     begin
      i:=Co.Items.IndexOf(TTah1ToStr(KnihData.Tahy[Cislo],pozice));
      if i<0 then ZpravovaKrabice('TSachovnice.PridejPoziciDoKnihovny'
      ,'Chyba',mb_ok or mb_IconHand);
      Co.ItemIndex:=i
     end
   end;
  begin
   with form1 do
    begin
   panel2.visible:=true;
   ListBox1.Items.Clear;
   ListBox2.Items.Clear;
   ListBox3.Items.Clear;
   ListBox4.Items.Clear;
   ListBox5.Items.Clear;
    end;
   rychle.naleztahy(pozice,tahy);
   PridejString('žádný');
   for i:=1 to tahy.poctah do pridejstring(ttah1tostr(tahy.t[i],pozice));
   Knihovna.DejData(Pozice,KnihStrom);
   if KnihStrom=nil then
    begin
     form1.label19.caption:='Nová pozice do knihovny';
     form1.Edit1.text:='Neznámé zahájení';
     {KnihData.Pozice:=Pozice;}
     for i:=1 to 5 do KnihData.Tahy[i].p1:=255;
    end
   else
    begin
     form1.label19.caption:='Zmìna pozice v knihovnì';
     KnihData:=KnihStrom^.Data;
     form1.Edit1.text:=KnihData.Nazev
    end;
   nastav(form1.listbox1,1);
   nastav(form1.listbox2,2);
   nastav(form1.listbox3,3);
   nastav(form1.listbox4,4);
   nastav(form1.listbox5,5)
  end;
procedure TSachovnice.OKPoziciDoKnihovny;
 Var KnihData:TKnihData;
  i:integer;
  tahy:ttahy;
  procedure vydoluj(odkud:TListBox;Cislo:byte);
   var i:integer;
   begin
    i:=Odkud.ItemIndex;
    if (i<0)or(i>tahy.poctah) then ZpravovaKrabice('TSachovnice.OKPoziciDoKnihovny'
      ,'Chyba',mb_ok or mb_IconHand);
    if i<1 then KnihData.tahy[cislo].p1:=255 else
     KnihData.tahy[cislo]:=tahy.t[i]
   end;
 begin
  rychle.naleztahy(pozice,tahy);
  KnihData.Pozice:=Pozice;
  vydoluj(form1.listbox1,1);
  vydoluj(form1.listbox2,2);
  vydoluj(form1.listbox3,3);
  vydoluj(form1.listbox4,4);
  vydoluj(form1.listbox5,5);
  KnihData.Nazev:=form1.Edit1.text;
  Knihovna.PridejData(KnihData);
 end;
 procedure TSachovnice.PridejPartiiDoKnihovny;
  var pos:TPozice;
   par:ppartie;
   t1:ttah1;
    v:TViditelnost;
  begin
   UlozStavFormu(V);
   SkryjFormy;
   PridejPartiiForm.ShowModal;
   ObnovStavFormu(V);
   if not PridejPartiiForm.potvrzeno then exit;
   par:=partie;
   pos:=pozice;
   while par^.l<>nil do
    begin
     tahni_zpet(pos,par^.t2);
     par:=par^.l;
    end;
   par:=par^.r;
   while par<>nil do
    begin
     osekejtah(par^.t2,t1);
     Knihovna.PridejTah(t1,pos,PridejPartiiForm.Edit1.Text);
     tahni(pos,t1);
     par:=par^.r
    end
  end;
 procedure TSachovnice.ProhledniKnihovnu;
  begin
   if Knihovna.KnihStrom=nil then
    begin
     ZpravovaKrabice('Knihovna je prázdná','Informace',mb_Ok);
     stav:=normal;
     form1.knihmenu(true);
    end
     else
    begin
     StaraPozice:=Pozice;
     form1.panel3.visible:=true;
     CisloProhlizenePozice:=0;
     ProhledniPozici(1);
    end
  end;
 procedure TSachovnice.ProhledniPozici(dn:LongInt);
  var KnihStrom:PKnihStrom;
  procedure Nastav(Co:TLabel;Cislo:byte);
   begin
    Co.Caption:=IntToStr(Cislo)+'. tah: ';
    if KnihStrom^.Data.Tahy[Cislo].p1=255 then Co.Caption:=Co.Caption+'žádný' else
      Co.Caption:=Co.Caption+TTah1ToStr(KnihStrom^.Data.Tahy[Cislo],pozice);
   end;
   label zpatky;
  begin
   CisloProhlizenePozice:=CisloProhlizenePozice+dn;
   if CisloProhlizenePozice<1 then
    begin
     ZpravovaKrabice('Pojedeme tedy od konce',
     'Jsme na zaèátku knihovny',mb_Ok);
     CisloProhlizenePozice:=Knihovna.PocetPozic;
    end;
   zpatky:;
   Knihovna.DejNTaData(CisloProhlizenePozice,KnihStrom);
   if KnihStrom=nil then
    begin
     ZpravovaKrabice('Pojedeme zase od zaèátku',
     'Jsme na konci knihovny',mb_Ok);
     CisloProhlizenePozice:=1;
     goto zpatky;
    end
   else
    begin
     Pozice:=KnihStrom^.Data.Pozice;
     Form1.Label27.caption:=KnihStrom^.Data.Nazev;
     nastav(form1.label20,1);
     nastav(form1.label21,2);
     nastav(form1.label22,3);
     nastav(form1.label23,4);
     nastav(form1.label24,5);
     Form1.Label31.caption:=IntToStr(Knihovna.PocetPozic);
     Form1.Label32.caption:=IntToStr(Knihovna.HloubkaStromu);
     Paint;
    end
  end;
 procedure TSachovnice.SmazpoziciVKnihovne;
  var KnihStrom:PknihStrom;
  begin
   Knihovna.DejData(pozice,Knihstrom);
   if KnihStrom=nil then
    ZpravovaKrabice('Tato pozice v knihovnì není, nemùžu ji tedy ani smazat',
    'Upozornìní',mb_ok) else
     begin
      if ZpravovaKrabice('Opravdu vymazat pozici z knihovny ?','Kontrolní dotaz',mb_yesno)
       = id_yes
       then Knihovna.Mazej(KnihStrom^.Data.Pozice)
     end
  end;
end.

unit Myslitel;
{$DEFINE JENBRANI}
interface
 uses coty;
type
 TStyl=(Nulovy, Normalni, OnDopredu, JaDopredu);
 {Nulovy     - ádné vıpisy
  Normalni   - myslím na svùj tah
  OnDopredu  - odhaduji soupeøùv tah pøi myšlení dopøedu
  JaDopredu  - poèítám svou odpovìï na oèekávanı soupeøùv tah pøi myšlení
               dopøedu
 }
TAkce=procedure;
TDejtahProc=procedure(t1:ttah1);
THodnotyTahu=array[1..maxtah] of longint;
THloubkyTahu=array[1..maxtah] of byte;
TMeziData=record
  Alfa,Beta:Longint;
   {Alfa a Beta PØED poèítáním prvního nedopoèteného tahu;
   Cena je hodnota posledního zlepšujícího tahu}
  Hloubka,I,Platnych:Integer;
  {Poslední nedopoètená hloubka; První nedopoètenı tah v Hloubce,
   Poèet tahù, pro nì má smysl Hodnoty}
  Dojeto:Boolean;
  Pozice:TPozice;{Pozice, k ní vede tah uivatele, na kterı se pøipravuji}
  Tahy:TTahy;{Všechny tahy z pozice, dosavadní nejlepší je první,
  prvních Platnych je setøídìno podle vıhodnosti.}
  Hodnoty:array[1..maxtah] of LongInt;
 end;
PMeziSeznam=^TMeziSeznam;
TMeziSeznam=record
 Data:TMezidata;
 n:PMeziSeznam;
end;
PMezivypocet=^TMezivypocet;
TMezivypocet=class
 public
 Seznam:PMeziSeznam;
 procedure Pridej(var Data:TMeziData); {Inteligentnì pøidá do Seznamu
 Inteligentnì znamená: Nejsou-li tam, pøidá je
                       Jsou-li tam do menší hloubky, pøepíše jimi ten údaj
                       Jsou-li tam do stejné nebo vìtší hloubky, neudìlá nic}
 procedure DejInfo(var Pozice:TPozice;var AlgCfg:TAlgCfg;var Data:TMeziData);
 {Inteligentnì najde v Seznamu informace o Pozici.
  Inteligentnì znamená, e pokud tam nejsou, tak rozumnì doplní údaje sám.
   Hloubka a I budou 0, tahy budou platné tahy a Cena hodnota Pozice}
 procedure SmazSeznam;
 destructor destroy;override;
end;
TMyslitel=class
 private
  VolanoMusimKoncit:word;{Abych mìl kontrolu nad èasem v dobì vıpoètu,
  volám metodu MusimKoncit:boolean. Ta otestuje èas a jednou za n volání
  pøedá øízení Woknùm, aby mohly distribuovat èekající zprávy.
  Ve VolanoMusimKoncit je poèet tìch volání. Mùe obèas pøetéct, ale to
  vùbec nevadí.}
  KoncovyCas:LongInt;{Èas, kdy musím ukonèit vıpoèet a táhnout.}
  Ukoncit:Boolean;{Vyprší-li èas, vynutí-li si uivatel tah nebo myslím-li
  dopøedu a v dùsledku uivatelova tahu se zaavolá PrestanDopredu}
  AkceKonecDopredu:TAkce;{Co mám pøi ukonèení myšlení dopøedu udìlat,
  pointer naproceduru bez parametrù. Je-li nil, nevolá se (tj. ádná akce).
  Vıznam: Chci udìlat nìco, kvùli èemu je tøeba pøestat myslet dopøedu
          napø. ukonèit program nebo pøemıšlet normálnì. Myšlení dopøedu
          ale nejde jen tak z procedury zastavit. Je tøeba zavolat
          PrestanDopredu, to nastaví Ukoncit na true a a se zpracují ve
          Windows všechny zprávy, dostane se k lízu myšlení dopøedu a samo
          se ukonèí (nebo Ukoncit=true). Jako poslední akci zavolá tuto
          proceduru, která vykoná to, co se pùvodnì mìlo udìlat.}
  Partie:PJednoPartie; {musím si pamatovat kus historie, kvùli pravidlu 50 tahù
  a pravidlu opakování pozic (a abych tøeba vùbec poznal vìènı šach).
  Sem si pøekopíruji potøebnou èást partie z objektu šachovnice pøi kadém
  volání myslící procedury (DejTah nebo MysliOTahDopredu).}
  Pozice:TPozice;{Sem si pøekopíruji pozici z objektu šachovnice
  pøi kadém volání myslící procedury (DejTah nebo MysliOTahDopredu).}
  MeziVypocet:TMeziVypocet; {Sem si uloím vısledky MysliOTahDopredu.
  Musí bıt nil, pokud jsem nic nevypoèítal !!!! Není-li nil, dealokuje se.
  Pouije se v DejTah a to pokud platí a) i b)
   a) MeziVypocet <> nil
   b) Pozice "=" nPozice (napø. uivatel mohl zmìnit pozici)}
  Hraji:TDejtahProc;{Tuhle procedure zavolám kdy táhnu. Tato procedura by
  mìla jen poslat zprávu na okno, v LParam bude zakódovanı tah.}
  function Transformuj(co:longint):longint;
  {Pøevede hodnotu pozice tak aby z n. pùltahem mat bylo (n+1). pùltahem
  mat. Jinak by algoritmus nepreferoval vdy nejkratší cestu k vítìzství.}
  function MusimKoncit:boolean;
  function Alfa_Beta(Alfa,Beta:LongInt;hloubka:integer;
           var dojeto:boolean; HloubkaRekurze:Integer;Styl:TStyl;
           var pocitam,Nejlepsi:String):longint;
{Alfa-beta metoda do zadané hloubky s dopoètem do tiché pozice
 s kaskádovitım prùchodem a se zapamatováváním hodnot tahù vypoètenıch a
 do konce.}
  function Alfa_Beta_Vrazi(Alfa,Beta:LongInt; hloubka:integer;
           var dojeto:boolean; HloubkaRekurze:Integer;Styl:TStyl):longint;
 {Dopoèet do tiché pozice, nejvıše však do zadané hloubky. Alfa-beta metoda
 s kaskádovitım prùchodem a se zapamatováváním hodnot tahù vypoètenıch a
 do tichého konce.}
  Procedure globBIterace(var MeziData:TMeziData; HorsiTahy:LongInt;
                         Styl:TStyl; var pocitam,Nejlepsi:String);
  Procedure globCIterace(var MeziData:TMeziData;  HorsiTahy:LongInt;
                          Styl:TStyl; var pocitam,Nejlepsi:String);
  Procedure VypisVariantu(Tah1:TTah1; Var Pocitam:String;PocPos:Byte;
    Styl:TStyl; Hloubka:Integer);
  Procedure VypisNejlepsi(Tah1:TTah1;Var Nejlepsi:String; Styl:TStyl);
 public
  MyslimDopredu,Myslim:boolean;{Stav}
  CasNaTah:LongInt;
  AlgCfg:TALgCfg;{Konfigurace algoritmu.}
  constructor Create(nHraji:TDejTahProc);
  destructor Destroy; override;
  procedure DejTah(var npozice:tpozice;var npartie:ppartie);
  {Pøekopíruje si parametry, pøemıšlí. A uplyne èas nebo je zavoláno
   HrajTed, zavolá Hraji(nejlepší tah) a hned potom se ukonèí.
   }
  procedure HrajTed;
 {Jen nastaví private promìnné a procedura konèí. V dùsledku nastavení
  promìnnıch objekt okamitì táhne (je-li na tahu).}
  procedure MysliOTahDopredu(var npozice:tpozice; npartie:ppartie);
 {Dealokuje MeziVypocet (není-li nil) a znovu vytvoøí.
  Musí bıt explicitnì zastaveno následující metodou. V nìkterıch pøípadech
  se ale ukonèí sama (pokud tøeba najde cestu k matu na všechny soupeøovy
  tahy). Dealokuje MeziVypocet (není-li nil).}
  procedure PrestanDopredu(nAkceKonecDopredu:TAkce);
 {Zastaví vıpoèet dopøedu. To co vypoèítal si pamatuje v MeziVypocet.
  Myslitel konèící vıpoèet pak zavolá AkceKonecDopredu.}
 end;
 function HodnotaToStr(hodnota:LongInt):string22;
implementation
 uses WinTypes,WinProcs,Forms,Rutiny,Rychle, Ohodnoc, Form, SysUtils,
       Sachovni,UKnih,Dialogs,Vypisova, NormForm, DoprForm;
 const mat=2147483645;
       NeHodnota=-2147483647;
{procedure Ladena;
 var w:word;
 begin
  asm
   mov ax,sp
   mov w,ax
  end;
  form1.label33.caption:=inttostr(w);
 end;}
function HodnotaToStr(hodnota:LongInt):string22;
 begin
  if (hodnota<mat-100) and (hodnota>100-mat) then
    result:=IntToStr(hodnota) else
   begin {blíí se mat}
    if hodnota=NeHodnota then begin result:='Nedopoèteno'; exit end;
    if Mat+1=Hodnota then begin result:='+Nekoneèno'; exit end;
    if -Mat-1=Hodnota then begin result:='-Nekoneèno'; exit end;
    if hodnota>0 then  result:='Bílı' else result:='Èernı';
    if (hodnota=mat)or(hodnota=-mat) then
     begin
      result:=result+' vyhrál';
      exit;
     end;
    if hodnota>0 then hodnota:=mat-hodnota else
     hodnota:=mat+hodnota;
    hodnota:=(hodnota+1)shr 1;
    result:=result+' dá mat '+IntToStr(hodnota)+'. tahem.'
   end
 end;

{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{!!!                  Procedury pro práci s PJednoPartie               !!!}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
 procedure CopyKusPartie(Kde:TPozice;Odkud:PPartie;var Kam:PJednoPartie);
  {Zkopíruje èást partie. Jde od souèasného stavu doleva a po první tah
   pìšcem nebo braní. Budoucnost tj. to, co je vpravo nezkopíruje.
   Je-li poslední tah braní nebo tah pìšcem bude Kam Nil.}
    var pom,pom2:PJednoPartie;
    begin
     Kam:=Nil;
     if (odkud<>nil) {Mìlo by nastat vdy...}  then
      begin
       while (odkud^.l<>nil) and not trvalaa_zmena(Kde,odkud^.t2) do
        begin
         new(pom);

         pom^.l:=kam;
         pom^.t2:=odkud^.t2;
         kam:=pom;
         odkud:=odkud^.l;
         tahni_zpet(Kde,kam^.t2);
        end; {Teï mám spoják v kam, ale je tøeba ho otoèit}
       pom:=nil;
       while kam<>nil do
        begin
         pom2:=kam^.l;
         kam^.l:=pom;
         pom:=kam;
         kam:=pom2;
        end;
       kam:=pom;
      {Otoèení dokonèeno}
      end
    end;
 procedure DonePJednoPartie(var p:PJednoPartie);
{Dealokace celého spojáku}
  var pom:PJednoPartie;
  begin
   while p<>nil do
    begin
     pom:=p^.l;
     dispose(p);

     p:=pom;
    end
  end;
 procedure PridejTah(var kam:PJednoPartie;co:ttah2);
  var pom:pJednoPartie;
  begin
   new(pom);

   pom^.t2:=co;
   pom^.l:=kam;
   kam:=pom
  end;
 procedure UberTah(var odkud:PJednoPartie);
  var pom:pJednoPartie;
  begin
   if odkud<>nil then
    begin
     pom:=odkud^.l;
     dispose(odkud);

     odkud:=pom
    end
  end;
 function PoloRemis(Partie:PJednoPartie;var Pozice:TPozice):boolean;
{Dochází v Partii k opakování poslední Pozice nebo aspoò k 50 tichım tahùm ?}
  function stejne(var pos1,pos2:TPozice):boolean;
   var x:byte;
   begin
    result:=true;
    if pos1.stav.b<>pos2.stav.b then result:=false else
     if pos1.stav.mimoch<>pos2.stav.mimoch then result:=false else
      for x:=0 to 63 do if pos1.sch[0,x]<>pos2.sch[0,x] then
       begin
        result:=false;
        exit
       end;
   end;
  var th:shortint;pompos:TPozice;
  begin
   th:=100;
   result:=false;
   pompos:=pozice;
   while (partie<>nil) and (th>0) do
    begin
     dec(th);
     if trvalaa_zmena(pompos,partie^.t2) then break;
     tahni_zpet(pompos,partie^.t2);
     if stejne(pozice,pompos) then begin result:=true; break end;
     partie:=partie^.l;
    end;
    if th=0 then result:=true
  end;
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{!!!                            TMeziVypocet                           !!!}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
 procedure TMeziVypocet.Pridej(var Data:TMeziData);
  var pom:PMeziSeznam;
  begin
   pom:=Seznam;
   while (pom<>nil)and(CMPPozice(Data.Pozice,pom^.Data.Pozice)<>0) do pom:=pom^.n;
   if pom=nil then
    begin
     new(pom);
     pom^.Data:=Data;
     pom^.n:=Seznam;
     Seznam:=Pom
    end
   else
    begin
     if (Data.Hloubka>Pom^.Data.Hloubka) or
        (Data.Hloubka=Pom^.Data.Hloubka) and (Data.i>Pom^.Data.i) then
      Pom^.Data:=Data
    end
  end;
 procedure TMeziVypocet.DejInfo(var Pozice:TPozice;var AlgCfg:TAlgCfg;var Data:TMeziData);
   var pom:PMeziSeznam;
  begin
   pom:=Seznam;
   while (pom<>nil)and(CMPPozice(Pozice,pom^.Data.Pozice)<>0) do pom:=pom^.n;
   if pom=nil then
    begin
     Data.Hloubka:=0;
     Data.Dojeto:=False;
     Data.I:=1;
     Rychle.NalezTahy(Pozice,Data.Tahy);
     Data.Pozice:=Pozice; {asi zbyteèné, ale pro jistotu}
     Data.Platnych:=1;
     Data.Hodnoty[1]:=HodnotaPozice(Pozice,AlgCfg);
     if Data.Hodnoty[1]>mat-AlgCfg.Okno then begin Data.Beta:=Data.Hodnoty[1]+1;
      Data.Alfa:=Data.Hodnoty[1]-AlgCfg.Okno end else
      if Data.Hodnoty[1]<-mat+AlgCfg.Okno then begin Data.Alfa:=Data.Hodnoty[1]-1;
       Data.Beta:=Data.Hodnoty[1]+AlgCfg.Okno end else
       begin Data.Alfa:=Data.Hodnoty[1]-AlgCfg.Okno; Data.Beta:=Data.Hodnoty[1]+AlgCfg.Okno end;
    end
   else Data:=pom^.Data
  end;
 procedure TMeziVypocet.SmazSeznam;
  var pom:PMeziSeznam;
  begin
   while Seznam<>nil do
    begin
     pom:=Seznam^.n;
     dispose(Seznam);
     Seznam:=pom
    end
  end;
 destructor TMeziVypocet.Destroy;
  begin
   SmazSeznam;
   inherited destroy;
  end;
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{!!!                               TMyslitel                           !!!}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
 constructor TMyslitel.Create(nHraji:TDejTahProc);
  begin
   inherited Create;
   MeziVypocet:=TMeziVypocet.Create;
   CasNaTah:=5000;
   Hraji:=nHraji;
  end;
destructor TMyslitel.Destroy;
  begin
   Mezivypocet.Free;
   inherited Destroy;
  end;
procedure TMyslitel.MysliOTahDopredu(var npozice:tpozice; npartie:ppartie);
 var MeziDataJeho:TMeziData;
 Procedure Jedeme(bily:boolean);
  var
  poprve:Boolean;
  T2:TTah2;
  MeziDataMoje:TMeziData;
  PomHloubka,K,Dobrych:Integer;
  Pocitam,Nejlepsi:String;
  label SkoroKonec;
  begin
   Pocitam:='';
   Nejlepsi:='';
   poprve:=true;
    repeat
     PomHloubka:=MeziDataJeho.Hloubka;
     if poprve or (MeziDataJeho.Tahy.Poctah>1) then
      begin
     {<Ladící vıpisy>}
     if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDopredu then
        Vypisovac.WriteStr(' Pøemıšlím co soupeø zahraje...');
     {</Ladící vıpisy>}
     {<Bìné vıpisy>}
     if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label4.Caption:='Vìštím soupeøùv tah.';
     {</Bìné vıpisy>}
      poprve:=false;
      end;
     if MeziDataJeho.Tahy.Poctah>1 then
      repeat
       if bily then globBiterace(MeziDataJeho,AlgCfg.DoprHorsiTahy,OnDopredu,Pocitam,Nejlepsi) else
          globCiterace(MeziDataJeho,AlgCfg.DoprHorsiTahy,OnDopredu,Pocitam,Nejlepsi)
      until ukoncit or MezidataJeho.Dojeto or (MezidataJeho.Hloubka>PomHloubka)
      else MezidataJeho.Dojeto:=true;

     Application.Processmessages;

     {<Ladící vıpisy>}
     if MezidataJeho.Platnych<1 then MezidataJeho.Platnych:=1;
     dobrych:=0;
  repeat
   inc(dobrych)
  until (dobrych=MeziDataJeho.Tahy.PocTah)or
   (Dobrych=MeziDataJeho.Platnych) or
   (MeziDataJeho.Hodnoty[1]<-mat+100) or
   (MeziDataJeho.Hodnoty[1]>mat-100) or  {Musím si dávat pozor na pøeteèení LongIntu}
   (MeziDataJeho.Hodnoty[dobrych+1]<MeziDataJeho.Hodnoty[1]-AlgCfg.DoprHorsiTahy)or
   (MeziDataJeho.Hodnoty[dobrych+1]>MeziDataJeho.Hodnoty[1]+AlgCfg.DoprHorsiTahy);
   for k:=1 to Dobrych do
    begin
     if Ukoncit then break;
     if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDopredu then
      Vypisovac.WriteStr(' Chystám se na soupeøùv tah '+
       TTah1ToStr(MeziDataJeho.Tahy.t[k],Pozice));
     {</Ladící vıpisy>}
     {<Bìné vıpisy>}
     if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label4.Caption:='Poèítám odpovìï na '
          +TTah1ToStr(MeziDataJeho.Tahy.t[k],Pozice)+'.';
     {</Bìné vıpisy>}
     DoplnTah(MeziDataJeho.Tahy.t[k],Pozice,T2);
     PridejTah(Partie,T2);
     tahni(Pozice,MeziDataJeho.Tahy.t[k]);
     {A teï myslím na odpovìï}
     MeziVypocet.DejInfo(Pozice,AlgCfg,MeziDataMoje);
     if (not ukoncit) and
        (not MeziDataMoje.Dojeto) and
        (MeziDataMoje.Hloubka<=MeziDataJeho.Hloubka) and
        (MeziDataMoje.Tahy.Poctah>0) then
     begin
    repeat
        if bily then globCiterace(MeziDataMoje,AlgCfg.NormHorsiTahy,JaDopredu,Pocitam,Nejlepsi) else
         globBiterace(MeziDataMoje,AlgCfg.DoprHorsiTahy,JaDopredu,Pocitam,Nejlepsi)
      until (Ukoncit)or(MeziDataMoje.Dojeto)or
      (MeziDataMoje.Hloubka>=MeziDataJeho.Hloubka);
      MeziVypocet.Pridej(MeziDataMoje);
      if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDopredu then
      Vypisovac.WriteStr(' Moje odpovìï: '+
       TTah1ToStr(MeziDataMoje.Tahy.t[1],Pozice));
     end;
     Tahni_Zpet(Pozice,T2);
     UberTah(Partie);
     end
    until ukoncit;
  end;

 var i:integer;
     t2:ttah2;
     t1:ttah1;
 begin
  {!!!!!!!!!!!!!!Ladìní!!!!!!!!!!!!}
  if form1.sachovnice.bilyalg.MyslimDopredu or
   form1.sachovnice.cernyalg.MyslimDopredu or
   form1.sachovnice.bilyalg.Myslim or
   form1.sachovnice.cernyalg.Myslim then {jeden z nich jsem já, ale to nevadí}
    ZpravovaKrabice('Mám myslet dopøedu a zatím se u myslí','Hrozná chyba !!!',mb_ok);
{!!!!!!!!!!!!!!!!!!!!!!!!!!}
  KoncovyCas:=mat+2;
  MyslimDopredu:=True;
{Mat+2 je toti zároveò nejvìtší LongInt, mùu tedy myslet poøád.}
  if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
   Vypisovac.WriteStr('Zaèínám myslet dopøedu...');
  AkceKonecDopredu:=nil;
  Ukoncit:=False;
  MeziVypocet.SmazSeznam; {Seznam mùe bıt nil, ale to nevadí.}
  Pozice:=nPozice;
  CopyKusPartie(Pozice,nPartie,Partie);
  MeziVypocet.DejInfo(Pozice,AlgCfg,MeziDataJeho);
 {Je sice jisté, e Pozice v mezivıpoètu nebude, to ale nevadí, stejnì to
   najde tahy atd...}
  if MeziDataJeho.Tahy.poctah>0 then
   begin
    if AlgCfg.PouzitKnihovnu then
     begin
      i:=1;
      while i<=MeziDataJeho.Tahy.poctah do
       begin
        doplntah(MeziDataJeho.Tahy.t[i],pozice,t2);
        tahni(pozice,MeziDataJeho.Tahy.t[i]);
        if Knihovna.DejTah(Pozice,t1) then
         begin
 {nebudu poèítat odpovìï na tah, kterı vede k pozici, co mám v knihovnì}
          MeziDataJeho.Tahy.t[i]:=MeziDataJeho.Tahy.t[MeziDataJeho.Tahy.poctah];
          dec(MeziDataJeho.Tahy.poctah);
          dec(i)
         end;
        tahni_zpet(pozice,t2);
        inc(i)
       end;
      application.processmessages;
     end; {Od PouzitKnihovnu}
    {Asi není nutné, ale to osekávání pøece jen chvíli trvalo...}
    if (MeziDataJeho.Tahy.poctah>0)and not Ukoncit then {mohl jsem toti vymazat všechny tahy}
     if hb in pozice.stav.b then Jedeme(true) else Jedeme(false);
   end;
  DonePJednoPartie(Partie);
  if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
   Vypisovac.WriteStr('Konèím myšlení dopøedu');
  Vypisovac.ZavriSoubor;{Nevadí, jestli není otevøenı}
  if assigned(AkceKonecDopredu) then
   postmessage(form1.handle,wm_Zavolej,0,longint(@AkceKonecDopredu));
  MyslimDopredu:=False;
 end;
Procedure TMyslitel.VypisVariantu(Tah1:TTah1; Var Pocitam:String;
               PocPos:Byte; Styl:TStyl; Hloubka:Integer);
 begin
   {<Bìné vıpisy>}
    case Styl of
     Normalni:
       if Vypisovac.Cfg.mnPovoleno and (Vypisovac.Cfg.mnpHloubka>=Hloubka) then
        begin
         Pocitam[0]:=char(PocPos);
         Pocitam:=Pocitam+' '+TTah1ToStr(Tah1,Pozice);
         MysNormForm.Label6.Caption:=Pocitam;
        end;
     OnDopredu:
       if Vypisovac.Cfg.mdPovoleno and (Vypisovac.Cfg.mdpHloubka>=Hloubka) then
        begin
         Pocitam[0]:=char(PocPos);
         Pocitam:=Pocitam+' '+TTah1ToStr(Tah1 ,Pozice);
         MysDopForm.Label7.Caption:=Pocitam;
        end;
     JaDopredu:
       if Vypisovac.Cfg.mdPovoleno and (Vypisovac.Cfg.mdpHloubka>=Hloubka) then
        begin
         Pocitam[0]:=char(PocPos);
         Pocitam:=Pocitam+' '+TTah1ToStr(Tah1,Pozice);
         MysDopForm.Label20.Caption:=Pocitam;
        end;
    end;
    {</Bìné vıpisy>}
 end;
Procedure TMyslitel.VypisNejlepsi(Tah1:TTah1;Var Nejlepsi:String; Styl:TStyl);
 begin
     {<Bìné vıpisy>}
    case Styl of
     Normalni:
       if Vypisovac.Cfg.mnPovoleno then
        if Vypisovac.Cfg.mnnHloubka>0 then
         MysNormForm.Label8.Caption:=TTah1ToStr(Tah1,Pozice)+Nejlepsi;
     OnDopredu:
       if Vypisovac.Cfg.mdPovoleno then
        if Vypisovac.Cfg.mdnHloubka>0 then
          MysDopForm.Label9.Caption:=TTah1ToStr(Tah1,Pozice)+Nejlepsi;
     JaDopredu:
       if Vypisovac.Cfg.mdPovoleno then
        if Vypisovac.Cfg.mnnHloubka>0 then
         MysDopForm.Label22.Caption:=TTah1ToStr(Tah1,Pozice)+Nejlepsi;
     end;
    {</Bìné vıpisy>}
 end;
Procedure TMyslitel.globBIterace(var MeziData:TMeziData; HorsiTahy:LongInt;
  Styl:TStyl;var Pocitam,Nejlepsi:String);
{Volat pouze hraje-li bílı.
Provedení jedné iterace v Okénku (Alfa,Beta).}
   var JeTah,Dj:boolean;
    i,k:integer;
    PocPos:Byte;
    t2:ttah2;
{    hodnota:LongInt;}
    PomTah:TTah1;
    PomHodnota:LongInt;
   begin
    if MeziData.dojeto then exit;
    PocPos:=length(Pocitam);
    Nejlepsi:='';
    {<Bìné vıpisy>}
    case Styl of
     Normalni: if Vypisovac.Cfg.mnPovoleno then
       MysNormForm.Label2.Caption:=intToStr(Mezidata.Hloubka);
     OnDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label11.Caption:=intToStr(Mezidata.Hloubka);
     JaDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label16.Caption:=intToStr(Mezidata.Hloubka);
    end;
    {</Bìné vıpisy>}
    {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     case Styl of
      Normalni: if Vypisovac.Cfg.osNormalni then
       Vypisovac.WriteZacatekIterace(MeziData);
      OnDopredu, JaDopredu: if Vypisovac.Cfg.osDopredu then
       Vypisovac.WriteZacatekIterace(MeziData);
     end;
    {</Ladící vıpisy>}
    MeziData.dojeto:=true;
    jetah:=false;
    if Mezidata.I=1 then Mezidata.Platnych:=1;
    for i:=Mezidata.I to MeziData.Tahy.PocTah do
      begin
       Mezidata.I:=I;
    {<Bìné vıpisy>}
     VypisVariantu(Mezidata.Tahy.t[I],Pocitam,Pocpos,Styl,1);
    {</Bìné vıpisy>}
    {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>1) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.WritePocitamTah(Mezidata,4)
       end;
     {</Ladící vıpisy>}
       DoplnTah(MeziData.Tahy.t[i],pozice,t2);
       tahni(Pozice,MeziData.Tahy.t[i]);
       PridejTah(Partie,T2);
       if PoloRemis(Partie,Pozice) then mezidata.hodnoty[i]:=0 else
       begin
        mezidata.hodnoty[i]:=Alfa_Beta(MeziData.Alfa,MeziData.Beta,MeziData.hloubka,dj,2,Styl,Pocitam,Nejlepsi);
       if mezidata.hodnoty[i]<> nehodnota then
        if mezidata.hodnoty[i]>mat-100 then dec(mezidata.hodnoty[i]) else
         if mezidata.hodnoty[i]<-mat+100 then inc(mezidata.hodnoty[i]);
        if not dj then Mezidata.dojeto:=false;{nedopoèetl-li jsem aspoò 1 tah,
                   je to celé nedopoètené}
       end;
       UberTah(Partie);
       tahni_zpet(pozice,t2);
       if mezidata.hodnoty[i]=NeHodnota then begin
        MeziData.dojeto:=false;
        Pocitam[0]:=char(PocPos);
        exit
       end;
       if mezidata.hodnoty[i]>Mezidata.alfa then
        begin
{2. zmìna} {probublám dobrım tahem dopøedu a to i v pøípadì, e není v (alfa,beta)}
            k:=i;
            while (k>1)and(MeziData.Hodnoty[k-1]<MeziData.Hodnoty[k]) do
             begin
              PomTah:=MeziData.Tahy.t[k];
              PomHodnota:=MeziData.Hodnoty[k];
              MeziData.Tahy.t[k]:=MeziData.Tahy.t[k-1];
              MeziData.Hodnoty[k]:=MeziData.Hodnoty[k-1];
              MeziData.Tahy.t[k-1]:=PomTah;
              MeziData.Hodnoty[k-1]:=PomHodnota;
              dec(k)
             end;
         if mezidata.hodnoty[1]>=Mezidata.beta then
          begin
           {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.WriteStr('  Neúspìch iterace');
        Vypisovac.WriteStr('  Pøelezl jsem okénko tahem '+
        TTah1ToStr(MeziData.Tahy.t[1],pozice))
       end;
         {</Ladící vıpisy>}
           MeziData.I:=1;
           MeziData.Alfa:=MeziData.beta-1;
           MeziData.Beta:=Mat;
           Pocitam[0]:=char(PocPos);
           exit {Okénko moc dole}
          end; {od pøelezení okénka}
          JeTah:=true;
          if i<>1 then inc(MeziData.Platnych);
{3. zmìna}If k=1 then
           begin
   {Tah je nejen v intervalu (alfa, beta), ale je skuteènì nejlepší}
    if (Mezidata.hodnoty[1]>mat-100)or(Mezidata.hodnoty[1]<-mat+100) then
             Mezidata.alfa:=mezidata.hodnoty[1]
            else
             if Mezidata.alfa<mezidata.hodnoty[1]-HorsiTahy then
              Mezidata.alfa:=mezidata.hodnoty[1]-HorsiTahy;
    {<Bìné vıpisy>}
          VypisNejlepsi(MeziData.Tahy.t[1],Nejlepsi,Styl);
    case Styl of
     Normalni: if Vypisovac.Cfg.mnPovoleno then
       MysNormForm.Label4.Caption:=HodnotaToStr(Mezidata.Hodnoty[1]);
     OnDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label13.Caption:=HodnotaToStr(Mezidata.Hodnoty[1]);
     JaDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label18.Caption:=HodnotaToStr(Mezidata.Hodnoty[1]);
    end;
    {</Bìné vıpisy>}
    {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
               Vypisovac.WriteDobryTah(Mezidata){je to dobøe ?};
       {</Ladící vıpisy>}
           end;

         if JeTah and (Mezidata.alfa>=mat-Mezidata.hloubka) then
          begin
           Mezidata.dojeto:=true;
           Pocitam[0]:=char(PocPos);
           exit;
          end
        end
      end; {od for cyklu pøes tahy}
    if not JeTah then
     begin
       {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.WriteStr('  Neúspìch iterace');
        Vypisovac.WriteStr('  Všechny tahy byly pod okénkem')
       end;
       {</Ladící vıpisy>}
      MeziData.Alfa:=-Mat;
      MeziData.Beta:=Mezidata.Hodnoty[1]+1;
      Mezidata.I:=1;
      {Okénko moc nahoøe}
     end
     else
      begin
       if (Mezidata.alfa<=-mat+Mezidata.hloubka) then
        begin
         Mezidata.dojeto:=true;
         Pocitam[0]:=char(PocPos);
         exit;
        end;
      Mezidata.I:=1;
    if MeziData.Hodnoty[1]<-mat+AlgCfg.Okno then
     Mezidata.Alfa:=MeziData.Hodnoty[1]-1
    else Mezidata.Alfa:=MeziData.Hodnoty[1]-AlgCfg.Okno;
    if MeziData.Hodnoty[1]>mat-AlgCfg.Okno then
     Mezidata.Beta:=MeziData.Hodnoty[1]+1
    else Mezidata.Beta:=MeziData.Hodnoty[1]+AlgCfg.Okno;
      Inc(Mezidata.Hloubka)
      end;
   Pocitam[0]:=char(PocPos);
  end;{Konec BIterace}
Procedure TMyslitel.globCIterace(var MeziData:TMeziData; HorsiTahy:LongInt;
  Styl:TStyl;var Pocitam,Nejlepsi:String);
{Volat pouze hraje-li èernı.
Provedení jedné iterace v Okénku (Alfa,Beta).}
   var JeTah,Dj:boolean;
    i,k:integer;
    PocPos:Byte;
    t2:ttah2;
    PomTah:TTah1;
    PomHodnota:LongInt;
   begin
    if MeziData.dojeto then exit;
    PocPos:=length(Pocitam);
    Nejlepsi:='';
    {<Bìné vıpisy>}
    case Styl of
     Normalni: if Vypisovac.Cfg.mnPovoleno then
       MysNormForm.Label2.Caption:=intToStr(Mezidata.Hloubka);
     OnDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label11.Caption:=intToStr(Mezidata.Hloubka);
     JaDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label16.Caption:=intToStr(Mezidata.Hloubka);
    end;
    {</Bìné vıpisy>}
    {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     case Styl of
      Normalni: if Vypisovac.Cfg.osNormalni then
       Vypisovac.WriteZacatekIterace(MeziData);
      OnDopredu, JaDopredu: if Vypisovac.Cfg.osDopredu then
       Vypisovac.WriteZacatekIterace(MeziData);
     end;
    {</Ladící vıpisy>}
    MeziData.dojeto:=true;
    jetah:=false;
    if Mezidata.I=1 then Mezidata.Platnych:=1;
    for i:=Mezidata.I to MeziData.Tahy.PocTah do
      begin
       Mezidata.I:=I;
    {<Bìné vıpisy>}
     VypisVariantu(Mezidata.Tahy.t[I],Pocitam,Pocpos,Styl,1);
    {</Bìné vıpisy>}
    {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>1) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.WritePocitamTah(Mezidata,4)
       end;
     {</Ladící vıpisy>}
       DoplnTah(MeziData.Tahy.t[i],pozice,t2);
       tahni(Pozice,MeziData.Tahy.t[i]);
       PridejTah(Partie,T2);
       if PoloRemis(Partie,Pozice) then mezidata.hodnoty[i]:=0 else
       begin
        mezidata.hodnoty[i]:=Alfa_Beta(MeziData.Alfa,MeziData.Beta,MeziData.hloubka,dj,2,Styl,Pocitam,Nejlepsi);
       if mezidata.hodnoty[i]<> nehodnota then
        if mezidata.hodnoty[i]>mat-100 then dec(mezidata.hodnoty[i]) else
         if mezidata.hodnoty[i]<-mat+100 then inc(mezidata.hodnoty[i]);
        if not dj then Mezidata.dojeto:=false;{nedopoèetl-li jsem aspoò 1 tah,
                   je to celé nedopoètené}
       end;
       UberTah(Partie);
       tahni_zpet(pozice,t2);
       if mezidata.hodnoty[i]=NeHodnota then begin
        MeziData.dojeto:=false;
        Pocitam[0]:=char(PocPos);
        exit
       end;
       if mezidata.hodnoty[i]<Mezidata.Beta then
        begin
{2. zmìna} {probublám dobrım tahem dopøedu a to i v pøípadì, e není v (alfa,beta)}
            k:=i;
            while (k>1)and(MeziData.Hodnoty[k-1]>MeziData.Hodnoty[k]) do
             begin
              PomTah:=MeziData.Tahy.t[k];
              PomHodnota:=MeziData.Hodnoty[k];
              MeziData.Tahy.t[k]:=MeziData.Tahy.t[k-1];
              MeziData.Hodnoty[k]:=MeziData.Hodnoty[k-1];
              MeziData.Tahy.t[k-1]:=PomTah;
              MeziData.Hodnoty[k-1]:=PomHodnota;
              dec(k)
             end;
         if mezidata.hodnoty[1]<=Mezidata.alfa then
          begin
           {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.WriteStr('  Neúspìch iterace');
        Vypisovac.WriteStr('  Podlezl jsem okénko tahem '+
        TTah1ToStr(MeziData.Tahy.t[1],pozice))
       end;
         {</Ladící vıpisy>}
           MeziData.I:=1;
           MeziData.Beta:=MeziData.Alfa+1;
           MeziData.Alfa:=-Mat;
           Pocitam[0]:=char(PocPos);
           exit {Okénko moc nahoøe}
          end; {od podlezení okénka}
          JeTah:=true;
          if i<>1 then inc(MeziData.Platnych);
{3. zmìna}If k=1 then
           begin
   {Tah je nejen v intervalu (alfa, beta), ale je skuteènì nejlepší}
    if (Mezidata.hodnoty[1]>mat-100)or(Mezidata.hodnoty[1]<-mat+100) then
             Mezidata.beta:=mezidata.hodnoty[1]
            else
             if Mezidata.beta>mezidata.hodnoty[1]+HorsiTahy then
              Mezidata.beta:=mezidata.hodnoty[1]+HorsiTahy;
    {<Bìné vıpisy>}
          VypisNejlepsi(MeziData.Tahy.t[1],Nejlepsi,Styl);
    case Styl of
     Normalni: if Vypisovac.Cfg.mnPovoleno then
       MysNormForm.Label4.Caption:=HodnotaToStr(Mezidata.Hodnoty[1]);
     OnDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label13.Caption:=HodnotaToStr(Mezidata.Hodnoty[1]);
     JaDopredu: if Vypisovac.Cfg.mdPovoleno then
       MysDopForm.Label18.Caption:=HodnotaToStr(Mezidata.Hodnoty[1]);
    end;
    {</Bìné vıpisy>}
    {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
               Vypisovac.WriteDobryTah(Mezidata);
       {</Ladící vıpisy>}
           end;

         if JeTah and (Mezidata.Beta<=-mat+Mezidata.hloubka) then
          begin
           Mezidata.dojeto:=true;
           Pocitam[0]:=char(PocPos);
           exit;
          end
        end
      end; {od for cyklu pøes tahy}
    if not JeTah then
     begin
       {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>0) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.WriteStr('  Neúspìch iterace');
        Vypisovac.WriteStr('  Všechny tahy byly nad okénkem')
       end;
       {</Ladící vıpisy>}
      MeziData.Beta:=Mat;
      MeziData.Alfa:=Mezidata.Hodnoty[1]-1;
      Mezidata.I:=1;
      {Okénko moc dole}
     end
     else
      begin
{       if (Mezidata.alfa<=-mat+Mezidata.hloubka) then
        begin
         Mezidata.dojeto:=true;
         Pocitam[0]:=char(PocPos);
         exit;
        end;}
       if (Mezidata.beta>=mat-Mezidata.hloubka) then
        begin
         Mezidata.dojeto:=true;
         Pocitam[0]:=char(PocPos);
         exit;
        end;
      Mezidata.I:=1;
    if MeziData.Hodnoty[1]<-mat+AlgCfg.Okno then
     Mezidata.Alfa:=MeziData.Hodnoty[1]-1
    else Mezidata.Alfa:=MeziData.Hodnoty[1]-AlgCfg.Okno;
    if MeziData.Hodnoty[1]>mat-AlgCfg.Okno then
     Mezidata.Beta:=MeziData.Hodnoty[1]+1
    else Mezidata.Beta:=MeziData.Hodnoty[1]+AlgCfg.Okno;
      Inc(Mezidata.Hloubka)
      end;
   Pocitam[0]:=char(PocPos);
  end;{Konec CIterace}
procedure TMyslitel.DejTah(var npozice:tpozice;var npartie:ppartie);
 var Mezidata:TMezidata;
  Procedure Jedeme(bily:boolean);
   var Pocitam,Nejlepsi:String;
  begin
   Pocitam:='';
   Nejlepsi:='';
   repeat
    if bily then globBIterace(MeziData,AlgCfg.NormHorsiTahy,Normalni,Pocitam,Nejlepsi)
     else globCIterace(MeziData,AlgCfg.NormHorsiTahy,Normalni,Pocitam,Nejlepsi)
   until ukoncit or Mezidata.dojeto;
  end;
 Label konec;
 var dobrych,k:integer;
 begin {DejTah}
{!!!!!!!!!!!!!!Ladìní!!!!!!!!!!!!}
  if form1.sachovnice.bilyalg.MyslimDopredu or
   form1.sachovnice.cernyalg.MyslimDopredu  or
   form1.sachovnice.bilyalg.Myslim or
   form1.sachovnice.cernyalg.Myslim then {jeden z nich jsem já, ale to nevadí}
    ZpravovaKrabice('Mám myslet a zatím se u myslí','Hrozná chyba !!!',mb_ok);
{!!!!!!!!!!!!!!!!!!!!!!!!!!}
  KoncovyCas:=CasNaTah+GetTickCount;
  if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
   Vypisovac.WriteStr('Zaèínám myslet...');
  Myslim:=True;
  Ukoncit:=False;
  Pozice:=nPozice;
  if Algcfg.PouzitKnihovnu and
   Knihovna.DejTah(Pozice,MeziData.Tahy.T[1]) then goto Konec;

  MeziVypocet.DejInfo(Pozice,AlgCfg,MeziData);
  CopyKusPartie(Pozice,nPartie,Partie);
  if MeziData.Tahy.poctah>1 then {Pokud má smysl pøemıšlet tak}
  if hb in pozice.stav.b then Jedeme(true) else Jedeme(false);
  {..else mám jen jeden pøípustnı tah}
  DonePJednoPartie(Partie);
  if Mezidata.Platnych<1 then Mezidata.Platnych:=1;
  dobrych:=0;
  repeat
   inc(dobrych)
  until (dobrych=MeziData.Tahy.PocTah)or
   (Dobrych=Mezidata.Platnych) or
   (MeziData.Hodnoty[1]<-mat+100) or
   (MeziData.Hodnoty[1]>mat-100) or
   (MeziData.Hodnoty[dobrych+1]<MeziData.Hodnoty[1]-AlgCfg.Nedeterminismus)or
   (MeziData.Hodnoty[dobrych+1]>MeziData.Hodnoty[1]+AlgCfg.Nedeterminismus);
  if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osNormalni then
   begin
    Vypisovac.WriteStr('Celkem platnıch tahù: '+inttostr(Mezidata.Platnych));
    Vypisovac.WriteStr('Dobré tahy:');
    for k:=1 to dobrych do
     Vypisovac.WriteStr('Tah: '+ttah1tostr(Mezidata.tahy.t[k],pozice)+' cena '+
      hodnotatostr(MeziData.Hodnoty[1]));
   end;
  k:=random(dobrych)+1;
  {if k<>1 then zpravovakrabice('','Nehraji nejlepší tah',mb_ok);}
  mezidata.tahy.t[1]:=mezidata.tahy.t[k];
  Konec:;
  if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
   Vypisovac.WriteStr('Myšlení ukonèeno. Zahraji '+TTah1ToStr(MeziData.Tahy.t[1],pozice)+'.');
  Vypisovac.ZavriSoubor;{Nevadí, jestli není otevøenı}
  Hraji(MeziData.Tahy.t[1]);
  myslim:=false;
 end;
procedure TMyslitel.HrajTed;
 begin
  Ukoncit:=True
 end;
procedure TMyslitel.PrestanDopredu(nAkceKonecDopredu:Takce);
 begin
  AkceKonecDopredu:=nAkceKonecDopredu;
  if MyslimDopredu then Ukoncit:=True
   else if assigned(AkceKonecDopredu) then
    postmessage(form1.handle,wm_Zavolej,0,longint(@AkceKonecDopredu));
 end;
function TMyslitel.Transformuj(co:longint):longint;
 begin
  if co=NeHodnota then result:=NeHodnota else
   if co>mat-100 then result:=co-1 else
    if co<-mat+100 then result:=co+1 else
     result:=co;
 end;
function TMyslitel.MusimKoncit:boolean;
 begin
  result:=false;
  inc(VolanoMusimKoncit);
  if ukoncit=true then result:=true else
   if {(VolanoMusimKoncit and $F)=0}true then
    if gettickcount>KoncovyCas then begin ukoncit:=true;result:=true  end;
  if {(VolanoMusimKoncit and $F)=0}true then application.processmessages
 end;
function TMyslitel.Alfa_Beta_Vrazi(Alfa,Beta:LongInt;hloubka:integer;
       var dojeto:boolean;HloubkaRekurze:Integer;Styl:TStyl):longint;
  var
   tahy:ttahy;
   t2:ttah2;
   pomtah1:ttah1;
   HodnotyTahu:THodnotyTahu;
   sach,dj:boolean;
   hodnota,HodPos,sAlfa,sBeta,pomlongint:longint;
   h:integer;
   i:byte;
  begin
   dojeto:=false;
   if (alfa<-mat+100) and (alfa>=-mat) then alfa:=alfa-1;
   if (beta>mat-100) and (beta<=mat) then beta:=beta+1;
   if MusimKoncit then result:=NeHodnota else
    begin
     sach:={$IFDEF JENBRANI}nalezbrani{$ELSE}nalezvrahy{$ENDIF}(pozice,tahy);
     if tahy.poctah=0 then
      begin
        dojeto:=true;
        if sach then {Je-li nìkdo v šachu a nemá pøípustnı vrah (a zde je
       vrahem kadı tah), je v matu.}
        if hb in pozice.stav.b then result:=-mat else result:=mat
       else result:=HodnotaPozice(Pozice,AlgCfg);
      end {Od Tahy.poctah=0}
     else
      begin
       if hloubka=0 then
        begin
         result:=HodnotaPozice(Pozice,AlgCfg);
         dojeto:=false {vraedná variata pokraèuje, ale nedopoèetl jsem ji}
        end
         else
        begin
         sAlfa:=Alfa; sBeta:=Beta; {V kaskádovém prùchodu bych si je rozhasil}
         if not sach then
          begin
{Není-li hráè v šachu, nemusí nutnì pokraèovat ve vraedné variantì a mùe
 se od ní odchılit. Aneb jinak bych poèítal, jako by se v šachách muselo
 brát. Je-li ale v šachu, je jeho další tah vdy vrah, take mu dalším
 propoètem nekøivdím.}
           HodPos:=HodnotaPozice(Pozice,AlgCfg);
           if (hb in pozice.stav.b)and(Hodpos>=sBeta)
            or not(hb in pozice.stav.b)and(Hodpos<=sAlfa) then
            begin
             dojeto:=true;
             result:=Hodpos;
             exit   {nevešel jsem se do (alfa, beta), navíc špatnım smìrem}
            end;
          end;
         for i:=1 to tahy.poctah do HodnotyTahu[i]:=NeHodnota;
         if hb in pozice.stav.b then{Hraje bílı}
           begin
            if (not sach) and (hodpos>sAlfa) then
             begin
              sAlfa:=hodpos;
              if sAlfa>=sBeta then
               begin
                result:=hodpos;
                dojeto:=true;
                exit
               end
             end;
            for h:=0 to hloubka-1 do
             begin
              dojeto:=true;
              Alfa:=sAlfa;
              Beta:=sBeta;
              for i:=1 to Tahy.PocTah do
               begin
               if HodnotyTahu[i]<>NeHodnota then hodnota:=HodnotyTahu[i]
{tj. if poèítal bych ji vypoètené, pøeètu si ti z pole}
                 else
                  begin  {musím poèítat}
                   DoplnTah(tahy.t[i],pozice,t2);
                   tahni(pozice,tahy.t[i]);
                   PridejTah(Partie,T2);
                   if PoloRemis(Partie,Pozice) then hodnota:=0 else
                   dj:=true;
                   hodnota:=transformuj(Alfa_Beta_Vrazi(Alfa,Beta,h,dj,HloubkaRekurze+1,Styl));
                   UberTah(Partie);
                   if dj then HodnotyTahu[i]:=hodnota
                   {Tah je dopoèítán, zapamatuji si hodnotu}
                   else dojeto:=false;{nedopoèetl-li jsem aspoò 1 tah,
                   je to celé nedopoètené}
                   tahni_zpet(pozice,t2);
                   if hodnota=NeHodnota then begin result:=NeHodnota;exit end;
                  end; {od musím poèítat}
                 if hodnota>alfa then
                 begin
                  alfa:=hodnota;
                  if alfa>=beta then
                   if h=hloubka-1 then
                    begin result:=alfa;dojeto:=false; exit end
                    else begin break end;
                  pomtah1:=tahy.t[i];  pomlongint:=HodnotyTahu[i];
                  tahy.t[i]:=tahy.t[1];HodnotyTahu[i]:=HodnotyTahu[1];
                  tahy.t[1]:=pomtah1;  HodnotyTahu[1]:=pomlongint;
                 end
             end; {od for cyklu pøes tahy}
             result:=alfa;
             if dojeto then break; {Dopoèítal jsem to a do konce. Zvıšení
hloubky propoètu nemá smysl (poèítal bych ji vypoètené).}
            end {od cyklu pøes hloubku}
           end {od hb in pozice.stav.b}
            else {Hraje èernı}
           begin
            if (not sach) and (hodpos<sBeta) then
             begin
              sBeta:=hodpos;
              if sAlfa>=sBeta then
               begin
                result:=hodpos;
                dojeto:=true;
                exit
               end
             end;
            for h:=0 to hloubka-1 do
             begin
              dojeto:=true;
              Alfa:=sAlfa;
              Beta:=sBeta;
              for i:=1 to Tahy.PocTah do
               begin
                if HodnotyTahu[i]<>NeHodnota then hodnota:=HodnotyTahu[i]
{tj. if poèítal bych ji vypoètené, pøeètu si ti z pole}
                 else
                  begin  {musím poèítat}
                   DoplnTah(tahy.t[i],pozice,t2);
                   tahni(pozice,tahy.t[i]);
                   PridejTah(Partie,T2);
                   dj:=true;
                   if PoloRemis(Partie,Pozice) then hodnota:=0 else
                    hodnota:=transformuj(Alfa_Beta_Vrazi(Alfa,Beta,h,dj,HloubkaRekurze+1,Styl));
                   UberTah(Partie);
                   if dj then HodnotyTahu[i]:=hodnota
                   {Tah je dopoèítán, zapamatuji si hodnotu}
                   else dojeto:=false;{nedopoèetl-li jsem aspoò 1 tah,
                   je to celé nedopoètené}
                   tahni_zpet(pozice,t2);
                   if hodnota=NeHodnota then begin result:=NeHodnota;exit end;
                  end; {od musím poèítat}
                 if hodnota<beta then
                 begin
                  beta:=hodnota;
                  if alfa>=beta then
                 if h=hloubka-1 then begin result:=alfa;dojeto:=false; exit end else
                  begin break end;
                  pomtah1:=tahy.t[i];  pomlongint:=HodnotyTahu[i];
                  tahy.t[i]:=tahy.t[1];HodnotyTahu[i]:=HodnotyTahu[1];
                  tahy.t[1]:=pomtah1;  HodnotyTahu[1]:=pomlongint;
                 end
             end; {od for cyklu pøes tahy}
          result:=beta;
          if dojeto then break; {Dopoèítal jsem to a do konce. Zvıšení
hloubky propoètu nemá smysl (poèítal bych ji vypoètené).}
            end; {Od cyklu pøes hloubku}
          end {Od hraje èernı}
        end  {od not(hloubka=0)}
      end {od not(tahy.poctah=0)}
    end {Od not MusimKoncit}
  end; {Od Alfa_Beta_Vrazi}
{Aèkoliv jsem víceménì vyznavaèem Pascalu, kdy vidím tolik endù za sebou...}
function TMyslitel.Alfa_Beta(Alfa,Beta:LongInt;hloubka:integer;
        var dojeto:boolean;HloubkaRekurze:Integer;Styl:TStyl;var Pocitam,Nejlepsi:String):longint;
  var
   tahy:ttahy;
   t2:ttah2;
   pomtah1:ttah1;
   HodnotyTahu:THodnotyTahu;
   sach,dj:boolean;
   hodnota,sAlfa,sBeta,pomlongint:longint;
   h:integer;
   i,PocPos,NejPos:byte;
   PomStr:String;
  begin
   if (alfa<-mat+100) and (alfa>=-mat) then alfa:=alfa-1;
   if (beta>mat-100) and (beta<=mat) then beta:=beta+1;
   PocPos:=Length(Pocitam);
   NejPos:=Length(Nejlepsi);
   if MusimKoncit then result:=NeHodnota else
    begin {nemusím konèit}
     dojeto:=false;
     if hloubka=0 then
      begin
       result:={HodnotaPozice(Pozice,AlgCfg);}
       transformuj(Alfa_Beta_Vrazi(Alfa,Beta,HloubkaRekurze+1,sach{nìjakı nepouitı boolean},
        HloubkaRekurze+1,Styl));
       if result=mat-1 then result:=mat else
       if result=-mat+1 then result:=-mat;
       if (result=mat)or(result=-mat)then
        dojeto:=true {Jsem v matu}
         else
       dojeto:=false; {variata pokraèuje, ale nedopoèetl jsem ji}
                {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writeStrOdsaz('Dopoèet do tiché pozice: '+HodnotatoStr(result),HloubkaRekurze+2)
       end;
       {</Ladící vıpisy>}

      end   {od hloubka=0}
     else
     begin {hloubka>0}
         {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writeZacatekAlfaBeta(Alfa,Beta,Hloubka,HloubkaRekurze)
       end;
       {</Ladící vıpisy>}
      sach:=rychle.naleztahy(pozice,tahy);
      if tahy.poctah=0 then
       begin
        if sach then {Je-li nìkdo v šachu a nemá pøípustnı tah je v matu.}
         if hb in pozice.stav.b then result:=-mat else result:=mat
        else result:=0; {remis}
        dojeto:=true;
       end {Od Tahy.poctah=0}
    else
      begin
          for i:=1 to tahy.poctah do HodnotyTahu[i]:=NeHodnota;
          sAlfa:=Alfa; sBeta:=Beta;
          if hb in pozice.stav.b then{Hraje bílı}
           begin
            result:=alfa;
            for h:=0 to hloubka-1 do
             begin
                 {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writeZacatekAlfaBetaIterace(sAlfa,sBeta,H,HloubkaRekurze)
       end;
       {</Ladící vıpisy>}
              Pocitam[0]:=Char(PocPos);
              dojeto:=true; Alfa:=sAlfa; Beta:=sBeta;
              for i:=1 to Tahy.PocTah do
               begin
               {<Bìné vıpisy>}
                VypisVariantu(Tahy.t[I],Pocitam,Pocpos,Styl,HloubkaRekurze);
               {</Bìné vıpisy>}
                 {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writestrodsaz(TTah1ToStr(Tahy.t[I],Pozice),3+HloubkaRekurze)
       end;
       {</Ladící vıpisy>}

                if HodnotyTahu[i]<>NeHodnota then
                 begin
                  hodnota:=HodnotyTahu[i];
                  pomStr:='';
                 end
{tj. if poèítal bych ji vypoètené, pøeètu si to z pole}
                 else
                  begin  {musím poèítat}
                   DoplnTah(tahy.t[i],pozice,t2);
                   tahni(pozice,tahy.t[i]);
                   PridejTah(Partie,T2);
                   dj:=true;
                   if PoloRemis(Partie,Pozice) then hodnota:=0 else
                    begin
                     pomStr:='';
                     hodnota:=transformuj(Alfa_Beta(Alfa,Beta,h,dj,HloubkaRekurze+1,Styl,Pocitam,PomStr));
                    end;
                   UberTah(Partie);
                   if dj then HodnotyTahu[i]:=hodnota
                   {Tah je dopoèítán, zapamatuji si hodnotu}
                   else dojeto:=false;{nedopoèetl-li jsem aspoò 1 tah,
                   je to celé nedopoètené}
                   tahni_zpet(pozice,t2);
                   if hodnota=NeHodnota then
                    begin
                     result:=NeHodnota;
                     Pocitam[0]:=Char(PocPos);
                     exit
                    end;
                  end; {od musím poèítat}
                 if hodnota>alfa then
                 begin
                  alfa:=hodnota;
                  result:=alfa;
                                   {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writestrodsaz('Zlepšující tah, Alfa='+Hodnotatostr(Alfa),3+HloubkaRekurze)
       end;
       {</Ladící vıpisy>}
                  if alfa>=beta then
                 if h=hloubka-1 then
                  begin
                   result:=beta;
                   dojeto:=false;
                   Pocitam[0]:=Char(PocPos);
                   exit
                  end else break;
                  pomtah1:=tahy.t[i];  pomlongint:=HodnotyTahu[i];
                  tahy.t[i]:=tahy.t[1];HodnotyTahu[i]:=HodnotyTahu[1];
                  tahy.t[1]:=pomtah1;  HodnotyTahu[1]:=pomlongint;
if h=hloubka-1 then
case styl of
 Normalni: if HloubkaRekurze<=Vypisovac.Cfg.mnnHloubka then
  begin
   Nejlepsi:=' '+TTah1ToStr(PomTah1,Pozice)+pomStr;
  end;
 OnDopredu,JaDopredu: if HloubkaRekurze<=Vypisovac.Cfg.mdnHloubka then
  begin
   Nejlepsi:=' '+TTah1ToStr(PomTah1,Pozice)+pomStr;
  end;
end;
                 end
             end; {od for cyklu pøes tahy}
             result:=alfa;
             if dojeto then break; {Dopoèítal jsem to a do konce. Zvıšení
hloubky propoètu nemá smysl (poèítal bych ji vypoètené).}
            end {od cyklu pøes hloubku}
           end {od hb in pozice.stav.b}
            else {Hraje èernı}
           begin
            result:=beta;
            for h:=0 to hloubka-1 do
             begin
     {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writeZacatekAlfaBetaIterace(sAlfa,sBeta,H,HloubkaRekurze)
       end;
       {</Ladící vıpisy>}
              Pocitam[0]:=Char(PocPos);
              dojeto:=true; Alfa:=sAlfa; Beta:=sBeta;
              for i:=1 to Tahy.PocTah do
               begin
        {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writestrodsaz(TTah1ToStr(Tahy.t[I],Pozice),3+HloubkaRekurze)
       end;
       {</Ladící vıpisy>}
                {<Bìné vıpisy>}
                VypisVariantu(Tahy.t[I],Pocitam,Pocpos,Styl,HloubkaRekurze);
               {</Bìné vıpisy>}
                if HodnotyTahu[i]<>NeHodnota then
                 begin
                  pomStr:='';
                  hodnota:=HodnotyTahu[i]
                 end
{tj. if poèítal bych ji vypoètené, pøeètu si ti z pole}
                 else
                  begin  {musím poèítat}
                   DoplnTah(tahy.t[i],pozice,t2);
                   tahni(pozice,tahy.t[i]);
                   PridejTah(Partie,T2);
                   dj:=true;
                   if PoloRemis(Partie,Pozice) then hodnota:=0 else
                    begin
                     PomStr:='';
                     hodnota:=transformuj(Alfa_Beta(Alfa,Beta,h,dj,HloubkaRekurze+1,Styl,Pocitam,PomStr));
                    end;
                   UberTah(Partie);
                   if dj then HodnotyTahu[i]:=hodnota
                   {Tah je dopoèítán, zapamatuji si hodnotu}
                   else dojeto:=false;{nedopoèetl-li jsem aspoò 1 tah,
                   je to celé nedopoètené}
                   tahni_zpet(pozice,t2);
                   if hodnota=NeHodnota then
                    begin result:=NeHodnota;Pocitam[0]:=Char(PocPos);exit end;
                  end; {od musím poèítat}
                 if hodnota<beta then
                 begin
                  beta:=hodnota;
        {<Ladící vıpisy>}
    if Vypisovac.Cfg.osPovoleno and (Styl<>Nulovy)
       and (Vypisovac.Cfg.osHloubka>HloubkaRekurze) then
     if (Styl=Normalni)and Vypisovac.Cfg.osNormalni or
       Vypisovac.Cfg.osDopredu and((Styl=OnDopredu)or(Styl=JaDopredu)) then
       begin
        Vypisovac.writestrodsaz('Zlepšující tah, Beta='+Hodnotatostr(Beta),3+HloubkaRekurze)
       end;
       {</Ladící vıpisy>}
                  result:=beta;
                  if alfa>=beta then
if h=hloubka-1 then begin result:=alfa;dojeto:=false; Pocitam[0]:=Char(PocPos);exit end else break;
                  pomtah1:=tahy.t[i];  pomlongint:=HodnotyTahu[i];
                  tahy.t[i]:=tahy.t[1];HodnotyTahu[i]:=HodnotyTahu[1];
                  tahy.t[1]:=pomtah1;  HodnotyTahu[1]:=pomlongint;
if h=hloubka-1 then
case styl of
 Normalni: if HloubkaRekurze<=Vypisovac.Cfg.mnnHloubka then
  begin
   Nejlepsi:=' '+TTah1ToStr(PomTah1,Pozice)+pomStr;
  end;
 OnDopredu,JaDopredu: if HloubkaRekurze<=Vypisovac.Cfg.mdnHloubka then
  begin
   Nejlepsi:=' '+TTah1ToStr(PomTah1,Pozice)+pomStr;
  end;
end;
                end
             end; {od for cyklu pøes tahy}
          result:=beta;

          if dojeto then break; {Dopoèítal jsem to a do konce. Zvıšení
hloubky propoètu nemá smysl (poèítal bych ji vypoètené).}
            end; {Od cyklu pøes hloubku}
          end {Od hraje èernı}
       end {od not(tahy.poctah=0)}
     end  {od not(hloubka=0)}
    end; {Od not MusimKoncit}
    Pocitam[0]:=Char(PocPos);
  end; {Od Alfa_Beta}
end.

unit CoTy; {CoTy znamená Const Type}
{26.6. 1998 12:00 Vznik souboru (modifikací zdrojového kódu mého programu
                  v Turbo Pascalu)}
interface

uses
  uTypes;

const
 nic=0;{prázdné políèko}
{bílı}
 pesec=1;
 jezdec=2;
 strelec=3;
 vez=4;
 dama=5;
 kral=6;
{èernı = - bílı}
{Tyto konstanty slouí pouze pro zpøehlednìní. Není moné je modifikovat !!}
 type TSch=array[0..7,0..7] of S1;{ve smyslu a..h, 1..8}
      TMoznosti=(mrb,vrb,mrc,vrc,hb);
{mrb = bude moci bílı dìlat malou rošádu (tj. nepohnul vìí na a1 ani králem
a nebyla vì na a1 sebraná ?)
vrb, mrc, vrc jsou analogie pro èerného nebo/a velkou rošádu}
{hb = je bílı na tahu}
      TStav=record
       b:set of Tmoznosti;
       mimoch:S1;{na jakém sloupci hrál pøedtím pìšcem o 2 ?
       (kvùli braní mimochodem)}
      end;
const ne_mimochodem=100; {normálnílní hodnota TStav.mimoch}
type  Tpozice=record
       sch:tsch;
       stav:tstav
      end;
      THScore = S2;

TTah1=record{pamìovì úsporná verze tahu, neobsahuje dost informace
pro vrácení tahu => nejde pouít pøi propoètu,
pouívám pøi hledání tahù, tady je kadı ušetøenı byte dobrı}
       p1,p2:byte;{p1=odkud.x+16*odkud.y, p2=kam.x+kam.y*16}
       promena:S1;{Obsahuje typ vısledné figury, tj. normálnì figuru,
       kterou se táhlo, vyjímka pøi promìnì pìšce
       jinımi slovy: co bude na poli p2 po provedení tahu}
      end;
 {Pøíklad: e7-e8D
p1=odkud.x+16*odkud.y=4+6*16
p2=kam.x+16*kam.y=4+7*16
promìna = bílá dáma = + dama = 5}
 TTah2=record {pouíván pøi vracení tahù}
       p1,p2:byte;
       promena:S1;
       bere:S1;{=co bylo na p2 pøed provedením tahu
    pozor, braní mimochodem teï  není braní
    (nebo berocí pìšec jde na prázdné políèko)}
       stav:tstav;{stav pozice pøed tímto tahem}
      end;
{ tdejtah=function(pos:tpozice;var t:ttah1):byte;}
const maxtah=128; {kolik nejvíc tahù pøipouštím z jedné pozice}
type TTahy=record {struktura pro záznam více tahù z jedné pozice}
      poctah: 0..maxtah; {kolik tahù tam je}
      t:array[1..maxtah] of ttah1; {tady jsou uloené}
{      stav:tstav}
     end;
const
  mat = High(THScore) - 2; // 2147483645;
  NeHodnota = Low(THScore); // -2147483647;

  zakladni_postaveni:tpozice=
 (Sch:
 ((4,1,0,0,0,0,-1,-4),
  (2,1,0,0,0,0,-1,-2),
  (3,1,0,0,0,0,-1,-3),
  (5,1,0,0,0,0,-1,-5),
  (6,1,0,0,0,0,-1,-6),
  (3,1,0,0,0,0,-1,-3),
  (2,1,0,0,0,0,-1,-2),
  (4,1,0,0,0,0,-1,-4));
   stav:(b:[mrb,vrb,mrc,vrc,hb];mimoch:ne_mimochodem));
type
{Následují typ hojnì uívané v heuristikách statické ohodnocovací funkce
myslícího algoritmu.}
thodnoty64=array[0..7,0..7] of integer;
Tcenyfigur=array[1..5] of integer;
TAlgCfg=record {Konfigurace statické ohodnocovací funkce}
 NormHorsiTahy,
 DoprHorsiTahy:integer;
 cenyfigur:tcenyfigur;
 NormalniPesciVePredu,
 VolniPesciVePredu,
 KrytiPesciVePredu,
 VolniAKrytiPesciVePredu:array[1..6] of integer;
 Dvojpech,Izolant,Volny,Kryty,VolnyAKryty,VedleKolegy,
 VezNaSloupci,DvojiceStrelcu, ZnicenaRosada, KralOdStredu,KralOdKrale,
 MaticiDama:integer;
 pesci, jezdci, strelci, kral:thodnoty64;
end;
const
AlgCfg:TAlgCfg=(
 NormHorsiTahy:0;
 DoprHorsiTahy:0;
// NormHorsiTahy:30;
// DoprHorsiTahy:100;
 cenyfigur:(1000,3200,3300,5500,9500);
 NormalniPesciVePredu:(-20,20,100,150,250,1500);
 VolniPesciVePredu:(-20,50,150,250,350,1500);
 KrytiPesciVePredu:(-20,50,100,200,270,1500);
 VolniAKrytiPesciVePredu:(-20,50,350,1000,1500,2500);
 Dvojpech:-200;
 Izolant:-100;
 Volny:100;
 Kryty:100;
 VolnyAKryty:250;
 VedleKolegy:80;
 VezNaSloupci:100;
 DvojiceStrelcu:300;
 ZnicenaRosada:-300;
 KralOdStredu:-100; {Z pozice matìného}
 KralOdKrale:60; {Z pozice matìného}
 MaticiDama:200; {Z pozice matícího}
 pesci:
((0   ,10  ,20  ,-200,-150,100 ,200 ,0   ),
 (0   ,20  ,10  ,-150,-100,100 ,200 ,0   ),
 (0   ,0   ,-50 ,200 ,150 ,100 ,200 ,0   ),
 (0   ,0   ,50  ,250 ,250 ,100 ,200 ,0   ),
 (0   ,0   ,50  ,250 ,250 ,100 ,200 ,0   ),
 (0   ,0   ,-300,0   ,0   ,100 ,200 ,0   ),
 (0   ,20  ,10  ,-250,-150,100 ,200 ,0   ),
 (0   ,10  ,20  ,-200,-100,100 ,200 ,0   )
 );
 jezdci:
((-300,-200,-100,-50 ,0   ,0   ,0   ,-150),
 (-100,-150,-50 ,0   ,120 ,120 ,0   ,0   ),
 (-150,50  ,100 ,80  ,150 ,150 ,150 ,0   ),
 (-50 ,0   ,70  ,200 ,250 ,250 ,250 ,50  ),
 (-50 ,0   ,70  ,200 ,250 ,250 ,250 ,50  ),
 (-150,50  ,100 ,80  ,150 ,150 ,150 ,0   ),
 (-100,-150,-50 ,0   ,120 ,120 ,0   ,0   ),
 (-300,-200,-100,-50 ,0   ,0   ,0   ,-150)
 );

 strelci:
((0   , 20  ,-20  ,50  ,50  ,20  ,-10 ,-30 ),
 (-20 , 200 ,-20  ,20  ,200 ,30  ,20  ,-30 ),
 (0   , -20 ,-20  ,200 ,50  ,50  ,40  ,-20 ),
 (-200, 100 ,-100 ,20  ,50  ,70  ,60  ,-20 ),
 (-200, 100 ,-100 ,20  ,50  ,70  ,60  ,-20 ),
 (0   , -20 ,-20  ,200 ,50  ,50  ,40  ,-20 ),
 (-20 , 200 ,-20  ,20  ,200 ,30  ,20  ,-30 ),
 (0   , 20  ,-20  ,50  ,50  ,20  ,-10 ,-30 )
 );

 kral:
((100 ,0   ,-500,-1000,-1000,-1000,-1000,-1000),
 (450 ,-200,-500,-1000,-1000,-1000,-1000,-1000),
 (400 ,-300,-500,-1000,-1000,-1000,-1000,-1000),
 (0   ,0   ,-500,-1000,-1000,-1000,-1000,-1000),
 (0   ,0   ,-500,-1000,-1000,-1000,-1000,-1000),
 (0   ,-300,-500,-1000,-1000,-1000,-1000,-1000),
 (500 ,-200,-500,-1000,-1000,-1000,-1000,-1000),
 (100 ,0   ,-500,-1000,-1000,-1000,-1000,-1000)
 )
 );
Type
string2=string[2];
string10=string[10];
string22=string[22];
string30=string[30];
implementation
end.

/*********************************************************/
/* cotyvar.h - definice zakladnich typu a konstant       */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef cotyvarH
#define cotyvarH
#include <time.h>
#include "volby.h"
/******************************************/
/*       Definice ciselnych typu          */
/******************************************/
#define s8 signed char
#define u8 unsigned char
#define s16 signed short
#define u16 unsigned short
#define s32 signed int
#define u32 unsigned int
#define bool int
#define true 1
#define false 0
#define KontrolaTypu  if (sizeof(s8) != 1 || sizeof(u8) != 1||\
     sizeof(s16) != 2 || sizeof(u16) != 2||\
     sizeof(s32) != 4 || sizeof(u32) != 4)\
  Chyba("Chyba: spatne nastavene ciselne typy");
/**************************************/
/*    Definice vsech poli             */
/**************************************/
#define a1 21
#define b1 22
#define c1 23
#define d1 24
#define e1 25
#define f1 26
#define g1 27
#define h1 28
#define a2 31
#define b2 32
#define c2 33
#define d2 34
#define e2 35
#define f2 36
#define g2 37
#define h2 38
#define a3 41
#define b3 42
#define c3 43
#define d3 44
#define e3 45
#define f3 46
#define g3 47
#define h3 48
#define a4 51
#define b4 52
#define c4 53
#define d4 54
#define e4 55
#define f4 56
#define g4 57
#define h4 58
#define a5 61
#define b5 62
#define c5 63
#define d5 64
#define e5 65
#define f5 66
#define g5 67
#define h5 68
#define a6 71
#define b6 72
#define c6 73
#define d6 74
#define e6 75
#define f6 76
#define g6 77
#define h6 78
#define a7 81
#define b7 82
#define c7 83
#define d7 84
#define e7 85
#define f7 86
#define g7 87
#define h7 88
#define a8 91
#define b8 92
#define c8 93
#define d8 94
#define e8 95
#define f8 96
#define g8 97
#define h8 98
typedef s8 TSch[12*10];
 /* Klasicka sachovnice 12*10 */
typedef struct {
u8 roch;  /* binarne 00...00vmVM */
	   /* V,v - moznost velke rosady bileho a cerneho
	      M,m - totez s malou  */
u8 mimoch;  /* Pole, na nemz stoji pesec tahnuvsi v predchozim tahu o 2,
	     nebo 0 pokud se minule netahlo pescem o 2 */
 bool bily;    /* Je bily na tahu ?*/
 TSch sch;} TPozice;
#define MaxHloubkaPropoctu 30
/* Horni odhad delky vetve stromu propoctu - kvuli velikosti
   datovych struktur */
#define TahuZPozice 64
/* Tohle neni zadny horni odhad. Jen kvuli velikosti zasobniku
 tahu.*/
#define HloubkaZasobnikuTahu (TahuZPozice*MaxHloubkaPropoctu)
/* Kolik tahu na zasobniku */
typedef struct {u16 data;  s16 cena;} TTah1;
/* Format TTah1::data:   def.: Nenormalni tah je
1) rosada
2) promena pesce
3) brani mimochodem
  def.: Normalni tah je kazdy tah, ktery neni nenormalni.
   Zbesily format TTah1.data je dusledkem me snahy o malou velikost TTah1
   a efektivni rutiny zejmena pro normalni tahy. (Nebot se s timto typem
   pocita v rekurzi a normalni tahy jsou skoro vsechny)
   binarne  1234567812345678
	        nmoooooookkkkkkk (normalni tah a brani mimochodem)
	        nmrcv00000000000 (rosada)
	        nmrcppoookkk0000 (promena pesce)
n - Je to nenormalni tah ?
  Pokud ne (tj. tah je normalni), je m=0 (MUSI byt 0) a ooooooo a kkkkkkk
   ma vyznam poli odkud a kam se tahne.
  Pokud ano (tj. tah je nenormalni):
   m - Je to rosada nebo promena pesce ?
    Pokud ne (tj. je to brani mimochodem) ma ooooooo a kkkkkkk tak‚ vyse
     uvedeny vyznam.
   Pokud ano:
    r - Je to rosada ?
     Pokud ano, potom
      c: je to rosada cerneho ? v: je to velka rosada ?
     Pokud ne (tj. je to promena pesce)
      c: je to promena cerneho pesce ?
      pp: v co se pesec meni 0=kun, 1=strelec, 2=vez, 3=dama
      ooo: cislo, ktere se musi pricist k A7 (je-li to promena bileho pesce)
	   nebo A2 (je-li to promena cerneho pesce), abychom dostali pole,
	   odkud pesec tahne
      kkk: totiz s polem promeny, jen misto A7 (resp. A2) se bere  A8
       (resp A1)

Presne v duchu predchozi definice si napisu konstanty pro rosady */
#define MBRoch (7<<13)
#define VBRoch ((7<<13)|(1<<11))
#define MCRoch (15<<12)
#define VCRoch (31<<11)
typedef struct {
u16 t;  /*data tahu*/
u8 roch;/*stav rosad pred zahranim - viz TPozice*/
u8 mimoch;/*stav mimochodem pred zahranim - viz TPozice*/
s8 brani;/*ktera figurka je tahem sebrana*/
u8 zmena;/*bylo tazeno pescem nebo bylo brani*/
u32 hashF;/*kvuli detekci opakovani*/
#ifdef STRINGTAH
char nazev[15]; /*Kvùli partiáøi*/
#endif
} TPartData;
typedef struct tpartie{
 struct tpartie *l;
 struct tpartie *p;
 TPartData data;} TPartie;
 /*Partie je obousmerny spojak tahu. Prvni uzel je nevyuzity
 - to abych mohl byt ve stavu pred zahranim tahu.*/
typedef struct{
 int VNT; /*Jsem v metodì nulového tahu ? Kolikrat vnorene ?*/
 bool NulTah; /* Smim pouzit metodu nuloveho tahu. (Napr.
 v koncovce (nebo pri ladeni :-)) ne. */
 time_t sKonceMysleni; /*Kdy mam koncit*/
 int msKonceMysleni;
 volatile bool MamKoncitMysleni;
 /*Je-li true, prestane se pocitat a vylezu z rekurze*/
} TStavPropoctu;
typedef struct{
 u32 DveNaXHash; /*Kdyz na to umocnim 2, mam velikost tabulky*/
 u32 DveNaXHashPech;/*Totez pro pescovou strukturu*/
 bool PrepisujHash;/*Mam prepisovat starsi ale hlubsi ? - normalne ano*/
} THashCfg; /*Nastaveni hash tabulek */

typedef struct {
 TTah1 tahy[HloubkaZasobnikuTahu]; /*Tahy */
 s16 hranice[MaxHloubkaPropoctu]; /* Pocatky skupin tahu
 hranice[0] by mela byt vzdy 0 */
 s16 pos; /*Prvni volna skupina (je-li 0, je zasobnik prazdny),
 ukazuje take hloubku zanoreni aktualni pozice ve stromu propoctu*/
 s8 mimoch[MaxHloubkaPropoctu];
/*Pole, na nemz stoji pesec tahnuvsi v predchozim tahu o 2,
  nebo 0 pokud se minule netahlo pescem o 2 */
 u8 roch[MaxHloubkaPropoctu];
 /*Stavy-moznosti rochovat*/
 s8 brani[MaxHloubkaPropoctu];
/*Sebrane figury tj. jaka figura byla sebrana tahem z teto pozice
 (nebylo-li tazeno, nezajimave)*/
 s16 bm[MaxHloubkaPropoctu],cm[MaxHloubkaPropoctu];
/* hodnota materialu bileho, hodnota materialu cerneho */
 s16 hodpos[MaxHloubkaPropoctu];
/* hodnoty pozice (nezahrnuje material) z hlediska bileho */
 u32 hF[MaxHloubkaPropoctu];
/* hodnoty hash funkce HashF */
 u32 hG[MaxHloubkaPropoctu];
/* hodnoty hash funkce HashF */
 u32 hPechF[MaxHloubkaPropoctu];
/* hodnoty hash funkce HashF */
 u32 hPechG[MaxHloubkaPropoctu];
/* hodnoty hash funkce HashF */
 u8 kam[MaxHloubkaPropoctu];
/* Cilova policka tahu - kvuli prohlubovani */
 u8 sach[MaxHloubkaPropoctu];
/* Je hrac na tahu v sachu ? */
 u8 zmen[MaxHloubkaPropoctu];
/* ke kolika nevratnym zmenam (tah pescem nebo brani) doslo
na ceste z korene. Jeden tah - beznem brani pescem se
pocita jako dve zmeny, to ale nevani.*/
 u8 rozsir[MaxHloubkaPropoctu];
/* ke kolika rozsirenim doslo na ceste z korene. 
 Neuvazuje se rozsireni pri jedinem pripustnem
 tahu.*/
#if 0
 u8 bkohroz[MaxHloubkaPropoctu]; /* Hrozi vazny sach
 damou bilemu krali ? */
 u8 ckohroz[MaxHloubkaPropoctu]; /* Hrozi vazny sach
 damou cernemu krali ? */
#endif
} TZasobnikTahu;
/* Je-li tedy zasobnik vynulovany byte po bytu, je "spravne prazdny" */
typedef struct{
	u32 kod; /* hash funkce pozice */
	s16 cena; /* cena pozice z hrace na tahu... */
	u8 hloubka; /* ....pri propoctu do hloubky hloubka */
	u8 priznak; /* xxxxxxHD
	 D - pozice je stejná nebo lepší než cena
	 H - pozice je stejná nebo horší než cena 
	(=> H&D - pozice má pøesnì danou hodnotu) */
} THashPrvek;
typedef struct {
	u32 kod;
	s16 cena;
	u8 b[8]; /* kde stoji bili pesci, je-li jich mene nez 8, je za poslednim 0*/
	u8 c[8]; /* kde stoji cerni pesci, je-li jich mene nez 8, je za poslednim 0*/
	u8 bt[8]; /*typ bilych pescu 0|0|izolovany|volny|kryty|vedle|opozdeny|blokovany*/
/*Opozdeny pesec je takovy, ze neni kryty pescem a policko pred nim je vicekrat
  napadeno pesci nez pokryto pesci a neni na nem pesec
 */
	u8 ct[8]; /*typ cernych pescu 0|0|izolovany|volny|kryty|vedle|opozdeny|blokovany*/
	u8  bb; /*bili na bilych polich (pocet) blokovani 2x*/
	u8  bc; /*bili na cernych polich (pocet) blokovani 2x*/
	u8  cb; /*cerni na bilych polich (pocet) blokovani 2x*/
	u8  cc; /*cerni na cernych polich (pocet) blokovani 2x*/
	u8  centr; /* pesci v centru (sloupce c az f)
	blokovani se pocitaji dvakrat*/
	u8  otsloupec; /*otevrene sloupce*/
} THashPech; /* Tohle ukladam do hash tabulky pescove struktury*/
#if 0
typedef struct{
	u32 kod; /* hash funkce pescove struktury pozice */
	s16 cena; /* cena te struktury z hlediska bileho */
    s16 nic; /* aby byla struktura na 8 B */
} THashPechPrvek;
#endif
typedef struct{
	s16 MaxPosZmena; 
/* Maximalni zmena pozicni slozka hodnoty pozice
   za jeden pultah. Uziva se k orezani ohodnocovaci
   funkce. (Aby se neprovadela oh. f. v pozicich se
   ztratou materialu.)
	*/
	s16 PesecKryty;/*Bonus za pesce kryteho jinym pescem*/
	s16 PesecVedle;/*Bonus za pesce, ktery ma vedle sebe
	jineho (Napr. e2 a d2)*/
	s16 PesecE2Blok; /*Pesec na e2/e7 a na e3/e6 je kamen*/
	s16 PesecD2Blok; /*Pesec na d2/d7 a na e3/e6 je kamen*/
	s16 DvojPesec; /*Postih za pesce, pred kterym je alespon
	jeden kolega*/
	s16 PesecIzolovany;/*Kdyz na sousednich sloupcich neni
	 pesec teze barvy*/
	s16 PesecVolny;/*Neni blokovan zadnym pescem a postoupi-li
	o 1, nebude ho moci sebrat zadny souperuv*/
	s16 PesecSlaby;/*Neni blokovan pescem ani kryty ani volny*/
	s16 SlabyPesecNapaden; /*Bonus za napadeni slabeho pesce
	(zatim jen vezi a kralem v koncovce)*/
	s16 VezNaSloupci;
	s16 hh1Bonus;
    s16 hh2Bonus;
	s16 FischeruvStrelec; /*Strelec v pasti na a2/h2 a7/h7*/
	/*Rozsirovaci meze - kdyz jsem provedl n+1 rozsireni,
	nebudu uz delat dalsi (n zavisi na typu rozsireni)*/
	u8 MaxRozsirSach; /* Rozsireni jsem-li v sachu*/
	u8 MaxRozsirPredstav; /* Rozsireni pri kryti sachu predstavenim*/
#if 0
	u8 MaxRozsirHrozba;/* Rozsireni pri hrozbe damou*/
#endif
	u8 MaxRozsirDober;/* Rozsireni pri brani berouci figury*/
	u8 MaxRozsirPesec7;/* Rozsireni v listu pri postupu pesce na 7. / 2. radu*/
	u8 MaxRozsirFischer;/* Rozsireni pri pasti na strelce (1. partie Spasskij - Fischer)*/
	u8 MaxHloubkaABB; /*Dopocet do tiche pozice*/
	u8 PovolHash; /*Ma se vubec uvazovat hash tabulka ?*/
	u8 PovolPechHash; /*Ma se vubec uvazovat hash tabulka pescu ?*/
    u8 PovolNullTah; /*Povolit nulovy tah*/
}TAlgKoef;

typedef struct{
 TAlgKoef AlgKoef;
 /*Jednoduche (ne pole) koeficienty*/
 s16 bp[h7+1],cp[h7+1];
 /*bily, cerny pesec*/
 s16 bpv[h7+1],cpv[h7+1];
 /*bily, cerny volny pesec - aditivum k bp a cp*/
 s16 bkz[h8+1],ckz[h8+1],kk[h8+1];
 /*bily, cerny kral v zahajeni, libovolny kral v koncovce*/
 s16 bj[h8+1],cj[h8+1];
 /*bily, cerny kun*/
 s16 bs[h8+1],cs[h8+1];
 /*bily, cerny strelec*/
} TAlgCfg;
typedef struct {
/* Na kterem sloupci jsou bili/cerni pesci*/
 u8 BPSloupec[8];
 u8 CPSloupec[8];
/* u8 BVSloupec[8];
 u8 CVSloupec[8];*/
 u8 b[5]; /*Pocet figur bileho - pesec..dama*/
 u8 c[5]; /*Totez pro cerneho*/
 u8 bk, ck; /*Kde jsou kralove*/
} TMaterial;
typedef u8 TVazby[8];
/*napr. NalezBileVazby spravne vyplni, obshuje policka.
Neni-li jich vsech 8, je za posledni 0*/
typedef u32 TRemPol[101];
typedef struct {
 TRemPol RemPol;
 int poc;
} TRemTab;/*Tabulka pozic z partie, ktere mohou nastat v propoctu
(kvuli detekci remiz v propoctu)*/
typedef struct {
 TPozice pozice; /*V ni probiha propocet*/
 TZasobnikTahu zasobnik;/*Zasobnik pro rekurzivni propocet*/
 TRemTab RemTab;/*Tabulka pozic z partie, ktere mohou nastat v propoctu
(kvuli detekci remiz v propoctu)*/
 TMaterial material;/*Inkrementalne pocitane veci, hlavne material*/
 u16 hh[MaxHloubkaPropoctu][2];
 /*
 Historicka heuristika
 Tah, ktery byl v jedne vetvi propoctu dobry, bude nejspis dobry
 i v jine vetvi na stejne urovni. [propocet][1. nejlepsi, 2. nejlepsi]
 Prida se jako bonus. (Uziti - v trideni po vygenerovani)
 */
 u8 HistHeur[1<<16];
 /* Jina hist. heur. Pole je indexovane primo kody tahu,
 kdyz je nejaky nejlepsi dostane bonus. (Uziti - v trideni po vygenerovani)*/
 u16 hvar[MaxHloubkaPropoctu][MaxHloubkaPropoctu];
 /*Co nalezi k hlavni variante (dalsi bonus)*/
 TStavPropoctu StavPropoctu;
 /*stav nuloveho tahu a ukoncovani*/
 THashCfg HashCfg;
 /*nastaveni hash tabulek*/
 TPartie *prt;
 /*partie*/
 int KonecPartie;
 /*je partie ukoncena*/
 THashPrvek *ht;
 /*hlavni hash tabulka*/
 THashPech *hpt;
 /*hash tabulka struktury pescu*/
 TAlgCfg AlgCfg;
 /*nastaveni algoritmu*/
 TVazby Vazby;
 /*kde jsou jake vazby (kvuli spec. pripadum v generatoru)*/
 } TUloha;
/* Je treba si pripravit reentrantnost. Mozna nekdy v budoucnu
   bude vysledek dll (pro wokna nebo unix),
   takze vsechny promenne, ktere by jinak byly globalni, si zabalim do
   jedne strukturky (pak budu mit seznam tehto struktur) */
#define mat 30000
/*Konstanta pro hodnotu pozice*/
extern const TPozice ZakladniPostaveni;
/*inicializacni konstantni promenna*/
extern const TAlgKoef STDAlgKoef;
/*inicializacni konstantni promenna*/
#ifdef Vypisy
extern int ABVH;
/*hloubka pripadnych ladicich vypisu*/
#endif
#define MAX(X,Y)((X)>(Y)?(X):(Y))
#define MIN(X,Y)((X)<(Y)?(X):(Y))
/*obecne uzitecna makra*/
#endif

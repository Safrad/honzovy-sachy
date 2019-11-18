/*********************************************************/
/* cotyvar.c - zakladni globalni promenne                */
/* 6.1. 2000 Jan Nemec                                   */
/*********************************************************/
#include "volby.h"
#include "cotyvar.h"
const TPozice ZakladniPostaveni=
/*Konstantni promenna uzita pri inicializaci*/
 {15/*vsechny rosady*/, 0/*ne mimochodem*/, 1, /*hraje bily*/
 { 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,   4,   2,   3,   5,   6,   3,   2,   4, 100, /* 1 */
   100,   1,   1,   1,   1,   1,   1,   1,   1, 100, /* 2*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 3*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 4*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 5*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 6*/
   100,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 100, /* 7*/
   100,  -4,  -2,  -3,  -5,  -6,  -3,  -2,  -4, 100, /* 8*/
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100
 }};
const TAlgKoef STDAlgKoef={
/*Bezne nastaveni mysliciho algoritmu.
  Neni zde vsechno, tabulkove koeficienty jsou v ohodnoc.c
  a jen za bileho (pro cerneho se dopocitaji dle symetrie).*/	
/*	s16 MaxPosZmena; 
   Maximalni zmena pozicni slozka hodnoty pozice
   za jeden pultah. Uziva se k orezani ohodnocovaci
   funkce. (Aby se neprovadela oh. f. v pozicich se
   ztratou materialu.)
	*/
	40,
	/*s16 PesecKryty; Bonus za pesce kryteho jinym pescem*/
	4,
	/*s16 PesecVedle;Bonus za pesce, ktery ma vedle sebe
	jineho (Napr. e2 a d2)*/
	2,
	/*s16 PesecE2Blok; Pesec na e2/e7 a na e3/e6 je kamen*/
	-10,
	/*s16 PesecD2Blok; Pesec na d2/d7 a na e3/e6 je kamen*/
	-10,
	/*s16 DvojPesec; Postih za pesce, pred kterym je alespon
	jeden kolega*/
	-7,
	/*s16 PesecIzolovany;Kdyz na sousednich sloupcich neni
	 pesec teze barvy*/
	-5,
/*	 s16 PesecVolny;Neni blokovan zadnym pescem a postoupi-li
	o 1, nebude ho moci sebrat zadny souperuv*/
	 5,
	/*s16 PesecSlaby;Neni blokovan pescem ani kryty ani volny*/
    -3,
	/*s16 SlabyPesecNapaden; Bonus za napadeni slabeho pesce
	(zatim jen kralem a jen v koncovce)*/
	6,
	/*s16 VezNaSloupci;*/
	4,
	/* s16 hh1Bonus;*/
	150,
	/* s16 hh2Bonus;*/
	75,
/*	s16 FischeruvStrelec; /*Strelec v pasti na a2/h2 a7/h7*/
   -60,
	/*u8 MaxRozsirSach;  Rozsireni jsem-li v sachu*/
	5,
	/*u8 MaxRozsirPredstav;  Rozsireni pri kryti sachu predstavenim*/
	5,
#if 0
	/*u8 MaxRozsirHrozba; Rozsireni pri hrozbe damou*/
	2,
#endif
	/*u8 MaxRozsirDober; Rozsireni pri brani berouci figury*/
	4,
	/*u8 MaxRozsirPesec7; Rozsireni v listu pri postupu pesce na 7. / 2. radu*/
	2,
	/*u8 MaxRozsirFischer; Rozsireni pri pasti na strelce (1. partie Spasskij - Fischer)*/
	4,
	/*u8 MaxHloubkaABB; /*Dopocet do tiche pozice*/
	4,
    /*u8 PovolHash; /*Ma se vubec uvazovat hash tabulka ?*/
	true,
  /*u8 PovolPechHash; /*Ma se vubec uvazovat hash tabulka pescu ?*/
	true,
   /* u8 PovolNullTah; /*Povolit nulovy tah*/
    true
};
#ifdef Vypisy
int ABVH=1;
/*
Pokud mam ladici vypisy, jak maji jit hluboko v rekurzi
*/
#endif

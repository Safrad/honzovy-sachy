/*********************************************************/
/* ohodnoc.c - ohodnocovaci funkce                       */
/* 13.1. 2001 Jan Nemec                                  */
/*********************************************************/
#include "volby.h"
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#if Typ_Produktu==DOS_UNIX
#include "dosio.h"
#endif
#include "generato.h"
#include "hashtab.h"
#include "hashpech.h"
#include "cotyvar.h"
#include "myslitel.h"
#include "ohodnoc.h"

u8 XPole[h8+1]=

{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,   0,   1,   2,   3,   4,   5,   6,   7, 100, /* 1*/
   100,   0,   1,   2,   3,   4,   5,   6,   7, 100, /* 2*/
   100,   0,   1,   2,   3,   4,   5,   6,   7, 100, /* 3*/
   100,   0,   1,   2,   3,   4,   5,   6,   7, 100, /* 4*/
   100,   0,   1,   2,   3,   4,   5,   6,   7, 100, /* 5*/
   100,   0,   1,   2,   3,   4,   5,   6,   7, 100, /* 6*/
   100,   0,   1,   2,   3,   4,   5,   6,   7, 100, /* 7*/
   100,   0,   1,   2,   3,   4,   5,   6,   7 }; /* 8*/

u8 YPole[h8+1]=

{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 1*/
   100,   1,   1,   1,   1,   1,   1,   1,   1, 100, /* 2*/
   100,   2,   2,   2,   2,   2,   2,   2,   2, 100, /* 3*/
   100,   3,   3,   3,   3,   3,   3,   3,   3, 100, /* 4*/
   100,   4,   4,   4,   4,   4,   4,   4,   4, 100, /* 5*/
   100,   5,   5,   5,   5,   5,   5,   5,   5, 100, /* 6*/
   100,   6,   6,   6,   6,   6,   6,   6,   6, 100, /* 7*/
   100,   7,   7,   7,   7,   7,   7,   7,   7 }; /* 8*/

s8 OpacnePole[h8+1]=

{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,  91,  92,  93,  94,  95,  96,  97,  98, 100, /* 1 */
   100,  81,  82,  83,  84,  85,  86,  87,  88, 100, /* 2*/
   100,  71,  72,  73,  74,  75,  76,  77,  78, 100, /* 3*/
   100,  61,  62,  63,  64,  65,  66,  67,  68, 100, /* 4*/
   100,  51,  52,  53,  54,  55,  56,  57,  58, 100, /* 5*/
   100,  41,  42,  43,  44,  45,  46,  47,  48, 100, /* 6*/
   100,  31,  32,  33,  34,  35,  36,  37,  38, 100, /* 7*/
   100,  21,  22,  23,  24,  25,  26,  27,  28 }; /* 8*/


s8 BelostPole[h8+1]=

{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,   0,   1,   0,   1,   0,   1,   0,   1, 100, /* 1 */
   100,   1,   0,   1,   0,   1,   0,   1,   0, 100, /* 2*/
   100,   0,   1,   0,   1,   0,   1,   0,   1, 100, /* 3*/
   100,   1,   0,   1,   0,   1,   0,   1,   0, 100, /* 4*/
   100,   0,   1,   0,   1,   0,   1,   0,   1, 100, /* 5*/
   100,   1,   0,   1,   0,   1,   0,   1,   0, 100, /* 6*/
   100,   0,   1,   0,   1,   0,   1,   0,   1, 100, /* 7*/
   100,   1,   0,   1,   0,   1,   0,   1,   0 }; /* 8*/

s8 StdCenaB[6][h8+1]=
/* Pesec */{
{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 1 */
   100,   0,   0,  -1, - 8, - 8,   0,   0,   0, 100, /* 2*/
   100,   1,   1,   1,   4,   4,   0,   1,   1, 100, /* 3*/
   100,   1,   1,   6,   8,   8,   6,   1,   1, 100, /* 4*/
   100,   4,   4,   6,  10,  10,   3,   4,   4, 100, /* 5*/
   100,  10,  10,  10,  15,  15,  10,  10,  10, 100, /* 6*/
   100,  20,  20,  20,  20,  20,  20,  20,  20, 100, /* 7*/
   100,   0,   0,   0,   0,   0,   0,   0,   0 }, /* 8*/

/* Kun */
{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100, -10,  -4,  -3,  -2,  -2,  -3,  -4, -10, 100, /* 1 */
   100,  -5,  -5,  -3,   0,   0,  -3,  -5,  -5, 100, /* 2*/
   100,  -3,   0,   3,   5,   5,   3,   0,  -3, 100, /* 3*/
   100,  -2,   5,   5,   7,   7,   5,   5,  -2, 100, /* 4*/
   100,   0,   5,   6,   8,   8,   6,   5,   0, 100, /* 5*/
   100,   5,   6,   7,   8,   8,   7,   6,   5, 100, /* 6*/
   100,   0,   5,   6,   8,   8,   6,   5,   0, 100, /* 7*/
   100, -10,  -5,  -2,   0,   0,  -2,  -5, -10 }, /* 8*/
/* Kral */
{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,  10,  15,  13,  -5,   0,  -5,  17,  12, 100, /* 1 */
   100,  -5,  -5, -10, -15, -15, -10,  -5,  -5, 100, /* 2*/
   100, -15, -15, -18, -20, -20, -18, -15, -15, 100, /* 3*/
   100, -30, -30, -30, -30, -30, -30, -30, -30, 100, /* 4*/
   100, -30, -30, -30, -30, -30, -30, -30, -30, 100, /* 5*/
   100, -30, -30, -30, -30, -30, -30, -30, -30, 100, /* 6*/
   100, -30, -30, -30, -30, -30, -30, -30, -30, 100, /* 7*/
   100, -30, -30, -30, -30, -30, -30, -30, -30}, /* 8*/
   /* Kral v koncovce */
{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100, -20, -15, -12, -10, -10, -12, -15, -20, 100, /* 1 */
   100, -15, -12,  -7,   0,   0,  -7, -12, -15, 100, /* 2*/
   100, -12,  -7,   1,   5,   5,   1,  -7, -12, 100, /* 3*/
   100, -10,   0,   5,  10,  10,   5,   0, -10, 100, /* 4*/
   100, -10,   0,   5,  10,  10,   5,   0, -10, 100, /* 5*/
   100, -12,  -7,   1,   5,   5,   1,  -7, -12, 100, /* 6*/
   100, -15, -12,  -7,   0,   0,  -7, -12, -15, 100, /* 7*/
   100, -20, -15, -12, -10, -10, -12, -15, -20}, /* 8*/
   /* Strelec */
{  100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,  -5,  -4,  -3,  -2,  -2,  -3,  -4,  -5, 100, /* 1 */
   100,  -5,   6,  -2,   5,   5,  -2,   6,  -5, 100, /* 2*/
   100,   0,   0,   1,   5,   5,   1,   0,   0, 100, /* 3*/
   100,   0,   2,   5,   5,   5,   5,   5,   0, 100, /* 4*/
   100,   0,   5,   6,   8,   8,   6,   5,   0, 100, /* 5*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 6*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 7*/
   100,  -5,   0,   0,   0,   0,   0,   0,  -5 }, /* 8*/
/* Volny pesec (aditivum)*/{
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
   /*     a    b    c    d    e    f    g    h*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 1 */
   100,   2,   2,   2,   2,   2,   2,   2,   2, 100, /* 2*/
   100,   3,   3,   3,   3,   3,   3,   3,   3, 100, /* 3*/
   100,   4,   4,   4,   4,   4,   4,   4,   4, 100, /* 4*/
   100,   7,   7,   7,   7,   7,   7,   7,   7, 100, /* 5*/
   100,   8,   8,   8,   8,   8,   8,   8,   8, 100, /* 6*/
   100,   0,   0,   0,   0,   0,   0,   0,   0, 100, /* 7*/
   100,   0,   0,   0,   0,   0,   0,   0,   0 } /* 8*/

};
static s16 KonCenyPescu[8]={0,-30,-28,-8,10,30,50,0};
int Sum(int maxabs){
/* Vrati nahodne cele cislo z intervalu (-maxabs,maxabs)
   z rozdeleni, kde hustota linearne roste od -maxabs,
   kde je 0 k 0, kde je nejvyssi a pak linearne klesa
   k maxabs, kde je nula. Jde o jakousi velmi spatnou
   aproximaci binomickeho rozdeleni.
*/
 int i,j,m;
 
 if(maxabs<=0) return 0;
 m=maxabs*maxabs;
 i=rand()%m;
 for(j=0;j<=maxabs;j++){i-=j; if(i<=0)return j-maxabs+1;}
 for(j=maxabs-1;j>1;j++){i-=j; if(i<=0)return maxabs-j;}
 return maxabs-1;
}
void NastavAlgCfgStd(TAlgCfg *a){
/*************************************/
/* nastavi TAlgCfg na bezne hodnoty  */
/*************************************/
 int i;

 a->AlgKoef=STDAlgKoef;
 for(i=a2;i<=h7;i++){
   a->bp[i]=StdCenaB[0][i];
   a->bpv[i]=StdCenaB[5][i];
  }
 for(i=1;i<=6;i++){
  memcpy(a->cp+a1+(7-i)*10,a->bp+a1+i*10,16);
  memcpy(a->cpv+a1+(7-i)*10,a->bpv+a1+i*10,16);
 }

 for(i=a1;i<=h8;i++){
  a->bj[i]=StdCenaB[1][i];
  a->bs[i]=StdCenaB[4][i];
  a->bkz[i]=StdCenaB[2][i];
  a->kk[i]=StdCenaB[3][i];
  }
 for(i=0;i<=7;i++){
  memcpy(a->cj+a1+(7-i)*10,a->bj+a1+i*10,16);
  memcpy(a->cs+a1+(7-i)*10,a->bs+a1+i*10,16);
  memcpy(a->ckz+a1+(7-i)*10,a->bkz+a1+i*10,16);
  }
   
}


#if 0
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
#endif
void ZasumAlgCfg(TAlgCfg *a, int sum){
/*******************/
/* zasumi TAlgCfg  */
/*******************/
 int i;

 a->AlgKoef.PesecKryty+=Sum(sum);
 a->AlgKoef.PesecVedle+=Sum(sum);
 a->AlgKoef.PesecE2Blok+=Sum(sum);
 a->AlgKoef.PesecD2Blok+=Sum(sum);
 a->AlgKoef.DvojPesec+=Sum(sum);
 a->AlgKoef.PesecIzolovany+=Sum(sum);
 a->AlgKoef.PesecVolny+=Sum(sum);
 a->AlgKoef.PesecSlaby+=Sum(sum);
 a->AlgKoef.SlabyPesecNapaden+=Sum(sum);
 a->AlgKoef.VezNaSloupci+=Sum(sum);
 a->AlgKoef.FischeruvStrelec+=Sum(sum);

 for(i=a2;i<=h7;i++){
   a->bp[i]+=Sum(sum/2);
   a->bpv[i]+=Sum(sum/2);
   a->cp[i]+=Sum(sum/2);
   a->cpv[i]+=Sum(sum/2);
  }
 
 for(i=a1;i<=h8;i++){
  a->bj[i]+=Sum(sum);
  a->bs[i]+=Sum(sum);
  a->bkz[i]+=Sum(sum);
  a->kk[i]+=Sum(sum);
  a->cj[i]+=Sum(sum);
  a->cs[i]+=Sum(sum);
  a->ckz[i]+=Sum(sum);
  }
}

bool ChytiBilehoPesce(int CernyKral, int BilyPesec, bool HrajeBily){
/* Vsechny figurky musi byt pochopitelne na sachovnici
 a pesec nekde mezi druhou a sedmou radou (vcetne.)*/
 int kcx, kcy, pbx, pby;

 if(HrajeBily)BilyPesec+=10;
 /*ted posuzuji, jako by byl na tahu cerny*/
 kcx=XPole[CernyKral];
 kcy=YPole[CernyKral];
 pbx=XPole[BilyPesec];
 pby=YPole[BilyPesec];
 if(pby>kcy+1 || abs(kcx-pbx)>8-pby)return false;
 return true;
}

#define Koncovka 0
#define BilyMacen 1 
#define CernyMacen 2
#define StredniHra 3

s16 HodnotaPozice(TUloha *u,s16 alfa,s16 beta){
/*****************************************/
/* Vrati hodnotu pozice mezi alfa a beta */
/*****************************************/
 /*na u->zasobnik.hodpos[u->zasobnik.pos] ulozi 
   1) nedojde-li k orezani hodnotu pozice else
    2) nejsem-li v koreni u->zasobnik.hodpos[u->zasobnik.pos-1] else
	 3) 0
   */

 s16 h,s, /* sem postupne pricitam pozicni faktory k materialu */
 stara, /* stara pozice bez materialu (kvuli prorezani) */
 material,bm,cm;
 s8 *ph8,*p,*pom,*pzaklad;
 bool bily;
 int hloubka,typ,i,j;
 THashPech *php;

#ifdef Statistika
	OH++;
#endif
  
 bily=u->pozice.bily;
 hloubka=u->zasobnik.pos;
 
 if(hloubka)stara=(s16)
	 u->zasobnik.hodpos[hloubka-1];
 bm=u->zasobnik.bm[hloubka];
 cm=u->zasobnik.cm[hloubka];
 material=h=(s16)(bm-cm);
 if(!bily){h=(s16)-h;stara=(s16)-stara;}
 /*  Kdyz jsem blizko matu, nema smysl hodnotit pozici */
   if (alfa > mat-255 || beta < -mat+255)
      goto Konec; 
/* Nasleduje orezani
 Kdyz novy material + pozice pred pultahem je moc velke
 nebo moc male, ani to nepocitej */

 if(hloubka){
  if(h+u->AlgCfg.AlgKoef.MaxPosZmena+stara<=alfa){h=alfa;goto Konec;}
  if(h-u->AlgCfg.AlgKoef.MaxPosZmena+stara>=beta){h=beta;goto Konec;}
 }

#ifdef Statistika
	OH2++;
#endif

 pzaklad=u->pozice.sch;
 ph8=pzaklad+h8;


if(!u->AlgCfg.AlgKoef.PovolPechHash) {
 php=u->hpt;
 goto NeniTam; 
 }
 php=u->hpt+(u->zasobnik.hPechF[hloubka]&
		((1<<u->HashCfg.DveNaXHashPech)-1));
 if(php->kod==u->zasobnik.hPechG[hloubka])goto JeTam;

  NeniTam:;
#ifdef Statistika
	OHP++;
#endif
  NastavPesce(u,php);
  JeTam:;
 s=php->cena;
 if(*(pzaklad+e2)==1 && *(pzaklad+e3))s+=u->AlgCfg.AlgKoef.PesecE2Blok;
 if(*(pzaklad+d2)==1 && *(pzaklad+d3))s+=u->AlgCfg.AlgKoef.PesecD2Blok;
 if(*(pzaklad+e7)==-1 && *(pzaklad+e6))s-=u->AlgCfg.AlgKoef.PesecE2Blok;
 if(*(pzaklad+e7)==-1 && *(pzaklad+d6))s-=u->AlgCfg.AlgKoef.PesecD2Blok;
 
 bm-=StdCenyFigur[6];
 cm-=StdCenyFigur[6];
 if(bm>=550 && cm>=550)typ=StredniHra;
 if(bm<350 && bm<cm-200)typ=BilyMacen;else
 if(cm<350 && cm<bm-200)typ=CernyMacen;else
 typ=Koncovka;
 
 if(typ==BilyMacen || typ==CernyMacen){
  div_t bk,ck;
  
  bk=div(u->material.bk-a1,10);
  ck=div(u->material.ck-a1,10);
  i=abs(bk.rem-ck.rem)+abs(bk.quot-ck.quot)-3;
  if(i<0)i++;
  i=14-i;
  if(typ==CernyMacen){
  s+=i*5; 
  s-=u->AlgCfg.kk[u->material.ck];
  }
  else{
   s-=i*5;
   s+=u->AlgCfg.kk[u->material.bk];
  }
 }
 {/*Nasleduje test na utekle volne pesce*/
 int NejBileho=0,NejCerneho=0;
 for(i=1;i<=4;i++) if(u->material.c[i]||u->material.b[i]){i=0;break;}
 if(i){ /*Pokud nejsou figury, jen kralove a pesci...*/
 j=u->material.b[0];
  for(i=0;i<j;i++){
   if(!((php->bt[i])&16)|| /*pesec neni volny*/
   ChytiBilehoPesce(u->material.ck,php->b[i],u->pozice.bily)) /* nebo jde zastavit*/
   continue; 
   NejBileho=MAX(NejBileho, YPole[php->b[i]]);
   }
 j=u->material.c[0];
  for(i=0;i<j;i++){
   if(!((php->ct[i])&16)|| /*pesec neni volny*/
   ChytiBilehoPesce(OpacnePole[u->material.bk],OpacnePole[php->c[i]],!u->pozice.bily)) /* nebo jde zastavit*/
   continue; 
   NejCerneho=MAX(NejCerneho, 7-YPole[php->c[i]]);
   }
 if(NejBileho>NejCerneho+1)s+=((NejBileho<<4)+256); else
 if(NejBileho<NejCerneho-1)s-=(((7-NejCerneho)<<4)+256);
}
 }
 for(p=pzaklad+a1;p<=ph8;p++)
  switch(*p){
   case 0:continue;
   case 100:continue;
   case 1:continue;
   case -1:continue;
   case 2:s+=u->AlgCfg.bj[p-pzaklad];break;
   case -2:s-=u->AlgCfg.cj[p-pzaklad];break;
   case 3:
   if((p==pzaklad+a7 ||p==pzaklad+b8) && *(pzaklad+b6)==1 && *(pzaklad+c7)==1 ||
      (p==pzaklad+h7 ||p==pzaklad+g8) && *(pzaklad+g6)==1 && *(pzaklad+f7)==1)
	    s+=u->AlgCfg.AlgKoef.FischeruvStrelec;
		/*Strelec v pasti*/
	s+=((BelostPole[p-pzaklad] ? php->cb : php->cc)<<1);
	/*strelec je dobry, kdyz ma barvu souperovych pescu*/
    s+=u->AlgCfg.bs[p-pzaklad];break;
   case -3:
   if((p==pzaklad+a2 ||p==pzaklad+b1) && *(pzaklad+b3)==-1 && *(pzaklad+c2)==-1 ||
       (p==pzaklad+h2 ||p==pzaklad+g1) && *(pzaklad+g3)==-1 && *(pzaklad+f2)==-1)
	    s-=u->AlgCfg.AlgKoef.FischeruvStrelec;
		/*Strelec v pasti*/
   s-=((BelostPole[p-pzaklad] ? php->bb : php->bc)<<1);
   /*strelec je dobry, kdyz ma barvu souperovych pescu*/
   s-=u->AlgCfg.cs[p-pzaklad];break;
   case 4:
    j=XPole[p-pzaklad];
	if(!u->material.CPSloupec[j]) /*Vez na volnem sloupci*/
	 {if(!u->material.BPSloupec[j])s+=u->AlgCfg.AlgKoef.VezNaSloupci;}
	 else
	{
	for(i=-10;i<=10;i+=20){ /* Po sloupci nahoru a dolu */
	 for(pom=p+i;!*pom;pom+=i);
      if(*pom==-1)
	   for(j=0;j<u->material.c[0];j++)
		if(php->c[j]==(pom-pzaklad)){
	     if(php->ct[j]&2)/*Napada opozdeneho pesce*/
	    s+=u->AlgCfg.AlgKoef.SlabyPesecNapaden;
		break;
	 }
	 }
	}/* od else*/
    break;
   case -4:
    j=XPole[p-pzaklad];
	if(!u->material.BPSloupec[j]) /*Vez na volnem sloupci*/
	 {if(!u->material.CPSloupec[j])s-=u->AlgCfg.AlgKoef.VezNaSloupci;}
	 else
	{
	for(i=-10;i<=10;i+=20){ /* Po sloupci nahoru a dolu */
	 for(pom=p+i;!*pom;pom+=i);
      if(*pom==1)
	   for(j=0;j<u->material.b[0];j++)
		if(php->b[j]==(pom-pzaklad)){
	     if(php->bt[j]&2)/*Napada opozdeneho pesce*/
	    s-=u->AlgCfg.AlgKoef.SlabyPesecNapaden;
		break;
	 }
	 }
	}/* od else*/
    break;
   case 6:
    if(u->zasobnik.bm[hloubka]>StdCenyFigur[6]+700)s+=u->AlgCfg.bkz[p-pzaklad];
	else s+=u->AlgCfg.kk[p-pzaklad];
	if(typ==Koncovka){
	 for(i=0;i<8;i++)
	  if(*(p+ofsety[i])==-1){/*Kral napada pesce*/
	   for(j=0;j<u->material.c[0];j++)
	    if(php->ct[j]&2 && php->c[j]==(p-pzaklad)+ofsety[i])/*Napada opozdeneho pesce*/
		 s+=u->AlgCfg.AlgKoef.SlabyPesecNapaden;
	  }
	}
	break;
   case -6:
    if(u->zasobnik.cm[hloubka]>StdCenyFigur[6]+700)s-=u->AlgCfg.ckz[p-pzaklad];
	else s-=u->AlgCfg.kk[p-pzaklad];
	if(typ==Koncovka){
	 for(i=0;i<8;i++)
	  if(*(p+ofsety[i])==1){/*Kral napada pesce*/
	   for(j=0;j<u->material.b[0];j++)
	    if(php->bt[j]&2 && php->b[j]==(p-pzaklad)+ofsety[i])/*Napada opozdeneho pesce*/
		 s-=u->AlgCfg.AlgKoef.SlabyPesecNapaden;
	  }
	}

	break;
  }
 if(bily)h+=s;else h-=s;

 u->zasobnik.hodpos[hloubka]=(bily ?  h : - h)-material;
 goto ven;
Konec:
 u->zasobnik.hodpos[hloubka]=hloubka ? u->zasobnik.hodpos[hloubka-1] : 0;
ven:
 return (h<alfa ? alfa : (h>beta ? beta : h));
}

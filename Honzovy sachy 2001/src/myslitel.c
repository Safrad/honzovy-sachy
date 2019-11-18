/*********************************************************/
/* myslitel.c - rekurzivni propocet (alfabeta)           */
/* 10.1. 2001 Jan Nemec                                   */
/*********************************************************/
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "volby.h"
#include "cotyvar.h"
#include "dosio.h"
#include "chyba.h"
#include "generato.h"
#include "globruti.h"
#include "knihovna.h"
#if Typ_Produktu==DOS_UNIX
#include <stdio.h>
#include "dosio.h"
#include "strtah.h"
#endif
#include "hashtab.h"
#include "ohodnoc.h"
#include "tabulky.h"
#include "lokruti.h"
#include "myslitel.h"
#if Typ_Produktu==Win32_Program
#include "kontrola.h"
#include "winmysl.h"
#include <windows.h>
#endif
#ifdef unix
#include <sys/timeb.h>
#endif
#if Typ_Produktu==Projekt
#include "scio.h"
#endif
#define SebranyKral 10000
/* Konstanta urcujici hranici pro hodnotu pozice:
     abs(hodnota)>SebranyKral    =>  nekdo nema krale
     else oba maji krale
   Zavisi na ohodnoceni figur  */

#define PISDOHISTHEUR(u,t,x)\
{if((u)->HistHeur[(u16)(t)]+x<=255)\
(u)->HistHeur[(u16)(t)]+=(MIN((x),10));\
else {(u)->HistHeur[(u16)(t)]=255;PulHistHeur(u);}}
/*Zapis do tabulek historicke heuristiky v uloze u
nejlepsi tah t na pozici
prida x tak, aby nepreteklo*/

bool MamKnihovnu=false; /*Pri inicializaci se (zrejme)
prepise na true*/

#ifdef Statistika
u32 NTU[MaxHloubkaPropoctu],
    NTN[MaxHloubkaPropoctu],
	MS,OH,OH2,OHP,UZ,S2U,S2N,
	AB[MaxHloubkaPropoctu],
	PR[MaxHloubkaPropoctu],
	ABB[MaxHloubkaPropoctu],
	HU[MaxHloubkaPropoctu];
#endif

void NastavCas(int ms, TUloha *u){
/* Nastavi cas tak, aby program koncil premysleni
za ms milisekund od doby vyvolani funkce */
#ifdef unix /*Je smutne, ze tohle nejde napsat implementacne
nezavisle... */
struct timeb t;

(void)ftime(&t);
u->StavPropoctu.sKonceMysleni=t.time+ms/1000;
u->StavPropoctu.msKonceMysleni=t.millitm+ms%1000;
if(u->StavPropoctu.msKonceMysleni>=1000){
 u->StavPropoctu.msKonceMysleni-=1000;
 u->StavPropoctu.sKonceMysleni++;
 }
#else
/*Kdyz nejsme na unixu, spocitam aspon neco podobneho
-ale neni to totez clock() pocita jen cas, kdy je proces
na procesoru
*/
u->StavPropoctu.msKonceMysleni=(clock()*1000)/CLK_TCK+ms;
#endif
}
void DotazNaCas(TUloha *u){
#ifdef unix
struct timeb t;
(void)ftime(&t);
if(t.time>u->StavPropoctu.sKonceMysleni ||
 t.time==u->StavPropoctu.sKonceMysleni && t.millitm>u->StavPropoctu.msKonceMysleni)
u->StavPropoctu.MamKoncitMysleni=true; 
#else
if((clock()*1000)/CLK_TCK>u->StavPropoctu.msKonceMysleni)u->StavPropoctu.MamKoncitMysleni=true;
#endif
}

static void PulHistHeur(TUloha *u){
/**********************************************/
/* Po preteceni se vydeli hist. heur. ctyrmi  */
/**********************************************/
 int i;
 for(i=0;i<(1<<16);i++)u->HistHeur[i]>>=2;
}

int cmprem (const void *ho1, const void *ho2){
/**********************/
/* funkce pro qsort() */
/**********************/
 return (*((u32 *)ho1)<*((u32 *)ho2) ? 
 1 : (*((u32 *)ho1)>*((u32 *)ho2) ? -1 : 0));
}
static void NastavRemTab(TUloha *u){
/************************************************/
/* Nastavi tabulku hodnot hash funkce pro       */
/* detekci opakovani pozic z partie v propoctu  */
/************************************************/
 int i;
 TPartie *prt;

 prt=u->prt;
 for(i=0;i<100;i++)
  {
   u->RemTab.RemPol[i]=prt->data.hashF;
   if(prt->data.zmena) break;
   prt=prt->l;
   if(!prt) break;
  }
 u->RemTab.poc=i+1;
 hassert(u->RemTab.poc<=100,"Mimo pole RemPol");
 u->RemTab.RemPol[u->RemTab.poc]=0;
  qsort((void *)(u->RemTab.RemPol),u->RemTab.poc,sizeof(u32),cmprem);
}

static bool PrtOpakRemis(TUloha *u, u32 hF){
 u32 *p=u->RemTab.RemPol;

 if(hF) while(hF<*p)p++; else p+=(u->RemTab.poc-1);
 hassert(p-u->RemTab.RemPol<101,"Mimo pole RemPol");
 return hF==*p;
}

static s16 UpravHodPos(TUloha *u, s16 hodpos){
/*********************************************************/
/* UpravHodPos											 */
/* - vstup = hodnota pozice i s materialem z hlediska 	 */
/*   strany ktera je na tahu							 */
/* - vystup = hodnota pozice bez materialu z hlediska	 */
/*  bileho												 */
/*********************************************************/
	hassert(u->zasobnik.pos<MaxHloubkaPropoctu,"Hloubka propoctu");
	if(!u->pozice.bily)hodpos=(s16)-hodpos;
	return (s16)(hodpos+
		u->zasobnik.cm[u->zasobnik.pos]-
		u->zasobnik.bm[u->zasobnik.pos]);
}

static s16 AlfaBeta(TUloha *uloha, s16 alfa, s16 beta, s16 hloubka
#ifdef Vypisy
	,FILE *soub
#endif
);
/* prototyp AlfaBeta neni v myslitel.h, ale je zde cyklicka
rekurze NulTah -> AlfaBeta -> NulTah */


void SectiJenMaterial(TUloha *uloha)
/*********************************************************/
/* Nastavi podle aktualni pozice polozky uloha->material */
/*********************************************************/
 {s8 *p;
  s8 *konec;
  int sloupec;

 konec=&(uloha->pozice.sch[h8]);
 (void)memset((void *)&(uloha->material),0,sizeof(TMaterial));
 for(p=&(uloha->pozice.sch[a1]),sloupec=0; p<=konec;
     sloupec=(sloupec==9 ? 0 : sloupec+1),p++)
  switch(*p){
  case 0:break;
  case 100:break;
  case  1:uloha->material.b[0]++;uloha->material.BPSloupec[sloupec]++;break;
  case -1:uloha->material.c[0]++;uloha->material.CPSloupec[sloupec]++;break;
  case  2:uloha->material.b[1]++;break;
  case -2:uloha->material.c[1]++;break;
  case  3:uloha->material.b[2]++;break;
  case -3:uloha->material.c[2]++;break;
  case  4:uloha->material.b[3]++;break;
  case -4:uloha->material.c[3]++;break;
  case  5:uloha->material.b[4]++;break;
  case -5:uloha->material.c[4]++;break;
  case  6:uloha->material.bk=p-uloha->pozice.sch;break;
  case -6:uloha->material.ck=p-uloha->pozice.sch;break;
  }
 }

void SectiMaterialBmCm(TUloha *uloha)
/*************************************************/
/* Nastavi podle aktualni pozice polozky		 */
/* uloha->zasobnik.bm[0], uloha->zasobnik.cm[0]  */
/* a uloha->material							 */
/*************************************************/
 {s8 *p;
  s8 *konec;
  int sloupec;

 uloha->zasobnik.bm[0]=0; uloha->zasobnik.cm[0]=0;
 konec=&(uloha->pozice.sch[h8]);
 (void)memset((void *)&(uloha->material),0,sizeof(TMaterial));
 for(p=&(uloha->pozice.sch[a1]),sloupec=0; p<=konec;
     sloupec=(sloupec==9 ? 0 : sloupec+1),p++){
  if(*p !=100 )
   if (*p>0)uloha->zasobnik.bm[0]+=StdCenyFigur[*p];
    else if(*p<0)uloha->zasobnik.cm[0]+=StdCenyFigur[-*p];
  switch(*p){
  case 0:break;
  case 100:break;
  case  1:uloha->material.b[0]++;uloha->material.BPSloupec[sloupec]++;break;
  case -1:uloha->material.c[0]++;uloha->material.CPSloupec[sloupec]++;break;
  case  2:uloha->material.b[1]++;break;
  case -2:uloha->material.c[1]++;break;
  case  3:uloha->material.b[2]++;break;
  case -3:uloha->material.c[2]++;break;
  case  4:uloha->material.b[3]++;break;
  case -4:uloha->material.c[3]++;break;
  case  5:uloha->material.b[4]++;break;
  case -5:uloha->material.c[4]++;break;
  case  6:uloha->material.bk=p-uloha->pozice.sch;break;
  case -6:uloha->material.ck=p-uloha->pozice.sch;break;
  }
  }
 }


static void NastavNullTah(TUloha *uloha)
/*********************************************/
/* Povoli nebo zakaze uziti nuloveho tahu    */
/* podle typu pozice (zakazuje v koncovce)   */
/*********************************************/
{
uloha->StavPropoctu.NulTah=true;
if(!uloha->AlgCfg.AlgKoef.PovolNullTah
   || !uloha->material.b[3]&&!uloha->material.b[4]&&(uloha->material.b[1]+uloha->material.b[2])<2||
 /*bily ma nejvyse jednu nejvyse lehkou figuru*/
	!uloha->material.c[3]&&!uloha->material.c[4]&&(uloha->material.c[1]+uloha->material.c[2])<2
 /*cerny ma nejvyse jednu nejvyse lehkou figuru*/
	)
	 uloha->StavPropoctu.NulTah=false;
 } 
void InitVypocet(TUloha *uloha)
/**********************************************************/
/* Inicializace pred zahajenim rekurzivniho propoctu      */
/* vola se z DejTah										  */
/**********************************************************/
 {int i;
  uloha->zasobnik.pos=0;
  SectiMaterialBmCm(uloha);
  uloha->zasobnik.hodpos[0]=UpravHodPos(uloha,HodnotaPozice(uloha,-mat,mat));
  NastavNullTah(uloha);
  uloha->zasobnik.hF[0]=HashF(&(uloha->pozice));
  uloha->zasobnik.hG[0]=HashG(&(uloha->pozice));
  uloha->zasobnik.hPechF[0]=HashPechF(&(uloha->pozice));
  uloha->zasobnik.hPechG[0]=HashPechG(&(uloha->pozice));
  /*(void)memset((void *)&(uloha->hh),0,sizeof(uloha->hh));*/
  for(i=0;i<(1<<16);i++)uloha->HistHeur[i]>>=3;
  (void)memset((void *)&(uloha->HistHeur),0,sizeof(uloha->HistHeur));
  (void)memset((void *)&(uloha->hvar[0][0]),0,sizeof(uloha->hvar));
  uloha->StavPropoctu.VNT=0;
  NastavRemTab(uloha);
#if 0
  uloha->zasobnik.bkohroz[0]=HrozbaBilemuKraliDamou(uloha);
  uloha->zasobnik.ckohroz[0]=HrozbaCernemuKraliDamou(uloha);
#endif
#ifdef Statistika
 memset((void *)AB,0,sizeof(AB));
 memset((void *)ABB,0,sizeof(ABB));
 memset((void *)NTU,0,sizeof(NTU));
 memset((void *)NTN,0,sizeof(NTN));
 memset((void *)HU,0,sizeof(NTN));
 MS=0;
 OH=0;
 OH2=0;
 OHP=0;
 UZ=0;
 S2U=0;
 S2N=0;
#endif
}

static void KopirujHVar(TUloha *uloha, u16 t)
/****************************************************/
/* Tridici heuristika - udrzovani hlavni varianty   */
/* tahu z h.v. pridam bonus                         */
/****************************************************/
{ int i,h;
   
   h=uloha->zasobnik.pos;
   hassert(h<MaxHloubkaPropoctu,"Hloubka propoctu");
   uloha->hvar[h][h]=t;
    for(i=1;;i++) {
      if(!uloha->hvar[h+1][h+i]) {
         uloha->hvar[h][h+i]=uloha->hvar[h+1][h+i];
         return;
      }
      uloha->hvar[h][h+i]=uloha->hvar[h+1][h+i];
   }
}

#define BlizKMatu(X) ((s16)(abs((int)(X))<SebranyKral ? (X) : (((X)<0) ? ((X)-1) : ((X)+1) )))
#define DalOdMatu(X) ((s16)(abs((int)(X))<SebranyKral ? (X) : (((X)<0) ? ((X)+1) : ((X)-1) )))
/*Prevod hodnot pozice. Normalni hodnoty necha byt,
ale ty matici (treba mat 5. pultahem) posune. Pri volani
alfabety se totiz take posouvam po stromu.*/

static bool NulovyTah(TUloha *uloha, s16 prah, s16 hloubka
#ifdef Vypisy
	,FILE *soub
#endif
	)
/*******************************************************************/
/* NulovyTah                                                       */
/* Necham ted hrat soupere, i kdyz na to nema pravo. Jsem na tom   */
/* stejne lepe nez beta nebo stejne ? Beta se preda jako prah.     */
/*******************************************************************/
{bool b;
 u8 m;
	
	hassert(uloha->zasobnik.pos<MaxHloubkaPropoctu,"Hloubka propoctu");
	if(hloubka>3)hloubka-=2; else hloubka=1;
    uloha->StavPropoctu.VNT++;
	uloha->zasobnik.hF[uloha->zasobnik.pos]^=hnF.bily;
	uloha->zasobnik.hG[uloha->zasobnik.pos]^=hnG.bily;
    uloha->pozice.bily=!uloha->pozice.bily;
	m=uloha->pozice.mimoch;
	uloha->pozice.mimoch=0;
#ifdef Vypisy
  if(ABVH-1>uloha->zasobnik.pos)fprintf(soub,"NulTah, hraje znovu %s ",uloha->pozice.bily ? "bily":"cerny");
#endif
	b=((-AlfaBeta(uloha,(s16)(-prah),(s16)(1-prah),hloubka
#ifdef Vypisy
	,soub
#endif
	))>=prah);
	uloha->pozice.mimoch=m;
	uloha->pozice.bily=!uloha->pozice.bily;
#ifdef Statistika
	if(b)NTU[uloha->zasobnik.pos]++;else NTN[uloha->zasobnik.pos]++;
#endif
	uloha->StavPropoctu.VNT--;
	uloha->zasobnik.hF[uloha->zasobnik.pos]^=hnF.bily;
	uloha->zasobnik.hG[uloha->zasobnik.pos]^=hnG.bily;
	return b;
}

static bool MaterialRemis(TUloha *u){
/**********************************************************/
/* Jednoduchy (ne zcela korektni) test, zda je uz remiza  */
/* nedostatkem materialu, aby se dal nepocitalo           */
/**********************************************************/
 hassert(u->zasobnik.pos<MaxHloubkaPropoctu,"Hloubka propoctu");
 if(u->material.b[0]||u->material.c[0]||
 u->zasobnik.bm[u->zasobnik.pos]+
 u->zasobnik.cm[u->zasobnik.pos]>40200)return false;
 return true;
}

#define NASTAVOKRAJE(p1,p2) {p1=uloha->zasobnik.tahy+uloha->zasobnik.hranice[zanor];\
   p2=uloha->zasobnik.tahy+uloha->zasobnik.hranice[zanor+1];}

static s16 AlfaBetaBrani(TUloha *uloha, s16 alfa, s16 beta, s16 hloubka)
/********************************************************************************/
/* AlfaBetaBrani do dane hloubky. Vraci hodnotu z hlediska toho, kdo je na tahu.*/
/* Hleda hodnotu na otevrenem intervalu (alfa,beta), vraci cislo z uzavreneho	*/
/* intervalu <alfa,beta>														*/
/*********************************************************************************/
 {TTah1 *pt1,*pt2,*pt0;
  s16 BezPropoctu,pomhod;
  int zanor;
 
#ifdef Statistika
  ABB[hloubka]++;
  UZ++;
#endif

 if(GetHash(uloha,alfa,beta,1,&BezPropoctu))return BezPropoctu;
 zanor=uloha->zasobnik.pos;
 if(zanor>MaxHloubkaPropoctu-4) return HodnotaPozice(uloha,alfa,beta);
  hassert(uloha->zasobnik.pos<MaxHloubkaPropoctu,"Hloubka propoctu");

  if(hloubka<uloha->AlgCfg.AlgKoef.MaxHloubkaABB&&MaterialRemis(uloha))return 0;

  /*Neni-li matici material, je remiza. Nema to smysl testovat
   v uvodnim vyvolani, proto hloubka<HloubkaTicha */
  if(!hloubka)return HodnotaPozice(uloha,alfa,beta);
  /*List*/
  uloha->zasobnik.sach[zanor]=(uloha->pozice.bily ?
  Ohrozeno(uloha->pozice.sch+uloha->material.bk,false):
  Ohrozeno(uloha->pozice.sch+uloha->material.ck,true));

  /*Ulozim si, jsem-li v sachu*/
  if(uloha->zasobnik.sach[zanor]){
   NalezTahyZeSachu(uloha);/*Vsechny legalni tahy*/
   NASTAVOKRAJE(pt1,pt2)
   if(pt1==pt2)return -mat;
   BezPropoctu=alfa;/*Jsem-li v sachu,
    nesmim ukoncit propocet*/
	pomhod=HodnotaPozice(uloha,alfa,beta);
	/*Ale presto musim spocitat hodnotu pozice,
	abych ji v synovi mohl pouzit pri linem
	vyhodnocovani.*/
  }
  else {/*Nejsem v sachu*/
   pomhod=BezPropoctu=HodnotaPozice(uloha,alfa,beta);
 /*a dohledani do ticha mi muze pozici jen zlepsit.*/
   if(BezPropoctu>=beta || MaxHloubkaPropoctu<zanor+4) return BezPropoctu;
   NalezBrani(uloha);
   /*Vsechny pseudolegalni tahy, ktere nejsou tiche.*/
   NASTAVOKRAJE(pt1,pt2)
   if(pt1==pt2)return BezPropoctu;
   /*Zadny netichy tah*/
   if(alfa<BezPropoctu)alfa=BezPropoctu;
   /*Dohledani pozici nezhorsi.*/
   }
   pt0=pt1;
 for(;pt1<pt2;pt1++){
    pt1->cena+=uloha->HistHeur[pt1->data];
  	if(pt1->data&127==uloha->zasobnik.kam[zanor-1])pt1->cena+=50;
  }
 pt1=pt0;
 SetridTahy(uloha);
 UlozStav(uloha);
 for(;pt1<pt2;pt1++)
  {
   if(!uloha->zasobnik.sach[zanor]&&
      pt1->cena+BezPropoctu<alfa)continue;
   Tahni(pt1->data,uloha);
   if((uloha->pozice.bily ?
    Ohrozeno(uloha->pozice.sch+uloha->material.ck,true):
    Ohrozeno(uloha->pozice.sch+uloha->material.bk,false))){
   TahniZpet(pt1->data,uloha);
   continue;
  }
   pt1->cena=(s16)-AlfaBetaBrani(uloha,BlizKMatu(-beta),BlizKMatu(-alfa),(s16)(hloubka-1));
   pt1->cena=DalOdMatu(pt1->cena);
   if(pt1->cena>alfa) alfa=pt1->cena;
    TahniZpet(pt1->data,uloha);
   if(pt1->cena>=beta) return beta; /*prelezeni okenka */
  }
 return alfa;
}

#if 0
/* Nakonec to nevyuzivam */
static cmptah(const void *elem1, const void *elem2 ){
 s16 ct1,ct2;

 ct1=(((TTah1 *)(elem1)))->cena;
 ct2=(((TTah1 *)(elem2)))->cena;
 return ct1<ct2 ? 1 : (ct1>ct2 ? -1 : 0);
}
#endif

static s16 AlfaBeta(TUloha *uloha, s16 alfa, s16 beta, s16 hloubka
#ifdef Vypisy
	,FILE *soub
#endif
	)
/*****************************************************************************/
/* AlfaBeta do dane hloubky. Vraci hodnotu z hlediska toho, kdo je na tahu.  */
/* Hleda hodnotu na otevrenem intervalu (alfa,beta), vraci cislo z uzavreneho*/
/* intervalu <alfa,beta>. Pokud nestihne propocet, nastavi MamKoncit         */
/* na true a vrati alfa.													 */
/*****************************************************************************/
 {TTah1 *pt0,*pt1,*pt2;
  bool MamPripustnyTah,prohlub;
  u16 *nt1,*nt2;
  int zanor,pom,i,poc;
  s16 cena,a,b,h,PosCena;
  s8 *uk;


 if(beta<=-mat)return-mat;
#ifdef Statistika
    AB[hloubka]++;
	UZ++;
#endif
 zanor=uloha->zasobnik.pos;
#ifdef Vypisy
if((ABVH-1)>zanor)
 fprintf(soub,"\nAlfaBeta alfa=%i; beta=%i; h=%i zanor=%i\n",(int)alfa,(int)beta,(int)hloubka,(int)zanor);
if((ABVH-1)>zanor)
 TiskniSachovnici(&uloha->pozice,soub);
#endif
 if(zanor>MaxHloubkaPropoctu-4){
   cena=HodnotaPozice(uloha,alfa,beta);
#ifdef Vypisy
if((ABVH-1)>zanor)
 fprintf(soub,"Jsem moc hluboko, vracim HodnotaPozice=%i]\n",(int)cena);
#endif
  return cena;
 }
  hassert(zanor<MaxHloubkaPropoctu&&zanor>0,"Hloubka propoctu");
/* Nejprve detekuji vsechny mozne remizy */
  if(!uloha->zasobnik.zmen[zanor-1]){
  /* V propoctu zatim nedoslo k brani ani tahu pescem =>
     je treba otestovat remizy */
   if(PrtOpakRemis(uloha, uloha->zasobnik.hF[zanor])){
#ifdef Vypisy
  if((ABVH-1)>zanor)
	  fprintf(soub,"Opakovani pozice z partie 0]\n");
#endif
    return 0;
   /*Opakuje se pozice z partie*/
}
   if(uloha->RemTab.poc+zanor>100){
#ifdef Vypisy
  if((ABVH-1)>zanor)
	  fprintf(soub,"50 tahu 0]\n");
#endif   
    return 0;
	/*remiza 50 tahu*/
	}
  }
  if(MaterialRemis(uloha)){
#ifdef Vypisy
  if((ABVH-1)>zanor)
	  fprintf(soub,"Neni matici material 0]\n");
#endif
   return 0;
  /*Remiza nedostatkem materialu*/
  }
  for(cena=(s16)(zanor-1);cena>=0;cena--)
if(uloha->zasobnik.hF[zanor]==uloha->zasobnik.hF[cena]&&
   uloha->zasobnik.hG[zanor]==uloha->zasobnik.hG[cena]){
#ifdef Vypisy
  if((ABVH-1)>zanor)
	  fprintf(soub,"Opakovani pozice 0]\n");
#endif
/*Remiza opakovanim pozice */
	return 0;
}
/*Konec detekce remiz*/
/*   if(uloha->StavPropoctu.CasKonceMysleni<=clock())uloha->StavPropoctu.MamKoncitMysleni=true;*/
DotazNaCas(uloha);
   if(uloha->StavPropoctu.MamKoncitMysleni){
#ifdef Vypisy
  if((ABVH-1)>zanor)
	  fprintf(soub,"Vyprsel cas, vracim alfa=%i]\n",(int)alfa);
#endif
/*Kdyz mi dosel cas...*/
	   return alfa;
   }

  a=alfa;
  b=beta;
  h=hloubka;
/*Promenne ukladam kvuli pozdejsimu zapisu do hash tabulky */

/* Nasleduje cteni z hash tabulky */
 if(/*!uloha->StavPropoctu.VNT&&*/GetHash(uloha,a,b,(u8)(h+1),&cena)) {
#ifdef Statistika
	   HU[hloubka]++;
#endif
#ifdef Vypisy
if((ABVH-1)>zanor)fprintf(soub,"vracim Hash=%i]",(int)cena);
#endif
  return cena;
 }
#if 0
 uloha->zasobnik.bkohroz[zanor]=HrozbaBilemuKraliDamou(uloha);
 uloha->zasobnik.ckohroz[zanor]=HrozbaCernemuKraliDamou(uloha);
#endif
/*  Prvni testy na prohlubovani
 - sebrani minule berouci figury
 - pesec dosel v listu pred policko promeny
 - sachoval jsem a souper predstavil (napr. maty na zakladni rade)
 */
 prohlub=false;
 if(
  uloha->AlgCfg.AlgKoef.MaxRozsirDober>=uloha->zasobnik.rozsir[zanor-1] &&
  zanor>1 && !uloha->StavPropoctu.VNT &&
  uloha->zasobnik.brani[zanor-2] &&
  uloha->zasobnik.kam[zanor-1]==uloha->zasobnik.kam[zanor-2])
 /*Souper mi neco sebral a ja jsem dobral
  jeho berouci figuru - to stoji za prohloubeni*/
  goto prohloubeni;
  pom=uloha->zasobnik.kam[zanor-1];
   if(
   !hloubka &&
   uloha->AlgCfg.AlgKoef.MaxRozsirPesec7>=uloha->zasobnik.rozsir[zanor-1] &&
   (uloha->pozice.sch[pom]==1 && pom >= a7
   || uloha->pozice.sch[pom]==-1 && pom <= h2)
   ) /*od if*/
/* Jsem v listu a pesec dosel na posledni radu  */
   goto prohloubeni;
  if(zanor>1 &&
    uloha->AlgCfg.AlgKoef.MaxRozsirPredstav>=uloha->zasobnik.rozsir[zanor-1] &&
	uloha->zasobnik.sach[zanor-1] &&
	abs(uloha->pozice.sch[pom])!=6 &&
	!uloha->zasobnik.brani[zanor-1]
   )
  /* Pokryl sach predstavenim*/
  goto prohloubeni;
  if(uloha->AlgCfg.AlgKoef.MaxRozsirFischer>=uloha->zasobnik.rozsir[zanor-1])
  switch(*(uk=uloha->pozice.sch+pom)){
   case 3: if(pom==a7 && uloha->pozice.sch[b7]==-1 && uloha->pozice.sch[c7]==-1 ||
              pom==h7 && uloha->pozice.sch[f7]==-1 && uloha->pozice.sch[g7]==-1)
			  goto prohloubeni;
			  break;
			  	/*Past na Fischerova strelce.
	Spasskij - Fischer
	Reykjavik 1972
	1. partie zapasu o mistra sveta
	29. ...Sxh2 ???
	     30. g3
		 A strelec je v pasti
		 */
   case 5: if(uloha->zasobnik.rozsir[zanor-1]<1&&HrozbaCernemuKraliDamou(uloha))goto prohloubeni;break;
   case -3:if(pom==a2 && uloha->pozice.sch[b2]==1 && uloha->pozice.sch[c2]==1 ||
              pom==h2 && uloha->pozice.sch[f2]==1 && uloha->pozice.sch[g2]==1)
		      goto prohloubeni;
		      break;
   case -5: if(uloha->zasobnik.rozsir[zanor-1]<1&&HrozbaBilemuKraliDamou(uloha))goto prohloubeni;break;
   case 2: if(!hloubka){
			for(poc=0,i=8;i<16;i++)
			  if(*(uk+(ofsety[i]))<-2)
			    poc++;
			if(poc>1)goto prohloubeni; /*vidle*/
			}
			break;
   case -2: if(!hloubka){
			for(poc=0,i=8;i<16;i++)if(*(uk+(ofsety[i]))>2 && *(uk+ofsety[i])<7)poc++;
			if(poc>1)goto prohloubeni;/*vidle*/
			}
			break;
   case 1: if(*(uk+11)<-1 && *(uk+9)<-1 || /*vidle nebo past na strelce*/
              pom==g3 && uloha->pozice.sch[h2]==-3 && uloha->pozice.sch[f2]==1 ||
              pom==b3 && uloha->pozice.sch[a2]==-3 && uloha->pozice.sch[c2]==1)
			  goto prohloubeni;
			  break;
  case -1: if(*(uk-11)<7 && *(uk-9)<7 && *(uk-11)>1 && *(uk-9)>1 ||
			/*vidle nebo past na strelce*/
              pom==g6 && uloha->pozice.sch[h7]==3 && uloha->pozice.sch[f7]==-1 ||
              pom==b6 && uloha->pozice.sch[a7]==3 && uloha->pozice.sch[c7]==-1)
			  goto prohloubeni;
			  break;
  }
#if 0
   else
   if(
    uloha->AlgCfg.AlgKoef.MaxRozsirHrozba>=uloha->zasobnik.rozsir[zanor-1] &&
	(uloha->pozice.bily && uloha->zasobnik.bkohroz[zanor] && !uloha->zasobnik.bkohroz[zanor-1]) ||
   (!uloha->pozice.bily && uloha->zasobnik.ckohroz[zanor] && !uloha->zasobnik.ckohroz[zanor-1])
	)/*Hrozi-li krali mozna mat damou (a pred souperovym
	tahem nehrozil), prohlubuji - moc se to ale neosvedcilo*/
	goto prohloubeni;
#endif
goto neprohlubuj; 
 prohloubeni:;
 {prohlub=true;
#ifdef Vypisy
if((ABVH-1)>zanor)fprintf(soub,"prohlubuji, hloubka=%i ",(int)(hloubka+1));
#endif

 hloubka++;
 uloha->zasobnik.rozsir[zanor-1]++;
 }
/*      Konec prvnich testu na prohlubovani           */
 neprohlubuj:;
  if(!hloubka || MaxHloubkaPropoctu<zanor+4)
   {cena=AlfaBetaBrani(uloha,alfa,beta,uloha->AlgCfg.AlgKoef.MaxHloubkaABB);
#ifdef Statistika
  UZ--;
#endif
#ifdef Vypisy
   if((ABVH-1)>zanor)fprintf(soub,"vracim ABB=%i]",(int)cena);
#endif
   goto Konec;}
   
uloha->zasobnik.sach[zanor]=(uloha->pozice.bily ?
  Ohrozeno(uloha->pozice.sch+uloha->material.bk,false):
  Ohrozeno(uloha->pozice.sch+uloha->material.ck,true));
/***********************************************************
 Selektivita
/**********************************************************/
if(!prohlub){
/* Mala selektivita
    - vlastní tah je prospìšný a pokud si na nìj upøu právo
      a stejnì pøeteèu betu, pøetekl bych jí nejspíš i v korektním
      propoètu*/
   if(hloubka==1 && uloha->StavPropoctu.NulTah &&
   !uloha->zasobnik.sach[zanor]&&
   AlfaBetaBrani(uloha,alfa,beta,uloha->AlgCfg.AlgKoef.MaxHloubkaABB)>=beta ){
#ifdef Statistika
	   MS++;
#endif
#ifdef Vypisy
  if((ABVH-1)>zanor)
	  fprintf(soub,"MS, vracim beta=%i]\n",(int)beta);
#endif
	   cena=beta;
	   goto Konec;
   }
/* Metoda nuleveho tahu */
   if(hloubka>1 && uloha->StavPropoctu.NulTah&&!uloha->zasobnik.sach[zanor]&&beta<mat-100){
	   if( NulovyTah(uloha,beta,hloubka
#ifdef Vypisy
	,soub
#endif
	)) {
#ifdef Vypisy
	if((ABVH-1)>zanor)
	fputs("NTU, vracim beta]\n",soub);
#endif
		   cena=beta;
		   goto Konec;
	   }
   }
/* Kdyz v hloubce 3 mam o damu mene nez alfa, snizim na 2*/
 pom=uloha->zasobnik.bm[zanor]-uloha->zasobnik.cm[zanor];
 if(!uloha->pozice.bily)pom=-pom;
 if(hloubka==3 && pom+450<alfa) hloubka--;
}
/********************************************************
 Konec selektivnich testu
********************************************************/
  if(uloha->zasobnik.sach[zanor]){
   NalezTahyZeSachu(uloha);
   NASTAVOKRAJE(pt1,pt2)
   pt0=pt1;
  if(pt1==pt2){
#ifdef Vypisy
  if((ABVH-1)>zanor) fputs(" Mat, vracim -mat]\n",soub);
#endif
  return -mat;
  }
  else
  if(pt1+1==pt2 && !prohlub){
/* Je jen jediny tah => prohlubovani*/
#ifdef Vypisy
if((ABVH-1)>zanor)fprintf(soub,"jen jeden tah prohlubuji, hloubka=%i]",(int)(hloubka+1));
#endif
 hloubka++;
 prohlub=true;
  }
  else{
  if(!prohlub && uloha->AlgCfg.AlgKoef.MaxRozsirSach>=uloha->zasobnik.rozsir[zanor-1])
  {hloubka++;
  uloha->zasobnik.rozsir[zanor-1]++;
#ifdef Vypisy
if((ABVH-1)>zanor)fprintf(soub,"Je sach, prohlubuji, hloubka=%i]",(int)(hloubka));
#endif
  }
  }
  }
  else {
   NalezTahy(uloha);
   NASTAVOKRAJE(pt1,pt2)
   pt0=pt1;
  if(pt1==pt2)
   {
#ifdef Vypisy
  if((ABVH-1)>zanor) fputs(" Pat, vracim 0]\n",soub);
#endif
	   cena=0;
	   goto Konec;
   }
 /* Specialni pripad patu - byl by to pat i kdyby kral mohl do sachu
    teoreticky muze nastat, prakticky asi ne */
 }
   if(!uloha->StavPropoctu.VNT){
 nt1=&(uloha->hh[zanor][0]);
 nt2=nt1+1;
 for(;pt1<pt2;pt1++){
    pt1->cena+=uloha->HistHeur[pt1->data];
  	if(pt1->data&127==uloha->zasobnik.kam[zanor-1])pt1->cena+=50;
	if(pt1->data==uloha->hvar[zanor][zanor])
	 pt1->cena+=250; else
	if(pt1->data==*nt1)pt1->cena+=uloha->AlgCfg.AlgKoef.hh1Bonus; else
	if(pt1->data==*nt2)pt1->cena+=uloha->AlgCfg.AlgKoef.hh2Bonus;
   }}
 pt1=pt0;
 SetridTahy(uloha);
 PosCena=HodnotaPozice(uloha,/*alfa,beta*/-mat,mat);
 UlozStav(uloha);
/***********************************************************************************
 Puvodni idea:
 Provedu iterace do male hloubky jen kvuli setrideni tahu
 Zjisteni: historicka heuristika poskytuje srovnatelne
  vysledky. K tomu aby se kaskadova metoda vyplatila
  i mimo koren by bylo zrejme treba nejak netrivialne
  vyuzivat ziskanou informaci, provadet dabelske manipulace
  s okenkem atd. Kod by pak byl velmi slozity, nachylny
  k chybam (mozne kolize s jinymi heuristikami) a vysledny
  efekt zrejme neprilis vyrazny.
 Zaver: kaskadova metoda jenom v koreni.
/***********************************************************************************/
#if 0
{s16 lokh;

 for(lokh=1;lokh<hloubka-1; lokh+=20){
  for(;pt1<pt2;pt1++)
  {
  Tahni(pt1->data,uloha);
  if((uloha->pozice.bily ?
    Ohrozeno(uloha->pozice.sch+uloha->material.ck,true):
    Ohrozeno(uloha->pozice.sch+uloha->material.bk,false))){
   TahniZpet(pt1->data,uloha);
   pt1->cena=-mat-1;
   continue;}
   pt1->cena=(s16)-AlfaBeta(uloha,BlizKMatu(-beta),BlizKMatu(-alfa),(s16)(lokh-1)
#ifdef Vypisy
	,soub
#endif
	 );
   pt1->cena=DalOdMatu(pt1->cena);
   TahniZpet(pt1->data,uloha);
   }
 pt1=pt0;
 }
 qsort(pt0,pt2-pt0,sizeof(void *),cmptah);
 }
#endif
/************************************************************************************
 Konec zavrzenych tridicich iteraci
*************************************************************************************/
 MamPripustnyTah=false;
 for(;pt1<pt2;pt1++)
  {
#ifdef Vypisy
	 if((ABVH-1)>zanor){
		 char s[15];
		 
		 TahToStr(pt1->data, uloha, s);
		 fprintf(soub,"%i.%s",(int)(1+zanor),s);

	 }
#endif

   Tahni(pt1->data,uloha);
  if((uloha->pozice.bily ?
    Ohrozeno(uloha->pozice.sch+uloha->material.ck,true):
    Ohrozeno(uloha->pozice.sch+uloha->material.bk,false))){
   TahniZpet(pt1->data,uloha);


#ifdef Vypisy
	 if((ABVH-1)>zanor){
	 fputs(" To neni pripustne\n",soub);
	 }
#endif
   continue;}
/*Tady bude if(hloubka==2 && (stojim+tah->cena)<alfa-3p) nepocitej*/
#ifdef Statistika
 /*if(hloubka==2 && pt1->cena+PosCena<a && !)S2U++;else S2N++;*/
#endif

   pt1->cena=(s16)-AlfaBeta(uloha,BlizKMatu(-beta),BlizKMatu(-alfa),(s16)(hloubka-1)
#ifdef Vypisy
	,soub
#endif
	 );
   pt1->cena=DalOdMatu(pt1->cena);
   TahniZpet(pt1->data,uloha);
#ifdef Vypisy
   if((ABVH-1)>zanor){
	   fprintf(soub," %i ",(int)pt1->cena);
   }
#endif
   MamPripustnyTah=true;
   if(pt1->cena>alfa)
    { 
	  if(!uloha->StavPropoctu.VNT){*nt2=*nt1; *nt1=pt1->data;
	  KopirujHVar(uloha,pt1->data);
	  pom=MAX(5-zanor,0);
	  pom*=pom;
	  PISDOHISTHEUR(uloha,pt1->data,/*hloubka*hloubka*/pom)
	  }
      alfa=pt1->cena;
    }
   if(pt1->cena>=beta) {
#ifdef Vypisy
 if((ABVH-1)>zanor)
	   fprintf(soub," Pres beta, vracim beta=%i]\n ",(int)beta);
#endif
#ifdef Statistika
  if(pt1!=pt0)PR[hloubka]++;
#endif
    cena=beta; /* prelezeni okenka */
	goto Konec;
   }
  }
 if(MamPripustnyTah) {
#ifdef Vypisy
if((ABVH-1)>zanor)
	   fprintf(soub," Konec, vracim alfa=%i]\n ",(int)alfa);
#endif
	 cena=alfa;
 }
  else
	   {
#ifdef Vypisy
if((ABVH-1)>zanor)
	   fprintf(soub," Neni sach, neni prip. tah, vracim 0]\n");
#endif 
  		 cena=0;
 } /* pat */

Konec:
 if(!uloha->StavPropoctu.MamKoncitMysleni){
 if(cena<=a)SetHash(uloha,(u8)(h+1),(u8)2,a);else
 if(cena>=b)SetHash(uloha,(u8)(h+1),(u8)1,b);else
 SetHash(uloha,(u8)(h+1),(u8)3,cena);
}
/*
if(cena<-mat || cena > mat){
 a=b;
}*/
 return cena;
 }

bool DejTah(TUloha *uloha,TTah1 *t1,u32 cas, bool *PrijmiRemis
#ifdef Vypisy
, FILE *soub
#endif
)
/*************************************************/
/*  Dejtah - Myslici algoritmus (jeho volani)    */
/*************************************************/
{TTah1 *pt0,*pt1,*pt2,tmp;
 s16 alfa,beta,h,stara,RemCena=0;
 int rozdil;
 int maxhloubka;

 if(PrijmiRemis)*PrijmiRemis=false;
 maxhloubka=MaxHloubkaPropoctu;
#if Typ_Produktu==Projekt
/* Pro specialni urovne zkratim dobu mysleni. Delam to trosku
nedeterministicky, aby to nehralo porad stejne. */
 switch(PrjData.typ){
  case 1: maxhloubka=4;
   if(!(rand()%4))maxhloubka++; else  if(!(rand()%10))cas=10;
   if(cas>1000) cas=1000; break;
  /* Opice */
  case 2: maxhloubka=5;
    if(!(rand()%4))maxhloubka++; else 
    if(!(rand()%4))maxhloubka--; 
   if(cas>1000) cas=1000; break;
  /* Clovek */
  case 3: if(cas>1200) cas=800+rand()%400; break;
  /* Prumer */
  case 4: if(cas>3500) cas=2500+rand()%1000; break;
  /* Mistr */
 }
 SCioVypis("funkce DejTah");
#ifdef SCioLadim
{char s[50];
 sprintf(s,"Kvalita %i",PrjData.typ);
 SCioVypis(s);
}
#endif
 if(PrjData.typ>2) /*Sekretarka a normal neznaji zahajeni*/
#endif
 if(MamKnihovnu&&(t1->data=KnihDejTah(&(uloha->pozice))))
 {
#if Typ_Produktu==Projekt
	 SCioVypis("Pozice je v knihovne");
#endif
	 return true;
}
 /*Kdyz jsem nasel pozici v knihovne, hned koncim.*/
 if(t1->data=TabDejTah(uloha)){
#if Typ_Produktu==Projekt
	 SCioVypis("Pozice je v knihovne");
#endif
	 return true;
 }
 /*Kdyz jsem nasel pozici v databazi koncovek, hned koncim.*/
/*
 uloha->StavPropoctu.CasKonceMysleni=(clock_t)((1000*clock())/CLK_TCK+cas);
 */
 uloha->StavPropoctu.MamKoncitMysleni=false;
NastavCas(cas,uloha);
 InitVypocet(uloha);
#ifdef Vypisy
fprintf(soub,"\nFunkce DejTah. Na tahu je %s. BM=%i, CM=%i\n",
		uloha->pozice.bily ? "bily" : "cerny",
 (int) uloha->zasobnik.bm[0],(int) uloha->zasobnik.cm[0]);
#endif
 if(PrijmiRemis){
  if(uloha->pozice.bily && uloha->zasobnik.bm[0]<=StdCenyFigur[6] ||
     !uloha->pozice.bily && uloha->zasobnik.cm[0]<=StdCenyFigur[6])
  *PrijmiRemis=true; else *PrijmiRemis=false;
  }
 NalezTahy(uloha);
 JenPripustne(uloha);
 /* To je sice pomale, ale nutne, nebot se mi nemusi podarit dopocitat
   do hloubky 1 a pak bych mohl vratit nepripustny tah.
   Kdyz to ale zavolam jen jednou za cely vypocet nejlepsiho tahu,
   tak to nezdrzuje. Ale v rekurzivnim propoctu pocitam i s ilegalnimi tahy */
 if (!uloha->zasobnik.hranice[1]) return false;
  /*Neni zadny pripustny tah*/
 if (uloha->zasobnik.hranice[1]==1){
#ifdef Vypisy
	 fputs("Je jen jeden pripustny tah\n",soub);
#endif
	 goto zaver;
 }
/* tedy mám alespoò dva tahy*/
 pt0=pt1=uloha->zasobnik.tahy;
 pt2=uloha->zasobnik.tahy+uloha->zasobnik.hranice[1];
 /*sort(pt1,pt2-pt1,sizeof(TTah1),CmpTTah1);*/
 SetridTahy(uloha);
#if Typ_Produktu==Win32_Program
 VypAktualizujNejlepsi(uloha,pt0->data);
#endif

 HodnotaPozice(uloha,-mat,mat);
 UlozStav(uloha);

for(h=0;h<=maxhloubka-4;h++)
{
#if Typ_Produktu==Win32_Program
 VypAktualizujHloubku(uloha,h);
#endif

#ifdef Vypisy
if(soub!=stdout){
fputc('\n',soub);
TiskniSachovnici(&uloha->pozice,soub);
}
#endif
if(h){
 pt0=pt1=uloha->zasobnik.tahy;
 pt2=uloha->zasobnik.tahy+uloha->zasobnik.hranice[1];
 if(pt1->cena>mat-1000){
  alfa=pt1->cena-10;
  beta=MIN(pt1->cena+10,mat);
 }
 else
 if(pt1->cena<-mat+1000){
  alfa=MAX(pt1->cena-10,-mat);
  beta=pt1->cena+10;
 }
 else
 if(h&1){
 alfa=(s16)(pt1->cena-rozdil-10);
 beta=(s16)(pt1->cena+rozdil);}
 else
 {alfa=(s16)(pt1->cena-rozdil);
 beta=(s16)(pt1->cena+rozdil+10);
 }
}
else
 {
/* pt0 1 a 2 už mám nastavené*/
 alfa=-mat;
 beta=mat;
 rozdil=20;
 }
#ifdef Vypisy
fprintf(soub,"\nPropocet do hloubky %i, alfa=%i, beta=%i: ",(int) h,(int) alfa, (int) beta);
#endif
#if Typ_Produktu==DOS_UNIX
printf("%i ",h%10);
#endif
 for(;pt1<pt2;pt1++) /* Cyklus pøes tahy*/
  {
uloha->hvar[h][h]=0;
#ifdef Vypisy
if(ABVH>0)
{char s[20];
TahToStr(pt1->data,uloha,s);
fprintf(soub,"%s",s);}
#endif
#if Typ_Produktu==Win32_Program
VypAktualizujTah(uloha,pt1->data);
#endif

Tahni(pt1->data,uloha);
pt1->cena=(s16)-AlfaBeta(uloha,(s16)(-beta),(s16)(-alfa),h
#ifdef Vypisy
	,soub
#endif
	);
TahniZpet(pt1->data,uloha);
tmp=*pt1;
if(uloha->StavPropoctu.MamKoncitMysleni)	goto zaver;

if(pt1==pt0){ /* poèítám první tah*/
 RemCena=pt1->cena;
#if Typ_Produktu==Win32_Program
 VypAktualizujCenu(uloha,pt1->cena);
#endif
 if(pt1->cena<=alfa) 
	 /* První tah podtekl alfa. Poèítaè zaèíná tušit neštìstí.
	 Nejspíš by podtekly i všechny další tahy*/
 {
    Tahni(pt1->data,uloha);
	 pt1->cena=(s16)-AlfaBeta(uloha,(s16)(-alfa-1),(s16)(mat),h
#ifdef Vypisy
	,soub
#endif
	);
	 TahniZpet(pt1->data,uloha);
   if(uloha->StavPropoctu.MamKoncitMysleni)	goto zaver;

#ifdef Vypisy
  if(ABVH>0) fputs(" Alfa podteceni",soub);
#endif
RemCena=pt1->cena;
#if Typ_Produktu==Win32_Program
 VypAktualizujCenu(uloha,pt1->cena);
#endif
 }
 else
 if(pt1->cena>=beta) 
 {/*První tah pøetekl beta*/
	 KopirujHVar(uloha, pt1->data);
	 Tahni(pt1->data,uloha);
   pt1->cena=(s16)-AlfaBeta(uloha,(s16)(-mat),(s16)(1-beta),h
#ifdef Vypisy
	,soub
#endif
	);
   TahniZpet(pt1->data,uloha);
   if(uloha->StavPropoctu.MamKoncitMysleni)	goto zaver;
#ifdef Vypisy
if(ABVH>0)fputs(" Beta preteceni",soub);
#endif
RemCena=pt1->cena;
#if Typ_Produktu==Win32_Program
 VypAktualizujCenu(uloha,pt1->cena);
#endif
 }
 alfa=pt1->cena;
 if(alfa>=mat-h){
#ifdef Vypisy
fprintf(soub," Davam mat %i. pultahem",mat-alfa+1);
#endif
	 goto zaver;
 }
 beta=(s16)(alfa+1);
 if(uloha->StavPropoctu.MamKoncitMysleni)goto zaver;
#ifdef Vypisy
if(ABVH>0)fprintf(soub," %i ",(int) pt1->cena);
fprintf(soub,"a=%i, b=%i ",(int) alfa, (int) beta);
#endif
} /* od prvního tahu */
else
{ /* jiný než první tah */
#ifdef Vypisy
if(ABVH>0)fprintf(soub," %i ",(int) pt1->cena);
#endif

   tmp=*pt1;
   if(tmp.cena>alfa)
    {

	  memmove(pt0+1,pt0,(pt1-pt0)*sizeof(TTah1));
      *pt0=tmp;
	  alfa=tmp.cena;
#if Typ_Produktu==Win32_Program
 VypAktualizujNejlepsi(uloha,pt0->data);
 VypAktualizujCenu(uloha,pt0->cena);
#endif
 RemCena=pt0->cena;
#ifdef Vypisy
if(ABVH>0)fprintf(soub,"dobry ");
fprintf(soub,"a=%i, b=%i ", beta-1, mat);
#endif
KopirujHVar(uloha,tmp.data);
Tahni(tmp.data,uloha);
pt0->cena=(s16)-AlfaBeta(uloha,(s16)(-mat),(s16)(1-beta),h
#ifdef Vypisy
	,soub
#endif
	);
TahniZpet(tmp.data,uloha);
if(uloha->StavPropoctu.MamKoncitMysleni) goto zaver;
#if Typ_Produktu==Win32_Program
 VypAktualizujCenu(uloha,pt0->cena);
#endif
 RemCena=pt0->cena;
if(pt0->cena>=mat-h){
#ifdef Vypisy
fprintf(soub," Davam mat %i. pultahem",mat-pt0->cena+1);
#endif
 goto zaver;
 } 
  alfa=(s16)(pt0->cena);
  beta=(s16)(alfa+1);	
#ifdef Vypisy
if(ABVH>0)fprintf(soub," %i ",pt0->cena);
fprintf(soub,"a=%i, b=%i ", (int)alfa, (int)beta);
#endif
} /* Od pøeteèení alfa */
} /* Od jiného než prvního tahu*/
} /*od cyklu pøes tahy*/
 if(alfa<=-mat+h){
#ifdef Vypisy
	 fprintf(soub," Dostanu mat %i. pultahem",mat+alfa+1);
#endif
	 break;
 }
 if(h)rozdil=abs(stara-pt0->cena)+10;
 stara=pt0->cena;
 PISDOHISTHEUR(uloha,pt0->data,h*h)
} /*Od cyklu pøes hloubku*/
zaver:
 *t1=uloha->zasobnik.tahy[0];
#ifdef Vypisy
 putc('\n',soub);
#endif
 if(PrijmiRemis){
  if(uloha->pozice.bily && uloha->zasobnik.bm[0]<=StdCenyFigur[6] ||
     !uloha->pozice.bily && uloha->zasobnik.cm[0]<=StdCenyFigur[6])
  *PrijmiRemis=true; else *PrijmiRemis=false;
  }
 if(RemCena<-50 && PrijmiRemis)*PrijmiRemis=true;
 return true;
} /* od funkce */

/*********************************************************/
/* lokruti.c - Test sachu ohrozeni a lokalni             */
/* (tj. nikoliv v partii) tahy                           */
/* 9.1. 2001 Jan Nemec                                   */
/*********************************************************/
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "volby.h"
#include "cotyvar.h"
#include "generato.h"
#include "hashtab.h"
#include "dosio.h"
#include "lokruti.h"

#if 0
static int PocetCernych(char *sch){
/*Ladici funkce*/
 int p;
 char *pom=sch+120;
 for(p=0;sch<pom;sch++)if(*sch<0)p++;
 return p;
}
#endif
/***************************************************/
/**  Ohrozeno   Je dane policko ohrozene ?        **/
/***************************************************/
bool Ohrozeno(s8 *p, bool bilym) /*bilym - ohrozuje to pole bily*/
/* p je pointer do sachovnice na zkouman‚ policko*/
 {int j,k;

 if (bilym)
 {
 if (*(p-9)==1) return true;/*pescem*/
 if (*(p-11)==1) return true;/*pescem*/
 for(j=8;j<=15;j++)if (*(p+ofsety[j])==2) return true;/*konem*/
 for(j=0;j<=7;j++)if (*(p+ofsety[j])==6) return true;/*kralem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){if((*(p+k)==4)||(*(p+k)==5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){if((*(p+k)==3)||(*(p+k)==5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
 } else /*cernym*/
  {
 if (*(p+9)==-1) return true;/*pescem*/
 if (*(p+11)==-1) return true;/*pescem*/
 for(j=8;j<=15;j++)if (*(p+ofsety[j])==-2) return true;/*konem*/
 for(j=0;j<=7;j++)if (*(p+ofsety[j])==-6) return true;/*kralem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){if((*(p+k)==-4)||(*(p+k)==-5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){if((*(p+k)==-3)||(*(p+k)==-5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
 }
 return false;
 }

 static bool OhrozenoNekralem(s8 *p, bool bilym){
/*Jako Ohrozeno z lokruti.h, ale neuvazuje napadeni
kralem*/
 /*bilym - ohrozuje to pole bily*/
/* p je pointer do sachovnice na zkouman‚ policko*/
 {int j,k;

 if (bilym)
 {
 if (*(p-9)==1) return true;/*pescem*/
 if (*(p-11)==1) return true;/*pescem*/
 for(j=8;j<=15;j++)if (*(p+ofsety[j])==2) return true;/*konem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){if((*(p+k)==4)||(*(p+k)==5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){if((*(p+k)==3)||(*(p+k)==5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
 } else /*cernym*/
  {
 if (*(p+9)==-1) return true;/*pescem*/
 if (*(p+11)==-1) return true;/*pescem*/
 for(j=8;j<=15;j++)if (*(p+ofsety[j])==-2) return true;/*konem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){if((*(p+k)==-4)||(*(p+k)==-5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){if((*(p+k)==-3)||(*(p+k)==-5))return true;if(*(p+k))break;k+=ofsety[j];}
 }
 }
 return false;
 }
}
static bool CistoMezi(s8 *p1, s8 *p2, int o){
/*Jsou same nuly mezi dvema policky na sachovnici ?
musi byt od sebe o nasobek o ?*/
 char *p;
 if(p1>p2){p=p1;p1=p2;p2=p;}
 for(p1+=o;p1<p2;p1+=o)if(*p1)return false;
 return true;
}

bool HrozbaBilemuKraliDamou(TUloha *u){
/*vraci true kdyz existuje policko vedle krale
ktere je napadeno (nejakou) souperovou damou a jeste
necim jinym (to neco jineho muze byt i za tou potencialne
ohrozujici damou) a neni kryte nicim jinym nez kralem

- to je casty obrazek banalnich jednotahovych matu*/
int i,dx,dy,x,y,kx,ky;
bool o,p;
div_t t;
char *pole;
 
  if(!u->material.c[4])return false;
  t=div(u->material.bk-a1,10);
  kx=t.rem; ky=t.quot; /* souradnice krale*/
  for(i=a1;i<=h8;i++)if(u->pozice.sch[i]==-5){
   t=div(i-a1,10); dx=t.rem; dy=t.quot; /* souradnice damy*/
   pole=u->pozice.sch+u->material.bk-11;
   for(y=ky-1;y<ky+2;y++,pole+=7)
    for(x=kx-1;x<kx+2;x++,pole++)
    {
	 if(x==kx && y==ky ||
	 *pole<0||*pole>6) continue;
	 p=false;
	 if(x==dx){
	  if(CistoMezi(u->pozice.sch+i,pole,10))p=true;
	 } else
	 if(y==dy){
	  if(CistoMezi(u->pozice.sch+i,pole,1))p=true;
	 }
	 else
	 if(y-dy==x-dx){
	  if(CistoMezi(u->pozice.sch+i,pole,11))p=true;
	 }
	 else
	 if(y-dy==dx-x){
	  if(CistoMezi(u->pozice.sch+i,pole,9))p=true;
	 }
	 if(!p) continue; /*Dama to policko nenapada*/

   if(!OhrozenoNekralem(pole,true))
    {
    u->pozice.sch[i]=0;
	o=Ohrozeno(pole,false);
	u->pozice.sch[i]=-5;
    if(o)return true;
   }
 }/* od for cyklu pres okoli krale*/
   if(u->material.c[4]==1) break; /*Kdyz ma jen jednu, nebudu hledat dalsi*/
  }
 return false;
}

bool HrozbaCernemuKraliDamou(TUloha *u){
/*vraci true kdyz existuje policko vedle krale
ktere je napadeno (nejakou) souperovou damou a jeste
necim jinym (to neco jineho muze byt i za tou potencialne
ohrozujici damou) a neni kryte nicim jinym nez kralem

- to je casty obrazek banalnich jednotahovych matu*/
int i,dx,dy,x,y,kx,ky;
bool o,p;
div_t t;
char *pole;
 
  if(!u->material.b[4])return false;
  t=div(u->material.ck-a1,10);
  kx=t.rem; ky=t.quot; /* souradnice krale*/
  for(i=a1;i<=h8;i++)if(u->pozice.sch[i]==5){
   t=div(i-a1,10); dx=t.rem; dy=t.quot; /* souradnice damy*/
   pole=u->pozice.sch+u->material.ck-11;
   for(y=ky-1;y<ky+2;y++,pole+=7)
    for(x=kx-1;x<kx+2;x++,pole++)
    {
	 if(x==kx && y==ky || *pole>0) continue;
	 p=false;
	 if(x==dx){
	  if(CistoMezi(u->pozice.sch+i,pole,10))p=true;
	 } else
	 if(y==dy){
	  if(CistoMezi(u->pozice.sch+i,pole,1))p=true;
	 }
	 else
	 if(y-dy==x-dx){
	  if(CistoMezi(u->pozice.sch+i,pole,11))p=true;
	 }
	 else
	 if(y-dy==dx-x){
	  if(CistoMezi(u->pozice.sch+i,pole,9))p=true;
	 }
	 if(!p) continue; /*Dama to policko nenapada*/

   if(!OhrozenoNekralem(pole,false))
    {
    u->pozice.sch[i]=0;
	o=Ohrozeno(pole,true);
	u->pozice.sch[i]=5;
    if(o)return true;
   }
 }/* od for cyklu pres okoli krale*/
   if(u->material.b[4]==1) break; /*Kdyz ma jen jednu, nebudu hledat dalsi*/
  }
 return false;
}


bool Sach(bool komu, s8 *sch)
/*************************************************************************/
/*   Sach je komu v sachu ?                                              */
/*   sch - pointr na 1. policko sachovnice 12*10 (tedy nikoliv a1)       */
/*************************************************************************/
{s8 kral;

 if (komu) kral=6; else kral=-6;
 for(sch+=a1; (*sch)!=kral; sch++);
 return Ohrozeno(sch, !komu);
}
void UlozStav(TUloha *uloha)
 {s16 hloubka;
  uloha->zasobnik.mimoch[hloubka=uloha->zasobnik.pos]=uloha->pozice.mimoch;
  uloha->zasobnik.roch[hloubka]=uloha->pozice.roch;
 }
 /**************************************************************************
 *   JednoTahni - Tahne v testu pripustnosti tahu                          *
 *   Na zasobnik ulozi jen udaje pro TahniZpet, nepocita cenu              *
 *   ani hash funkce												       *
 ***************************************************************************/
void JednoTahni(u16 tah, TUloha *uloha)
 { u8 odkud,kam;
   s8 co;
  s16 hloubka;

  hloubka=uloha->zasobnik.pos++;
  uloha->pozice.mimoch=0; /*Vetsina tahu neni pescem o 2, pokud ano, osetri se*/
  uloha->pozice.bily=!uloha->pozice.bily;
  if(!(tah>>15)) /* Normalni tah*/
   {kam=(u8)(tah&127);
    odkud=(u8)(tah>>7);
    if(/* bud cerny tahne pescem o 2*/
		odkud-kam==20 && uloha->pozice.sch[odkud]==-1
		/* a bily pesec ciha */
	&& (uloha->pozice.sch[kam+1]==1 || uloha->pozice.sch[kam-1]==1)
	/* nebo bily tahne pescem o 2 */
	|| odkud-kam==-20 && uloha->pozice.sch[odkud]==1
		/* a cerny pesec ciha */
	&& (uloha->pozice.sch[kam+1]==-1 || uloha->pozice.sch[kam-1]==-1))
		
      uloha->pozice.mimoch=kam;
 /* Niceni rosad
   Pozn.: nejde dat vsude 'else', protoze napr. Va1xa8 nici obe velke rosady*/
    if (odkud==e1) uloha->pozice.roch&=12; else /* 1100b*/
    if (odkud==e8) uloha->pozice.roch&=3; else /* 0011b*/
  { if (kam==a1 || odkud==a1) uloha->pozice.roch&=13;/*1101b*/
    if (kam==h1 || odkud==h1) uloha->pozice.roch&=14;/*1110b*/
    if (kam==a8 || odkud==a8) uloha->pozice.roch&=7; /*0111b*/
    if (kam==h8 || odkud==h8) uloha->pozice.roch&=11;/*1011b*/
  }
/* Ulozim si sebranou figuru*/
 uloha->zasobnik.brani[hloubka]=uloha->pozice.sch[kam];
 BeznyTah:; /* sem se skace z konce brani mimochodem*/
 /* zakladni rutina normalniho tahu:*/
 uloha->pozice.sch[kam]=uloha->pozice.sch[odkud];
 uloha->pozice.sch[odkud]=0;
Konec:;
 return;
 }
  /* Nenormalni tah

     Mala bila rosada*/
  if (tah==MBRoch)
   {uloha->pozice.sch[e1]=0;
    uloha->pozice.sch[g1]=6;
    uloha->pozice.sch[h1]=0;
    uloha->pozice.sch[f1]=4;
    uloha->pozice.roch&=12;
    uloha->zasobnik.brani[hloubka]=0;
    goto Konec;}
  /*Velka bila rosada*/
  if (tah==VBRoch)
   {uloha->pozice.sch[e1]=0;
    uloha->pozice.sch[c1]=6;
    uloha->pozice.sch[a1]=0;
    uloha->pozice.sch[d1]=4;
    uloha->pozice.roch&=12;
    uloha->zasobnik.brani[hloubka]=0;
    goto Konec;}
 /*Mala cerna rosada*/
  if (tah==MCRoch)
   {uloha->pozice.sch[e8]=0;
    uloha->pozice.sch[g8]=-6;
    uloha->pozice.sch[h8]=0;
    uloha->pozice.sch[f8]=-4;
    uloha->pozice.roch&=3;
    uloha->zasobnik.brani[hloubka]=0;
    goto Konec;}
  /*Velka cerna rosada*/
  if (tah==VCRoch)
   {uloha->pozice.sch[e8]=0;
    uloha->pozice.sch[c8]=-6;
    uloha->pozice.sch[a8]=0;
    uloha->pozice.sch[d8]=-4;
    uloha->pozice.roch&=3;
    uloha->zasobnik.brani[hloubka]=0;
    goto Konec;}
  /*Promena bileho pesce*/
 if ((tah>>12)==12)
  {odkud=(u8)(a7+((tah>>7)&7));
   kam=(u8)(a8+((tah>>4)&7));
   co=(s8)(2+((tah>>10)&3));
   /* Ulozim si, co jsem sebral */
   uloha->zasobnik.brani[hloubka]=uloha->pozice.sch[kam];
   uloha->pozice.sch[odkud]=0;
   uloha->pozice.sch[kam]=co;
   if (kam==a8) /* meni pesce na a8, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=7; /*0111b*/
   if (kam==h8) /* meni pesce na h8, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=11; /*1011b */
   goto Konec;
  }
  /*Promena cerneho pesce*/
 if ((tah>>12)==13)
  {
  odkud=(u8)(a2+((tah>>7)&7));
   kam=(u8)(a1+((tah>>4)&7));
   co=(s8)(-(2+((tah>>10)&3))); 
	
   /* Ulozim si, co jsem sebral */
   uloha->zasobnik.brani[hloubka]=uloha->pozice.sch[kam];
   uloha->pozice.sch[odkud]=0;
   uloha->pozice.sch[kam]=co;
   if (kam==a1) /* meni pesce na a1, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=13; /*1101b*/
   if (kam==h1) /* meni pesce na h1, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=14; /*1110b*/
    goto Konec;
  }
 /* Brani mimochodem (nic jineho to uz byt nemuze)*/
 tah&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
 kam=(u8)(tah&127);
 odkud=(u8)(tah>>7);
 if(odkud<kam)
  {uloha->pozice.sch[kam-10]=0;
   uloha->zasobnik.brani[hloubka]=-1;
 }
   /* to hral bily*/
 else
  {uloha->pozice.sch[kam+10]=0;
   uloha->zasobnik.brani[hloubka]=1;
 }
   /* cerny*/
 goto BeznyTah; /* zbytek je stejny jako pro normalni tah*/
 }
 /**************************************************************************
 *   Tahni - Tahne v propoctu (Nikoliv v partii)                           *
 *   Ulozi na zasobnik sebranou figuru, potom zvedne pos o 1               *
 *   a pak ulozi materialistickou cenu vznikle pozice                      *
 ***************************************************************************/
 void Tahni(u16 tah, TUloha *uloha)
 { s8 odkud,kam;
   s8 co,pom;
  s16 hloubka;
  int sloupec;
/*if(PocetCernych(uloha->pozice.sch)>4){ 
TiskniSachovnici(&uloha->pozice,stdout);
}*/
  hloubka=uloha->zasobnik.pos++;
  uloha->zasobnik.zmen[hloubka]=(hloubka ? uloha->zasobnik.zmen[hloubka-1] : 0);
  uloha->zasobnik.rozsir[hloubka]=(hloubka ? uloha->zasobnik.rozsir[hloubka-1] : 0);
  uloha->zasobnik.hF[hloubka+1]=uloha->zasobnik.hF[hloubka]^
  hnF.bily ^ hnF.mimoch[uloha->pozice.mimoch] ^ hnF.roch[uloha->pozice.roch];
  uloha->zasobnik.hG[hloubka+1]=uloha->zasobnik.hG[hloubka]^
  hnG.bily ^ hnG.mimoch[uloha->pozice.mimoch] ^ hnG.roch[uloha->pozice.roch];
  uloha->zasobnik.hPechG[hloubka+1]=uloha->zasobnik.hPechG[hloubka];
  uloha->zasobnik.hPechF[hloubka+1]=uloha->zasobnik.hPechF[hloubka];
  uloha->pozice.mimoch=0; /*Vetsina tahu neni pescem o 2, pokud ano, osetri se*/
  uloha->pozice.bily=!uloha->pozice.bily;
  uloha->zasobnik.bm[hloubka+1]=uloha->zasobnik.bm[hloubka];
  uloha->zasobnik.cm[hloubka+1]=uloha->zasobnik.cm[hloubka];
  if(!(tah>>15)) /* Normalni tah*/
   {kam=(u8)(tah&127);
    odkud=(u8)(tah>>7);
	uloha->zasobnik.kam[hloubka]=kam;
	/*Kdyz tahnu pescem, doslo ke zmene*/
	if(abs(uloha->pozice.sch[odkud])==1)
	 (uloha->zasobnik.zmen[hloubka])++;
    if(/* bud cerny tahne pescem o 2*/
		odkud-kam==20 && uloha->pozice.sch[odkud]==-1
		/* a bily pesec ciha */
	&& (uloha->pozice.sch[kam+1]==1 || uloha->pozice.sch[kam-1]==1)
	/* nebo bily tahne pescem o 2 */
	|| odkud-kam==-20 && uloha->pozice.sch[odkud]==1
		/* a cerny pesec ciha */
	&& (uloha->pozice.sch[kam+1]==-1 || uloha->pozice.sch[kam-1]==-1))
		
      uloha->pozice.mimoch=kam;
 /* Niceni rosad
   Pozn.: nejde dat vsude 'else', protoze napr. Va1xa8 nici obe velke rosady*/
    if (odkud==e1) uloha->pozice.roch&=12; else /* 1100b*/
    if (odkud==e8) uloha->pozice.roch&=3; else /* 0011b*/
  { if (kam==a1 || odkud==a1) uloha->pozice.roch&=13;/*1101b*/
    if (kam==h1 || odkud==h1) uloha->pozice.roch&=14;/*1110b*/
    if (kam==a8 || odkud==a8) uloha->pozice.roch&=7; /*0111b*/
    if (kam==h8 || odkud==h8) uloha->pozice.roch&=11;/*1011b*/
  }
/* Ulozim si sebranou figuru*/
 uloha->zasobnik.brani[hloubka]=uloha->pozice.sch[kam];
 /* Ulozim si zmenu hodnoty pozice, hraje-li bily.
 Nejprve jen to, ze tahnouci figurka zmenila pole*/
 if(uloha->pozice.sch[kam]>0)/* a musim odecist materialni cenu sebrane figury bile*/
   uloha->zasobnik.bm[hloubka+1]-=StdCenyFigur[uloha->pozice.sch[kam]];
 else
 if(uloha->pozice.sch[kam]<0) /* a cerne */
  uloha->zasobnik.cm[hloubka+1]-=StdCenyFigur[-uloha->pozice.sch[kam]];
 BeznyTah:; /* sem se skace z konce brani mimochodem*/
 /* Zahashuji strukturu pescu */
 if(uloha->pozice.sch[odkud]==1){
  uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[7][odkud];
  uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[7][odkud];
  uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[7][kam];
  uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[7][kam];
 } else
 if(uloha->pozice.sch[odkud]==-1){
  uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[5][odkud];
  uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[5][odkud];
  uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[5][kam];
  uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[5][kam];
 }
if(uloha->pozice.sch[kam]==1){
  uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[7][kam];
  uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[7][kam];
}else
 if(uloha->pozice.sch[kam]==-1){
  uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[5][kam];
  uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[5][kam];
 }
/* Zmena polozky material */
 switch(uloha->pozice.sch[odkud]){
 case 1: /*Mohl pescem zmenit sloupec a to pokud bral.*/
  if(kam-odkud==11){
   sloupec=odkud%10-1;
   uloha->material.BPSloupec[sloupec]--;
   uloha->material.BPSloupec[sloupec+1]++;}else
  if(kam-odkud==9){
   sloupec=odkud%10-1;
   uloha->material.BPSloupec[sloupec]--;
   uloha->material.BPSloupec[sloupec-1]++;}
   break;
 case -1: /*Mohl pescem zmenit sloupec a to pokud bral.*/
  if(kam-odkud==-11){
   sloupec=odkud%10-1;
   uloha->material.CPSloupec[sloupec]--;
   uloha->material.CPSloupec[sloupec-1]++;}else
  if(kam-odkud==-9){
   sloupec=odkud%10-1;
   uloha->material.CPSloupec[sloupec]--;
   uloha->material.CPSloupec[sloupec+1]++;}
   break;
 case 6:uloha->material.bk=kam;break;
 case -6:uloha->material.ck=kam;break;
 }
 switch(uloha->pozice.sch[kam]){
  case 0: break;
  case 1: uloha->material.BPSloupec[kam%10-1]--;
          uloha->material.b[0]--; break;
  case -1: uloha->material.CPSloupec[kam%10-1]--;
          uloha->material.c[0]--; break;
  case 2: uloha->material.b[1]--; break;
  case -2: uloha->material.c[1]--; break;
  case 3: uloha->material.b[2]--; break;
  case -3: uloha->material.c[2]--; break;
  case 4: uloha->material.b[3]--; break;
  case -4: uloha->material.c[3]--; break;
  case 5: uloha->material.b[4]--; break;
  case -5: uloha->material.c[4]--; break;
 }
 /* zakladni rutina normalniho tahu:*/
 uloha->zasobnik.hF[hloubka+1]^=hnF.f[uloha->pozice.sch[odkud]+6][odkud];
 uloha->zasobnik.hG[hloubka+1]^=hnG.f[uloha->pozice.sch[odkud]+6][odkud];
/* Z výchozího policka zmizi puvodni figura */
 uloha->zasobnik.hF[hloubka+1]^=hnF.f[6][odkud];
 uloha->zasobnik.hG[hloubka+1]^=hnG.f[6][odkud];
/* A bude tam prazdno */
 uloha->zasobnik.hF[hloubka+1]^=hnF.f[uloha->pozice.sch[kam]+6][kam];
 uloha->zasobnik.hG[hloubka+1]^=hnG.f[uloha->pozice.sch[kam]+6][kam];
/* Z ciloveho policka zmizi puvodni figura */
 uloha->zasobnik.hF[hloubka+1]^=hnF.f[uloha->pozice.sch[odkud]+6][kam];
 uloha->zasobnik.hG[hloubka+1]^=hnG.f[uloha->pozice.sch[odkud]+6][kam];
/* A bude tam tahnouci figura */
 uloha->pozice.sch[kam]=uloha->pozice.sch[odkud];
 uloha->pozice.sch[odkud]=0;
Konec:;
 if(uloha->zasobnik.brani[hloubka])(uloha->zasobnik.zmen[hloubka])++;
/* Jeste musim zahashovat novy stav rosad a mimochodem */
  uloha->zasobnik.hF[hloubka+1]^=hnF.mimoch[uloha->pozice.mimoch] ^ hnF.roch[uloha->pozice.roch];
  uloha->zasobnik.hG[hloubka+1]^=hnG.mimoch[uloha->pozice.mimoch] ^ hnG.roch[uloha->pozice.roch];
#ifdef LadimHash
  if(!uloha->StavPropoctu.VNT){
  if(uloha->zasobnik.hF[hloubka+1]!=HashF(&(uloha->pozice)) ||
     uloha->zasobnik.hG[hloubka+1]!=HashG(&(uloha->pozice)) ||
	uloha->zasobnik.hPechF[hloubka+1]!=HashPechF(&(uloha->pozice))||
	uloha->zasobnik.hPechG[hloubka+1]!=HashPechG(&(uloha->pozice))
	 )
  { TiskniSachovnici(&(uloha->pozice));
	 fputs("\nChyba hash funkce !!!!!!!\n",stderr);}
  }
#endif
/*
 if(!KontrolaMaterialu(uloha)){
  TiskniSachovnici(&(uloha->pozice));
  printf("Chyba materialu, Tahni, tah %i",(int)tah);
  exit(1);
  }
  */
 return;
 }
  /* Nenormalni tah

     Mala bila rosada*/
  if (tah==MBRoch)
   {uloha->pozice.sch[e1]=0;
    uloha->pozice.sch[g1]=6;
    uloha->pozice.sch[h1]=0;
    uloha->pozice.sch[f1]=4;
    uloha->pozice.roch&=12;
    uloha->zasobnik.brani[hloubka]=0;
	/* Rosada zmenila hodnotu pozice*/
	uloha->zasobnik.hF[hloubka+1]^=
     hnF.f[6+6][e1]^hnF.f[6+6][g1]
	^hnF.f[4+6][h1]^hnF.f[4+6][f1]^
	 hnF.f[6][e1]^hnF.f[6][h1]
	^hnF.f[6][g1]^hnF.f[6][f1];
	uloha->zasobnik.hG[hloubka+1]^=
     hnG.f[6+6][e1]^hnG.f[6+6][g1]
	^hnG.f[4+6][h1]^hnG.f[4+6][f1]^
	 hnG.f[6][e1]^hnG.f[6][h1]
	^hnG.f[6][g1]^hnG.f[6][f1];
	uloha->material.bk=g1;
	uloha->zasobnik.kam[hloubka]=g1;
    goto Konec;}
  /*Velka bila rosada*/
  if (tah==VBRoch)
   {uloha->pozice.sch[e1]=0;
    uloha->pozice.sch[c1]=6;
    uloha->pozice.sch[a1]=0;
    uloha->pozice.sch[d1]=4;
    uloha->pozice.roch&=12;
    uloha->zasobnik.brani[hloubka]=0;
    uloha->zasobnik.hF[hloubka+1]^=
     hnF.f[6+6][e1]^hnF.f[6+6][c1]
	^hnF.f[4+6][a1]^hnF.f[4+6][d1]^
	 hnF.f[6][e1]^hnF.f[6][a1]
	^hnF.f[6][c1]^hnF.f[6][d1];
	uloha->zasobnik.hG[hloubka+1]^=
     hnG.f[6+6][e1]^hnG.f[6+6][c1]
	^hnG.f[4+6][a1]^hnG.f[4+6][d1]^
	 hnG.f[6][e1]^hnG.f[6][a1]
	^hnG.f[6][c1]^hnG.f[6][d1];
	uloha->material.bk=c1;
	uloha->zasobnik.kam[hloubka]=c1;
    goto Konec;}
 /*Mala cerna rosada*/
  if (tah==MCRoch)
   {uloha->pozice.sch[e8]=0;
    uloha->pozice.sch[g8]=-6;
    uloha->pozice.sch[h8]=0;
    uloha->pozice.sch[f8]=-4;
    uloha->pozice.roch&=3;
    uloha->zasobnik.brani[hloubka]=0;
	uloha->zasobnik.hF[hloubka+1]^=
     hnF.f[6-6][e8]^hnF.f[6-6][g8]
	^hnF.f[6-4][h8]^hnF.f[6-4][f8]^
	 hnF.f[6][e8]^hnF.f[6][h8]
	^hnF.f[6][f8]^hnF.f[6][g8];
	uloha->zasobnik.hG[hloubka+1]^=
     hnG.f[6-6][e8]^hnG.f[6-6][g8]
	^hnG.f[6-4][h8]^hnG.f[6-4][f8]^
	 hnG.f[6][e8]^hnG.f[6][h8]
	^hnG.f[6][f8]^hnG.f[6][g8];
	uloha->material.ck=g8;
	uloha->zasobnik.kam[hloubka]=g8;
    goto Konec;}
  /*Velka cerna rosada*/
  if (tah==VCRoch)
   {uloha->pozice.sch[e8]=0;
    uloha->pozice.sch[c8]=-6;
    uloha->pozice.sch[a8]=0;
    uloha->pozice.sch[d8]=-4;
    uloha->pozice.roch&=3;
    uloha->zasobnik.brani[hloubka]=0;
	uloha->zasobnik.hF[hloubka+1]^=
     hnF.f[6-6][e8]^hnF.f[6-6][c8]
	^hnF.f[6-4][a8]^hnF.f[6-4][d8]^
	 hnF.f[6][e8]^hnF.f[6][a8]
	^hnF.f[6][c8]^hnF.f[6][d8];
	uloha->zasobnik.hG[hloubka+1]^=
     hnG.f[6-6][e8]^hnG.f[6-6][c8]
	^hnG.f[6-4][a8]^hnG.f[6-4][d8]^
	 hnG.f[6][e8]^hnG.f[6][a8]
	^hnG.f[6][c8]^hnG.f[6][d8];
	uloha->material.ck=c8;
	uloha->zasobnik.kam[hloubka]=c8;
    goto Konec;}
  /*Promena bileho pesce*/
 if ((tah>>12)==12)
  {(uloha->zasobnik.zmen[hloubka])++;
   odkud=(u8)(a7+((tah>>7)&7));
   uloha->zasobnik.kam[hloubka]=kam=(u8)(a8+((tah>>4)&7));
   co=(s8)(2+((tah>>10)&3));
   uloha->material.BPSloupec[odkud%10-1]--;
   uloha->material.b[0]--;
   uloha->material.b[co-1]++;
   pom=-uloha->pozice.sch[kam]-1;
   if(pom>=0 && pom<5){
    uloha->material.c[pom]--;
   }
   /* Ulozim si, co jsem sebral */
   uloha->zasobnik.brani[hloubka]=uloha->pozice.sch[kam];
   /* jak se zmenil material bileho */
   uloha->zasobnik.bm[hloubka+1]+=
	   StdCenyFigur[co]-StdCenyFigur[1];
   /* a cerneho */
   uloha->zasobnik.cm[hloubka+1]-=StdCenyFigur[-uloha->pozice.sch[kam]];
   /* Take se zmenila pozice*/
	uloha->zasobnik.hF[hloubka+1]^=
     hnF.f[uloha->pozice.sch[kam]+6][kam]^hnF.f[co+6][kam]^
	 hnF.f[1+6][odkud]^hnF.f[6][odkud];
	uloha->zasobnik.hG[hloubka+1]^=
     hnG.f[uloha->pozice.sch[kam]+6][kam]^hnG.f[co+6][kam]^
	 hnG.f[1+6][odkud]^hnG.f[6][odkud];
   uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[7][odkud];
   uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[7][odkud];
    uloha->pozice.sch[odkud]=0;
   uloha->pozice.sch[kam]=co;
   if (kam==a8) /* meni pesce na a8, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=7; /*0111b*/
   if (kam==h8) /* meni pesce na h8, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=11; /*1011b */
   goto Konec;
  }
  /*Promena cerneho pesce*/
 if ((tah>>12)==13)
  {(uloha->zasobnik.zmen[hloubka])++;
  odkud=(u8)(a2+((tah>>7)&7));
   uloha->zasobnik.kam[hloubka]=kam=(u8)(a1+((tah>>4)&7));
   co=(s8)(-(2+((tah>>10)&3))); 

   uloha->material.CPSloupec[odkud%10-1]--;
   uloha->material.c[0]--;
   uloha->material.c[-co-1]++;
   pom=uloha->pozice.sch[kam]-1;
   if(pom>=0 && pom<5){
    uloha->material.b[pom]--;
   }
	
   /* Ulozim si, co jsem sebral */
   uloha->zasobnik.brani[hloubka]=uloha->pozice.sch[kam];
   /* jak se zmenil material cerneho */
   uloha->zasobnik.cm[hloubka+1]+=
	   StdCenyFigur[-co]-StdCenyFigur[1];
   /* a bileho */
   uloha->zasobnik.bm[hloubka+1]-=StdCenyFigur[uloha->pozice.sch[kam]];
   /* Take se zmenila pozice*/
	uloha->zasobnik.hF[hloubka+1]^=
     hnF.f[uloha->pozice.sch[kam]+6][kam]^hnF.f[co+6][kam]^
	 hnF.f[6-1][odkud]^hnF.f[6][odkud];
	uloha->zasobnik.hG[hloubka+1]^=
     hnG.f[uloha->pozice.sch[kam]+6][kam]^hnG.f[co+6][kam]^
	 hnG.f[6-1][odkud]^hnG.f[6][odkud];
   uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[5][odkud];
   uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[5][odkud];
   uloha->pozice.sch[odkud]=0;
   uloha->pozice.sch[kam]=co;
   if (kam==a1) /* meni pesce na a1, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=13; /*1101b*/
   if (kam==h1) /* meni pesce na h1, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=14; /*1110b*/
    goto Konec;
  }
 /* Brani mimochodem (nic jineho to uz byt nemuze)*/
 tah&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
 uloha->zasobnik.kam[hloubka]=kam=(u8)(tah&127);
 odkud=(u8)(tah>>7);
 if(odkud<kam)
  {uloha->material.c[0]--;
   uloha->material.CPSloupec[kam%10-1]--;
   uloha->pozice.sch[kam-10]=0;
   uloha->zasobnik.brani[hloubka]=-1;
   uloha->zasobnik.cm[hloubka+1]-=StdCenyFigur[1];
   uloha->zasobnik.hF[hloubka+1]^=hnF.f[6-1][kam-10]^hnF.f[6][kam-10];
   uloha->zasobnik.hG[hloubka+1]^=hnG.f[6-1][kam-10]^hnG.f[6][kam-10];   
   uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[5][kam-10];
   uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[5][kam-10];
 }
   /* to hral bily*/
 else
  {uloha->material.b[0]--;
   uloha->material.BPSloupec[kam%10-1]--;
   uloha->pozice.sch[kam+10]=0;
   uloha->zasobnik.brani[hloubka]=1;
   uloha->zasobnik.bm[hloubka+1]-=StdCenyFigur[1];
   uloha->zasobnik.hF[hloubka+1]^=hnF.f[6+1][kam+10]^hnF.f[6][kam+10];
   uloha->zasobnik.hG[hloubka+1]^=hnG.f[6+1][kam+10]^hnG.f[6][kam+10];
   uloha->zasobnik.hPechF[hloubka+1]^=hnF.f[7][kam+10];
   uloha->zasobnik.hPechG[hloubka+1]^=hnG.f[7][kam+10];
 }
   /* cerny*/
 goto BeznyTah; /* zbytek je stejny jako pro normalni tah*/
 }
/***************************************************************************
 *   TahniZpet - Tahne zpet v propoctu (Nikoliv v partii)                  *         *
 *    V zasobniku nejprve snizi pos o 1 a pak cte z urovne pos             *
 ***************************************************************************/
void TahniZpet(u16 tah, TUloha *uloha)
 {s8 odkud, kam, hloubka;
  s8 co;
  int sloupec;
/*  static u32 pocet=0;
if(tah==10071)pocet++;
if(tah==10071 && pocet==270){
TiskniSachovnici(&uloha->pozice,stdout);
}
  if(PocetCernych(uloha->pozice.sch)>4){ /
TiskniSachovnici(&uloha->pozice,stdout);
}*/
  hloubka=(u8)--uloha->zasobnik.pos;
  uloha->pozice.mimoch=uloha->zasobnik.mimoch[hloubka];
  uloha->pozice.roch=uloha->zasobnik.roch[hloubka];
  uloha->pozice.bily=!uloha->pozice.bily;
  if(!(tah>>15)) /* Normalni tah*/
   {kam=(u8)(tah&127);
    odkud=(u8)(tah>>7);
  /*(uloha->pozice.sch[odkud])*/

 switch(uloha->pozice.sch[kam]){
 case 1: /*Mohl pescem zmenit sloupec a to pokud bral.*/
  if(kam-odkud==11){
   sloupec=odkud%10-1;
   uloha->material.BPSloupec[sloupec]++;
   uloha->material.BPSloupec[sloupec+1]--;}else
  if(kam-odkud==9){
   sloupec=odkud%10-1;
   uloha->material.BPSloupec[sloupec]++;
   uloha->material.BPSloupec[sloupec-1]--;}
   break;
 case -1: /*Mohl pescem zmenit sloupec a to pokud bral.*/
  if(kam-odkud==-11){
   sloupec=odkud%10-1;
   uloha->material.CPSloupec[sloupec]++;
   uloha->material.CPSloupec[sloupec-1]--;}else
  if(kam-odkud==-9){
   sloupec=odkud%10-1;
   uloha->material.CPSloupec[sloupec]++;
   uloha->material.CPSloupec[sloupec+1]--;}
   break;
 case 6:uloha->material.bk=odkud;break;
 case -6:uloha->material.ck=odkud;break;
 }
 switch(uloha->zasobnik.brani[hloubka]){
  case 0: break;
  case 1: uloha->material.BPSloupec[kam%10-1]++;
          uloha->material.b[0]++; break;
  case -1: uloha->material.CPSloupec[kam%10-1]++;
          uloha->material.c[0]++; break;
  case 2: uloha->material.b[1]++; break;
  case -2: uloha->material.c[1]++; break;
  case 3: uloha->material.b[2]++; break;
  case -3: uloha->material.c[2]++; break;
  case 4: uloha->material.b[3]++; break;
  case -4: uloha->material.c[3]++; break;
  case 5: uloha->material.b[4]++; break;
  case -5: uloha->material.c[4]++; break;
 }
 uloha->pozice.sch[odkud]=uloha->pozice.sch[kam];
 uloha->pozice.sch[kam]=uloha->zasobnik.brani[hloubka];

 goto konec;
 }
  /* Nenormalni tah

     Mala bila rosada*/
  if (tah==MBRoch)
   {uloha->pozice.sch[e1]=6;
    uloha->pozice.sch[g1]=0;
    uloha->pozice.sch[h1]=4;
    uloha->pozice.sch[f1]=0;
	uloha->material.bk=e1;
    goto konec;}
  /*Velka bila rosada*/
  if (tah==VBRoch)
   {uloha->pozice.sch[e1]=6;
    uloha->pozice.sch[c1]=0;
    uloha->pozice.sch[a1]=4;
    uloha->pozice.sch[d1]=0;
	uloha->material.bk=e1;
    goto konec;}
 /*Mala cerna rosada*/
  if (tah==MCRoch)
   {uloha->pozice.sch[e8]=-6;
    uloha->pozice.sch[g8]=0;
    uloha->pozice.sch[h8]=-4;
    uloha->pozice.sch[f8]=0;
	uloha->material.ck=e8;
    goto konec;}
  /*Velka cerna rosada*/
  if (tah==VCRoch)
   {uloha->pozice.sch[e8]=-6;
    uloha->pozice.sch[c8]=0;
    uloha->pozice.sch[a8]=-4;
    uloha->pozice.sch[d8]=0;
	uloha->material.ck=e8;
    goto konec;}
  /*Promena bileho pesce*/
 if ((tah>>12)==12)
  {odkud=a7+((tah>>7)&7);
   kam=a8+((tah>>4)&7);
   co=uloha->zasobnik.brani[hloubka];
   uloha->material.b[0]++;
   uloha->material.BPSloupec[odkud % 10 -1]++;
   uloha->material.b[uloha->pozice.sch[kam]-1]--;
   if(co<0 && co>-6){
    uloha->material.c[-co-1]++;
	}
   uloha->pozice.sch[odkud]=1;
   uloha->pozice.sch[kam]=co;
   goto konec;
  }
  /*Promena cerneho pesce*/
 if ((tah>>12)==13)
  {
   odkud=a2+((tah>>7)&7);
   kam=a1+((tah>>4)&7);
   co=uloha->zasobnik.brani[hloubka];
   uloha->material.c[0]++;
   uloha->material.CPSloupec[odkud % 10 -1]++;
   uloha->material.c[-uloha->pozice.sch[kam]-1]--;
   if(co>0 && co<6){
    uloha->material.b[co-1]++;
	}
   uloha->pozice.sch[odkud]=-1;
   uloha->pozice.sch[kam]=co;
   goto konec;
  }
 /* Brani mimochodem (nic jineho to uz byt nemuze)*/
 tah&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
 kam=(u8)(tah&127);
 odkud=(u8)(tah>>7);
 co=kam%10-1;
 uloha->pozice.sch[kam]=0;
 if(odkud<kam)
  {uloha->pozice.sch[kam-10]=-1; /* to hraje bily*/
   uloha->pozice.sch[odkud]=1;
   uloha->material.c[0]++;
   uloha->material.BPSloupec[co]--;
   uloha->material.CPSloupec[co]++;
   uloha->material.BPSloupec[(kam==odkud+11) ? co-1: co+1]++;
   }
 else
 {uloha->pozice.sch[kam+10]=1;  /* cerny */
  uloha->pozice.sch[odkud]=-1;
  uloha->material.b[0]++;
  uloha->material.CPSloupec[co]--;
  uloha->material.BPSloupec[co]++;
  uloha->material.CPSloupec[(kam==odkud-9) ? co-1: co+1]++;
  }
konec:;
  /*if(PocetCernych(uloha->pozice.sch)>4){ 
TiskniSachovnici(&uloha->pozice,stdout);
}*/
/*
 if(!KontrolaMaterialu(uloha)){
  TiskniSachovnici(&(uloha->pozice));
  printf("Chyba materialu, TahniZpet, tah %i",(int)tah);
  exit(1);
  }*/
 }

void JednoTahniZpet(u16 tah, TUloha *uloha)
 {u8 odkud, kam, hloubka;

  hloubka=(u8)--uloha->zasobnik.pos;
  uloha->pozice.mimoch=uloha->zasobnik.mimoch[hloubka];
  uloha->pozice.roch=uloha->zasobnik.roch[hloubka];
  uloha->pozice.bily=!uloha->pozice.bily;
  if(!(tah>>15)) /* Normalni tah*/
   {kam=(u8)(tah&127);
    odkud=(u8)(tah>>7);
 uloha->pozice.sch[odkud]=uloha->pozice.sch[kam];
 uloha->pozice.sch[kam]=uloha->zasobnik.brani[hloubka];

 goto konec;
 }
  /* Nenormalni tah

     Mala bila rosada*/
  if (tah==MBRoch)
   {uloha->pozice.sch[e1]=6;
    uloha->pozice.sch[g1]=0;
    uloha->pozice.sch[h1]=4;
    uloha->pozice.sch[f1]=0;
    goto konec;}
  /*Velka bila rosada*/
  if (tah==VBRoch)
   {uloha->pozice.sch[e1]=6;
    uloha->pozice.sch[c1]=0;
    uloha->pozice.sch[a1]=4;
    uloha->pozice.sch[d1]=0;
    goto konec;}
 /*Mala cerna rosada*/
  if (tah==MCRoch)
   {uloha->pozice.sch[e8]=-6;
    uloha->pozice.sch[g8]=0;
    uloha->pozice.sch[h8]=-4;
    uloha->pozice.sch[f8]=0;
    goto konec;}
  /*Velka cerna rosada*/
  if (tah==VCRoch)
   {uloha->pozice.sch[e8]=-6;
    uloha->pozice.sch[c8]=0;
    uloha->pozice.sch[a8]=-4;
    uloha->pozice.sch[d8]=0;
    goto konec;}
  /*Promena bileho pesce*/
 if ((tah>>12)==12)
  {
   uloha->pozice.sch[a7+((tah>>7)&7)]=1;
   uloha->pozice.sch[a8+((tah>>4)&7)]=uloha->zasobnik.brani[hloubka];
   goto konec;
  }
  /*Promena cerneho pesce*/
 if ((tah>>12)==13)
  {
   uloha->pozice.sch[a2+((tah>>7)&7)]=-1;
   uloha->pozice.sch[a1+((tah>>4)&7)]=uloha->zasobnik.brani[hloubka];
   goto konec;
  }
 /* Brani mimochodem (nic jineho to uz byt nemuze)*/
 tah&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
 kam=(u8)(tah&127);
 odkud=(u8)(tah>>7);
 if(odkud<kam)
  {uloha->pozice.sch[kam-10]=-1; /* to hraje bily*/
   uloha->pozice.sch[odkud]=1;}
 else
 {uloha->pozice.sch[kam+10]=1;  /* cerny */
  uloha->pozice.sch[odkud]=-1;}
 uloha->pozice.sch[kam]=0;
konec:;
 }

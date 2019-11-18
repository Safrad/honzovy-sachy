/*********************************************************/
/* globruti.c - globalni sachove rutiny                  */
/* napr. zahrani a vraceni tahu v partii                 */ 
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include <stdarg.h>
#include <stdlib.h>
#include "volby.h"
#include "cotyvar.h"
#include "chyba.h"
#include "globruti.h"
#include "myslitel.h"
#include "generato.h"
#include "partie.h"
#include "hashtab.h"
#include "lokruti.h"
#include "strtah.h"
#if Typ_Produktu==Win32_Program
char NazvyVysledku[8][38]={
 "Hrajeme dál",
 "Bílý dostal mat",
 "Èerný dostal mat",
 "Remíza trojnásobným opakováním pozice",
 "Remíza díky pravidlu padesáti tahù",
 "Remíza, bílý dostal pat",
 "Remíza, èerný dostal pat",
 "Remíza, není matící materiál"
};
/*Pouze pro Windows*/
#endif
void ZjistiTypKoncePartie(TUloha *uloha)
/************************************************************************
 * Jak dopadla partie ? Nastaví správnì uloha->KonecPartie              *
 ************************************************************************/
 {int i,bbs,bcs,cbs,ccs,cj,bj;
 uloha->KonecPartie=0;
 NalezTahy(uloha);
 JenPripustne(uloha);
 if(uloha->zasobnik.hranice[1]==0)
  {
   if(Sach(uloha->pozice.bily,uloha->pozice.sch))
    uloha->KonecPartie=uloha->pozice.bily ? BilyVMatu : CernyVMatu;
   else
    uloha->KonecPartie=uloha->pozice.bily ? RemisBilyVPatu : RemisCernyVPatu;
  }
 else
 switch(Remiza50Nebo3(uloha))
  {
  case 50:uloha->KonecPartie=Remis50;break;
  case 3: uloha->KonecPartie=Remis3;break;
 }
 if(uloha->KonecPartie)return;
 bbs=bcs=cbs=ccs=cj=bj=0;
 for(i=a1;i<=h8;i++){
	 switch(uloha->pozice.sch[i]){
	 case 1:return;
	 case 4:return;
	 case 5:return;
	 case -1:return;
	 case -4:return;
	 case -5:return;
	 case 2:bj++;break;
	 case -2:cj++;break;
	 case 3:if(((i/10)+(i%10))&1)bbs++;else bcs++;break;
	 case -3:if(((i/10)+(i%10))&1)cbs++;else ccs++;break;
	 }
 }
 if((i=bbs+bcs+cbs+ccs+cj+bj)<=1||i==bbs+cbs||i==bcs+ccs)
	 uloha->KonecPartie=RemisMaloMaterialu;
 /*Je-li zadna nebo jen jedna lehka figura nebo
  jsou na sachovnici jen strelci jedne barvy, nebude mat*/
}

void JenPripustne(TUloha *uloha)
/*************************************************************************
 *  JenPripustne - Vynda z prvni dle pos volne (ale v praxi obsazene)    *
 *   urovne zasobniku nepripustne tahy tj. ty vedouci k sachu.           *
 *  Ty tahy tam uz musi byt.                                             *
 *  Pomerne pomale, neuzivat v rekurzi propoctu.                         *
 *  Nastavi pocatek druhe prazdne urovne (snizi nebo necha)              *
 *************************************************************************/
{TTah1 *pz,*pdo,*pkonec; /*pointery do zasobniku tahu
 pz - odkud beru testovane tahy
 pdo - kam je davam
 pkonec - prvni volne misto na zasobniku pred cistkou*/

 pdo=pz=uloha->zasobnik.tahy+ /* najedu ukazately na pocatek tahu
 posledni urovne v zasobniku*/
   uloha->zasobnik.hranice[uloha->zasobnik.pos];
 pkonec=uloha->zasobnik.tahy+ /* najedu pkoncem pocatek (neexistujicich) tahu
 prvni nevyuzite urovne v zasobniku*/
   uloha->zasobnik.hranice[uloha->zasobnik.pos+1];
 UlozStav(uloha);
 while (pz<pkonec)
 {JednoTahni(pz->data,uloha);
  if(!Sach(!uloha->pozice.bily,uloha->pozice.sch)) *pdo++=*pz;
  JednoTahniZpet(pz->data,uloha);pz++;
 }
 uloha->zasobnik.hranice[uloha->zasobnik.pos+1]=(s16)(pdo-uloha->zasobnik.tahy);
  /* uprava te horni hranice prvni volne skupiny zasobniku
     (mohl jsem neco vyskrtat) */
}

bool KorektniTah(u16 tah, TUloha *uloha)
/*************************************************************************/
/*  KorektniTah - je to pripustny tah ?                                  */
/*  Zvedne uroven zasobniku, nalezne tahy, vyskrta nepripustne,          */
/*  pokusi se tam ten tah najit a nakonec snizi uroven zasobniku zpet.   */
/*************************************************************************/
{s16 i;

 uloha->zasobnik.pos++;
 NalezTahy(uloha);
 JenPripustne(uloha);
 for(i=uloha->zasobnik.hranice[uloha->zasobnik.pos];
     i<uloha->zasobnik.hranice[uloha->zasobnik.pos+1];i++)
  if(tah==uloha->zasobnik.tahy[i].data) {uloha->zasobnik.pos--;return true;}

 uloha->zasobnik.pos--;
 return false;
}

bool KTNehledej(u16 tah, TUloha *uloha)
/*************************************************************************/
/*  KTNehledej -  Analogie KorektiTah, jen už vše musí být na zásobníku. */
/*  Ze zásobníku pouze ète.												 */
/*************************************************************************/
{s16 i;

 for(i=uloha->zasobnik.hranice[uloha->zasobnik.pos];
     i<uloha->zasobnik.hranice[uloha->zasobnik.pos+1];i++)
  if(tah==uloha->zasobnik.tahy[i].data) return true;
 return false;
}
void GlobTahni(bool TestKonce, TUloha *uloha, bool useknout, ...)
/*************************************************************************
 *   GlobTahni - Tah v partii (nikoliv v propoctu)                       *
 *   na zasobnik ani nesahne                                             *
 *   je-li useknout true, je dalsim parametrem unsigned - tah, ktery ze se to *
 *    ma zahrat tah - a tim se taky preplacne pripadny ocas partie       *
 *   je-li useknout false, nejsou zadne dalsi parametry, jde o           *
 *    znovuzahrani vraceneho tahu - ten se nacte z partie, ta se posune  *
 *    o 1 doprava, ocas se nemaze                                        *
 Tahy jsou unsigned a ne u16 kvuli nesmyslne iso norme
 (u16 by byla chyba pri prekladu !!!)
 *************************************************************************/
 {s8 odkud;
  s8 kam;
  va_list ptr;
  TPartData data;
  u16 tah;
  unsigned tah32;

  data.mimoch=(u8)uloha->pozice.mimoch;
  data.roch=uloha->pozice.roch;
  data.brani=0; /*pripady, kdy by to bylo blbe se pak opravi*/
  data.zmena=0;

  if (useknout)
  {va_start(ptr,useknout);
   tah32=va_arg(ptr,unsigned);
   tah=(u16)tah32;
   va_end(ptr);
#ifdef STRINGTAH
   NalezTahy(uloha);
   TahToStr(tah,uloha,data.nazev);
#endif
  }
  else
   tah=uloha->prt->p->data.t;
  data.t=tah;

  uloha->pozice.mimoch=0; /*Vetsina tahu neni pescem o 2, pokud ano, osetri se*/
  uloha->pozice.bily=!uloha->pozice.bily;
  if(!(tah>>15)) /* Normalni tah*/
   {kam=(s8)(tah&127);
    odkud=(s8)(tah>>7);
	if(abs(uloha->pozice.sch[odkud])==1)data.zmena=1;
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
 data.brani=uloha->pozice.sch[kam];
 BeznyTah:; /* sem se skace z konce brani mimochodem*/
 /* zakladni rutina normalniho tahu:*/
 uloha->pozice.sch[kam]=uloha->pozice.sch[odkud];
 uloha->pozice.sch[odkud]=0;
 goto PridejDoPartie;
 }
  /* Nenormalni tah
     Mala bila rosada*/
  if (tah==MBRoch)
   {uloha->pozice.sch[e1]=0;
    uloha->pozice.sch[g1]=6;
    uloha->pozice.sch[h1]=0;
    uloha->pozice.sch[f1]=4;
    uloha->pozice.roch&=12;
    data.brani=0;
    goto PridejDoPartie;}
  /*Velka bila rosada*/
  if (tah==VBRoch)
   {uloha->pozice.sch[e1]=0;
    uloha->pozice.sch[c1]=6;
    uloha->pozice.sch[a1]=0;
    uloha->pozice.sch[d1]=4;
    uloha->pozice.roch&=12;
    data.brani=0;
    goto PridejDoPartie;}
 /*Mala cerna rosada*/
  if (tah==MCRoch)
   {uloha->pozice.sch[e8]=0;
    uloha->pozice.sch[g8]=-6;
    uloha->pozice.sch[h8]=0;
    uloha->pozice.sch[f8]=-4;
    uloha->pozice.roch&=3;
    data.brani=0;
    goto PridejDoPartie;}
  /*Velka cerna rosada*/
  if (tah==VCRoch)
   {uloha->pozice.sch[e8]=0;
    uloha->pozice.sch[c8]=-6;
    uloha->pozice.sch[a8]=0;
    uloha->pozice.sch[d8]=-4;
    uloha->pozice.roch&=3;
    data.brani=0;
    goto PridejDoPartie;}
  /*Promena bileho pesce*/
 if ((tah>>12)==12)
   {data.zmena=1;
   data.brani=uloha->pozice.sch[a8+((tah>>4)&7)];
   uloha->pozice.sch[a7+((tah>>7)&7)]=0;
   uloha->pozice.sch[a8+((tah>>4)&7)]=(s8)(2+((tah>>10)&3));
   if (((tah>>4)&7)==0) /* meni pesce na a8, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=7; /*0111b*/
   if (((tah>>4)&7)==7) /* meni pesce na h8, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=11; /*1011b */
    goto PridejDoPartie;
  }
  /*Promena cerneho pesce*/
 if ((tah>>12)==13)
  {data.zmena=1;
   data.brani=uloha->pozice.sch[a1+((tah>>4)&7)];
   uloha->pozice.sch[a2+((tah>>7)&7)]=0;
   uloha->pozice.sch[a1+((tah>>4)&7)]=(s8)-(2+((tah>>10)&3));
   if (((tah>>4)&7)==0) /* meni pesce na a1, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=13; /*1101b*/
   if (((tah>>4)&7)==7) /* meni pesce na h1, mohl sezrat vez => rosady...*/
    uloha->pozice.roch&=14; /*1110b*/
    goto PridejDoPartie;
  }
 /* Brani mimochodem (nic jineho to uz byt nemuze)*/
 tah&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
 kam=(s8)(tah&127);
 odkud=(s8)(tah>>7);
 if(odkud<kam)
   {uloha->pozice.sch[kam-10]=0; /* to hraje bily*/
   data.brani=-1;}
 else
  {uloha->pozice.sch[kam+10]=0; /* cerny*/
   data.brani=1;}
 goto BeznyTah; /* zbytek je stejny jako pro normalni tah*/
 PridejDoPartie:;
 if (useknout) {
  data.hashF=HashF(&(uloha->pozice));
  if(data.brani)data.zmena=1;
  PridejTah(&uloha->prt,data);
 }
 else uloha->prt=uloha->prt->p;
 if(TestKonce)ZjistiTypKoncePartie(uloha);
}
void GlobTahniZpet(TUloha *uloha)
/***************************************************************************
 *   GlobTahniZpet - Tahne zpet v partii (Nikoliv v propoctu)              *
 *   Posune se v partii o 1 doleva, ocas nemaze, na zasobnik ani nesahne   *
 ***************************************************************************/
 {register u8 odkud;
  register u8 kam;
/*  u8 hloubka;*/
  u16 data;

#if LadeniGlobruti > 10
 if (!uloha->prt || !uloha->prt->l) Chyba("GlobTahniZpet");
#endif
  uloha->KonecPartie=false;
  uloha->pozice.mimoch=uloha->prt->data.mimoch;
  uloha->pozice.roch=uloha->prt->data.roch;
  uloha->pozice.bily=!uloha->pozice.bily;
  data=uloha->prt->data.t;
  uloha->prt=uloha->prt->l;

  if(!(data>>15)) /* Normalni tah*/
   {kam=(s8)(data&127);
    odkud=(s8)(data>>7);
 uloha->pozice.sch[odkud]=uloha->pozice.sch[kam];
 uloha->pozice.sch[kam]=uloha->prt->p->data.brani;

 return;
 }
  /* Nenormalni tah
     Mala bila rosada*/
  if (data==MBRoch)
   {uloha->pozice.sch[e1]=6;
    uloha->pozice.sch[g1]=0;
    uloha->pozice.sch[h1]=4;
    uloha->pozice.sch[f1]=0;
    return;}
  /*Velka bila rosada*/
  if (data==VBRoch)
   {uloha->pozice.sch[e1]=6;
    uloha->pozice.sch[c1]=0;
    uloha->pozice.sch[a1]=4;
    uloha->pozice.sch[d1]=0;
    return;}
 /*Mala cerna rosada*/
  if (data==MCRoch)
   {uloha->pozice.sch[e8]=-6;
    uloha->pozice.sch[g8]=0;
    uloha->pozice.sch[h8]=-4;
    uloha->pozice.sch[f8]=0;
    return;}
  /*Velka cerna rosada*/
  if (data==VCRoch)
   {uloha->pozice.sch[e8]=-6;
    uloha->pozice.sch[c8]=0;
    uloha->pozice.sch[a8]=-4;
    uloha->pozice.sch[d8]=0;
    return;}
  /*Promena bileho pesce*/
 if ((data>>12)==12)
  {
   uloha->pozice.sch[a7+((data>>7)&7)]=1;
   uloha->pozice.sch[a8+((data>>4)&7)]=uloha->prt->p->data.brani;
   return;
  }
  /*Promena cerneho pesce*/
 if ((data>>12)==13)
  {
   uloha->pozice.sch[a2+((data>>7)&7)]=-1;
   uloha->pozice.sch[a1+((data>>4)&7)]=uloha->prt->p->data.brani;
   return;
  }
 /* Brani mimochodem (nic jin‚ho to uz byt nemuze)*/
 data&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
 kam=(s8)(data&127);
 odkud=(s8)(data>>7);
 if(odkud<kam)
  {uloha->pozice.sch[kam-10]=-1; /* to hraje bily*/
   uloha->pozice.sch[odkud]=1;}
 else
  {uloha->pozice.sch[kam+10]=1;  /* cerny */
   uloha->pozice.sch[odkud]=-1;}
 uloha->pozice.sch[kam]=0;
 }

bool JeTam1(u8 odkud,TUloha *uloha)
/****************************************************/
/* Je mezi nalezenymi tahi nejaky vedouci z odkud ? */
/****************************************************/
{TTah1 *p,*k;
 u16 t;

 p=&uloha->zasobnik.tahy[uloha->zasobnik.hranice[uloha->zasobnik.pos]]-1;
 k=&uloha->zasobnik.tahy[uloha->zasobnik.hranice[uloha->zasobnik.pos+1]]-1;
 while(p<k)
  {p++;
  t=p->data;
  if(!(t>>15)) /* Normalni tah*/  if  (odkud==t>>7)  return true; else continue;
  if ((t==MBRoch || t==VBRoch)) if (odkud==e1) return true; else continue;
  if ((t==MCRoch || t==VCRoch)) if (odkud==e8) return true; else continue;
  /*Promena bileho pesce*/
  if ((t>>12)==12) if (odkud == a7+((t>>7)&7)) return true; else continue;
  /*Promena cerneho pesce*/
  if ((t>>12)==13) if (odkud == a2+((t>>7)&7)) return true; else continue;
  /* Brani mimochodem (nic jineho to uz byt nemuze)*/
  if ((t&0x3fff)>>7 == odkud) return true; else continue;
  }
 return false;
}

bool JeTam2(u8 odkud,u8 kam,TUloha *uloha)
/***********************************************************/
/* Je mezi nalezenymi tahi nejaky vedouci z odkud do kam ? */
/***********************************************************/
{TTah1 *p,*k;
 u16 t;

 p=&uloha->zasobnik.tahy[uloha->zasobnik.hranice[uloha->zasobnik.pos]]-1;
 k=&uloha->zasobnik.tahy[uloha->zasobnik.hranice[uloha->zasobnik.pos+1]]-1;
 while(p<k)
  {p++;
   t=p->data;
 /* Normalni tah*/
if(!(t>>15))  if(kam==(t&127) && odkud==(t>>7)) return true; else continue;
/*Rošády*/
if (t==MBRoch) if(odkud==e1 && kam==g1) return true; else continue;
if (t==VBRoch) if(odkud==e1 && kam==c1) return true; else continue;
if (t==MCRoch) if(odkud==e8 && kam==g8) return true; else continue;
if (t==VCRoch) if(odkud==e8 && kam==c8) return true; else continue;
  /*Promena bileho pesce*/
if ((t>>12)==12)
 if(odkud==a7+((t>>7)&7) && kam==a8+((t>>4)&7)) return true; else continue;
  /*Promena cerneho pesce*/
if ((t>>12)==13)
 if(odkud==a2+((t>>7)&7) && kam==a1+((t>>4)&7)) return true; else continue;
/* Brani mimochodem (nic jineho to uz byt nemuze)*/
t&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
if(kam==(t&127) && odkud==(t>>7)) return true; else continue;
} /* konec while cyklu*/
 return false;
}
#if Typ_Produktu==Win32_Program
#include "promdlg.h"
u16 DoplnTah(HWND hwnd,u8 odkud,u8 kam,TUloha *uloha)
/***************************************************/
/* Jen windows - pripadny dialog promeny pesce     */
/***************************************************/ 
 {
 TTah1 *p,*k;
 u16 t;

 p=&uloha->zasobnik.tahy[uloha->zasobnik.hranice[uloha->zasobnik.pos]]-1;
 k=&uloha->zasobnik.tahy[uloha->zasobnik.hranice[uloha->zasobnik.pos+1]]-1;
 while(p<k)
  {p++;
   t=p->data;
 /* Normalni tah*/
if(!(t>>15))  if(kam==(t&127) && odkud==(t>>7)) return t; else continue;
/*Rošády*/
if (t==MBRoch) if(odkud==e1 && kam==g1)  return t; else continue;
if (t==VBRoch) if(odkud==e1 && kam==c1)  return t; else continue;
if (t==MCRoch) if(odkud==e8 && kam==g8)  return t; else continue;
if (t==VCRoch) if(odkud==e8 && kam==c8)  return t; else continue;
  /*Promena bileho pesce*/
if ((t>>12)==12)
 if(odkud==a7+((t>>7)&7) && kam==a8+((t>>4)&7))
  return(t&(0xFFFF^(3<<10)))|(DialogPromeny(hwnd,1)<<10);
 else continue;
  /*Promena cerneho pesce*/
if ((t>>12)==13)
 if(odkud==a2+((t>>7)&7) && kam==a1+((t>>4)&7))
  return(t&(0xFFFF^(3<<10)))|(DialogPromeny(hwnd,0)<<10);
 else continue;
/* Brani mimochodem (nic jineho to uz byt nemuze)*/
if(kam==(t&0x3fff&127) && odkud==((t&0x3fff)>>7)) return t; else continue;
} /* konec while cyklu*/
 return 0;
 }
#endif

bool stejne(s8 *s1,s8 *s2)
/****************************/
/* jsou 2 šachovnice stejné */
/****************************/
{int i;
  for (i=a1;i<=h8;i++) if (s1[i]!=s2[i]) return false;
  return true;
}
bool DulezityTah(TPozice *pos,u16 t)
/*********************************************/
/* Pozice je pøed zahráním tahu t.           */
/* vrací true - je to tah pìšcem nebo braní  */
/* false - jindy                             */
/*********************************************/
 {
  if (t&(1<<15))
   {
    /* nenormalni tah */
     if (t&(1<<14))
      /* rosada nebo promena pesce*/
      {
       if (t&(1<<13)) return false; else return true;
                     /* rosada else promena pesce*/
      }
     else
     /* brani mimochodem */
      return true;
   }
  else
    /* nenormalni tah */
   {
    if (pos->sch[t&127] || pos->sch[t>>7]==1 || pos->sch[t>>7]==-1) return true;
     else return false;
   }
 }
int Remiza50Nebo3(TUloha *uloha)
/************************************************************************
*  Je remíza 50 tahy nebo 3x stejná pozice ?                            *
*  vrací 50, 3 nebo 0 (význam je jasný)                                 *
************************************************************************/
{int i,stejnych;
 TPozice pos;

 stejnych=0;
 pos=uloha->pozice;
 for(i=0;i<100;i++)
  {
   if(!uloha->prt->l) break;
   GlobTahniZpet(uloha);
   if(DulezityTah(&uloha->pozice,uloha->prt->p->data.t)){i++;break;}
   if(stejne(pos.sch,uloha->pozice.sch)&& (i&1))
     if(++stejnych==2){ i++;break;}
   if (i==99) stejnych=49;
  }
 for(;i>0;i--) GlobTahni(false,uloha,false);
 if (stejnych<2)stejnych=0;else stejnych++;
 return stejnych;
}


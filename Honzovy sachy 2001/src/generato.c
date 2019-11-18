/*********************************************************/
/* generato.c - generator tahu                           */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include <stdlib.h>
#include <string.h>
#include "volby.h"
#include "cotyvar.h"
#include "lokruti.h"
#include "ohodnoc.h"
#include "chyba.h"
#include "globruti.h"
#include "generato.h"

#define CENA(t) ((t).cena+u->HistHeur[(t).data])
/* Tridim podle ceny+hist. heur.*/

void TahQuickSort(TUloha *u,TTah1 *p1,TTah1 *p2)
/*************************************************/
/* Rekurzivni trideni tahu podle nadejnosti      */
/* knihovni qsort je moc obecny a tedy i pomaly  */
/*************************************************/
{TTah1 t1,*a,*b;
 s16 pivo;
 	
	if(p2-p1==1){ /*jsou-li jen 2*/
		if(p1->cena<p2->cena){t1=*p1;*p1=*p2;*p2=t1;}
		return;
	}
	if(p2-p1<10){ /*je-li jich malo, je rychlejsi
	kvadraticky minimax*/
		for(;p1<p2;p1++){
			b=p1;
			for(a=p1+1;a<=p2;a++)
				if(a->cena>b->cena){t1=*a;*a=*b;*b=t1;}
		}
		return;
	}
	pivo=(p1+((p2-p1)>>1))->cena;
	a=p1;b=p2;
	do{
	 while(a->cena>pivo)a++;
	 while(b->cena<pivo)b--;
	 if(a<=b){
		 {t1=*a;*a=*b;*b=t1;}
		 a++;
		 b--;
	 }
	}
	while(a<=b);
	if(a<p2)TahQuickSort(u,a,p2); /*rekurze*/
	if(b>p1)TahQuickSort(u,p1,b);
}
void SetridTahy(TUloha *uloha){
/**********************************/
/* Jen zavola quicksort           */
/**********************************/
TahQuickSort(uloha,uloha->zasobnik.tahy+uloha->zasobnik.hranice[uloha->zasobnik.pos],
		uloha->zasobnik.tahy+uloha->zasobnik.hranice[uloha->zasobnik.pos+1]-1);
}

const int StdCenyPromen[4]={110,115,225,375};
/* Zmena materialu po promene pesce v kone..damu*/
const s16 StdCenyFigur[7]={0,50,160,165,275,425,20000};
/* Pozor - kral nesmi byt 30000 - hrozilo by preteceni s16 */
const s8 ofsety[16]=
{  1,  -1,  10,  -10, /* Vez*/
  11, -11,   9,  -9,  /* Strelec*/
  21,  19,  12,   8, -21, -19, -12, - 8 /* Kun*/
};
/* Jak chodi figury (na 10x12) - hlavne pro generator */
const s8 ofsetyX[16]=
{  1,  -1,   0,   0, /* Vez*/
   1,  -1,  -1,   1,  /* Strelec*/
   1,  -1,   2,  -2, -1,  1, -2, 2 /* Kun*/
};
/* X slozka posunuti */
const s8 ofsetyY[16]=
{  0,  0,  1,  -1, /* Vez*/
   1, -1,  1,  -1,  /* Strelec*/
   2,  2,  1,   1, -2, -2, -1, -1 /* Kun*/
};
/* Y slozka posunuti */

/***********************************************************/
/* Makra pro pridavani nalezenych tahu v generatoru        */
/* na zasobik                                              */
/***********************************************************/
#define ZaradTah(pzas,p1,p2) \
 {\
 (pzas)->cena=0;\
 (pzas)->data=(u16)(((p1)<<7) | (p2));\
 (pzas)++;\
 }
/* ZaradTah
 Zaradi tah na zasobnik
 Tah nesmi byt
 1) promena pesce
 2) brani (tah by byl spravny, ale byla by spatne cena)
 3) brani mimochodem
 4) rosada*/


/*Obe nasledujici makra na bezne brani (ne brani mimochodem a brani
  promenou pesce) mohou byt pouzity i na tah, ktery vubec branim neni.*/

#define ZaradBileBrani(pzas,p1, p2, p)\
 {\
  (pzas)->cena=(s16)(StdCenyFigur[-*(p)]);\
  (pzas)->data=(u16) (( (p1)<<7 ) | (p2) );\
  (pzas)++;\
 }
/* Bezne brani (ne mimochodem) - bily bere cernou figuru*/
#define ZaradCerneBrani(pzas,p1, p2, p)\
 {\
  (pzas)->cena=(s16)(StdCenyFigur[*(p)]);\
  (pzas)->data=(u16)(((p1)<<7) | (p2));\
  (pzas)++;\
 }
/* Bezna brani (ne mimochodem) - cerny bere bilou figuru*/
#define ZaradMimochodem(pzas,p1, p2)\
 {\
  (pzas)->cena=(s16)(StdCenyFigur[1]);\
  (pzas)->data=(u16)((1<<15)|((p1)<<7) | (p2));\
  (pzas)++;\
 }
/*brani mimochodem (pro obe barvy) */

#define ZaradBilouPromenu(pzas,p1, p2, fig, k)\
 {\
  (pzas)->cena=(s16)(StdCenyPromen[fig]\
   +StdCenyFigur[-(k)]);\
  (pzas)->data=(u16)((3<<14)|(fig<<10)|((p1-a7)<<7)|((p2-a8)<<4));\
  (pzas)++;\
 }
 /* Zaradi promenu bileho pesce
p1 - odkud
p2 - kam
fig - v co se meni
     pozor, nestandardni kodovani
      0 - kun
      1 - strelec
      2 - vez
      3 - dama
k - absolutni hodnota kodu sebrane figury (neni-li tah zaroven brani, tak 0)
      */

#define ZaradCernouPromenu(pzas,p1, p2, fig, k)\
 {\
  (pzas)->cena=(s16)(StdCenyPromen[fig]\
   +StdCenyFigur[k]);\
  (pzas)->data=(u16)((13<<12)|(fig<<10)|((p1-a2)<<7)|((p2-a1)<<4));\
  (pzas)++;\
 }
 /* Zaradi promenu cerneho pesce
p1 - odkud
p2 - kam
fig - v co se meni
     pozor, nestandardni kodovani
      0 - kun
      1 - strelec
      2 - vez
      3 - dama
k - kod sebrane figury (neni-li tah zaroven brani, tak 0)
      */
#define DlouhaBilaFigura(pzas,o1,o2,q,k)\
{\
 for(j=(o1);j<=(o2);j++)\
  {\
   for((q)=p+ofsety[j],(k)=i+ofsety[j];*(q)<=0;(q)+=ofsety[j],k+=ofsety[j])\
    { if(*q<0) {ZaradBileBrani((pzas),i,k,q) break;}\
      ZaradTah(pzas,i,k);\
    }\
  }\
}
/*Strelec, dama, vez
  pzas - zasobnik
  o1, o2 - od jakeho ofsetu do jakeho
  q - pointer na pole, kam se hraje
  k pomocna promenna */
#define DlSDlouhaBilaFigura(pzas,o1,o2,q,k)\
{\
 for(j=(o1);j<=(o2);j++)\
  {\
   xo=ofsetyX[j];yo=ofsetyY[j];\
   for((q)=p+ofsety[j],(k)=i+ofsety[j];*(q)<=0;(q)+=ofsety[j],k+=ofsety[j],xo+=ofsetyX[j],yo+=ofsetyY[j])\
    { if(*q<0) {if(q==a)ZaradBileBrani((pzas),i,k,q) break;}\
      if(MEZI(xo,yo))ZaradTah(pzas,i,k);\
    }\
  }\
}
/* Obdoba pri kryti dlouheho sachu*/
#define DlouhaCernaFigura(pzas,o1,o2,q,k)\
{\
 for(j=o1;j<=o2;j++)\
  {\
   for((q)=p+ofsety[j],(k)=i+ofsety[j];*(q)>=0 && *(q)<7;(q)+=ofsety[j],k+=ofsety[j])\
    {if(*(q)>0) {ZaradCerneBrani(pzas,i,k,q) break;}\
    ZaradTah(pzas,i,k);\
    }\
  }\
}
/*Strelec, dama, vez
  pzas - zasobnik
  o1, o2 - od jakeho ofsetu do jakeho
  q - pointer na pole, kam se hraje
  k pomocna promenna */
#define DlSDlouhaCernaFigura(pzas,o1,o2,q,k)\
{\
 for(j=(o1);j<=(o2);j++)\
  {\
   xo=ofsetyX[j];yo=ofsetyY[j];\
   for((q)=p+ofsety[j],(k)=i+ofsety[j];\
   *(q)>=0 && *(q)<7;(q)+=ofsety[j],k+=ofsety[j],xo+=ofsetyX[j],yo+=ofsetyY[j])\
    { if(*q>0) {if(q==a)ZaradCerneBrani((pzas),i,k,q) break;}\
      if(MEZI(xo,yo))ZaradTah(pzas,i,k);\
    }\
  }\
}
/* Obdoba pri kryti dlouheho sachu*/
#define ZaradRosadu(pzas,jakou)\
{\
  (pzas)->data=(u16)jakou;\
  (pzas)->cena=0;\
  (pzas)++;\
}
/* Zaradi rosadu */
#define DlouhaBilaFiguraBrani(pzas,o1,o2)\
{\
 for(j=o1;j<=o2;j++)\
   for(q=p+ofsety[j],k=i+ofsety[j];*q<=0;q+=ofsety[j],k+=ofsety[j])\
     if(*q<0) {ZaradBileBrani(pzas,i,k,q) break;}\
 }
/* neco jako DlouhaBilaFigura pro NalezBrani*/
#define DlouhaCernaFiguraBrani(pzas,o1,o2)\
{\
 for(j=o1;j<=o2;j++)\
   for(q=p+ofsety[j],k=i+ofsety[j];*q>=0 && *q<7;q+=ofsety[j],k+=ofsety[j])\
    if(*q>0) {ZaradCerneBrani(pzas,i,k,q) break;}\
}
/* neco jako DlouhaCernaFigura pro NalezBrani*/
void NalezTahy(TUloha *u)
/*************************************************************/
/* NalezTahy												 */
/* Generuje vsechny pseudolegalni tahy (jako kdyby kral mohl */
/* jit do sachu)                                             */
/* Ceny nastavi podle zmeny materialu, tahy netridi          */
/*************************************************************/
{int j,k,i; /*promenne pro for cykly*/
 s8 *p; /* hlavni pointer na pole v pozici*/
 s8 *q; /* pomocny pointer na pole v pozici*/
 TTah1 *pzas; /* pointer do zasobniku tahu*/

 pzas=u->zasobnik.tahy+ /* najedu ukazatelem na pocatek tahu nove urovne
  v zasobniku*/
   u->zasobnik.hranice[u->zasobnik.pos];
 if (u->pozice.bily)
  {
  for (i=a1,p=&(u->pozice.sch[a1]); i<=h8; i++,p++)
   {if (*p<1 || *p>6) continue;
    switch (*p){
     case 1 : /*pesec*/
      if (i<a7) /*tedy nehrozi promena*/
       { if (*(p+11)<0) 
	    ZaradBileBrani(pzas,i,i+11,(p+11))
	 if (*(p+9)<0) ZaradBileBrani(pzas,i,i+9,(p+9))
	 if (!*(p+10)) /* policko pred pescem je volne*/
	 { 
		 ZaradTah(pzas,i,i+10) 
			 if (i<=h2 && !*(p+20)) ZaradTah(pzas,i,i+20)} /* pescem o 2*/
	 if (u->pozice.mimoch==i+1) ZaradMimochodem(pzas,i,i+11) else
	  if (u->pozice.mimoch==i-1) ZaradMimochodem(pzas,i,i+9)
       }
     else /* i>=a7 => promeny pesce*/
      {if (!*(p+10)) for(j=3;j>=0;j--) ZaradBilouPromenu(pzas,i,i+10,j,0)
       if (*(p+11)<0) for(j=3;j>=0;j--) ZaradBilouPromenu(pzas,i,i+11,j,*(p+11))
       if (*(p+9)<0) for(j=3;j>=0;j--) ZaradBilouPromenu(pzas,i,i+9,j,*(p+9))
      }
   break;
  case 2: /* kun*/
   for (j=8;j<=15;j++) if ((*(p+ofsety[j]))<=0) ZaradBileBrani(pzas,i,i+ofsety[j],(p+ofsety[j]));
   break;
  case 3: /* strelec*/
   DlouhaBilaFigura(pzas,4,7,q,k)
  break;
  case 4: /* vez*/
   DlouhaBilaFigura(pzas,0,3,q,k)
  break;
  case 5: /* dama*/
   DlouhaBilaFigura(pzas,0,7,q,k)
  break;
  case 6: /* kral*/
   for (j=0;j<=7;j++) if ((*(p+ofsety[j]))<=0) ZaradBileBrani(pzas,i,i+ofsety[j],(p+ofsety[j]));
   if((u->pozice.roch&1)&&(!*(p+1))&&(!*(p+2))
	   && !Ohrozeno(p+1,false) && !Ohrozeno(p,false))  {
	    ZaradRosadu(pzas,MBRoch)
   }
   if((u->pozice.roch&2)&&(!*(p-1))&&(!*(p-2))&&(!*(p-3))
	   && !Ohrozeno(p-1,false) && !Ohrozeno(p,false)){
	   ZaradRosadu(pzas,VBRoch)
   }
   break; /* od krale */
  }/* od switch*/
 } /* od for cyklu*/
 } /* od hraje bily*/
 else
  {
  for (i=a1,p=&(u->pozice.sch[a1]); i<=h8; i++,p++)
   {if (*p>=0) continue;
    switch (*p){
     case -1 : /*pesec*/
      if (i>h2) /*tedy nehrozi promena*/
       { if (*(p-11)>0 && *(p-11)<7) ZaradCerneBrani(pzas,i,i-11,(p-11))
	 if (*(p-9)>0 && *(p-9)<7) ZaradCerneBrani(pzas,i,i-9,(p-9))
	 if (!*(p-10)) /* policko pred pescem je volne*/
	 { ZaradTah(pzas,i,i-10) if (i>=a7 && !*(p-20)) ZaradTah(pzas,i,i-20)} /* pescem o 2*/
	 if (u->pozice.mimoch==i+1) ZaradMimochodem(pzas,i,i-9) else
	  if (u->pozice.mimoch==i-1) ZaradMimochodem(pzas,i,i-11)
	  }
     else /* i<=h2 => promeny pesce*/
      {if (!*(p-10)) for(j=3;j>=0;j--) ZaradCernouPromenu(pzas,i,i-10,j,0)
       if (*(p-11)>0 && *(p-11)<7) for(j=3;j>=0;j--) ZaradCernouPromenu(pzas,i,i-11,j,*(p-11))
       if (*(p-9)>0  && *(p-9)<7) for(j=3;j>=0;j--) ZaradCernouPromenu(pzas,i,i-9,j,*(p-9))
      }
   break;
  case -2: /* kun*/
   for (j=8;j<=15;j++) if ((*(p+ofsety[j]))>=0 && (*(p+ofsety[j])<7))
    ZaradCerneBrani(pzas,i,i+ofsety[j],(p+ofsety[j]));
   break;
  case -3: /* strelec*/
   DlouhaCernaFigura(pzas,4,7,q,k)
  break;
  case -4: /* vez*/
   DlouhaCernaFigura(pzas,0,3,q,k)
  break;
  case -5: /* dama*/
   DlouhaCernaFigura(pzas,0,7,q,k)
  break;
  case -6: /* kral*/
   for (j=0;j<=7;j++) if ((*(p+ofsety[j]))>=0 && (*(p+ofsety[j]))<7) 
    ZaradCerneBrani(pzas,i,i+ofsety[j],(p+ofsety[j]))
   if((u->pozice.roch&4)&&(!*(p+1))&&(!*(p+2))
       && !Ohrozeno(p+1,true) && !Ohrozeno(p,true)){
	   ZaradRosadu(pzas,MCRoch)
   }
   if((u->pozice.roch&8)&&(!*(p-1))&&(!*(p-2))&&(!*(p-3))
	   && !Ohrozeno(p-1,true) && !Ohrozeno(p,true)){
	   ZaradRosadu(pzas,VCRoch)
   }
   break;
  }/* od switch*/
 } /* od for cyklu*/
 } /* od hraje bily*/
 u->zasobnik.hranice[u->zasobnik.pos+1]=(s16)(pzas-u->zasobnik.tahy);
}
/******************************************/
/* NalezBrani - jako NalezTahy, ale jen   */
/* brani a promeny pesce v damu           */
/******************************************/
void NalezBrani(TUloha *u)
{int j,k,i;
 s8 *p; /* hlavni pointer na pole v pozici*/
 s8 *q; /* pomocny pointer na pole v pozici*/
 TTah1 *pzas; /* pointer do zasobniku tahu*/

 pzas=u->zasobnik.tahy+ /* najedu ukazatelem na pocatek tahu nove urovne
  v zasobniku*/
   u->zasobnik.hranice[u->zasobnik.pos];
 if (u->pozice.bily)
  {
  for (i=a1,p=&(u->pozice.sch[a1]); i<=h8; i++,p++)
   {if (*p<1 || *p>6) continue;
    switch (*p){
     case 1 : /*pesec*/
      if (i<a7) /*tedy nehrozi promena*/
       { if (*(p+11)<0) ZaradBileBrani(pzas,i,i+11,(p+11))
	 if (*(p+9)<0) ZaradBileBrani(pzas,i,i+9,(p+9))
	 if (u->pozice.mimoch==i+1) ZaradMimochodem(pzas,i,i+11) else
	  if (u->pozice.mimoch==i-1) ZaradMimochodem(pzas,i,i+9)
       }
     else /* i>=a7 => promeny pesce*/
      {if (!*(p+10)) ZaradBilouPromenu(pzas,i,i+10,3,0)
       if (*(p+11)<0) ZaradBilouPromenu(pzas,i,i+11,3,*(p+11))
       if (*(p+9)<0)  ZaradBilouPromenu(pzas,i,i+9,3,*(p+9))
      }
   break;
  case 2: /* kun*/
   for (j=8;j<=15;j++) if ((*(p+ofsety[j]))<0) ZaradBileBrani(pzas,i,i+ofsety[j],(p+ofsety[j]));
   break;
  case 3: /* strelec*/
   DlouhaBilaFiguraBrani(pzas,4,7)
  break;
  case 4: /* vez*/
   DlouhaBilaFiguraBrani(pzas,0,3)
  break;
  case 5: /* dama*/
   DlouhaBilaFiguraBrani(pzas,0,7)
  break;
  case 6: /* kral*/
   for (j=0;j<=7;j++) if ((*(p+ofsety[j]))<0) ZaradBileBrani(pzas,i,i+ofsety[j],(p+ofsety[j]));
   break;
  }/* od switch*/
 } /* od for cyklu*/
 } /* od hraje bily*/
 else
  {
  for (i=a1,p=&(u->pozice.sch[a1]); i<=h8; i++,p++)
   {if (*p>=0) continue;
    switch (*p){
     case -1 : /*pesec*/
      if (i>h2) /*tedy nehrozi promena*/
       { if (*(p-11)>0 && *(p-11)<7) ZaradCerneBrani(pzas,i,i-11,(p-11))
	 if (*(p-9)>0 && *(p-9)<7) ZaradCerneBrani(pzas,i,i-9,(p-9))
	 if (u->pozice.mimoch==i+1) ZaradMimochodem(pzas,i,i-9) else
	 if (u->pozice.mimoch==i-1) ZaradMimochodem(pzas,i,i-11)
      }
     else /* i<=h2 => promeny pesce*/
      {if (!*(p-10)) ZaradCernouPromenu(pzas,i,i-10,3,0)
       if (*(p-11)>0 && *(p-11)<7) ZaradCernouPromenu(pzas,i,i-11,3,*(p-11))
       if (*(p-9)>0  && *(p-9)<7) ZaradCernouPromenu(pzas,i,i-9,3,*(p-9))
      }
   break;
  case -2: /* kun*/
   for (j=8;j<=15;j++) if ((*(p+ofsety[j]))>0 && (*(p+ofsety[j])<7))
    ZaradCerneBrani(pzas,i,i+ofsety[j],(p+ofsety[j]));
   break;
  case -3: /* strelec*/
   DlouhaCernaFiguraBrani(pzas,4,7)
  break;
  case -4: /* vez*/
   DlouhaCernaFiguraBrani(pzas,0,3)
  break;
  case -5: /* dama*/
   DlouhaCernaFiguraBrani(pzas,0,7)
  break;
  case -6: /* kral*/
   for (j=0;j<=7;j++) if ((*(p+ofsety[j]))>0 && (*(p+ofsety[j]))<7) ZaradCerneBrani(pzas,i,i+ofsety[j],(p+ofsety[j]))
  break;
  }/* od switch*/
 } /* od for cyklu*/
 } /* od hraje bily*/

 u->zasobnik.hranice[u->zasobnik.pos+1]=(s16)(pzas-u->zasobnik.tahy);
}

#define TESTUJ(X,Y) {if(*(p+(X))==(Y)){if(poc)return 2;else{*a=p+(X);poc++;}}}
/* Pomocne makro pro KymOhrozeno - test pro 1 typ figury */
#define TESTUJ2(X,Y,Z) {if(*(p+(X))==(Y)||*(p+(X))==(Z)){if(poc)return 2;else{*a=p+(X);poc++;}}}
/* Pomocne makro pro KymOhrozeno - test pro 2 typy figury */
int KymOhrozeno(s8 *p, s8 **a, bool bilym)
/*******************************************************/
/*  KymOhrozeno   Je policko p ohrozene ?              */
/*  Odkud ? - prvního nalezeného ohrozovace vraci v a  */
/*  Kolikrat - navratova hodnota (nejvyse ale 2)       */
/*  bilym - ohrozuje to pole bily                      */
/*******************************************************/
 {int j,k,poc;
 poc=0;
 *a=p;
 if (bilym)
 {
 TESTUJ(-9,1) /*pescem*/
 TESTUJ(-11,1)/*pescem*/
 for(j=8;j<=15;j++)TESTUJ(ofsety[j],2) /*konem*/
 for(j=0;j<=7;j++)TESTUJ(ofsety[j],6) /*kralem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,4,5)if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,3,5)if(*(p+k))break;k+=ofsety[j];}
 }
 } else /*cernym*/
  {
 TESTUJ(9,-1)/*pescem*/
 TESTUJ(11,-1)/*pescem*/
 for(j=8;j<=15;j++)TESTUJ(ofsety[j],-2)/*konem*/
 for(j=0;j<=7;j++)TESTUJ(ofsety[j],-6)/*kralem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,-4,-5)if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,-3,-5)if(*(p+k))break;k+=ofsety[j];}
 }
 }
 return poc;
 }
#undef TESTUJ
#undef TESTUJ2
/* Tato jmena budu jeste pouzivat */

#define TESTUJ(X,Y) {if(*(p+(X))==(Y))poc++;}
/* Pomocne makro pro PocetOhrozeni - test pro 1 typ figury */
#define TESTUJ2(X,Y,Z) {if(*(p+(X))==(Y)||*(p+(X))==(Z))poc++;}
/* Pomocne makro pro PocetOhrozeni - test pro 2 typy figury */
int PocetOhrozeni(s8 *p, bool bilym)
/***************************************/
/* Kolikrat je dane pole ohrozeno ?    */
/***************************************/
 {int j,k,poc;
 poc=0;
 if (bilym)
 {
 TESTUJ(-9,1) /*pescem*/
 TESTUJ(-11,1)/*pescem*/
 for(j=8;j<=15;j++)TESTUJ(ofsety[j],2) /*konem*/
 for(j=0;j<=7;j++)TESTUJ(ofsety[j],6) /*kralem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,4,5)if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,3,5)if(*(p+k))break;k+=ofsety[j];}
 }
 } else /*cernym*/
  {
 TESTUJ(9,-1)/*pescem*/
 TESTUJ(11,-1)/*pescem*/
 for(j=8;j<=15;j++)TESTUJ(ofsety[j],-2)/*konem*/
 for(j=0;j<=7;j++)TESTUJ(ofsety[j],-6)/*kralem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,-4,-5)if(*(p+k))break;k+=ofsety[j];}
 }
  for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){TESTUJ2(k,-3,-5)if(*(p+k))break;k+=ofsety[j];}
 }
 }
 return poc;
 }
void NalezBileVazby(TUloha *u,int pole){
/**********************************************************/
/* Nalezne vsechny kameny bileho, ktere jsou              */
/* ve vazbe vuci poli pole. (Na poli je napr. bily kral)  */
/**********************************************************/
 s8 *p;
 int i,j;
 u8 pl;

 j=0;
 for(i=0;i<8;i++)
  for(p=u->pozice.sch+pole+ofsety[i];;p+=ofsety[i]){
   if(!*p)continue;
   if(*p==100||*p<0)break;
   pl=p-u->pozice.sch;
   /*Nasel jsem figuru, ktera je mozna ve vazbe*/
   for(p+=ofsety[i];;p+=ofsety[i]){
    if(!*p)continue;
	if(*p==-5 || *p==-4 && i<4 || *p==-3 && i>=4)
	 u->Vazby[j++]=pl; 
	break;
   }
   break;
  }
  if(j<8)u->Vazby[j]=0;
}
void NalezCerneVazby(TUloha *u,int pole){
/**********************************************************/
/* Nalezne vsechny kameny cerneho, ktere jsou             */
/* ve vazbe vuci poli pole. (Na poli je napr. cerny kral) */
/**********************************************************/
 s8 *p;
 int i,j;
 u8 pl;
 
 j=0;
 for(i=0;i<8;i++)
  for(p=u->pozice.sch+pole+ofsety[i];;p+=ofsety[i]){
   if(!*p)continue;
   if(*p>0)break;
   pl=p-u->pozice.sch;
   /*Nasel jsem figuru, ktera je mozna ve vazbe*/
   for(p+=ofsety[i];;p+=ofsety[i]){
    if(!*p)continue;
	if(*p<3||*p>5)break;
	if(*p==5 || *p==4 && i<4 || *p==3 && i>=4)
	u->Vazby[j++]=pl;
	break;
   }
   break;
  }
  if(j<8)u->Vazby[j]=0;
}

#define PREVOD(x,y,z){z=x;x=z+y;y=z-y;}
/* Linearni transformace - prevod diagonaly na sloupec/radek */
bool Mezi(int x1,int y1,int x2,int y2,int x3,int y3){
/*******************************************************************/
/* necht A=[x1,y1],B=[x3,y3] jsou na jedne diagonale/sloupci/radce */
/* je [x2,y2] mezi nimi ? Na polozavrenem useku <A,B) ?            */
/*******************************************************************/
 int pom;
 if(x1!=x3 && y1!=y3){
 /*Diagonalu prevedu na sloupec nebo radku
 - to je pekna (rekl bych akademicka) myslenka*/
 PREVOD(x1,y1,pom)
 PREVOD(x2,y2,pom)
 PREVOD(x3,y3,pom)
 }
 if(x1==x3){ /*stejny sloupec*/
  if(x2==x3){
   if(y1<y3)return y1<=y2 && y2<y3;
   else return y3<y2 && y2<=y1;
  }
  else return false;
 }
 else 
{/*stejna radka*/
 if(y2==y3){
   if(x1<x3)return x1<=x2 && x2<x3;
   else return x3<x2 && x2<=x1;
  }
  else return false;
 }
}
bool VeVazbe(TUloha *u,int pole){
/*****************************************/
/* Je pole (figura na nem) vazane        */
/* Vyzaduje u->Vazby                     */
/*****************************************/
 int i;
 for(i=0;i<8;i++)
  if(!u->Vazby[i])break;
  else if(u->Vazby[i]==pole)return true;
 return false;
}

#define ZKUS(o,f){if(*(a+(o))==f&&!VeVazbe(u,pa+(o)))\
ZaradBileBrani(*pzas,pa+(o),pa,a)}

#define ZKUSPROMENY(o) {if(*(a+(o))==1&&!VeVazbe(u,pa+(o)))\
{int ugh; for(ugh=0;ugh<4;ugh++)ZaradBilouPromenu(*pzas,pa+(o),pa,ugh,*a);}}

/*Pomocne makro pro BileBraniNaPole*/
void BileBraniNaPole(TUloha *u,TTah1 **pzas,s8 *a){
/*****************************************************************/
/* Necht na poli a je SACHUJICI kamen cerneho a necht            */
/* se jedna o sach jednonasobny. Potom funkce najde              */
/* vsechny pripustne (nikoli pseudo-) tahy ktere tento           */
/* kamen odstrani (i brani mimochodem) krome jednoho tahu:       */
/* sebrani kamena na poli a napadenym kralem.                    */
/* Rutina ma jedinou (polo)chybu. Neuvazuje, ze pesec sebrany    */
/* mimochodem mohl byt vazan. To ale nevadi nebot tuto           */
/* proceduru pouzivam jen pro brani sachujici figury a           */
/* v partii nemuze davat sach pesec sebratelny mimochodem,       */
/* ktery je zaroven vazany, nebot jinak by pred tahem            */
/* pesce o 2 byl nehrajici v sachu.                              */
/*****************************************************************/
int pa,j,k;

 NalezBileVazby(u,u->material.bk);
 pa=a-u->pozice.sch;
 if(u->pozice.mimoch==pa){
  if(u->pozice.sch[pa-1]==1)if(!VeVazbe(u,pa-1))ZaradMimochodem(*pzas,pa-1, pa+10)
  if(u->pozice.sch[pa+1]==1)if(!VeVazbe(u,pa+1))ZaradMimochodem(*pzas,pa+1, pa+10)
 }
 
 if(pa>=a8) {ZKUSPROMENY(-11);ZKUSPROMENY(-9);} else
  {ZKUS(-9,1);ZKUS(-11,1)}/*pescem*/
 for(j=8;j<=15;j++)ZKUS(ofsety[j],2)/*konem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){ZKUS(k,4)ZKUS(k,5)if(*(a+k))break;k+=ofsety[j];}
 }
for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){ZKUS(k,3)ZKUS(k,5)if(*(a+k))break;k+=ofsety[j];}
 }
}
#undef ZKUS
#undef ZKUSPROMENY

#define ZKUS(o,f) {if(*(a+(o))==f&&!VeVazbe(u,pa+(o)))\
ZaradCerneBrani(*pzas,pa+(o),pa,a)}
/*Pomocne makro pro CerneBraniNaPole*/
#define ZKUSPROMENY(o) {if(*(a+(o))==-1&&!VeVazbe(u,pa+(o)))\
{int ugh; for(ugh=0;ugh<4;ugh++)ZaradCernouPromenu(*pzas,pa+(o),pa,ugh,*a);}}

void CerneBraniNaPole(TUloha *u,TTah1 **pzas,s8 *a){
/******************************/
/* Obdoba BileBraniNaPole     */
/******************************/
int pa,j,k;
 
 NalezCerneVazby(u,u->material.ck);
 pa=a-u->pozice.sch;
 if(u->pozice.mimoch==pa){
  if(u->pozice.sch[pa-1]==-1)if(!VeVazbe(u,pa-1))ZaradMimochodem(*pzas,pa-1, pa-10)
  if(u->pozice.sch[pa+1]==-1)if(!VeVazbe(u,pa+1))ZaradMimochodem(*pzas,pa+1, pa-10)
 }
 if(pa<=h1) {ZKUSPROMENY(11);ZKUSPROMENY(9);} else
  {ZKUS(9,-1);ZKUS(11,-1)}/*pescem*/
 for(j=8;j<=15;j++)ZKUS(ofsety[j],-2)/*konem*/
 for(j=0;j<=3;j++) /*vezi nebo damou po rade/sloupci*/
 {k=ofsety[j];
 while(1){ZKUS(k,-5)ZKUS(k,-4)if(*(a+k))break;k+=ofsety[j];}
 }
for(j=4;j<=7;j++) /*strelcem nebo damou po diagonale*/
 {k=ofsety[j];
 while(1){ZKUS(k,-5)ZKUS(k,-3)if(*(a+k))break;k+=ofsety[j];}
 }
}
#undef ZKUS
#undef ZKUSPROMENY

#define MEZI(dx,dy) Mezi(axy.rem,axy.quot,fxy.rem+(dx),fxy.quot+(dy),kxy.rem,kxy.quot)

void BilyKryjeDlouhySach(TUloha *u,TTah1 **pzas,s8 *a){
/*********************************************************/
/* Funkce nalezne tahy, kterymi bily pokryje nekontektni */
/* sach  (krome tahu kralem)                             */
/*********************************************************/
 int ia,i,j,k,xo,yo;
 div_t axy,kxy,fxy;
 s8 *p,*q;

 NalezBileVazby(u,u->material.bk);
 ia=a-u->pozice.sch;
 axy=div(ia-a1,10);
 kxy=div(u->material.bk-a1,10);
 for (i=a1,p=&(u->pozice.sch[a1]); i<=h8; i++,p++)
   {if (*p<1 || *p>5 || VeVazbe(u,i)) continue;
    fxy=div(i-a1,10);
    switch (*p){
     case 1 : /*pesec*/
      if (i<a7) /*tedy nehrozi promena*/
       {
	 if (!*(p+10)) /* policko pred pescem je volne*/
	 { 
		if(MEZI(0,1)) ZaradTah(*pzas,i,i+10)
		else
		if (i<=h2 && !*(p+20) && MEZI(0,2)) ZaradTah(*pzas,i,i+20)
	 } /* pescem o 2*/
        if((p+11)==a)ZaradBileBrani(*pzas,i,i+11,a);
		if((p+9)==a)ZaradBileBrani(*pzas,i,i+9,a);
     }
     else /* i>=a7 => promeny pesce*/
      {if (!*(p+10)&&MEZI(0,1)) for(j=3;j>=0;j--) ZaradBilouPromenu(*pzas,i,i+10,j,0)
       if (*(p+11)<0 && p+11==a) for(j=3;j>=0;j--) ZaradBilouPromenu(*pzas,i,i+11,j,*(p+11))
       if (*(p+9)<0 && p+9==a) for(j=3;j>=0;j--) ZaradBilouPromenu(*pzas,i,i+9,j,*(p+9))
      }
   break;
  case 2: /* kun*/
   for (j=8;j<=15;j++) if ((*(p+ofsety[j]))<=0&&MEZI(ofsetyX[j],ofsetyY[j])) ZaradBileBrani(*pzas,i,i+ofsety[j],(p+ofsety[j]));
   break;
  case 3: /* strelec*/
   DlSDlouhaBilaFigura(*pzas,4,7,q,k)
  break;
  case 4: /* vez*/
   DlSDlouhaBilaFigura(*pzas,0,3,q,k)
  break;
  case 5: /* dama*/
   DlSDlouhaBilaFigura(*pzas,0,7,q,k)
  break;
  }/* od switch*/
 } /* od for cyklu*/
}

void CernyKryjeDlouhySach(TUloha *u,TTah1 **pzas,s8 *a){
/*********************************/
/* analogie BilyKryjeDlouhySach  */
/*********************************/
 int ia,i,j,k,xo,yo;
 div_t axy,kxy,fxy;
 s8 *p,*q;

 NalezCerneVazby(u,u->material.ck);
 ia=a-u->pozice.sch;
 axy=div(ia-a1,10);
 kxy=div(u->material.ck-a1,10);
 for (i=a1,p=u->pozice.sch+a1; i<=h8; i++,p++)
   {if (*p>-1 || VeVazbe(u,i)) continue;
    fxy=div(i-a1,10);
    switch (*p){
     case -1 : /*pesec*/
      if (i>h2) /*tedy nehrozi promena*/
       {
	 if (!*(p-10)) /* policko pred pescem je volne*/
	 { 
		if(MEZI(0,-1)) ZaradTah(*pzas,i,i-10)
		else
		if (i>=a7 && !*(p-20) && MEZI(0,-2)) ZaradTah(*pzas,i,i-20)
	} /* pescem o 2*/
        if((p-11)==a)ZaradCerneBrani(*pzas,i,i-11,a);
		if((p-9)==a)ZaradCerneBrani(*pzas,i,i-9,a);
     }
     else /* i<=h2 => promeny pesce*/
      {if (!*(p-10)&&MEZI(0,-1)) for(j=3;j>=0;j--) ZaradCernouPromenu(*pzas,i,i-10,j,0)
       if (*(p-11)>0 && *(p-9)<7 && p-11==a) for(j=3;j>=0;j--) ZaradCernouPromenu(*pzas,i,i-11,j,*(p-11))
       if (*(p-9)>0 && *(p-9)<7 && p-9==a) for(j=3;j>=0;j--) ZaradCernouPromenu(*pzas,i,i-9,j,*(p-9))
      }
   break;
  case -2: /* kun*/
   for (j=8;j<=15;j++) 
    if ((*(p+ofsety[j]))>=0&&(*(p+ofsety[j]))<=6 
	     &&MEZI(ofsetyX[j],ofsetyY[j])) 
	 ZaradCerneBrani(*pzas,i,i+ofsety[j],(p+ofsety[j]));
   break;
  case -3: /* strelec*/
   DlSDlouhaCernaFigura(*pzas,4,7,q,k)
  break;
  case -4: /* vez*/
   DlSDlouhaCernaFigura(*pzas,0,3,q,k)
  break;
  case -5: /* dama*/
   DlSDlouhaCernaFigura(*pzas,0,7,q,k)
  break;
  }/* od switch*/
 } /* od for cyklu*/
}

void NalezTahyZeSachu(TUloha *u){
/**********************************************************/
/* Nalezne vsechny legalni (nikoliv pseudolegalni) tahy.  */
/* Predpoklada se, ze hrac na tahu je v sachu a spravne   */
/* nastavene u->material                                  */
/**********************************************************/
 s8 *a;
 int i, bily,odkud,kam;
 TTah1 *pzas; /* pointer do zasobniku tahu*/

 /*NalezTahy(u);
 JenPripustne(u);
 return;*/
 
 pzas=u->zasobnik.tahy+
 /* najedu ukazatelem na pocatek tahu nove urovne
  v zasobniku*/
  u->zasobnik.hranice[u->zasobnik.pos];
 bily=u->pozice.bily;

 /*Nejprve vyzkousime tahy kralem, to má smysl i pri dvojsachu*/
 
 if(bily){
  a=u->pozice.sch+u->material.bk;
  *a=(s8)0;  
  for(i=0;i<8;i++)
   if ((*(a+ofsety[i]))<=0 && !Ohrozeno((a+ofsety[i]),false)){
   odkud=a-u->pozice.sch;
   kam=odkud+ofsety[i];
   ZaradBileBrani(pzas,odkud,kam,(a+ofsety[i]))
  }
  *a=(s8)6;
 }
 else /*cerny*/{
  a=u->pozice.sch+u->material.ck;
  *a=(s8)0;
  for(i=0;i<8;i++)
   if ((*(a+ofsety[i]))>=0 && (*(a+ofsety[i]))<=6 && !Ohrozeno((a+ofsety[i]),true)){
   odkud=a-u->pozice.sch;
   kam=odkud+ofsety[i];
   ZaradCerneBrani(pzas,odkud,kam,(a+ofsety[i]))
  }
  *a=(s8)-6;
  }
 i=KymOhrozeno(u->pozice.sch+(bily ? u->material.bk : u->material.ck), &a, !bily);
 if(i==1){
 
 /*Pokud neni dvojsach, ma smysl zkouset i predstaveni
 nebo sebrani sachujici figury, nejen tahy napadenym kralem.
 Sebrani sachujici figury, ktere je zaroven tahem kralem
 (napr. De7+ Kxe7) jiz bylo nalezeno pri tazich kralem.*/
 if(bily){
  if(*a==-2|| 
  (
  (i=abs((a-u->pozice.sch)-u->material.bk)),
  (i==1||i==10||i==11||i==9)
  )
  )
   /*kontaktni sach nebo sach jezdcem => urcite nejde predstavit*/
   BileBraniNaPole(u,&pzas,a);
  else
  /*Jednonasobny sach po sloupci, radce nebo diagonale
  kdy navic sachujici figura neni tesne u krale.*/
   BilyKryjeDlouhySach(u,&pzas,a);
 }
 else
 {if(*a==2|| 
  (
  (i=abs((a-u->pozice.sch)-u->material.ck)),
  (i==1||i==10||i==11||i==9)
  )
  )
  
   /*kontaktni sach nebo sach jezdcem => urcite nejde predstavit*/
   CerneBraniNaPole(u,&pzas,a);
   else
   CernyKryjeDlouhySach(u,&pzas,a);
 } /*od cerny*/
 }
 u->zasobnik.hranice[u->zasobnik.pos+1]=(s16)(pzas-u->zasobnik.tahy);
}

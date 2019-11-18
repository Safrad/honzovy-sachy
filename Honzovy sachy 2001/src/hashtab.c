/**********************************************************/
/* hashtab.c - hash funkce pro tabulku ohodnocenych pozic */
/* 31.12. 2000 Jan Nemec                                  */
/**********************************************************/
#include "volby.h"
#include <time.h>
#include <stdlib.h>
#include "cotyvar.h"
#include "chyba.h"
#include "hashtab.h"

THashNahoda hnF, hnG;
/* Dve sady nahodnych cisel pro dve funkce */
u32 MojeRand(void){
/*************************************************************/
/* rand() nepokryva cele u32, vraci totiz int. MojeRand ano. */
/*************************************************************/
	return ((rand()&255)<<24)|((rand()&255)<<16)|((rand()&255)<<8)|(rand()&255);
}
void HashInit(void){
/*********************************************************/
/* HashInit naplni koeficienty obou hashovacich funkci   */
/* pseudonahodnymi cisly                                 */
/* Vola se JEDNOU na zacatku celeho PROGRAMU             */
/*********************************************************/
int i,k;

 for(i=0;i<=12;i++)
  for(k=a1;k<=h8;k++)
  {hnF.f[i][k]=MojeRand();
   hnG.f[i][k]=MojeRand();
  }
  for(i=0;i<=h5;i++){
	  hnF.mimoch[i]=MojeRand();
	  hnG.mimoch[i]=MojeRand();}
hnF.bily=MojeRand();
hnG.bily=MojeRand();
for(i=0;i<=15;i++){
	hnF.roch[i]=MojeRand();
	hnG.roch[i]=MojeRand();
}
}


u32 hash(TPozice *pos, THashNahoda *hn){
/**********************************************************/
/* Vypocet hash funkce dane nahodnymi cisly hn postupnym  */
/* xorovanim faktoru									  */
/**********************************************************/

	int i,j;
	u32 navrat;

	navrat=0;
	for(i=0;i<=7;i++)
		for(j=0;j<=7;j++)
			navrat^=hn->f[pos->sch[a1+j+i*10]+6][a1+j+i*10];
	navrat^=hn->mimoch[pos->mimoch];
	navrat^=hn->roch[pos->roch];
	if(pos->bily)navrat^=hn->bily;
	return navrat;
}
u32 HashF(TPozice *pos){
	return hash(pos,&hnF);
}
u32 HashG(TPozice *pos){
	return hash(pos,&hnG);
}
/**********************************************************************/
/* HashF a HashG												      */
/* Hashovaci funkce, vrati hash kod pozice. Nevola se v rekursivnim   */
/* propoctu, ale jen jednou na zacatku propoctu. V rekursi se pocita  */
/* "inkementalne" postupnym xorovanim tahu.                           */
/* F urcuje pozici v tabulce, G cislo pro kontrolu                    */
/**********************************************************************/

u32 hashPech(TPozice *pos, THashNahoda *hn){
/**********************************************************/
/* Vypocet pescove hash funkce dane nahodnymi cisly hn    */
/* postupnym xorovanim faktoru  						  */
/**********************************************************/
	int i;
	u32 navrat;

	navrat=0;
	for(i=a2;i<=h7;i++)
		if(pos->sch[i]==-1)navrat^=hn->f[5][i];else
		if(pos->sch[i]==1)navrat^=hn->f[7][i];
	return navrat;
}
u32 HashPechF(TPozice *pos){
	return hashPech(pos,&hnF);
}
u32 HashPechG(TPozice *pos){
	return hashPech(pos,&hnG);
}
/**********************************************************************/
/* HashPechF a HashPechG										      */
/* Hashovaci funkce, vrati hash kod pescove struktury. Nevola se      */
/* v rekursivnim propoctu, ale jen jednou na zacatku propoctu.        */
/* V rekursi se pocita "inkementalne" postupnym xorovanim tahu.       */
/* F urcuje pozici v tabulce, G cislo pro kontrolu                    */
/**********************************************************************/
bool GetHash(TUloha *uloha, s16 alfa, s16 beta, u8 hloubka, s16 *cena)
/**************************************************/
/* Je pozice v tabulce ? A jak je ohodnocena ?    */
/**************************************************/
{THashPrvek *p;
 int zanor;

	if(!uloha->AlgCfg.AlgKoef.PovolHash) return false;
	zanor=uloha->zasobnik.pos;
    p=uloha->ht+(uloha->zasobnik.hF[zanor]&((1<<uloha->HashCfg.DveNaXHash)-1));
	if(p->kod!=uloha->zasobnik.hG[zanor]||
		p->hloubka<hloubka ||
		!(p->priznak&2) && p->cena<beta ||
		!(p->priznak&1) && p->cena>alfa)
	return false;
	*cena=p->cena;
	return true;
}
void SetHash(TUloha *uloha, u8 hloubka, u8 priznak, s16 cena){
/*******************************/
/* Ulozi pozici do tabulky     */
/*******************************/
 THashPrvek *p;
 int zanor;

 if(!uloha->AlgCfg.AlgKoef.PovolHash) return;
 hassert(cena<mat+1 && cena>-mat-1,"Cena v hash tabulce");
 zanor=uloha->zasobnik.pos;
 p=uloha->ht+(uloha->zasobnik.hF[zanor]&((1<<uloha->HashCfg.DveNaXHash)-1));
 /*if(hloubka<p->hloubka) return;*/
 /* to abych si neprepsal hloubeji propoctenou pozici 
  Nicmene ted si to klidne prepisu*/
 p->priznak=priznak;
 p->cena=cena;
 p->hloubka=hloubka;
 p->kod=uloha->zasobnik.hG[zanor];
}
bool GetPechHash(TUloha *uloha, THashPech **hp){
/********************************************************/
/* Je struktura pescu v tabulce ? A jak je ohodnocena ? */
/********************************************************/

	THashPech *p;
	int zanor;
	
	if(!uloha->AlgCfg.AlgKoef.PovolPechHash) return false;
	zanor=uloha->zasobnik.pos;
	p=uloha->hpt+(uloha->zasobnik.hPechF[zanor]&
		((1<<uloha->HashCfg.DveNaXHashPech)-1));
	if(p->kod==uloha->zasobnik.hPechG[zanor]){
	 *hp=p;
	 return true;}
	return false;
}
void SetPechHash(TUloha *uloha, THashPech *hp){
/****************************************/
/* Ulozi strukturu pescu do tabulky     */
/****************************************/
	THashPech *p;
	int zanor;

	if(!uloha->AlgCfg.AlgKoef.PovolPechHash) return;
	zanor=uloha->zasobnik.pos;
	p=uloha->hpt+(uloha->zasobnik.hPechF[zanor]&
		((1<<uloha->HashCfg.DveNaXHashPech)-1));
	*p=*hp;
	p->kod=uloha->zasobnik.hPechG[zanor];
}
void MazejHash(TUloha *u){
/***************************/
/* Vyprazdni Hash tabulku  */
/***************************/
	int i;
	for(i=0;i<(1<<u->HashCfg.DveNaXHash);i++)
		u->ht[i].hloubka=0;
}


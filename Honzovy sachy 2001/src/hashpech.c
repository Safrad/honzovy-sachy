#include <string.h>
#include <math.h>
#include "volby.h"
#include "cotyvar.h"
#include "hashpech.h"
#include "ohodnoc.h"

void NastavPesce(TUloha *u, THashPech *ph){
int i,j;
int bp,cp;

memset(ph,0,sizeof(THashPech));
ph->kod=u->zasobnik.hPechG[u->zasobnik.pos];
for(i=0;i<=7;i++) {
  if(u->material.BPSloupec[i]>1)ph->cena+=((u->material.BPSloupec[i]-1)*u->AlgCfg.AlgKoef.DvojPesec);
  if(u->material.CPSloupec[i]>1)ph->cena-=((u->material.CPSloupec[i]-1)*u->AlgCfg.AlgKoef.DvojPesec);

  if(!(u->material.BPSloupec[i]||u->material.CPSloupec[i])) {
         ph->otsloupec++;
      }/*pocet otevrenych sloupcu*/
		else if((i>=2)&&(i<=5)) {
			ph->centr += u->material.BPSloupec[i]+u->material.CPSloupec[i];
		}/*pocet pescu v centru*/
   }
  bp=cp=0;
  for(i=0;i<=h8;i++){
   switch(u->pozice.sch[i]){
    case 0:continue;
	case 100:continue;
	case 1:
	 ph->b[bp++]=i;
	 if(BelostPole[i])ph->bb++;else ph->bc++;
	 break;
	case -1:
	ph->c[cp++]=i;
	if(BelostPole[i])ph->cb++;else ph->cc++;
	break;
   }
   } /*od for cyklu */
    /*Uz vim kde jsou pesci*/
   /*Ohodnotim bile*/
   for(j=0;j<bp;j++){
    int d;
	s8 *p,*q;
	
	i=ph->b[j];
	p=u->pozice.sch+i;
	d=(i-a1)%10;
    if(
	d==0 && ! u->material.BPSloupec[1] ||
	d==7 && ! u->material.BPSloupec[6] ||
	d && d!=7 && !(u->material.BPSloupec[d-1]||u->material.BPSloupec[d+1]))
	 ph->bt[j]=32; /*izolovany*/
	else{
	 if(*(p+1)==1||*(p-1)==1)ph->bt[j]|=4; /*vedle*/
	 if(*(p-11)==1||*(p-9)==1)ph->bt[j]|=8; /*kryty*/
	}
	if(*(p+10)==-1 && *(p+11)!=-1 && *(p+9)!=-1){
	 ph->bt[j]|=1;/*blokovany*/
	 if(BelostPole[i])ph->bb++;else ph->bc++;
	 /*blokovani se pocitaji 2x*/
	 if(d>1 && d<6)ph->centr++;
	 /*a tady take*/
	 }
	 else {
	  for(q=p+10;q<u->pozice.sch+a8;q+=10)
	   if(abs(*q)==1||*(q+1)==-1||*(q-1)==-1)
	    {q=NULL;break;}
	  if(q!=NULL)ph->bt[j]|=16; /*volny*/
	 } /* od neni blokovany */
	 if(!(ph->bt[j]&8)&&abs(*(p+10))!=1){
	  d=0;
	  if(*(p+21)==-1)d++;
	  if(*(p+19)==-1)d++;
	  if(*(p+1)==1)d--;
	  if(*(p-1)==1)d--;
	  if(d>0)ph->bt[j]|=2;
	 }
   } /* od for cyklu*/
   /*Ohodnotim cerne*/
   for(j=0;j<cp;j++){
    int d;
	s8 *p,*q;
	
	i=ph->c[j];
	p=u->pozice.sch+i;
	d=(i-a1)%10;
    if(d==0 && ! u->material.CPSloupec[1] ||
	   d==7 && ! u->material.CPSloupec[6] ||
	d && d!=7 && !(u->material.CPSloupec[d-1]||u->material.CPSloupec[d+1]))
	 ph->ct[j]=32; /*izolovany*/
	else{
	 if(*(p+1)==-1||*(p-1)==-1)ph->ct[j]|=4; /*vedle*/
	 if(*(p+11)==-1||*(p+9)==-1)ph->ct[j]|=8; /*kryty*/
	}
	if(*(p-10)==1 && *(p-11)!=1 && *(p-9)!=1){
	 ph->ct[j]|=1;/*blokovany*/
	 if(BelostPole[i])ph->cb++;else ph->cc++;
	 /*blokovani se pocitaji 2x*/
	 if(d>1 && d<6)ph->centr++;
	 /*a tady take*/
	 }
	 else {
	  for(q=p-10;q>u->pozice.sch+h1;q-=10)
	   if(abs(*q)==1||*(q+1)==1||*(q-1)==1)
	    {q=NULL;break;}
	  if(q!=NULL)ph->ct[j]|=16; /*volny*/
	 } /* od neni blokovany */
	 if(!(ph->ct[j]&8)&&abs(*(p-10))!=1){
	  d=0;
	  if(*(p-21)==1)d++;
	  if(*(p-19)==1)d++;
	  if(*(p+1)==-1)d--;
	  if(*(p-1)==-1)d--;
	  if(d>0)ph->ct[j]|=2;
	 }
   } /* od for cyklu*/
   for(j=0;j<bp;j++){
    i=ph->bt[j];
	/*0|0|izolovany|volny|kryty|vedle|opozdeny|blokovany*/
	if(i&32)ph->cena+=u->AlgCfg.AlgKoef.PesecIzolovany;
    if(i&2)ph->cena+=u->AlgCfg.AlgKoef.PesecSlaby;
	if(i&8)ph->cena+=u->AlgCfg.AlgKoef.PesecKryty; else
	if(i&4)ph->cena+=u->AlgCfg.AlgKoef.PesecVedle;
	if(i&16)ph->cena+=u->AlgCfg.bpv[ph->b[j]];
	ph->cena+=u->AlgCfg.bp[ph->b[j]];
   }
 for(j=0;j<cp;j++){
    i=ph->ct[j];
	/*0|0|izolovany|volny|kryty|vedle|opozdeny|blokovany*/
	if(i&32)ph->cena-=u->AlgCfg.AlgKoef.PesecIzolovany;
    if(i&2)ph->cena-=u->AlgCfg.AlgKoef.PesecSlaby;
	if(i&8)ph->cena-=u->AlgCfg.AlgKoef.PesecKryty; else
	if(i&4)ph->cena-=u->AlgCfg.AlgKoef.PesecVedle;
	if(i&16)ph->cena-=u->AlgCfg.cpv[ph->c[j]];
	ph->cena-=u->AlgCfg.cp[ph->c[j]];
   }

} /* od funkce*/


/*********************************************************/
/* tabulky.c - prace s databazi koncovek                 */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include "volby.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "volby.h"
#include "cotyvar.h"
#include "dosio.h"
#include "generato.h"
#include "globruti.h"
#include "sachy.h"
#include "myslitel.h"
#include "lokruti.h"
#include "tabulky.h"
#define velikost (64*64*10*2)
/*Kral slabsi strany je vzdy v trojuhelniku a1-d1-d4*/
/*
 253 - na tahu je bily nebo (cerny a ma tah) 
 254 - cerny je v patu
 0 - cerny je v matu
 
*/
u16 TabDejTah(TUloha *u){
	TTah1 *p1,*p2;
	FILE *f;
	u8 t,ts;
	int index;

	if((index=TPoziceToInt(&(u->pozice)))<0)return 0;
	f=fopen("kdk.tab","rb");
	if(!f)return 0;
	NalezTahy(u);
	JenPripustne(u);
	UlozStav(u);
	p1=u->zasobnik.tahy+u->zasobnik.hranice[0];
	p2=u->zasobnik.tahy+u->zasobnik.hranice[1];
	fseek(f,index,SEEK_SET);
	fread((void *)&ts,1,1,f);
	for(;p1<p2;p1++){
	 JednoTahni(p1->data,u);
	 index=TPoziceToInt(&(u->pozice));
	 fseek(f,index,SEEK_SET);
	 fread((void *)&t,1,1,f);
	 TahniZpet(p1->data,u);
	 if(u->pozice.bily && t<ts || !u->pozice.bily && t>=ts-1)break;
	}
	fclose(f);
	return p1->data;
}
u8 TypPozice(TUloha *u){
 if(u->pozice.bily) return 253;
 NalezTahy(u);
 JenPripustne(u);
 if(u->zasobnik.hranice[1])return 253;
 if(Sach(false, u->pozice.sch)) return 0;
 return 254;
}
bool IntToTPozice(int i,TPozice *pos){
	/* Vraci true - uspech*/
 int K,D,k,j;

 if(i>=velikost || i<0) return false;
 
 k=i%10;
 i/=10;
 D=i&63;
 i>>=6;
 K=i&63;
 pos->bily=i>>6;
 i=D&7;
 j=D>>3;
 D=a1+i+10*j;
 i=K&7;
 j=K>>3;
 K=a1+i+10*j;
 if(k<4)k+=a1;else
  if(k<7)k+=b2-4;else
   if(k<9)k+=c3-7;else
	k=d4;
 if(k==K || K==D || k==D) return false;
 memset(pos->sch,100,sizeof(TSch));
 for(i=a1,j=0;i<=h8;j=(j==9 ? 0 : j+1),i++){
	 if(i==K){pos->sch[i]=6;continue;}
	 if(i==D){pos->sch[i]=5;continue;}
	 if(i==k){pos->sch[i]=-6;continue;}
	 if(j<8)pos->sch[i]=0;
 }
 if(!pos->bily && Ohrozeno(pos->sch+K,false) ||
	 pos->bily && Ohrozeno(pos->sch+k,true))
	 return false;
 pos->mimoch=0;
 pos->roch=0;
 return true;
}
int TPoziceToInt(TPozice *pos){
	/* Vraci -1 jako neuspech*/

 int i,j,pole,Kx,Ky,kx,ky,Dx,Dy;
 Kx=-1;kx=-1;Dx=-1;
  for(j=0;j<8;j++)
   for(i=0;i<8;i++)
  {
	  pole=i+a1+j*10;
	  switch(pos->sch[pole]){
	  case 0:continue;
	  case 6:Kx=i;Ky=j;continue;
	  case -6:kx=i; ky=j;continue;
	  case 5:Dx=i; Dy=j; continue;
	  default: return -1;
	  }
   }
   if(Kx<0||kx<0||Dx<0) return -1;
   if(kx>3){kx=7-kx;Kx=7-Kx;Dx=7-Dx;}
   if(ky>3){ky=7-ky;Ky=7-Ky;Dy=7-Dy;}
   if(ky>kx){i=kx;kx=ky;ky=i;i=Kx;Kx=Ky;Ky=i;}
/* To bylo kvuli symetriim */
   switch(ky){
   case 0:break;
   case 1:kx+=3;break;
   case 2:kx+=5;break;
   case 3:kx=9;break;
   }
   Kx+=(Ky<<3);
   Dx+=(Dy<<3);
  return ((pos->bily<<12)|(Kx<<6)|Dx)*10+kx;
}

void generujKDK(){
 TUloha *u;
 u8 *p;
 FILE *f;
 int i,index,pocet,j;
 bool konec;
 TTah1 *p1,*p2;

 p=(u8 *)malloc(velikost);
 if(p==NULL){puts("Malo pameti");return;}
 u=InitUlohu(0,0);
 puts("Hledam maty a paty...");
 for(i=0;i<velikost;i++){
	 j=IntToTPozice(i,&(u->pozice));
	 if(j){
		/* j=TPoziceToInt(&(u->pozice));
		 if(j!=i){
			 TiskniSachovnici(&(u->pozice));
			 printf("Vrr puvodni==%i!=%i==vysledek\n",i,j);
			 break;}*/
		 p[i]=TypPozice(u);
		 /*if(!p[i]){putchar('.');TiskniSachovnici(&(u->pozice));}
		 if(p[i]==254){
			 TiskniSachovnici(&(u->pozice));
			 putchar('p');
		 }*/
	 } else p[i]=255;
 }
 puts("A ted jedu v cyklu");
 for (i=1;i<100;i++){
	 printf("Pocitam mat cernemu %i. pultahem\n",i);
	 pocet=0;
	 if(i&1){ /* Tahne bily */
		 for(j=velikost/2;j<velikost;j++)
			 if(p[j]==253){
				 IntToTPozice(j,&(u->pozice));
				 NalezTahy(u);
				 JenPripustne(u);
				 UlozStav(u);
				 p1=u->zasobnik.tahy+u->zasobnik.hranice[0];
				 p2=u->zasobnik.tahy+u->zasobnik.hranice[1];
				 konec=false;
				 for(;p1<p2;p1++){
					 //TiskniSachovnici(&(u->pozice));
					 JednoTahni(p1->data,u);
					 //TiskniSachovnici(&(u->pozice));
					 index=TPoziceToInt(&(u->pozice));
					 //printf("%i ",(int)p[index]);
					 if(index<0){TiskniSachovnici(&(u->pozice),stdout);return;}
					 if(p[index]<252){
						 p[j]=p[index]+1;pocet++;
						 //TiskniSachovnici(&(u->pozice));
						 konec=true;}
					 TahniZpet(p1->data,u);
					 if (konec) break;
				 }/* od for */
			 }/* od if */
	 } /* od if(i&1) */
	 else {
		 for(j=0;j<velikost/2;j++)
			 if(p[j]==253){
				 IntToTPozice(j,&(u->pozice));
				 NalezTahy(u);
				 JenPripustne(u);
				 UlozStav(u);
				 p1=u->zasobnik.tahy+u->zasobnik.hranice[0];
				 p2=u->zasobnik.tahy+u->zasobnik.hranice[1];
				 konec=false;
				 for(;p1<p2;p1++){
					 JednoTahni(p1->data,u);
					 index=TPoziceToInt(&(u->pozice));
					 if(index>=0 && p[index]>252){konec=true;}
					 TahniZpet(p1->data,u);
					 if (konec) break;
					 if (index<0) break;
				 }/* od for */
				 if(index<0){p[j]=254;pocet++;}else;
				 if(p1==p2){p[j]=i;pocet++;}
			 }/* od if */
	 } /* od else k if(i&1) */
	 printf("Ohodnotil jsem %i pozic.\n",pocet);
	 if(!pocet)break;
 }
 for(i=0;i<velikost;i++)if(p[i]>252)p[i]=15;
 f=fopen("kdk.tab","wb");
 fwrite((void *)p,1,velikost,f);
 fclose(f);
 free((void *)p);
 DoneUlohu(&u);
}

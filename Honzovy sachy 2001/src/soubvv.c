/*********************************************************/
/* soubvv.c - IO partie do formatu HS 1350               */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "volby.h"
#include "cotyvar.h"
#include "strtah.h"
#include "globruti.h"
#include "generato.h"
#include "myslitel.h"
#include "partie.h"

char PismenoKamene(s8 k){
	if(k<0)k=(s8)-k;
	switch(k){
	case 1: return 'P';
	case 2: return 'J';
	case 3: return 'S';
	case 4: return 'V';
	case 5: return 'D';
	case 6: return 'K';
	}
 return 'X';
}
bool UlozDoSouboru(char *jmeno,TUloha *u){
/******************************************************/
/* Ulozeni aktualni partie do souboru formatu HS 1350 */
/******************************************************/
	FILE *f;
	TPartie *prt;
	char jmt[15];
	int i;
	s8 j;

	f=fopen(jmeno,"w");
	if(!f)return false;
	prt=u->prt;
	while (u->prt->l){
		GlobTahniZpet(u);
	}
	fprintf(f,"Poèáteèní postavení:\nBílý:\n");
	for(j=1;j<=6;j++)
		for(i=a1;i<=h8;i++)
			if(u->pozice.sch[i]==j){
				putc(PismenoKamene(j),f);
				putc((i-a1)%10+'a',f);
				putc((i-a1)/10+'1',f);
				putc(' ',f);
			}
	fprintf(f,"\nMalá rošáda: %s",(u->pozice.roch&1)?"Ano":"Ne");
	fprintf(f,"\nVelká rošáda: %s",(u->pozice.roch&2)?"Ano":"Ne");
	fprintf(f,"\nÈerný:\n");
	for(j=-1;j>=-6;j--)
		for(i=a1;i<=h8;i++)
			if(u->pozice.sch[i]==j){
				putc(PismenoKamene(j),f);
				putc((i-a1)%10+'a',f);
				putc((i-a1)/10+'1',f);
				putc(' ',f);
			}
	fprintf(f,"\nMalá rošáda: %s",(u->pozice.roch&4)?"Ano":"Ne");
	fprintf(f,"\nVelká rošáda: %s",(u->pozice.roch&8)?"Ano":"Ne");
	fputs("\nNa tahu je: ",f);
	fputs(u->pozice.bily ? "Bílý":"Èerný",f);
	putc('\n',f);
	fprintf(f,"Prùbìh partie:\n");
	i=0;
	while (u->prt->p){
		NalezTahy(u);
		TahToStr(u->prt->p->data.t,u,jmt);
		if(!i&&!u->pozice.bily){
			fprintf(f,"     1... %s\n",jmt);
			GlobTahni(false,u,false);
			i=2;
			continue;
		}
		if(u->pozice.bily)
			fprintf(f,"%i. %s",i/2+1,jmt);
		else
			fprintf(f,", %s\n",jmt);
		GlobTahni(false,u,false);
		i++;
	}
	while (u->prt!=prt)GlobTahniZpet(u);
	fclose(f);
	return true;
}
bool OtevriZeSouboru(char *jmeno,TUloha *u){
/*******************************************************/
/* Otevreni aktualni partie ze souboru formatu HS 1350 */
/*******************************************************/
	TPartie *prt; /* Zde si uchovám pùvodní partii*/
	TPozice pos; /*Zde si uchovám pùvodní pozici*/
/*Když se otevøení nepodaøí, vrátím se k pùvodním*/
	int i,j,k;
	s8 g;
	FILE *f;
	char s[100];
	u16 t;

	prt=u->prt;
	u->prt=NULL;
/* Teï mám v prt pùvodní partii a u->prt prázdnou */
	pos=u->pozice;
	for(i=0;i<=7;i++)
		for(j=0;j<=7;j++){
			u->pozice.sch[i*10+j+a1]=0;
		}
	u->pozice.roch=0;
	u->pozice.mimoch=0;
/* Teï analogicky s pozicí*/
	f=fopen(jmeno,"r");
	if(!f)goto chyba;
	if(!fgets(s,50,f) || strcmp(s,"Poèáteèní postavení:\n")||
		!fgets(s,50,f))goto chybaf;
        if(!strcmp(s,"Bílý:\n"))u->pozice.bily=1;else
		if(!strcmp(s,"Èerný:\n"))u->pozice.bily=0;else
			goto chybaf;
	if(!fgets(s,97,f))goto chybaf;
	j=strlen(s);
	for(i=0;i<j;){
		switch(s[i]){
		case 'K':g=6; break;
		case 'D':g=5; break;
		case 'V':g=4; break;
		case 'S':g=3; break;
		case 'J':g=2; break;
		case 'P':g=1; break;
		default:g=0;
		}
		if(!g)break;
		i++;
		if(s[i]>'h' || s[i]<'a'|| s[i+1]>'8' || s[i+1]<'1') break;
		u->pozice.sch[a1+(s[i]-'a')+(s[i+1]-'1')*10]=g;
		i+=3;
	}
	if(!fgets(s,50,f))goto chybaf;
	if(strncmp(s,"Malá rošáda: ",13))goto chybaf;
	if(!strcmp(s+13,"Ano\n"))u->pozice.roch|=1;
	else
	if(strcmp(s+13,"Ne\n"))goto chybaf;
	if(!fgets(s,50,f))goto chybaf;
	if(strncmp(s,"Velká rošáda: ",14))goto chybaf;
	if(!strcmp(s+14,"Ano\n"))u->pozice.roch|=2;
	else
	if(strcmp(s+14,"Ne\n"))goto chybaf;

	if(!fgets(s,50,f) || strcmp(s,"Èerný:\n")) goto chybaf;
	if(!fgets(s,97,f))goto chybaf;
	j=strlen(s);
	for(i=0;i<j;){
		switch(s[i]){
		case 'K':g=6; break;
		case 'D':g=5; break;
		case 'V':g=4; break;
		case 'S':g=3; break;
		case 'J':g=2; break;
		case 'P':g=1; break;
		default:g=0;
		}
		if(!g)break;
		i++;
		g=(s8)-g;
		if(s[i]>'h' || s[i]<'a'|| s[i+1]>'8' || s[i+1]<'1') break;
		u->pozice.sch[a1+(s[i]-'a')+(s[i+1]-'1')*10]=g;
		i+=3;
	}
	if(!fgets(s,50,f))goto chybaf;
	if(strncmp(s,"Malá rošáda: ",13))goto chybaf;
	if(!strcmp(s+13,"Ano\n"))u->pozice.roch|=4;
	else
	if(strcmp(s+13,"Ne\n"))goto chybaf;
	if(!fgets(s,50,f))goto chybaf;
	if(strncmp(s,"Velká rošáda: ",14))goto chybaf;
	if(!strcmp(s+14,"Ano\n"))u->pozice.roch|=8;
	else
	if(strcmp(s+14,"Ne\n"))goto chybaf;
	
	if(!fgets(s,50,f))goto chybaf;
	if(strncmp(s,"Na tahu je: ",12))goto chybaf;
	if(!strcmp(s+12,"Bílý\n"))u->pozice.bily=1;
	else
	if(!strcmp(s+12,"Èerný\n"))u->pozice.bily=0;
	else goto chybaf;
	if(!fgets(s,50,f) || strcmp(s,"Prùbìh partie:\n"))
		goto chybaf;
/* A koneènì naèítám partii */
	InitPartie(&(u->prt),&(u->pozice));
	if(!u->pozice.bily){
		/* ve výchozí pozici zaèínal èerný */
	if(!fgets(s,50,f)||!s[0]) goto KonecPartie;
		if(strstr(s,"     1... ")!=s) goto chybaf;
		NalezTahy(u);
		JenPripustne(u);
		if(!StrToTah(s+10,u,&t))goto chybaf;
		if(!KTNehledej(t,u))goto chybaf;
		GlobTahni(true,u,true,(unsigned)t);
	}
	
	while(1){
		if(!fgets(s,50,f)||!s[0]) break;
		j=strlen(s);
	for(k=0;k<2;k++){
		if(k){
			for(i=0;i<j;i++)if(s[i]==',') break;
			if(s[i]!=',') goto KonecPartie;
		}
		else{
			for(i=0;i<j;i++)if(s[i]=='.') break;
		}
		i+=2;
		if(i>=j)goto chybaf;
		NalezTahy(u);
		JenPripustne(u);
		if(!StrToTah(s+i,u,&t))goto chybaf;
		if(!KTNehledej(t,u))goto chybaf;
		GlobTahni(true,u,true,(unsigned)t);
		}
	}
KonecPartie:;
	fclose(f);
	DonePartie(&prt);
	return true;
chybaf:
	fclose(f);
chyba:
	DonePartie(&(u->prt));
	u->prt=prt;
	u->pozice=pos;
/* Obnovil jsem pùvodní pozici a partii */
	return false;
}

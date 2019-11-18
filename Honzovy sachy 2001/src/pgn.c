/*********************************************************/
/* pgn.c - export do formatu pgn                         */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "volby.h"
#if Typ_Produktu==Win32_Program
#include <windows.h>
#include "winmain.h"
#endif
#include "cotyvar.h"
#include "partie.h"
#include "strtah.h"
#include "globruti.h"
#include "generato.h"
#include "pgn.h"
#if Typ_Produktu==Win32_Program
#define ID_OK 1020
#define ID_Zrusit 1021
#define ID_BilJm 1002
#define ID_BilEl 1003
#define ID_CerJm 1004
#define ID_CerEl 1005
#define ID_Turnaj 1008
#define ID_Kolo 1009
#define ID_Misto 1010
#define ID_Komentator 1000
#define ID_Den 1011
#define ID_Mesic 1012
#define ID_Rok 1013
#define ID_BilElCh 1014
#define ID_CerElCh 1015
#define ID_Vysledek 1017
#define ID_ECO 1018
#define ID_ECOCh 1019

static bool GlobOK;
static TPGNInfo *GlobInfo;
#endif

void ECOToStr(int e,char *s){
	if(!e){s[0]='?';s[1]=0;}
	sprintf(s,"%c%02d",(e/100)+'A'-1,e%100);
}
bool StrToECO(char *s,int *e){
	if(strlen(s)!=3||s[0]>'E'||s[0]<'A'||!isdigit(s[1])||!isdigit(s[1]))
		return false;
	*e=100*(s[0]-'A'+1)+10*(s[1]-'0')+s[2]-'0';
	return true;
}
#if Typ_Produktu==Win32_Program
static bool PrectiDialog(HWND hwnd,char *chyba){
	char s[256];
	int whiteelo,blackelo,round,eco,rok,mesic,den;
	
	if(!IsDlgButtonChecked(hwnd,ID_BilElCh))
		whiteelo=0;
	else {
	 whiteelo=GetDlgItemInt(hwnd, ID_BilEl, NULL, FALSE);
	 if(!whiteelo){
		 strcpy(chyba,"Elo bílého musí být kladné celé èíslo !");
		 return false;
	 }
	}
	if(!IsDlgButtonChecked(hwnd,ID_CerElCh))
		blackelo=0;
	else {
	 blackelo=GetDlgItemInt(hwnd, ID_CerEl, NULL, FALSE);
	 if(!blackelo){
		 strcpy(chyba,"Elo èerného musí být kladné celé èíslo !");
		 return false;
	 }
	}
	round=GetDlgItemInt(hwnd, ID_Kolo, NULL, FALSE);
	 if(!round){
		 strcpy(chyba,"Kolo musí být kladné celé èíslo !");
		 return false;
	 }
	if(!IsDlgButtonChecked(hwnd,ID_ECOCh))
		eco=0;
	else{
	GetDlgItemText(hwnd, ID_ECO,s,200);
	if(!StrToECO(s,&eco)) {
		strcpy(chyba,"ECO musí obsahovat velké písmeno A až E a 2 èíslice");
	    return false;
	}
	}
	rok=GetDlgItemInt(hwnd, ID_Rok, NULL, TRUE);
	 if(!rok){
		 strcpy(chyba,"Rok musí být nenulové celé èíslo !");
		 return false;
	 }
	mesic=GetDlgItemInt(hwnd, ID_Mesic, NULL, FALSE);
	 if(mesic<1 || mesic>12){
		 strcpy(chyba,"Mìsic musí být celé èíslo z <1, 12> !");
		 return false;
	 }
	den=GetDlgItemInt(hwnd, ID_Den, NULL, FALSE);
	 if(den<1 || den>31){
		 strcpy(chyba,"Den musí být celé èíslo z <1, 31> !");
		 return false;
	 }
	DonePGN(GlobInfo);
	GlobInfo->eco=eco;
	GlobInfo->round=round;
	GlobInfo->whiteelo=whiteelo;
	GlobInfo->blackelo=blackelo;
	GlobInfo->rok=rok;
	GlobInfo->mesic=mesic;
	GlobInfo->den=den;
	GetDlgItemText(hwnd,ID_BilJm,s,200);
	GlobInfo->white=strdup(s);
	GetDlgItemText(hwnd,ID_CerJm,s,200);
	GlobInfo->black=strdup(s);
	GetDlgItemText(hwnd,ID_Turnaj,s,200);
	GlobInfo->event=strdup(s);
	GetDlgItemText(hwnd,ID_Misto,s,200);
	GlobInfo->site=strdup(s);
	GetDlgItemText(hwnd,ID_Komentator,s,200);
	GlobInfo->annotator=strdup(s);
	GlobInfo->result=SendDlgItemMessage(hwnd,ID_Vysledek,CB_GETCURSEL,0,0);
	return true;
}

BOOL CALLBACK PGNDlgWinProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {char s[100];
 switch(uMsg){
   case WM_INITDIALOG:
	   SetDlgItemText(hwnd,ID_BilJm,GlobInfo->white);
	   SetDlgItemText(hwnd,ID_CerJm,GlobInfo->black);
	   SetDlgItemText(hwnd,ID_Turnaj,GlobInfo->event);
	   SetDlgItemText(hwnd,ID_Misto,GlobInfo->site);
	   SetDlgItemInt(hwnd,ID_Kolo,GlobInfo->round,FALSE);
	   SetDlgItemText(hwnd,ID_Komentator,GlobInfo->annotator);
	   SetDlgItemInt(hwnd,ID_BilEl,GlobInfo->whiteelo,FALSE);
	   SetDlgItemInt(hwnd,ID_CerEl,GlobInfo->blackelo,FALSE);
	   SetDlgItemInt(hwnd,ID_Den,GlobInfo->den,FALSE);
	   SetDlgItemInt(hwnd,ID_Mesic,GlobInfo->mesic,FALSE);
	   SetDlgItemInt(hwnd,ID_Rok,GlobInfo->rok,FALSE);
	   CheckDlgButton(hwnd,ID_BilElCh,0);
	   CheckDlgButton(hwnd,ID_CerElCh,0);
	   ECOToStr(GlobInfo->eco,s);
	   SetDlgItemText(hwnd,ID_ECO,s);
	   CheckDlgButton(hwnd,ID_ECOCh,0);
	   SendDlgItemMessage(hwnd,ID_Vysledek,CB_ADDSTRING,0,(LPARAM) "1-0");
	   SendDlgItemMessage(hwnd,ID_Vysledek,CB_ADDSTRING,0,(LPARAM) "1/2-1/2");
	   SendDlgItemMessage(hwnd,ID_Vysledek,CB_ADDSTRING,0,(LPARAM) "0-1");
	   SendDlgItemMessage(hwnd,ID_Vysledek,CB_SETCURSEL,GlobInfo->result,0);

  	return TRUE;
   case WM_COMMAND:
	   switch (LOWORD(wParam)){
	   case ID_BilEl:
		   if(HIWORD(wParam)==EN_CHANGE)
			   CheckDlgButton(hwnd,ID_BilElCh,1);
		   return TRUE;
		case ID_CerEl:
		   if(HIWORD(wParam)==EN_CHANGE)
			   CheckDlgButton(hwnd,ID_CerElCh,1);
		   return TRUE;
		case ID_ECO:
		   if(HIWORD(wParam)==EN_CHANGE)
			   CheckDlgButton(hwnd,ID_ECOCh,1);
		   return TRUE;
		case ID_OK:
			if(HIWORD(wParam)==BN_CLICKED) {
				if(PrectiDialog(hwnd,s)){
				GlobOK=true;
				EndDialog(hwnd,0);}
				else MessageBox(hwnd,s,"Chyba v zdaných datech",MB_OK | MB_ICONSTOP | MB_TASKMODAL);
			}
			return TRUE;
		case ID_Zrusit:
			if(HIWORD(wParam)==BN_CLICKED) EndDialog(hwnd,0);
			return TRUE;
       default: return TRUE;}
   default: return FALSE;
  }
 }


bool DialogPGN(HWND otec, TPGNInfo *p){
	GlobOK=false;
	GlobInfo=p;
	DialogBox(hInstance,"PGNDLG",otec,PGNDlgWinProc);
	return GlobOK;
}
#endif
/*************************************************************************/
/* PGNTTah1ToStr - prevod tahu na retezec pro PGN                        */
/*************************************************************************/
void PGNTahToStr(u16 tah, TUloha *uloha, char *s)
  {int odkud,kam,i;

  if(!(tah>>14)) /* Normalni tah*/
   {kam=tah&127;
    odkud=tah>>7;
    i=0;
    switch (abs(uloha->pozice.sch[odkud])){
    case 1:if (uloha->pozice.sch[kam]) s[i++]=(char)((odkud-a1)%10 + 'a');
	    goto PesecJeJednoznacny;
    case 2:s[i++]='N';break;
    case 3:s[i++]='B';break;
    case 4:s[i++]='R';break;
    case 5:s[i++]='Q';break;
    case 6:s[i++]='K';break;
    }
   if (!JednoZnacny(tah,uloha,J_Nic)) /* Zkusim Da1 */
    {    /* Tak Dha1 */
    if (JednoZnacny(tah,uloha,J_Sloupec)) s[i++]=(char)((odkud-a1)%10 + 'a');
     else /* Tak D1a1 */
      if (JednoZnacny(tah,uloha,J_Radka)) s[i++]=(char)((odkud-a1)/10 + '1');
       else /* Tak teda Dh1a1 (nutne pokud jsou 3 damy na h1, h8 a a8)*/
	{s[i++]=(char)((odkud-a1)%10 + 'a');
	 s[i++]=(char)((odkud-a1)/10 + '1');
	}
    }
   PesecJeJednoznacny:;
    if (uloha->pozice.sch[kam]) s[i++]='x';
    s[i++]=(char)((kam-a1)%10 + 'a');
    s[i++]=(char)((kam-a1)/10 + '1');
    s[i]=0;
    return;
    }
  /* Nenormalni tah
     Mala rosada*/
  if (tah==MBRoch || tah==MCRoch)
   { (void) strcpy((char *) s,"O-O"); return;}
  /*Velka rosada*/
  if (tah==VBRoch || tah==VCRoch)
   { (void) strcpy((char *) s,"O-O-O"); return;}

  /*Promena bileho pesce*/
 if ((tah>>12)==12 || (tah>>12)==13 ) {
 if ((tah>>12)==12)
  {odkud=a7+((tah>>7)&7);
   kam=a8+((tah>>4)&7);}
  else
  {odkud=a2+((tah>>7)&7);
   kam=a1+((tah>>4)&7);}
   i=0;
   s[i++]=(char)((odkud-a1)%10 + 'a');
   if (uloha->pozice.sch[kam]) {s[i++]='x'; s[i++]=(u8)((kam-a1)%10 + 'a');}
   s[i++]=(char)((kam-a1)/10 + '1');
   s[i++]='=';
   switch((tah>>10)&3){
   case 0:s[i++]='N';break;
   case 1:s[i++]='B';break;
   case 2:s[i++]='R';break;
   case 3:s[i++]='Q';break;
   }
   s[i]=0;
   return;
  }
 /* Brani mimochodem (nic jineho to uz byt nemuze)*/
 tah&=0x3fff; /* odstraneni prvnich dvou bitu, aby se lepe siftovalo*/
 kam=tah&127;
 odkud=tah>>7;
 i=0;
 s[i++]=(char)((odkud-a1)%10 + 'a');
/* s[i++]=(odkud-a1)/10 + '1';*/
 s[i++]='x';
 s[i++]=(char)((kam-a1)%10 + 'a');
 s[i++]=(char)((kam-a1)/10 + '1');
 s[i]=0;
 return;
}

void InitPGN(TPGNInfo *p){
	p->event=strdup("?");
	p->site=strdup("?");
	p->rok=2000;
	p->mesic=5;
	p->den=16;
	p->round=1;
	p->white=strdup("Uživatel");
	p->black=strdup("Honzovy šachy");
	p->result=0; /*1:0*/
	p->eco=100; /*A00*/
	p->whiteelo=1734;
	p->blackelo=2000;
	p->annotator=strdup("nikdo");
	p->plycount=0;
}
void DonePGN(TPGNInfo *p){
 free(p->event);
 free(p->site);
 free(p->white);
 free(p->black);
 free(p->annotator);
}
void PisKusHlavy(char *nazev, char *hodnota, FILE *f){
	fprintf(f,"[%s \"%s\"]\n",nazev,hodnota);
}
void PGNPisTahy(TUloha *u,FILE *f){
	TPartie *prt;
	int i;
	char jmt[20];

	prt=u->prt;
	while (u->prt->l)GlobTahniZpet(u);
	i=0;
	while (u->prt->p){
		NalezTahy(u);
		PGNTahToStr(u->prt->p->data.t,u,jmt);
		if(!i&&!u->pozice.bily){
			fprintf(f,"     1... %s\n",jmt);
			GlobTahni(false,u,false);
			i=2;
			continue;
		}
		if(u->pozice.bily)
			fprintf(f,"%i. %s",i/2+1,jmt);
		else
			fprintf(f," %s ",jmt);
		GlobTahni(false,u,false);
		if(!((i+1)&15))putc('\n',f);
		i++;
	}
	while (u->prt!=prt)GlobTahniZpet(u);
}
bool UlozDoPGN(char *jmeno,TUloha *u,TPGNInfo *pgn){
	FILE *f;
	char s[10];

	f=fopen(jmeno,"a");
	if(!f)return false;
	PisKusHlavy("Event",pgn->event,f);
	PisKusHlavy("Site",pgn->site,f);
	fprintf(f,"[Date \"%i.%i.%i\"]\n",pgn->rok,pgn->mesic,pgn->den);
	fprintf(f,"[Round \"%i\"]\n",pgn->round);
	PisKusHlavy("White",pgn->white,f);
	PisKusHlavy("Black",pgn->black,f);
	PisKusHlavy("Result",pgn->result ? ((pgn->result<0) ? "0-1" : "1-0") : "1/2-1/2",f);
	ECOToStr(pgn->eco,s);
	PisKusHlavy("ECO",s,f);
	fprintf(f,"[WhiteElo \"%i\"]\n",pgn->whiteelo);
	fprintf(f,"[BlackElo \"%i\"]\n",pgn->blackelo);
	PisKusHlavy("Annotator",pgn->annotator,f);
	fprintf(f,"[Plycount \"%i\"]\n\n",PocetPultahu(u->prt));
	PGNPisTahy(u,f);
	fputs("\n\n\n",f);
	fclose(f);
	return true;
}


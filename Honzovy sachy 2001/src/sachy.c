/*********************************************************/
/* sachy.c - obsahuje main a zakladni init a done        */
/* 10.3. 2001 Jan Nemec                                   */
/*********************************************************/
#include "volby.h"
#if Typ_Produktu == DOS_UNIX || Typ_Produktu == CGI_script
#include <stdio.h>
#endif
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "cotyvar.h"
#include "partie.h"
#include "kontrola.h"
#include "chyba.h"
#include "ohodnoc.h"
#include "myslitel.h"
#include "knihovna.h"
#include "hashtab.h"
#if Typ_Produktu==DOS_UNIX
#include "dosio.h"
#elif Typ_Produktu==CGI_script
#include "wwwio.h"
#elif Typ_Produktu==Projekt
#include "scio.h"
#endif
TUloha *InitUlohu(int DveNaXHash,int DveNaXHashPech)
/*********************************************/
/* Inicializace ulohy (Alokace tabulek atd)  */
/*********************************************/
{TUloha *uloha;

 uloha=(TUloha *)malloc(sizeof(TUloha));
 (void) memset((void *) uloha, 0, sizeof(TUloha));
 uloha->prt=NULL;
 uloha->pozice=ZakladniPostaveni;
 InitPartie(&(uloha->prt),&(uloha->pozice));
 NastavAlgCfgStd(&(uloha->AlgCfg));
 ZasumAlgCfg(&(uloha->AlgCfg), 5);
 uloha->KonecPartie=0;
 uloha->ht=(THashPrvek *)malloc((1<<DveNaXHash)*sizeof(THashPrvek));
 memset((void *)uloha->ht,0,(1<<DveNaXHash)*sizeof(THashPrvek));
 uloha->hpt=(THashPech *)malloc((1<<DveNaXHashPech)*sizeof(THashPech));
 memset((void *)uloha->hpt,0,(1<<DveNaXHashPech)*sizeof(THashPech));
 uloha->HashCfg.DveNaXHash=DveNaXHash;
 uloha->HashCfg.DveNaXHashPech=DveNaXHashPech;
 return uloha;
}
void DoneUlohu(TUloha **uloha)
/**********************************/
/* mazani ulohy a jejich tabulek  */
/**********************************/
 {DonePartie(&((*uloha)->prt));
 free((void *)((*uloha)->ht));
 free((void *)((*uloha)->hpt));
 free((void *)*uloha);
 *uloha=NULL;
}
void InitProgram(TUloha **uloha, char *knihsoubor)
/*********************************************/
/* Provede inicializaci celeho programu      */
/* (srand, knihovna...)                      */
/*********************************************/
{
#ifndef Umi_sizeof
KontrolaTypu
#endif
 HashInit();
 srand((unsigned)time(NULL));
#if Typ_Produktu==Projekt
 switch(PrjData.typ){
/* Sekretarka nepotrebuje velke hash tabulky
(jen by promrhalo pamet na serveru)*/
  case 1: *uloha=InitUlohu(1,10); break;
  case 2: *uloha=InitUlohu(1,11); break;
  case 3: *uloha=InitUlohu(10,12); break;
  case 4: *uloha=InitUlohu(16+rand()&1,13); break;
  default: *uloha=InitUlohu(17+rand()&1,13); break;
 }
#else
 *uloha=InitUlohu(18,13);
#endif
 if(!!knihsoubor && !init_knihovna(knihsoubor)) {
#if Typ_Produktu==Projekt
	 SCioVypis("Nacetl jsem knihovnu");
#endif
	 MamKnihovnu=true;
 }
#if Typ_Produktu==Projekt
 else
	 SCioVypis("varovani: Neuspech nacitani knihovny");
#endif
}

#if Typ_Produktu==DOS_UNIX
#ifndef WITHOUT_MAIN /*Kvuli knihovne pro GTK*/
int main(void)
/******************/
/* konzolovy main */
/******************/
{TUloha *uloha;

puts("Honzuv sachovy program");
 InitProgram(&uloha,"knihovna");
 HlavniDosCyklus(uloha);
 puts("Konec programu");
 DoneUlohu(&uloha);
 return 0;
}
#endif
#elif Typ_Produktu==CGI_script
int main(void)
/************/
/* cgi main */
/************/
 {TUloha *uloha;
 u8 *data;

#ifndef Simulace_CGI
 char *method;
 int length;
#endif

InitProgram(&uloha,knihovna);

#ifdef Simulace_CGI

data=(u8 *) strdup(
"TAH=2B0B&"
"POZICE=0F000164646464646464646464646464646464646464646404020305060302046464010101010001010164640000000000000000646400000000000000006464000000FB00000000646400000000000000006464FFFFFF00FFFFFFFF6464FCFEFD00FAFDFEFC646464646464646464646464646464646464646464");
/*length=strlen(vstup);*/
#else
 method=getenv("REQUEST_METHOD");
 if (method==NULL) Chyba("Neni definovana promenna REQUEST_METHOD!");
  /* nevim, jestli je POST, nebo GET */
 if (StejneVM(method,"GET"))
 {
   data=(u8 *)strdup(getenv("QUERY_STRING"));
 }
 if (StejneVM(method,"POST"))
 {
  length=atoi(getenv("CONTENT_LENGTH"));
  data=malloc(length+1);
  /* cteni daneho poctu bytu */
  fread(data,length,1,stdin);
  data[length]=0;
 }
#endif
 uloha=InitUlohu();
 WWWZpracujData(data,uloha);
 DoneUlohu(&uloha);
 free(data);
 return(0);
 }
#elif Typ_Produktu==Win32_DLL
#error DLL není implementována
#elif Typ_Produktu==Win32_Program
/* Vše je ve winmain.c*/
#elif Typ_Produktu==Projekt
int main(int argc, char **argv){
/*************************************/
/* main pro ptojekt Sachove centrum  */
/*************************************/
TUloha *uloha;

#ifdef SCioLadim
 char s[20];
 int i;
 sprintf(s,"pha%i.log",(int)getpid());
 remove(s);
 SCioVypis("Argumenty:");
 for(i=0;i<argc;i++)SCioVypis(argv[i]);
#endif

 SCioVypis("Vstoupil jsem do main()");
 SCNactiArgumenty(argc,argv);
 SCioVypis("Volam InitProgram(&uloha,\"knihovna\");");
 InitProgram(&uloha,"knihovna");
 SCOtevriSocket();
 SCCyklus(uloha);
 SCZavriSocket();
 SCioVypis("Volam DoneUlohu(&uloha);");
 DoneUlohu(&uloha);
 SCioVypis("Ted skoncim (return 0; ve funkci main())");
 return 0;
}
#else
#error Na co se to teda vlastne preklada ???
#endif

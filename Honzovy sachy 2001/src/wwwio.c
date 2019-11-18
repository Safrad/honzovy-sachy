/*********************************************************/
/* wwwio.c - pro variantu cgi-script                     */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include "volby.h"
#if Typ_Produktu == CGI_script
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "cotyvar.h"
#include "chyba.h"
#include "generato.h"
#include "globruti.h"
#include "strtah.h"
#include "myslitel.h"
#include "kontrola.h"
#include "wwwio.h"
#ifndef Simulace_CGI
#define AdresaObrazu "http://www.ms.mff.cuni.cz/~jnem6403/sachy/"
#define AdresaScriptu "http://www.ms.mff.cuni.cz/cw/jnem6403/a.out"
#else
#define AdresaObrazu ""
/*"C:\\Honza\\Mojestr\\Sachy\\"*/
#define AdresaScriptu "http://www.ms.mff.cuni.cz/cw/jnem6403/cgi-bin/a.out"
#endif
#define INPUTPOZICE "POZICE"
#define INPUTTAH "TAH"
/* Pise sestnactkove data na stdout */
static void WWWPisData(void *data,int size)
 {u8 c;
  for(;size>0;data=(void *)(((u8 *) data)+1),size--)

   {c= ((*((u8 *)data)) >>4);
    putchar((c<10) ? c+'0' : c+'A'-10);
    c= ((*((u8 *)data))&15);
    putchar((c<10) ? c+'0' : c+'A'-10);
   }
 }
/* cte sestnactkove z retezce p do data
   vraci true  - bylo dost dat
	 false - prislo neco, co neni hexacislice */
static bool WWWCtiData(u8 *p,void *data,int size)
 {
#define dt ((u8 *)data)
  while(size>0)
   {if (*p>='A' && *p<= 'F') *dt=(((*p)-'A')+10)<<4;
     else if (*p>='0' && *p<= '9') *dt=((*p)-'0')<<4;
      else return false;
    p++;
    if (*p>='A' && *p<= 'F') *dt|=(((*p)-'A')+10);
     else if (*p>='0' && *p<= '9') *dt|=((*p)-'0');
      else return false;
    p++;
    data=(void *)(dt+1); /* Pozor, reznicina */
    size--;
   }
  return true;
#undef dt
 }
static bool WWWCtiDataZInputu(u8 *p,void *data,int size,u8 *jmeno)
 {
  p= (u8 *) strstr((char *) p,(char *)jmeno);
  if(p==NULL)return false;
  p+=(1+strlen((char *) jmeno));
  return(WWWCtiData(p,data,size));
 }
/* <INPUT TYPE=HIDDEN NAME="POZICE" VALUE="FF97F"> */
static void WWWPisDataDoHidden(void *data,int size,char *jmeno)
 {
  printf("<INPUT TYPE=HIDDEN NAME=\"%s\" VALUE=\"",(char *) jmeno);
  WWWPisData(data,size);
  puts("\">");
 }
static void TiskniFiguru(s8 jakou, bool BilePole)
 {printf("<TD><IMG SRC=\"%s",AdresaObrazu);
  if(jakou)
  {putchar(jakou>0 ? 'b' : 'c');
   putchar(BilePole ? 'b' : 'c');
   putchar(abs(jakou)+'0');
  }
 else
  {putchar(BilePole ? 'b' : 'c');
   putchar('p');
  }
  printf(".gif\"></TD>");
 }
static void WWWTiskniSachovnici(s8 *sch,bool BilyNahoru)
 {int x,y;
 printf("<TABLE CELLPADDING=0 CELLSPACING=0>\n");
 if (BilyNahoru)
  for (y=7;y>=0;y--){printf("<TR>");
   for (x=0;x<=7;x++) TiskniFiguru(sch[x+21+y*10],(x^y)&1);
   printf("<TR>\n");}
  else
   for (y=0;y<=7;y++){printf("<TR>");
    for (x=7;x>=0;x--) TiskniFiguru(sch[x+21+y*10],(x^y)&1);
    printf("<TR>\n");}
 printf("</TABLE>\n");
 }
/*
  Odprocentuj - prevedeni vstupu na normalni tvar
*/
#if 0
static void Odprocentuj(u8 *data)
 {u8 *p;

  p=data;
  while(1)
   {switch(*data){
     case 0: *p=0; return;
     case '+':*p=' ';break;
     case '%':if (*(data+1) && *(data+2))
  {data++; *p=((*data>='0' && *data<='9') ? *data-'0' : ((*data>='a' && *data<='f') ? *data -'a':*data-'A'))<<4;
   data++; *p|=((*data>='0' && *data<='9') ? *data-'0' : ((*data>='a' && *data<='f') ? *data -'a':*data-'A'));}
   /*
    Dva dvojnasobne podminene vyrazy za sebou. Spravnej ceckar by z toho
    mohl mit ograsmus.
   */
      else Chyba("Spatny konec parametru");
      break;
     default: if(p!=data) *p=*data;
     }
    p++;data++;
   }
 }
#endif
static void WWWTiskniTahy(TUloha *uloha)
 {u8 s[20];
  int i;

 puts("<select name=\""  INPUTTAH "\" SIZE=\"1\">");
 for(i=0;i<uloha->zasobnik.hranice[1];i++)
 {TahToStr(uloha->zasobnik.tahy[i].data,uloha,s);

  printf("<option value=\"");
  WWWPisData((void *) &(uloha->zasobnik.tahy[i].data),sizeof(u16));
  putchar('"');putchar('>');
  puts((char *) s);
 }
 puts("</select>");
 }
void WWWZpracujData(u8 *data, TUloha *uloha)
 {TTah1 tah1;
  u16 t;

if(*data)memset(&(uloha->pozice),-8,sizeof(TPozice));
    if (WWWCtiDataZInputu(data,&(uloha->pozice),sizeof(TPozice),(u8 *) INPUTPOZICE))
     {
      if(PripustnaPozice(&(uloha->pozice))) Chyba("Nepripustna pozice");
      if (!WWWCtiDataZInputu(data,&t,sizeof(u16),(u8 *) INPUTTAH))Chyba("Nemùžu preèíst tah");
      if(!KorektniTah(t,uloha))Chyba("Zahrál jsi nekorektní tah");
      GlobTahni(true,uloha,true,(unsigned)t);
      if(DejTah(uloha,&tah1,5000)) GlobTahni(true,uloha,true,(unsigned)tah1.data);
       
     }
    else uloha->pozice=ZakladniPostaveni;
    puts("Content-type: text/html\nPragma: no-cache\n\n");
    puts( "<HTML>\n"
	  "<HEAD>\n"
	  "<META HTTP-EQUIV=\"Content-Type\"\n"
	  "CONTENT=\"text/html; charset=windows-1250\">\n"
	  "<TITLE>Šachový program</TITLE>\n"
	  "</HEAD>\n"
	  "<BODY BGCOLOR=#C0C0C0>");
/*    puts((char *)data); */
   NalezTahy(uloha);
   JenPripustne(uloha);
   WWWTiskniSachovnici(uloha->pozice.sch,true);
   puts("<BR>");
   if(uloha->zasobnik.hranice[1])
   {
    printf("<FORM ACTION=\"%s\" METHOD=\"POST\">\n Váš tah: \n",AdresaScriptu);
    WWWTiskniTahy(uloha);
    puts("&nbsp;<INPUT TYPE=SUBMIT VALUE=\"Odeslat\">");
    WWWPisDataDoHidden((void *) &(uloha->pozice),sizeof(TPozice),INPUTPOZICE);
    puts("</FORM>");
   }
  else
  {puts("Partie skonèila.");
  }
   puts("</BODY>\n"
	"</HTML>\n");


/* Odprocentuj(data);*/
  }
bool StejneVM(char *s1, char *s2)
 {
  for(;*s1 && *s2; s1++,s2++)
   if(toupper(*s1)!=toupper(*s2))return false;
  if(*s1 || *s2)return false;
  return true;
 }
#endif
/*Typ_Produktu == CGI_script*/


/*********************************************************/
/* dosio.c - consolovy vstup a vystup                    */
/* 11.1. 2001 Jan Nemec                                  */
/* Pro consolovou variantu programu a pro ladici vypisy  */
/*********************************************************/
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include "volby.h"
#include "cotyvar.h"
#include "ohodnoc.h"
#include "dosio.h"
#include "hashpech.h"
#include "myslitel.h"
#include "lokruti.h"
#include "strtah.h"
#include "generato.h"
#include "globruti.h"
#include "partie.h"
#include "soubvv.h"
#include "tabulky.h"
#include "hashtab.h"
#include "kontrola.h"
#include "sachy.h"
#ifdef Vypisy
char VypSoubor[256]="";
#endif

void TestujGenerator(TUloha *uloha)
{int i;
 char s[20];

 (void) memset((void *) &(uloha->zasobnik), 0, sizeof(TZasobnikTahu));
 InitVypocet(uloha);
 if(Ohrozeno(uloha->pozice.sch+(uloha->pozice.bily ? uloha->material.bk : uloha->material.ck),!uloha->pozice.bily))
  NalezTahyZeSachu(uloha); else {
 NalezTahy(uloha);
 JenPripustne(uloha);}
 SetridTahy(uloha);
 for(i=0;i<uloha->zasobnik.hranice[1];i++)
 {TahToStr(uloha->zasobnik.tahy[i].data,uloha,s);
  printf("%s (%i)(%i); ",s,(int)uloha->zasobnik.tahy[i].data,(int)uloha->zasobnik.tahy[i].cena);
  if (i % 4==3) puts("");
 }
 puts("");
 
}
static const char JmenaFigur[7]={' ','p','j','s','v','d','k'};
static void TiskniFiguru(s8 figura,FILE *f)
 {
   putc(figura>0 ? '*' : ' ',f);
   putc(toupper(JmenaFigur[abs(figura)]),f);
 }
void TiskniSachovnici(TPozice *pos,FILE *f)
 {int x,y;
  for (y=7;y>=0;y--)
   {fprintf(f,"%d  |",y+1);
    for (x=0;x<=7;x++)
    {TiskniFiguru(pos->sch[21+x+y*10],f);putc('|',f);}
    putc('\n',f);}
  fprintf(f,"   ");
  for (x=0;x<=7;x++) {putc(' ',f);putc(x+'a',f);putc(' ',f);}
  putc('\n',f);
  fprintf(f,"Rosady: ");
  if(pos->roch&1)fprintf(f,"mb ");
  if(pos->roch&2)fprintf(f,"vb ");
  if(pos->roch&4)fprintf(f,"mc ");
  if(pos->roch&8)fprintf(f,"vc ");
  fputc('\n',f);
 if (pos->mimoch) fprintf(f,"Tazeno pescem o 2 na %c%c\n",
  pos->mimoch%10-1+'a',pos->mimoch/12-1+'1');
 fprintf(f,"Na tahu je %s.\n",pos->bily ? "bily":"cerny");
 for(y=0;y<12;y++)
  for(x=0;x<10;x++)
   if((x==0||x==10)&&(y<2||y>9)&&pos->sch[x+y*10]!=100)
    fprintf(f,"Na [%i,%i] neni okraj 100 !!!!!\n",x,y);
   }

#if Typ_Produktu==DOS_UNIX 

#define HelpStr "\
?  - Tato napoveda\n\
ko - Konec\n\
np - Nova partie\n\
tg - Test generatoru tahu\n\
tc - Test rychlosti generatoru tahu\n\
ta - Tahni, pocitaci\n\
ca - Cas mysleni na tah\n\
zp - Zadej pozici\n\
sa - Nakresli sachovnici\n\
sc - Identifikuje sachy\n\
oh - Nakresli ohrozena pole\n\
tz - Vraceni tahu\n\
td - Znovuzahrani vraceneho tahu\n\
ul - Uloz partii\n\
ot - Otevri partii\n\
ge - Generuj tabulky koncovek\n\
mv - Myslici vypisy (nastaveni)\n\
of - Test ohodnocovaci funkce\n\
ns - Test - nalez tahy za sachu\n\
va - NalezVazby\n\
e4, exd5, exd6 e.p., e8D, exd8D, O-O, Da1, Dxa1, Dha1, Dhxa1,\n\
D8a1, D8xa1, Dh8a1, Dh8xa1 - Priklady zadani tahu cloveka\n"

int Cas=5;

void CasMysleni(void){
	char s[256];
	printf("Cas mysleni je %i s.\nZadej novy:",Cas);
	fgets(s,254,stdin);
	sscanf(s,"%i",&Cas);
}
static void TiskniOhrozeni(TUloha *uloha)
 {s16 x,y;
  int i;

  for (y=7;y>=0;y--)
   {printf("%d  ",y+1);
    for (x=0;x<=7;x++)
   {i=Ohrozeno(&(uloha->pozice.sch[21+x+y*10]),0)+
      (Ohrozeno(&(uloha->pozice.sch[21+x+y*10]),1)<<1);
    putchar('0'+i);TiskniFiguru(uloha->pozice.sch[21+x+y*10],stdout);
	putchar('|');}
    putchar('\n');}
  printf("   ");
  for (x=0;x<=7;x++) {putchar(' ');putchar(x+'a');putchar(' ');}
  putchar('\n');
  printf("Rosady: ");
  if(uloha->pozice.roch&1)printf("mb ");
  if(uloha->pozice.roch&2)printf("vb ");
  if(uloha->pozice.roch&4)printf("mc ");
  if(uloha->pozice.roch&8)printf("vc ");
  putchar('\n');
 if (uloha->pozice.mimoch) printf("Tazeno pescem o 2 na %c%c\n",
  uloha->pozice.mimoch%10-1+'a',uloha->pozice.mimoch/12-1+'1');

  }
void ZadejPozici(TUloha *uloha){
 TPozice pos;
 int i,j,c,b;
 char s[256],f;
 
 (void)memset((void *)&(pos.sch),100,sizeof(TSch));
 for(i=2;i<=9;i++)
  for(j=1;j<=8;j++)
	  pos.sch[i*10+j]=0;
  pos.roch=0;
  pos.mimoch=0;
  pos.bily=0;
start:
  puts("Zadej bile figury, kazdou na novy radek, prazdny je konec.\n"
	  "napr. Jc3 Pa2 nebo prazdne policko Ne4.");
  while(1){
bstart:
   gets(s);
   if(!s[0])break;
   if(strlen(s)!=3)goto bchyba;
   switch(s[0]){
   case 'N':f=0;break;
   case 'P':
	   if(s[2]=='1'||s[2]=='8') goto bchyba;
	   f=1;break;
   case 'J':f=2;break;
   case 'S':f=3;break;
   case 'V':f=4;break;
   case 'D':f=5;break;
   case 'K':f=6;break;
   default:
bchyba:
	   puts("Chybne zadani");goto bstart;
   }
   if(s[1]<'a'||s[1]>'h' || s[2]<'1'||s[2]>'8') goto bchyba;
   pos.sch[(s[2]-'1')*10+a1+s[1]-'a']=f;
  }
 puts("A ted cerne figury");
  while(1){
cstart:
   gets(s);
   if(!s[0])break;
   if(strlen(s)!=3)goto cchyba;
   switch(s[0]){
   case 'N':f=0;break;
   case 'P':
	   if(s[2]=='1'||s[2]=='8') goto cchyba;
	   f=-1;break;
   case 'J':f=-2;break;
   case 'S':f=-3;break;
   case 'V':f=-4;break;
   case 'D':f=-5;break;
   case 'K':f=-6;break;
   default:
cchyba:
	   puts("Chybne zadani");goto cstart;
   }
   if(s[1]<'a'||s[1]>'h' || s[2]<'1'||s[2]>'8') goto cchyba;
   pos.sch[(s[2]-'1')*10+a1+s[1]-'a']=f;
  }
  c=b=0;
  for(i=a1;i<=h8;i++){
	  if(pos.sch[i]==-6)c++;
	  if(pos.sch[i]==6)b++;
  }
  if(c!=1 || b!=1){
	  puts("Kazda strana musi mit prave jednoho krale");
	  TiskniSachovnici(&pos,stdout);
	  goto start;
  }
  puts("Kdo je na tahu ? (b-c)");
  if(getchar()!='c')pos.bily=1;
  if(PripustnaPozice(&pos)){
      puts("Nepripustna pozice");
	  TiskniSachovnici(&pos,stdout);
	  goto start;
  }
  puts("Zadano uspesne");
  TiskniSachovnici(&pos,stdout);
  DonePartie(&(uloha->prt));
  InitPartie(&(uloha->prt),&pos);
  uloha->pozice=pos;
}
void NastavVypisy(void){
#ifdef Vypisy
	printf("Nastaveni vypisu mysliciho algoritmu\nHloubka vypisu (nyni je %i):",ABVH);
	scanf("%i",&ABVH);
	puts("Do jakeho souboru (prazdny retezec je standartni vystup):");
	gets(VypSoubor);
	gets(VypSoubor);
#else
	puts("Vypisy jsou vypnuty.");
#endif
}
void TestujGeneratorCas(TUloha *uloha)
{s32 i;

 (void) memset((void *) &(uloha->zasobnik), 0, sizeof(TZasobnikTahu));
 puts("Musim 300000 krat nalezt vsechny pseudolegalni tahy z aktualni pozice");
 puts("Zacatek testu...");
 for (i=0; i<=300000; i++)
 {NalezTahy(uloha); uloha->zasobnik.hranice[0]=0; uloha->zasobnik.pos=0; }
 puts("Konec testu");
 (void) memset((void *) &(uloha->zasobnik), 0, sizeof(TZasobnikTahu));
}
void TiskniSachy(TUloha *uloha)
{printf("Bily %s v sachu.\n",Sach(1,&(uloha->pozice.sch[0])) ? "je" : "neni");
 printf("Cerny %s v sachu.\n",Sach(0,&(uloha->pozice.sch[0])) ? "je" : "neni");
}
void TahPocitace(TUloha *uloha)
{TTah1 t1;
 char str[20];
#ifdef Vypisy
 FILE *f;
 int i;
 
 if(VypSoubor[0]){
 f=fopen(VypSoubor,"w");
 if(!f){
	 puts("Nemohu otevrit soubor pro vystup !!");
	 f=stdout;
	 ABVH=0;
 }
 }
 else
 f=stdout;
#endif
 if (DejTah(uloha,&t1,Cas*1000,NULL
#ifdef Vypisy
,f
#endif
))
  {TahToStr(t1.data,uloha,str);
#ifdef Vypisy
#ifdef Statistika
   fputs("AB ",f);
   for(i=0;i<15;i++)
	   fprintf(f ,"%i ",AB[i]);
	   fputs("\n",f);
   fputs("PR ",f);
   for(i=0;i<15;i++)
	   fprintf(f ,"%i ",PR[i]);
	   fputs("\n",f);
	fputs("ABB ",f);
   for(i=0;i<15;i++)
	   fprintf(f ,"%i ",ABB[i]);
	   fputs("\n",f);
	 fputs("NTU ",f);
	for(i=0;i<15;i++)
	   fprintf(f ,"%i ",NTU[i]);
	   fputs("\n",f);
	fputs("NTN ",f);
	for(i=0;i<15;i++)
	   fprintf(f ,"%i ",NTN[i]);
	   fputs("\n",f);
	 fputs("HU ",f);
	for(i=0;i<15;i++)
	   fprintf(f ,"%i ",HU[i]);
	   fputs("\n",f);
	fprintf(f,"MS=%i\nUZ=%i,OH=%i,OH2=%i,OHP=%i,S2U=%i,S2N=%i\n",(int)MS,(int)UZ,(int)OH,(int)OH2,(int)OHP,(int)S2U,(int)S2N);
#endif
#endif
   printf("Pocitac tahne: %s\n",str);
   GlobTahni(true,uloha,true,(unsigned)t1.data);
   /*TiskniSachovnici(uloha);*/}
 else
  puts("Zadny pripustny tah !!!");
#ifdef Vypisy
if(VypSoubor[0]) fclose(f);
#endif
}
void OhodTest(TUloha *u){
	SectiMaterialBmCm(u);
	u->zasobnik.hPechF[0]=HashPechF(&(u->pozice));
    u->zasobnik.hPechG[0]=HashPechG(&(u->pozice));
	printf("Hodnota pozice (z pohledu %s) %i\n",(u->pozice.bily ? "bileho" : "cerneho"),(int)HodnotaPozice(u,-mat,mat));
}
void Uloz(TUloha *uloha){
	char s[256];

	puts("Jmeno souboru:");
	gets(s);
	if(UlozDoSouboru(s,uloha))
		puts("Partie ulozena"); else
		puts("Neuspech pri ukladani !");
}
void Otevri(TUloha *uloha){
	char s[256];

	puts("Jmeno souboru:");
	gets(s);
	if(OtevriZeSouboru(s,uloha))
		puts("Partie otevrena"); else
		puts("Neuspech pri otvirani !");
}
void HlavniDosCyklus(TUloha *uloha)
{char s[256];
 u16 tah;
 
 while(1)
 { (void) puts("Zadej prikaz (\'?\' znamena napoveda)");
   (void) gets(s);
   if (!strcmp(s,"ko")) break;
   if (!s[0]) continue;
   if (!strcmp(s,"?")) {(void) puts(HelpStr); continue;}
   if (!strcmp(s,"mv")){NastavVypisy();continue;}
   if (!strcmp(s,"np")) {DoneUlohu(&uloha);
		  uloha=InitUlohu(18,17);TiskniSachovnici(&(uloha->pozice),stdout); continue;}
   if (!strcmp(s,"zp")) {ZadejPozici(uloha);continue;};
   if (!strcmp(s,"of")) {OhodTest(uloha);continue;};
   if (!strcmp(s,"ta")) {TahPocitace(uloha);continue;};
   if (!strcmp(s,"tz")) {
    if (uloha->prt->l){ GlobTahniZpet(uloha);TiskniSachovnici(&(uloha->pozice),stdout);}
       else printf("Nelze se vratit nezahrane\n"); continue;};
   if (!strcmp(s,"td")) {
    if (uloha->prt->p){ GlobTahni(false,uloha,false);TiskniSachovnici(&(uloha->pozice),stdout);}
       else printf("Nelze se znovu zahrat nevracene\n"); continue;};
   if (!strcmp(s,"sa")) {TiskniSachovnici(&(uloha->pozice),stdout);continue;};
   if (!strcmp(s,"sc")) {TiskniSachy(uloha);continue;};
   if (!strcmp(s,"oh")) {TiskniOhrozeni(uloha);continue;};
   if (!strcmp(s,"ca")) {CasMysleni();continue;};
   if (!strcmp(s,"tg")) {TestujGenerator(uloha);continue;};
   if (!strcmp(s,"tc")) {TestujGeneratorCas(uloha);continue;};
   if (!strcmp(s,"ul")) {Uloz(uloha);continue;};
   if (!strcmp(s,"ot")) {Otevri(uloha);continue;};
   if (!strcmp(s,"ge")) {generujKDK();continue;};
   if (!strcmp(s,"mh")) {MazejHash(uloha);continue;};
   if (!strcmp(s,"ns")) {NalezTahyZeSachu(uloha);continue;};
   if (!strcmp(s,"va")) {InitVypocet(uloha);
    NalezBileVazby(uloha,uloha->material.bk);continue;};
   if (!strcmp(s,"hp")) {
   THashPech h;

    InitVypocet(uloha);
    NastavPesce(uloha,&h);
	continue;};
   if (!strcmp(s,"hr")) {
   InitVypocet(uloha);
   puts(HrozbaBilemuKraliDamou(uloha) ? "Ano" : "Ne");
   puts(HrozbaCernemuKraliDamou(uloha) ? "Ano" : "Ne");
   continue;}
   if(NalezTahy(uloha),JenPripustne(uloha),StrToTah(s,uloha,&tah))
    {if (KorektniTah(tah,uloha))  GlobTahni(true,uloha,true,(unsigned)tah);
       else printf("\"%s\" neni pripustny tah\n",s);
    TiskniSachovnici(&(uloha->pozice),stdout);continue;}
   printf("Neznamy prikaz nebo chybna notace tahu\n");
  }
}

#endif
/*od TypProduktu==DOS_UNIX*/

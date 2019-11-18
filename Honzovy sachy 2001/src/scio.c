/*********************************************************/
/* scio.c - projektove IO pres sockety                   */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include "volby.h"
#if Typ_Produktu==Projekt
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/timeb.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include "cotyvar.h"
#include "chyba.h"
#include "myslitel.h"
#include "generato.h"
#include "globruti.h"
#include "scio.h"
#define SCioLadim
#ifdef SCioLadim
#include "dosio.h"
#endif

char Host[256];
int Port;

#define KONEC 200
#define TAH 10
#define NABIDKA_REMIZY 11
#define O_NABIDKA_REMIZY 12
#define VZDAVAM 6
#define CHYBA 17
/*Typy zprav*/
#define ChNeniTah 1
#define ChNactiBuffer 2
#define ChNeznamaZprava 3
#define ChNepripustnaZprava 4
#define ChNepripustnyTah 5
#define ChHlavickaZpravy 6
/*Typy chybovych kodu*/
#define MaxDelkaMysleni 5000
/*Dele nikdy nebudu myslet - kvuli vytizeni serveru*/
TPrjData PrjData;

/*static bool PrvniTah=1;*/

FILE *GetPidFile(){
/*****************************************/
/* Otevre log soubor pro zapis na konec  */
/*****************************************/
 char s[20];
 sprintf(s,"pha%i.log",(int)getpid());
 return fopen(s,"a");
}

void SCioVypisString(char *str){
/**************************************************/
/* Ladici hlaska, pise na stdout a do log souboru */
/**************************************************/
 FILE *f;
 
 fputs("PHA:",stdout);
 puts(str);
 if(!(f=GetPidFile())) return;
 fputs(str,f);
 putc('\n',f);
 fclose(f);
}

static bool MojeAtoi(char *s, s32 *i){
/***********************************/
/* Normalni atoi je dost blba...   */
/***********************************/
	bool minus;
	int j;

	if(!i || !s || ((s[0]<'0' || s[0]>'9')&&s[0]!='-')) return false;
	*i=0;j=0;
	if(s[0]=='-'){minus=true;j++;} else minus=false;
	while(1){
		if(j>8 || s[j]>'9' || s[j]<'0')return false;
		(*i)*=10;
		(*i)+=s[j]-'0';
		j++;
		if(!s[j])break;
	}
	if(minus)*i=-*i;
	return true;
}

static bool SCioJsouData(int soket){
/************************************************/
/*Je mozno ze socketu pøeèíst aspoò jeden byte ?*/
/************************************************/
	fd_set mnoz;
	struct timeval cas;

	cas.tv_sec=1;
	cas.tv_usec=0;
	FD_ZERO(&mnoz);
	FD_SET(soket,&mnoz);
    return select(FD_SETSIZE, &mnoz, NULL, NULL, &cas)==1;
	
}

void PosliZpravu(u16 typ,...){
/*****************************************************************/
/* PosliZpravu(typ,sizeof(param1),&param1, .....,				 */
/* sizeof(paramn),&paramn,	0)									 */						
/* Zkonvertuje 4 a 2 bytové argumenty k poslání na formát sítì ! */
/*****************************************************************/
	va_list p;
	unsigned char buf[256];
	int i,j;
	void *ptr;
	
	*((s32 *)(buf))=-1-PrjData.typ; /* id hráèe*/
	*((u32 *)buf)=htonl(*((u32 *)buf));
	*((s32 *)(buf+4))=PrjData.cs; /* id stolku*/
	*((u32 *)(buf+4))=htonl(*((u32 *)(buf+4)));
	*((u16 *)(buf+8))=(u16)(typ+7000);
	*((u16 *)(buf+8))=htons(*((u16 *)(buf+8)));
	i=10;
	
	va_start(p,typ);
	while(1){
		j=va_arg(p,int);
		if(!j || j+i>=256) break;
		ptr=va_arg(p,void *);
		memcpy((void *)(buf+i),ptr,j);
		if(j==2) *((u16 *)(buf+i))=htons(*((u16 *)(buf+i)));else
		if(j==4) *((u32 *)(buf+i))=htonl(*((u32 *)(buf+i)));
		i+=j;
	}
	va_end(p);
	write(PrjData.soket,buf,i);
}
void PosliString(char *s){
 u16 *ws;
 u16 *dws;
 int i;
 u16 delka;
SCioVypis("Posilam string...");
 ws=(u16 *)malloc(2*(delka=strlen(s)));
 dws=ws;
 while(*s){
  *dws++=(u16)(*s++);
  *(dws-1)=htons(*(dws-1));
 } 
 i=-1-PrjData.typ;
 PosliZpravu(13,4,&i,2,&delka,0);
 write(PrjData.soket,ws,2*delka);
 free(ws);
}

void SCNactiArgumenty(int argc, char **argv){
/*******************************************/
/* Zpracovani argumentu - muze se ukoncit  */
/*******************************************/
 SCioVypis("Nacitam parametry...");
 if(argc<7) Chyba("Spatny pocet argumentu\n. Syntaxe: pha barva cp ct cs host port [obtiznost]");
 if(!strcmp(argv[1],"b"))PrjData.bily=true; else
 if(!strcmp(argv[1],"c"))PrjData.bily=false; else
 Chyba("Prvni parametr spatne !!!");
 if(!MojeAtoi(argv[2],&PrjData.cp) || (PrjData.cp<1)) Chyba("Druhy parametr spatne !!!");
  else PrjData.cp*=1000; /* z vterin na milisekundy */
 if(!MojeAtoi(argv[3],&PrjData.ct) || (PrjData.ct<0)) Chyba("Treti parametr spatne !!!");
	PrjData.ct*=1000; /* ze vterin na milisekundy */
 if(!MojeAtoi(argv[4],&PrjData.cs) || (PrjData.cs<0)) Chyba("Ctvrty parametr spatne !!!");
 strncpy(Host,argv[5],255);
 if(!MojeAtoi(argv[6],&Port) || (Port<6)) Chyba("Sesty parametr spatne !!!");
 if(argc>=8){
  if(!MojeAtoi(argv[7],&PrjData.typ) || PrjData.typ<1 || PrjData.typ>5) Chyba("Sedmy parametr spatne !!!");
  }
 else PrjData.typ=5;
 SCioVypis("Parametry jsou v poradku.");
 PrjData.cas=PrjData.cp;
 PrjData.PrijmiRemis=false;
#ifdef SCioLadim
 {
	 char s[250];
	 sprintf(s,"Cas na partii: %i ms, cas na tah: %i ms, obtiznost: %i",(int)PrjData.cp,(int)PrjData.ct,PrjData.typ);
	 SCioVypis(s);
 }
#endif
}

void SCOtevriSocket(void){
/***************************/
/* Otevreni socketu k PSH  */
/***************************/
struct servent *se;
struct hostent *ha;
struct sockaddr_in sa;

SCioVypis("Otviram socket k serveru...");
if(!(ha=gethostbyname(Host))) Chyba("gethostbyname()");
SCioVypis("gethostbyname() OK");
PrjData.soket=socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
if(PrjData.soket==-1)Chyba("socket()");
SCioVypis("socket() OK");
sa.sin_family=PF_INET;
sa.sin_port=Port;
memcpy(&sa.sin_addr.s_addr,ha->h_addr_list[0],ha->h_length);
if(connect(PrjData.soket,(struct sockaddr *)&sa,sizeof(sa))==-1)
Chyba("connect()");
SCioVypis("connect() OK");
SCioVypis("Socket uspesne otevren.");
/*PosliString("Ahoj");*/
}

void SCZavriSocket(void){
/**************************/
/* Zavreni socketu k PSH  */
/**************************/
	close(PrjData.soket);
	SCioVypis("Program zavira socket.");
}
static bool NactiBuffer(void *buf,int size){
/********************************************************/
/* Pro délku 2 nebo 4 konvertuje poøadí bytù !!         */
/* vrací true, naèten; false nenaèten nebo jen èásteènì */
/********************************************************/
	int i,j;

	i=0;
	while(i<size){
		j=read(PrjData.soket,(void *)(((char *)(buf))+i),size-i);
		if(!j){
			SCioVypis("Neuspech read v NactiBuffer");
			return false;
		}
		i+=j;
	}
	if(size==2)*((u16 *)buf)=ntohs(*((u16 *)buf));
	if(size==4)*((u32 *)buf)=ntohl(*((u32 *)buf));
	return true;
}
bool ZpravaDoBufferu(void *buf /*aspoò na 10 bytù!!*/){
/*************************************************************/
/* Naète zprávu (vèetne hlavièky) bez parametrù do bufferu.  */
/* Nepodaøí-li se, nebo je-li chybná hlavièka, pošle chybu,  */
/* zavolá pøíslušný SCioVypis() a vrati false                */
/*************************************************************/
	int ch;
	
		if(!NactiBuffer((void *)buf,10)) {
			ch=ChNactiBuffer;
			SCioVypis("Kriticka chyba. Nemohu nacist data ze socketu !!!");
			PosliZpravu(CHYBA,4,&ch,0);
			return false;}
		
		if(ntohl(*((u32 *)buf))!=0xFFFFFFFF || *((unsigned *)buf+1)){
/* Špatná hlavièka, mìly by tam být samé nuly*/
		   ch=ChHlavickaZpravy;
			SCioVypis("Kriticka chyba. Spatna hlavicka zpravy !!!");
			PosliZpravu(CHYBA,4,&ch,0);
			return false;
		}
		return true;
}
void SCCyklus(TUloha *u){
/*********************************/
/* Cyklus komunikace pres socket */
/*********************************/
	s32 DelkaMysleni,i;
	struct timeb tp,tp2;
	u16 zprava;
	TTah1 tah;
	u32 ch;
	unsigned char buf[20];
#ifdef SCioLadim
	char s[20];
#endif

	
	SCioVypis("Zacatek cyklu komunikace");
	while(1){
		if(u->pozice.bily==PrjData.bily){
			SCioVypis("Jsem na tahu.");
			ftime(&tp);
#ifdef SCioLadim
		{char sc[50];
		sprintf(sc,"ct=%i, cas=%i",(int)(PrjData.ct),(int)(PrjData.cas));
		SCioVypis(sc);
		}
#endif
			DelkaMysleni=(PrjData.ct+PrjData.cas/20);
			if(DelkaMysleni>MaxDelkaMysleni)DelkaMysleni=
			MaxDelkaMysleni-(rand()&1)*(MaxDelkaMysleni/5);
			if(DelkaMysleni>PrjData.cas)DelkaMysleni=PrjData.cas;
#ifdef SCioLadim
			{
			char sc[20];

			sprintf(sc,"Budu myslet %i ms.",(int)DelkaMysleni);
			SCioVypis(sc);
			}
#endif
			SCioVypis("Premyslim...");
			if(!DejTah(u,&tah,DelkaMysleni,&(PrjData.PrijmiRemis))){
				/* Mam táhnout, ale neni pripustny tah */
				ch=ChNeniTah;
				SCioVypis("Kriticka chyba. Neni pripustny tah !!!");
				PosliZpravu(CHYBA,4,&ch,0);
				break;
			}
			ftime(&tp2);
			DelkaMysleni=(tp2.time-tp.time)*1000+tp2.millitm-tp.millitm; 
#ifdef SCioLadim
			NalezTahy(u);
			TahToStr(tah.data,u,s);
			SCioVypis(s);
#endif
			
			if(SCioJsouData(PrjData.soket)){
/* V prubehu mysleni mi dosla
	a) nabidka remizy
	b) prikaz k ukonceni
*/
			SCioVypis("Neco mi prislo kdyz jsem premyslel.");

		if(!ZpravaDoBufferu(buf)) break;
		switch(ntohs((*((u16 *)(buf+8))))-6000){
			/*To by mìlo být èíslo zprávy.*/
		case KONEC:
			SCioVypis("Pry se mam sam ukoncit.");
			goto ven;
		case NABIDKA_REMIZY:
			SCioVypis("Prisla mi nabidka remizy.");
			if(PrjData.PrijmiRemis){
			SCioVypis("Prijimam remizu");
			PosliZpravu(O_NABIDKA_REMIZY,1,"\001",0);
			}
			else
			{
			SCioVypis("Odmitam remizu");
			PosliZpravu(O_NABIDKA_REMIZY,1,"\000",0);
			}
			break;
		case TAH:
			SCioVypis("Kriticka chyba. Souper hraje, kdyz neni na tahu.");
			ch=ChNepripustnaZprava;
			PosliZpravu(CHYBA,4,&ch,0); 
			goto ven;
		default:
			SCioVypis("Kriticka chyba. Prisla mi neznama zprava.");
			ch=ChNeznamaZprava;
			PosliZpravu(CHYBA,4,&ch,0); 
			goto ven;
		} /* od switch*/
			} /* od Nìco mi pøišlo*/
			PosliZpravu(TAH,2,&(tah.data),4,&(DelkaMysleni),0);
			SCioVypis("Poslal jsem tah");
		/*	if(PrvniTah){PrvniTah=false; PosliString("Ahoj");}*/
			PrjData.cas-=DelkaMysleni;
			PrjData.cas+=PrjData.ct;
			GlobTahni(false,u,true,(unsigned)tah.data);
			/*
			- to je asi uz zbytecny vypis
#ifdef SCioLadim
			TiskniSachovnici(&(u->pozice));
			puts("Muzes hrat");
			TestujGenerator(u);
#endif
*/
		} /* od jsem na tahu*/
		SCioVypis("Cekam na zpravu...");
		if(!ZpravaDoBufferu((void *)buf)) break;
		
		switch(ntohs((*((u16 *)(buf+8))))-6000){
			/*To by mìlo být èíslo zprávy.*/
		case KONEC:
			SCioVypis("Pry se mam sam ukoncit.");
			goto ven;
		case NABIDKA_REMIZY:
			SCioVypis("Prisla mi nabidka remizy.");
			if(PrjData.PrijmiRemis){
			SCioVypis("Prijimam remizu");
			PosliZpravu(O_NABIDKA_REMIZY,1,"\001",0);
			}
			else
			{
			SCioVypis("Odmitam remizu");
			PosliZpravu(O_NABIDKA_REMIZY,1,"\000",0);
			}
			break;
		case TAH:

			SCioVypis("Prisel mi tah");
			if(!NactiBuffer((void *)&(tah.data),2)||!NactiBuffer((void *)&(DelkaMysleni),4))
			{
				SCioVypis("Kriticka chyba. Nemohu nacist data ze socketu !!!");
				ch=ChNactiBuffer;
				PosliZpravu(CHYBA,4,&ch,0);
				goto ven;
			}
			NalezTahy(u);
			JenPripustne(u);
			if(!KorektniTah(tah.data,u)){
				SCioVypis("Kriticka chyba. Dostal jsem nepripustny tah !!!");
				ch=ChNepripustnyTah;
				PosliZpravu(CHYBA,4,&ch,0);
				goto ven;
			}
#ifdef SCioLadim
			TahToStr(tah.data,u,s);
			SCioVypis(s);
#endif
			GlobTahni(false,u,true,(unsigned)tah.data);
			PrjData.soupcas+=PrjData.cp;
			PrjData.soupcas-=DelkaMysleni;
			break;
		default:
			SCioVypis("Kriticka chyba. Prisla mi neznama zprava.");
			ch=ChNeznamaZprava;
			PosliZpravu(CHYBA,4,&ch,0); 
			goto ven;
		}
	} /* od while cyklu*/
ven:;
	SCioVypis("Program opousti hlavni smycku");
}
#endif

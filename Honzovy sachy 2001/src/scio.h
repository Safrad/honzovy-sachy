/*********************************************************/
/* scio.h - projektove IO pres sockety                   */
/* 6.1. 2000 Jan Nemec                                   */
/*********************************************************/
#ifndef scioH
#define scioH
#include "volby.h"
#if Typ_Produktu!=Projekt
#error Inkludovat scio.h jen pokud kompiluji na projekt
#endif
#include "cotyvar.h"

typedef struct{
	bool bily; /*Za koho hraji*/
	int cp,ct,cs;
/* Výchozí èas na partii a na tah v milisekundách a èíslo stolku*/
	int cas,soupcas; 
/*Za jak dlouho (milisekundy) me a souperi spadne praporek, když nepotáhneme */
	int soket;
	int typ;/*
	uzivatelem pozadovana kvalita hry programu
	 1 - sekretarka
	 2 - normal
	 3 - prumer
	 4 - Honza
	 5 - Nadhonza
	*/
	bool PrijmiRemis;
} TPrjData;
extern TPrjData PrjData;
void SCNactiArgumenty(int argc,char **argv);
/*******************************************/
/* Zpracovani argumentu - muze se ukoncit  */
/*******************************************/
void SCCyklus(TUloha *u);
/*********************************/
/* Cyklus komunikace pres socket */
/*********************************/
void SCOtevriSocket(void);
/***************************/
/* Otevreni socketu k PSH  */
/***************************/
void SCZavriSocket(void);
/**************************/
/* Zavreni socketu k PSH  */
/**************************/
void SCioVypisString(char *str);
/**************************************************/
/* Ladici hlaska, pise na stdout a do log souboru */
/**************************************************/

/*#define SCioLadim*/

#ifdef SCioLadim
#define SCioVypis(X) SCioVypisString(X)
#else
#define SCioVypis(X)
#endif

#endif


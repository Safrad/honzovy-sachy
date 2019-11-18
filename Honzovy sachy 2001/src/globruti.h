/*********************************************************/
/* globruti.h - globalni sachove rutiny                  */
/* napr. zahrani a vraceni tahu v partii                 */ 
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef globrutiH
#define globrutiH
#include "volby.h"
#include "cotyvar.h"
#define LadeniGlobruti 100
void GlobTahni(bool TestKonce, TUloha *uloha, bool useknout, ...);
/***********************************************************************/
/*  GlobTahni - Tah v partii (nikoliv v propoctu)                      */
/*  na zasobnik ani nesahne                                            */
/*  je-li useknout true, je dalsim parametrem u16 - ktery ze se to     */
/*  ma zahrat tah - a tim se taky preplacne pripadny ocas partie       */
/*  je-li useknout false, nejsou zadne dalsi parametry, jde o          */
/*  znovuzahrani vraceneho tahu - ten se nacte z partie, ta se posune  */
/*  o 1 doprava, ocas se nemaze                                        */
/*  Je-li TestKonnce true, otestuje se, neskonèila-li partie.          */
/***********************************************************************/
void GlobTahniZpet(TUloha *uloha);
/***************************************************************************/
/*   GlobTahniZpet - Tahne zpet v partii (Nikoliv v propoctu)              */
/*   Posune se v partii o 1 doleva, ocas nemaze, na zasobnik ani nesahne   */
/***************************************************************************/
bool KorektniTah(u16 tah, TUloha *uloha);
/*************************************************************************/
/*  KorektniTah - je to pripustny tah ?                                  */
/*  Zvedne uroven zasobniku, nalezne tahy, vyskrta nepripustne,          */
/*  pokusi se tam ten tah najit a nakonec snizi uroven zasobniku zpet.   */
/*************************************************************************/
bool KTNehledej(u16 tah, TUloha *uloha);
/*************************************************************************/
/*  KTNehledej -  Analogie KorektiTah, jen už vše musí být na zásobníku. */
/*  Ze zásobníku pouze ète.												 */
/*************************************************************************/
void JenPripustne(TUloha *uloha);
/*************************************************************************
 *  JenPripustne - Vynda z prvni dle pos volne (ale v praxi obsazene)    *
 *  urovne zasobniku nepripustne tahy.                                   *
 *  tj. ty vedouci k sachu. Pomerne pomale, neuzivat v rekurzi propoctu. *
 *  Nastavi pocatek nove prazdne urovne (snizi nebo necha)               *
 *************************************************************************/
bool JeTam1(u8 odkud,TUloha *uloha);
/****************************************************/
/* Je mezi nalezenymi tahi nejaky vedouci z odkud ? */
/****************************************************/
bool JeTam2(u8 odkud,u8 kam,TUloha *uloha);
/***********************************************************/
/* Je mezi nalezenymi tahi nejaky vedouci z odkud do kam ? */
/***********************************************************/
#if Typ_Produktu==Win32_Program
#include <windows.h>
u16 DoplnTah(HWND hwnd,u8 odkud,u8 kam,TUloha *uloha);
/***************************************************/
/* Jen windows - pripadny dialog promeny pesce     */
/***************************************************/ 
#endif
int Remiza50Nebo3(TUloha *uloha);
/************************************************************************
*  Je remíza 50 tahy nebo 3x stejná pozice ?                            *
*  vrací 50, 3 nebo 0 (význam je jasný)                                 *
************************************************************************/

#define BilyVMatu 1
#define CernyVMatu 2
#define Remis3 3
#define Remis50 4
#define RemisBilyVPatu 5
#define RemisCernyVPatu 6
#define RemisMaloMaterialu 7
void ZjistiTypKoncePartie(TUloha *uloha);
/************************************************************************
 * Jak dopadla partie ? Nastaví správnì uloha->KonecPartie              *
 ************************************************************************/
#if Typ_Produktu==Win32_Program
extern char NazvyVysledku[8][38];
#endif
#endif


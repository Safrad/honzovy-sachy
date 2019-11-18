/**********************************************************/
/* hashtab.h - hash funkce pro tabulku ohodnocenych pozic */
/* 31.12. 2000 Jan Nemec                                  */
/**********************************************************/
#ifndef hashtabH
#define hashtabH
#include "volby.h"
#include "cotyvar.h"

typedef struct{
	u32 f[13][h8+1]; 
/* [od cerneho krale pres prazdne pole az po bileho krale][pole]*/
	u32 bily;
	u32 roch[16];
	u32 mimoch[h5+1];
}THashNahoda;
/* THashNahoda - obsahuje nahodna cisla pro vsechny dvojice
(typ kamene, pole), dale pro stav mimochodem, rosad a kdo
je na tahu*/

extern THashNahoda hnF;
extern THashNahoda hnG; /* Dve sady nahodnych cisel pro
dve funkce */
void HashInit(void);
/*********************************************************/
/* HashInit naplni koeficienty obou hashovacich funkci   */
/* pseudonahodnymi cisly                                 */
/* Vola se JEDNOU na zacatku celeho PROGRAMU             */
/*********************************************************/
u32 HashF(TPozice *pos);
u32 HashG(TPozice *pos);
/**********************************************************************/
/* HashF a HashG												      */
/* Hashovaci funkce, vrati hash kod pozice. Nevola se v rekursivnim   */
/* propoctu, ale jen jednou na zacatku propoctu. V rekursi se pocita  */
/* "inkementalne" postupnym xorovanim tahu.                           */
/* F urcuje pozici v tabulce, G cislo pro kontrolu                    */
/**********************************************************************/
void MazejHash(TUloha *u);
/***************************/
/* Vyprazdni Hash tabulku  */
/***************************/
bool GetHash(TUloha *uloha, s16 alfa, s16 beta, u8 hloubka, s16 *cena);
/**************************************************/
/* Je pozice v tabulce ? A jak je ohodnocena ?    */
/**************************************************/
void SetHash(TUloha *uloha, u8 hloubka, u8 priznak, s16 cena);
/*******************************/
/* Ulozi pozici do tabulky     */
/*******************************/
u32 HashPechF(TPozice *pos);
u32 HashPechG(TPozice *pos);
/*************************************************/
/* HashPechF a HashPechF                         */
/* 2 hash funkce struktury pescu                 */
/* (v rekurzi nevolat, pocita se inkrementalne)  */
/*************************************************/
bool GetPechHash(TUloha *uloha, THashPech **hp);
/********************************************************/
/* Je struktura pescu v tabulce ? A jak je ohodnocena ? */
/********************************************************/
void SetPechHash(TUloha *uloha, THashPech *hp);
/****************************************/
/* Ulozi strukturu pescu do tabulky     */
/****************************************/
#endif

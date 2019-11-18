/*********************************************************/
/* generato.h - generator tahu                           */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef generatoH
#define generatoH
#include "volby.h"
#include "cotyvar.h"
extern const s16 StdCenyFigur[7]; /* Kolik stoji napr. jezdec */
extern const s8 ofsety[16]; /* Jak figurky skacou */
void NalezTahy(TUloha *u);
/*******************************************************************************/
/* NalezTahy - generuje pseudolegalni (jako by se kral smel octnout v sachu)   */
/* tahy na zasobnik. Zacne na hranice[pos], pos nezvysi, ale na zaver          */
/* spravne nastavi hranice[pos+1]. Takze pokud to zavolam 2* po sobe,          */
/* ma to tentyz efekt, jako bych to zavolal 1*. Nastavi cenu tahu podle        */
/* zmeny materialu                                                             */
/*******************************************************************************/
void NalezBrani(TUloha *u);
/*******************************************************************************/
/* NalezBrani                                                                  */
/* Generuje vsechny pseudolegalni (jako kdyby kral mohl jit do sachu) brani    */
/* a promeny pesce v damu. Jinak obdoba NalezTahy                              */
/*******************************************************************************/
void NalezTahyZeSachu(TUloha *u);
/*****************************************************/
/* Nalezne legalni tahy, je-li hrac na tahu v sachu  */
/*****************************************************/
void SetridTahy(TUloha *uloha);
/************************************************************************/
/* Setridi aktualni uroven tahu na zasobniku podle cena+hitor. heur     */
/************************************************************************/
int PocetOhrozeni(s8 *p, bool bilym);
/****************************************/
/* Kolikrat je dane policko ohrozeno    */
/****************************************/
void NalezBileVazby(TUloha *u,int pole);
/*********************************************************/
/* Nalezne vsechny kameny bileho, ktere jsou             */
/* ve vazbe vuci poli pole. (Na poli je napr. bily kral) */
/*********************************************************/
#endif

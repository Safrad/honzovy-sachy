/*********************************************************/
/* ohodnoc.h - ohodnocovaci funkce                       */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef ohodnocH
#define ohodnocH
#include "volby.h"
#include "cotyvar.h"
s16 HodnotaPozice(TUloha *u,s16 alfa,s16 beta);
/*****************************************/
/* Vrati hodnotu pozice mezi alfa a beta */
/*****************************************/
void NastavAlgCfgStd(TAlgCfg *a);
/*************************************/
/* nastavi TAlgCfg na bezne hodnoty  */
/*************************************/
void ZasumAlgCfg(TAlgCfg *a, int sum);
/*************************************/
/* zasumi TAlgCfg (max zmena = sum)  */
/*************************************/
int Sum(int maxabs);
/***********************************************************/
/* Vrati nahodne cele cislo z intervalu (-maxabs,maxabs)   */
/* z rozdeleni, kde hustota linearne roste od -maxabs,     */
/* kde je 0 k 0, kde je nejvyssi a pak linearne klesa	   */
/* k maxabs, kde je nula. Jde o jakousi velmi spatnou	   */
/* aproximaci binomickeho rozdeleni.					   */
/***********************************************************/
extern s8 BelostPole[h8+1];
#endif

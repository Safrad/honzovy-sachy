/*********************************************************/
/* dosio.h - consolovy vstup a vystup                    */
/* 11.1. 2001 Jan Nemec                                  */
/*********************************************************/
#ifndef dosioH
#define dosioH
#include "volby.h"
#include <stdio.h>
#include "cotyvar.h"
void TestujGenerator(TUloha *uloha);
/*********************************************************/
/* Test generatoru tahu                                  */
/*********************************************************/
void TestujGeneratorCas(TUloha *uloha);
/*********************************************************/
/* Test rychlosti generatoru tahu                        */
/*********************************************************/
void TiskniSachy(TUloha *uloha);
/*********************************************************/
/* Test detekce sachu                                    */
/*********************************************************/
void TiskniSachovnici(TPozice *pos, FILE *f);
/*********************************************************/
/* Vytiskne aktualni pozice                              */
/*********************************************************/
void TahPocitace(TUloha *uloha);
/*********************************************************/
/* Volani mysliciho algoritmu a IO                       */
/*********************************************************/
void HlavniDosCyklus(TUloha *uloha);
/*********************************************************/
/* Rezim zadavani a plneni prikazu                       */
/*********************************************************/
#endif

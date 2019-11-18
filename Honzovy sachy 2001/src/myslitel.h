/*********************************************************/
/* myslitel.h - rekurzivni propocet (alfabeta)           */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef myslitelH
#define myslitelH
#include "volby.h"
#ifdef Vypisy
#include <stdio.h>
#endif
#include "cotyvar.h"
extern bool MamKnihovnu;
/*Sem pri inicializaci nastavim, zda jsem uspesne nalezl
knihovnu zahajeni*/
bool DejTah(TUloha *uloha,TTah1 *t1,u32 cas, bool *PrijmiRemis
#ifdef Vypisy
, FILE *soub
#endif
);
/**************************************************************************/
/*  Dejtah - Myslici algoritmus (jeho volani)
/* cas je v ms
/* PrijmiRemis muze byt NULL. Jinak tam pha da, zda by prijal remizu      */
/***************************************************************************/
void UlozStav(TUloha *uloha);
/***************************************************************************
*   UlozStav - ulozi stav mimochodem a rosad na zasobnik do pos            *
 *   s pos nic nedela                                                      *
 ***************************************************************************/
void SectiMaterialBmCm(TUloha *uloha);
/*************************************************/
/* Nastavi podle aktualni pozice polozky		 */
/* uloha->zasobnik.bm[0], uloha->zasobnik.cm[0]  */
/* a uloha->material							 */
/*************************************************/
void SectiJenMaterial(TUloha *uloha);
/*********************************************************/
/* Nastavi podle aktualni pozice polozky uloha->material */
/*********************************************************/
void InitVypocet(TUloha *uloha);
/**********************************************************/
/* Inicializace pred zahajenim rekurzivniho propoctu      */
/* vola se z DejTah										  */
/**********************************************************/
#ifdef Statistika
extern u32 
    NTU[MaxHloubkaPropoctu],
    NTN[MaxHloubkaPropoctu],
	MS,
	OH,
	OH2,
	OHP,
	UZ,
	S2U,S2N,
	AB[MaxHloubkaPropoctu],
	PR[MaxHloubkaPropoctu],
	ABB[MaxHloubkaPropoctu],
	HU[MaxHloubkaPropoctu];
#endif
#endif

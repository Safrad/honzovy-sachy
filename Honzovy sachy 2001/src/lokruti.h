/*********************************************************/
/* lokruti.h - Test sachu ohrozeni a lokalni             */
/* (tj. nikoliv v partii) tahy                           */
/* 6.1. 2001 Jan Nemec                                   */
/*********************************************************/
#ifndef lokrutiH
#define lokrutiH
#include "cotyvar.h"
bool Ohrozeno(s8 *p, bool bilym);
/***************************************************/
/**  Ohrozeno   Je dane policko ohrozene ?        **/
/***************************************************/
bool Sach(bool komu, s8 *sch);
/*************************************************************************/
/*   Sach je komu v sachu ?                                              */
/*   sch - pointr na 1. policko sachovnice 12*10 (tedy nikoliv a1)       */
/*************************************************************************/
bool HrozbaBilemuKraliDamou(TUloha *u);
bool HrozbaCernemuKraliDamou(TUloha *u);
void JednoTahni(u16 tah, TUloha *uloha);
/***************************************************************************
 *   JednoTahni - Tahne v testu pripustnosti tahu                          *
 *   Na zasobnik ulozi jen udaje pro TahniZpet a hodpos,
 *   nic nepocita, ani hash funkce												       *
 ***************************************************************************/
void JednoTahniZpet(u16 tah, TUloha *uloha);
/***************************************************************************/
/* Opacna funkce k JednoTahni                                              */
/***************************************************************************/
void Tahni(u16 tah, TUloha *uloha);
/***************************************************************************
 *   Tahni - Tahne v propoctu (Nikoliv v partii)                           *
 *   Ulozi na zasobnik sebranou figuru a potom zvedne pos o 1              *
 ***************************************************************************/
void TahniZpet(u16 tah, TUloha *uloha);
/*************************************************************************
 *   TahniZpet - Tahne zpet v propoctu (Nikoliv v partii)                *
 *    V zasobniku nejprve snizi pos o 1 a pak cte z urovne pos           *
**************************************************************************/
#endif


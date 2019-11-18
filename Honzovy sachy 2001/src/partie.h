/*********************************************************/
/* partie.h - prace s partii - seznamem tahu             */
/* 1.6. 2000 Jan Nemec                                   */
/*********************************************************/
#ifndef partieH
#define partieH
#include "volby.h"
#include "cotyvar.h"
#define LadeniPartie 100
void DonePartie(TPartie **prt);
/*******************************/
/* Smaze spojak a da tam NULL  */
/*******************************/
void InitPartie(TPartie **prt, TPozice *pos);
/*******************************/
/* Udela novou partii          */
/*******************************/
int PocetPultahu(TPartie *prt);
/*******************************/
/* PocetPultahu (vlevo+vpravo) */
/*******************************/
int VlevoPocetPultahu(TPartie *prt);
/*******************************/
/* PocetPultahu (vlevo)        */
/*******************************/
void PridejTah(TPartie **prt, TPartData data);
/***********************/
/* Novy tah do partie  */
/***********************/
#endif

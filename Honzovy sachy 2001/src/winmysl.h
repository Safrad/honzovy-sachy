/*********************************************************/
/* winmysl.c - okno s myslicimi vypisy - jen windows     */
/* 13.1. 2001 Jan Nemec                                  */
/*********************************************************/
#ifndef winmyslH
#define winmyslH
#include "volby.h"
#if Typ_Produktu!=Win32_Program
#error Pouze pro wokna
#endif
#include <windows.h>
#include "cotyvar.h"

extern HWND HandlePartiare;
void ZobrazVypisy(HWND otec);
void InitTriduVypisu(void);
void VypAktualizujTah(TUloha *u,u16 t);
void VypAktualizujNejlepsi(TUloha *u,u16 t);
void VypAktualizujHloubku(TUloha *u,int h);
void VypAktualizujCenu(TUloha *u,s16 c);
#endif

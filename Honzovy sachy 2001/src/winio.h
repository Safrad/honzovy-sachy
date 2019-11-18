/*********************************************************/
/* winio.h - IO interaktivni verze pro Windows           */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef winioH
#define winioH
#include "cotyvar.h"
extern s8 Oznaceno;
extern TSch KSachovnice;
extern volatile bool Myslim;
void WinTiskniFiguru(HDC KamDC,HDC BMPDC,int f,int x,int y);
void WinTiskniPole(HDC KamDC,HDC BMPDC,int cerne,int oznacene,int x,int y);
void WinTiskniSachovnici(HDC DC, int x, int y, TSch *sch);
void WinTiskniTah(HWND hwnd, u16 tah);
void ZobrazTahy(HWND hwnd, TUloha *uloha);
void TiskniNPoli(HWND hwnd,...);
#endif


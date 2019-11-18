/*********************************************************/
/* winmain.h - modul obsahujici WinMain - jen Windows    */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef winmainH
#define winmainH
#include "volby.h"
#include "cotyvar.h"
#define WM_PripravTah WM_USER
#define WM_HrajTah (WM_USER+1)
/* LOWORRD(wParam) je tah */
typedef struct
{
 bool BilyHrajeNahoru,BilyClovek,CernyClovek;
 unsigned PosunSchX,PosunSchY;
 u32 CasBileho, CasCerneho;
 COLORREF BarvaPozadi;
 COLORREF BarvyUzivatele[16];
} TWinNastaveni;
extern TWinNastaveni Nastaveni;
extern HBITMAP hFigury;
extern HBITMAP hPole;
extern TUloha *uloha;
extern HINSTANCE hInstance;
extern HWND HlavniOkno;
#endif

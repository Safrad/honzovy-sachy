/*********************************************************/
/* partiar.h - okno s partiarem - jen windows            */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef partiarH
#define partiarH
#include "volby.h"
#if Typ_Produktu!=Win32_Program
#error Pouze pro wokna
#endif
extern HWND HandlePartiare;
void ZobrazPartiar(HWND otec);
void InitTriduPartiare(void);
void ZmenPartiar(TUloha *uloha);
#endif

/*********************************************************/
/* pgn.h - export do formatu pgn                         */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef pgnH
#define pgnH
#include "volby.h"
#include "cotyvar.h"
typedef struct {
 char *event;
 char *site;
 int rok, mesic, den; /*[Date "2000.12.4"]*/
 int round;
 char *white;
 char *black;
 int whiteelo;
 int blackelo;
 int result; /*"0,1,2;  "1-0","1/2-1/2","0-1"*/
 int eco; /* "B17  jako 217*/
 char *annotator;
 int plycount;
} TPGNInfo;

#if Typ_Produktu==Win32_Program
bool DialogPGN(HWND otec, TPGNInfo *p);
#endif
void InitPGN(TPGNInfo *p);
void DonePGN(TPGNInfo *p);
bool UlozDoPGN(char *jmeno,TUloha *u,TPGNInfo *pgn);
#endif


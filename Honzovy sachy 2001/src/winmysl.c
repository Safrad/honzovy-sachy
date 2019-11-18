/*********************************************************/
/* winmysl.c - okno s myslicimi vypisy - jen windows     */
/* 13.1. 2001 Jan Nemec                                  */
/*********************************************************/
#include "volby.h"
#if Typ_Produktu==Win32_Program
#include <windows.h>
#include <string.h>
#include <stdio.h>
#include "cotyvar.h"
#include "winmain.h"
#include "strtah.h"

static WNDCLASS TridaVypisu;
static HWND HandleVypisu, sh,sn,sc, st;
#define NazevTridyVypisu "Výpisy"
#define VypRozmerX 300
#define VypRozmerY 130
int zx,zy;


LRESULT CALLBACK VypisyWinProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {switch(uMsg){
   case WM_CLOSE:HandleVypisu=0;
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
   default: return DefWindowProc(hwnd, uMsg, wParam, lParam);
  }
 }
#define StylOkna WS_POPUP|WS_CAPTION|WS_VISIBLE

 void ZobrazVypisy(HWND otec)
 {RECT r2;
  
  r2.left=360;
  r2.top=120+VypRozmerY;
  r2.right=360+VypRozmerX;
  r2.bottom=120+2*VypRozmerY;
  AdjustWindowRect(&r2,StylOkna,FALSE);
  HandleVypisu=CreateWindow (NazevTridyVypisu,"Myslící výpisy",
                StylOkna,
                r2.left,r2.top,r2.right-r2.left+1,r2.bottom-r2.top+1,
				otec,0, hInstance, NULL);
  zx=20;zy=20;
  CreateWindow ("STATIC","Hloubka:", WS_CHILD|WS_VISIBLE,
                10,10,VypRozmerX/5,zy*2,
				HandleVypisu,0, hInstance, NULL);
  sh=CreateWindow ("STATIC","", WS_CHILD|WS_VISIBLE,
                10+VypRozmerX/4,10,VypRozmerX/5,zy*2,
				HandleVypisu,0, hInstance, NULL);
  CreateWindow ("STATIC","Poèítám:", WS_CHILD|WS_VISIBLE,
                10+VypRozmerX/2,10,VypRozmerX/5,zy*2,
				HandleVypisu,0, hInstance, NULL);
  st=CreateWindow ("STATIC","", WS_CHILD|WS_VISIBLE,
                10+(VypRozmerX*3)/4,10,VypRozmerX/5,zy*2,
				HandleVypisu,0, hInstance, NULL);
  CreateWindow ("STATIC","Nejlepší:", WS_CHILD|WS_VISIBLE,
                10,10+zy*2,200,zy*2,
				HandleVypisu,0, hInstance, NULL);
  sn=CreateWindow ("STATIC","", WS_CHILD|WS_VISIBLE,
                10+VypRozmerX/4,10+zy*2,VypRozmerX/5,zy*2,
				HandleVypisu,0, hInstance, NULL);
  CreateWindow ("STATIC","Cena:", WS_CHILD|WS_VISIBLE,
                10+VypRozmerX/2,10+zy*2,VypRozmerX/5,zy*2,
				HandleVypisu,0, hInstance, NULL);
  sc=CreateWindow ("STATIC","", WS_CHILD|WS_VISIBLE,
                10+(VypRozmerX*3)/4,10+zy*2,VypRozmerX/5,zy*2,
				HandleVypisu,0, hInstance, NULL);

 }

void VypAktualizujTah(TUloha *u,u16 t){
 char s[20];

 TahToStr(t,u,s);
 SendMessage(st,WM_SETTEXT,0,(LPARAM)s);
}
void VypAktualizujNejlepsi(TUloha *u,u16 t){
 char s[20];

 TahToStr(t,u,s);
 SendMessage(sn,WM_SETTEXT,0,(LPARAM)s);
}
void VypAktualizujHloubku(TUloha *u,int h){
 char s[20];

 sprintf(s,"%i",h);
 SendMessage(sh,WM_SETTEXT,0,(LPARAM)s);
}
void VypAktualizujCenu(TUloha *u,s16 c){
 char s[20];

 sprintf(s,"%i",(int)c);
 SendMessage(sc,WM_SETTEXT,0,(LPARAM)s);
}
void InitTriduVypisu(void)
 {
   TridaVypisu.style=0;
   TridaVypisu.lpfnWndProc=VypisyWinProc;
   TridaVypisu.cbClsExtra=0;
   TridaVypisu.cbWndExtra=0;
   TridaVypisu.hInstance=hInstance;
   TridaVypisu.hIcon=NULL;
   TridaVypisu.hCursor=LoadCursor(NULL,IDC_ARROW);
   TridaVypisu.hbrBackground=GetStockObject(LTGRAY_BRUSH);
   TridaVypisu.lpszMenuName=NULL;
   TridaVypisu.lpszClassName=NazevTridyVypisu;
   RegisterClass(&TridaVypisu);
  }
#endif

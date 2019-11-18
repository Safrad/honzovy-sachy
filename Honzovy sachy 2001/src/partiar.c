/*********************************************************/
/* partiar.c - okno s partiarem - jen windows            */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include "volby.h"
#if Typ_Produktu==Win32_Program
#include <windows.h>
#include <string.h>
#include <stdio.h>
#include "cotyvar.h"
#include "winmain.h"
#include "partie.h"
#include "partiar.h"

static WNDCLASS TridaPartiare;
static HWND HandlePartiare;
#define NazevTridyPartiare "Partiáø"
#define PrtRozmerX 300
#define PrtRozmerY 130

static HWND Tahy[3];

void ZmenPartiar(TUloha *uloha){
	int i;
	char tahy[3][15];
	TPartie *p;

	if(!HandlePartiare)return;
	p=uloha->prt;
	for (i=0;i<3;i++){
		tahy[i][0]=0;
		if(p&&p->l){sprintf(tahy[i],"%s%i.%s %s",
			((uloha->pozice.bily+i)&1)?"\t":"",
			(VlevoPocetPultahu(uloha->prt)-i+1)/2,
			((uloha->pozice.bily+i)&1)?"..":"",
			p->data.nazev);p=p->l;}
		
		SendMessage(Tahy[2-i],WM_SETTEXT,0,(LPARAM)tahy[i]);
	}
}

LRESULT CALLBACK PartiarWinProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {switch(uMsg){
   case WM_CLOSE:HandlePartiare=0;
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
//   case WM_PAINT: return wmpaint(hwnd);
   default: return DefWindowProc(hwnd, uMsg, wParam, lParam);
  }
 }
#define StylOkna WS_POPUP|WS_CAPTION|WS_VISIBLE
 void ZobrazPartiar(HWND otec)
 {RECT r,r2;
 int i;
  
  GetWindowRect(otec,&r);
  r2.left=360;
  r2.top=80;
  r2.right=360+PrtRozmerX;
  r2.bottom=80+PrtRozmerY;
  AdjustWindowRect(&r2,StylOkna,FALSE);
  HandlePartiare=CreateWindow (NazevTridyPartiare,"Partiáø",
                StylOkna,
                r2.left,r2.top,r2.right-r2.left+1,r2.bottom-r2.top+1,
				otec,0, hInstance, NULL);
 for(i=0;i<3;i++)Tahy[i]=CreateWindow(
    "STATIC",	// address of registered class name
    "bleble",	// address of window name
    WS_VISIBLE | WS_CHILD,	// window style
    10,	// horizontal position of window
    10+40*i,	// vertical position of window
    PrtRozmerX,	// window width
    30,	// window height
    HandlePartiare,	// handle of parent or owner window
    NULL,	// handle of menu or child-window identifier
    hInstance,	// handle of application instance
    NULL 	// address of window-creation data
   );
 }

void InitTriduPartiare(void)
 {
   TridaPartiare.style=0;
   TridaPartiare.lpfnWndProc=PartiarWinProc;
   TridaPartiare.cbClsExtra=0;
   TridaPartiare.cbWndExtra=0;
   TridaPartiare.hInstance=hInstance;
   TridaPartiare.hIcon=NULL;
   TridaPartiare.hCursor=LoadCursor(NULL,IDC_ARROW);
   TridaPartiare.hbrBackground=GetStockObject(LTGRAY_BRUSH);
   TridaPartiare.lpszMenuName=NULL;
   TridaPartiare.lpszClassName=NazevTridyPartiare;
   RegisterClass(&TridaPartiare);
  }
#endif

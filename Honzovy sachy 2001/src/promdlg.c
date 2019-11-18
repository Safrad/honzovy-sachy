/*********************************************************/
/* promdlg.c - dialog promeny pesce - jen windows        */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#include "volby.h"
#if Typ_Produktu==Win32_Program
#include <windows.h>
#include "winmain.h"
#include "winio.h"
#include "PromDlg.h"
#define NazevTridyDialogu "Dialog promìny"
#define DlgRozmerX 160
#define DlgRozmerY 40
WNDCLASS TridaDialogu;
/* Tøída oken vzhledem podobným dialogu */
HWND GlobOtec;
int GlobBarva,GlobVysl;
volatile int Kliknul;

static LRESULT wmpaint(HWND hwnd)
 {HDC dc,FDC,PDC;
  PAINTSTRUCT ps;
  int i;
  HBITMAP bm1,bm2;

  dc=BeginPaint(hwnd,&ps);
  FDC=CreateCompatibleDC(dc);
  bm1=SelectObject(FDC,hFigury);
  PDC=CreateCompatibleDC(dc);
  bm2=SelectObject(PDC,hPole);
  for (i=0;i<=3;i++)
   {
    WinTiskniPole(dc,PDC,i&1,0,40*i,0);
    WinTiskniFiguru(dc,FDC,GlobBarva ? 5-i : i-5,40*i+2,2);
   }
  EndPaint(hwnd,&ps);
  SelectObject(FDC, bm1);
  SelectObject(PDC, bm2);
  DeleteDC(FDC);
  DeleteDC(PDC);
  return 0;
 }
LRESULT CALLBACK PromenaWinProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {switch(uMsg){
    case WM_PAINT: return wmpaint(hwnd);
   case WM_LBUTTONDOWN:
    Kliknul=1;
    GlobVysl=(3-LOWORD(lParam)/40)&3;
    PostMessage(hwnd,WM_CLOSE,0,0);
    return 0;
	case WM_CLOSE: if(Kliknul){
	 EnableWindow(GlobOtec,TRUE);
	 DestroyWindow(hwnd); 
	 }return 0;
   default: return DefWindowProc(hwnd, uMsg, wParam, lParam);
  }
 }

void InitTriduDialogu(void)
 {
   TridaDialogu.style=0;
   TridaDialogu.lpfnWndProc=PromenaWinProc;
   TridaDialogu.cbClsExtra=0;
   TridaDialogu.cbWndExtra=0;
   TridaDialogu.hInstance=hInstance;
   TridaDialogu.hIcon=NULL;
   TridaDialogu.hCursor=LoadCursor(NULL,IDC_ARROW);
   TridaDialogu.hbrBackground=GetStockObject(WHITE_BRUSH);
   TridaDialogu.lpszMenuName=NULL;
   TridaDialogu.lpszClassName=NazevTridyDialogu;
   RegisterClass(&TridaDialogu);
  }
#define StylOkna WS_POPUP|WS_CAPTION|WS_DLGFRAME|WS_VISIBLE
 int DialogPromeny(HWND otec, int bily)
 {RECT r,r2;
  MSG msg;

  GlobVysl=3;/*Dáma*/
  GlobOtec=otec;
  GlobBarva=bily;
  GetWindowRect(otec,&r);
  r2.left=(r.left+r.right-DlgRozmerX)/2;
  r2.top=(r.top+r.bottom-DlgRozmerY)/2;
  r2.right=r2.left+DlgRozmerX;
  r2.bottom=r2.top+DlgRozmerY;
  AdjustWindowRect(&r2,StylOkna,FALSE);
  CreateWindow (NazevTridyDialogu,"Tak co to bude ?",
                StylOkna,
                r2.left,r2.top,r2.right-r2.left+1,r2.bottom-r2.top+1,
				otec,0, hInstance, NULL);
  EnableWindow(otec,FALSE);
  Kliknul=0;
  while (GetMessage(&msg, NULL, 0, 0)==1)
  {TranslateMessage(&msg);
   DispatchMessage(&msg);
   if (Kliknul) break;
  }

  return GlobVysl;

 }
#endif

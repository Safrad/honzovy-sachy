#include "volby.h"
#if Typ_Produktu==Win32_Program
#include <windows.h>
#include <math.h>
#include <string.h>
#include "cotyvar.h"
#include "winmain.h"
#include "winio.h"
#include "partiar.h"
#include "partie.h"
#include "kontrola.h"

#define NazevTridyOkna "Okno pozice"
#define OknoRozmerX (460+100)
#define OknoRozmerY 440
#define SchX 10
#define SchY 10
#define FGRX 370
#define FGRY 10

int zx,zy;

WNDCLASS TridaOkna;

HWND GlobOtec,OProm,bok,bzrusit,bprazdna,cbily,
     cmb,cvb,cmc,cvc,Grupac,Automat;
TPozice GlobPozice;
s8 fig=1;

static void NastavXYZnaku(int *x,int *y,HDC dc){
TEXTMETRIC tm;
 GetTextMetrics(dc,&tm); 
 *x=tm.tmAveCharWidth;
 *y=tm.tmHeight;
}
static void KliklNaTypy(x,y){
HDC dc,FDC,PDC;
HBITMAP bm1,bm2;

dc=GetDC(OProm);
FDC=CreateCompatibleDC(dc);
bm1=SelectObject(FDC,hFigury);
PDC=CreateCompatibleDC(dc);
bm2=SelectObject(PDC,hPole);
if(fig){
WinTiskniPole(dc,PDC,(abs(fig)+!!(fig<0))&1,0,FGRX+40*!!(fig<0),40*abs(fig)+FGRY);
WinTiskniFiguru(dc,FDC,fig,2+FGRX+40*!!(fig<0),2+40*abs(fig)+FGRY); 
}
else{
WinTiskniPole(dc,PDC,0,0,FGRX,FGRY);
WinTiskniPole(dc,PDC,1,0,FGRX+40,FGRY);
}
fig=y/40;
if(x>=40)fig=-fig;
if(fig){
WinTiskniPole(dc,PDC,(abs(fig)+!!(fig<0))&1,1,FGRX+40*!!(fig<0),40*abs(fig)+FGRY);
WinTiskniFiguru(dc,FDC,fig,2+FGRX+40*!!(fig<0),2+40*abs(fig)+FGRY); 
}
else{
WinTiskniPole(dc,PDC,0,1,FGRX,FGRY);
WinTiskniPole(dc,PDC,1,1,FGRX+40,FGRY);
}
ReleaseDC(OProm,dc);
SelectObject(FDC,bm1);
SelectObject(PDC,bm2);
DeleteDC(FDC);
DeleteDC(PDC);
}

void NastavCheckboxy(bool PodlePuvodniPozice){
 SendMessage(Automat,BM_SETCHECK,(WPARAM)(BST_CHECKED),0);
 if(PodlePuvodniPozice){
 SendMessage(cbily,BM_SETCHECK,(WPARAM)((GlobPozice.bily)?BST_CHECKED:BST_UNCHECKED),0);
 SendMessage(cmb,BM_SETCHECK,(WPARAM)((GlobPozice.roch&1)?BST_CHECKED:BST_UNCHECKED),0);
 SendMessage(cvb,BM_SETCHECK,(WPARAM)((GlobPozice.roch&2)?BST_CHECKED:BST_UNCHECKED),0);
 SendMessage(cmc,BM_SETCHECK,(WPARAM)((GlobPozice.roch&4)?BST_CHECKED:BST_UNCHECKED),0);
 SendMessage(cvc,BM_SETCHECK,(WPARAM)((GlobPozice.roch&8)?BST_CHECKED:BST_UNCHECKED),0);
 }
 else{
 SendMessage(cmb,BM_SETCHECK,(WPARAM)((GlobPozice.sch[e1]==6 && GlobPozice.sch[h1]==4)?BST_CHECKED:BST_UNCHECKED),0);
 SendMessage(cvb,BM_SETCHECK,(WPARAM)((GlobPozice.sch[e1]==6 && GlobPozice.sch[a1]==4)?BST_CHECKED:BST_UNCHECKED),0);
 SendMessage(cmc,BM_SETCHECK,(WPARAM)((GlobPozice.sch[e8]==-6 && GlobPozice.sch[h8]==-4)?BST_CHECKED:BST_UNCHECKED),0);
 SendMessage(cvc,BM_SETCHECK,(WPARAM)((GlobPozice.sch[e8]==-6 && GlobPozice.sch[a8]==-4)?BST_CHECKED:BST_UNCHECKED),0);
 }
}
void CtiZCheckboxu(){

GlobPozice.roch=
(!!(BST_CHECKED==SendMessage(cmb,BM_GETCHECK,0,0)))|
((!!(BST_CHECKED==SendMessage(cvb,BM_GETCHECK,0,0)))<<1)|
((!!(BST_CHECKED==SendMessage(cmc,BM_GETCHECK,0,0)))<<2)|
((!!(BST_CHECKED==SendMessage(cvc,BM_GETCHECK,0,0)))<<3);
GlobPozice.bily=
!!(BST_CHECKED==SendMessage(cbily,BM_GETCHECK,0,0));
}


static void KliklNaSch(x,y){
HDC dc,FDC,PDC;
HBITMAP bm1,bm2;
int pole;

x/=40;
y/=40;
pole=a1+x+(7-y)*10;
GlobPozice.sch[pole]=fig;
dc=GetDC(OProm);
FDC=CreateCompatibleDC(dc);
bm1=SelectObject(FDC,hFigury);
PDC=CreateCompatibleDC(dc);
bm2=SelectObject(PDC,hPole);
WinTiskniPole(dc,PDC,(x+y)&1,0,SchX+40*x,SchY+40*y);
WinTiskniFiguru(dc,FDC,fig,2+SchX+40*x,2+SchY+40*y); 
ReleaseDC(OProm,dc);
SelectObject(FDC,bm1);
SelectObject(PDC,bm2);
DeleteDC(FDC);
DeleteDC(PDC);
if(BST_CHECKED==SendMessage(Automat,BM_GETCHECK,0,0)
&& (pole==a1 || pole== e1 || pole==h1 ||
    pole==a8 || pole== e8 || pole==h8)){
NastavCheckboxy(false);
}
}


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
  for (i=0;i<=6;i++)
   {
    WinTiskniPole(dc,PDC,i&1,fig==i,FGRX,40*i+FGRY);
    WinTiskniFiguru(dc,FDC,i,2+FGRX,40*i+2+FGRY);
	WinTiskniPole(dc,PDC,!(i&1),-fig==i,FGRX+40,40*i+FGRY);
    WinTiskniFiguru(dc,FDC,-i,2+FGRX+40,40*i+2+FGRY);
   }
  SelectObject(FDC,bm1);
  SelectObject(PDC,bm2);
  DeleteDC(FDC);
  DeleteDC(PDC);
  WinTiskniSachovnici(dc, SchX, SchY, &(GlobPozice.sch));
  EndPaint(hwnd,&ps);
  return 0;
 }
LRESULT CALLBACK PoziceWinProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {int x,y;
 HDC dc;
 switch(uMsg){
   case WM_CLOSE: EnableWindow(GlobOtec,TRUE);
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
   case WM_PAINT: return wmpaint(hwnd);
   case WM_COMMAND:
   if(((HWND)lParam)==Automat){
    if(BST_CHECKED==SendMessage(Automat,BM_GETCHECK,0,0))
	NastavCheckboxy(false);
   } else
    if(((HWND)lParam)==bzrusit)PostMessage(hwnd,WM_CLOSE,0,0); else
    if(((HWND)lParam)==bok){
	 CtiZCheckboxu();
	 if(!PripustnaPozice(&GlobPozice)){
	  uloha->pozice=GlobPozice;
	  InitPartie(&(uloha->prt),&GlobPozice);
	  uloha->KonecPartie=false;
	  ZmenPartiar(uloha);
	  PostMessage(hwnd,WM_CLOSE,0,0);
	  PostMessage(HlavniOkno,WM_PripravTah,0,0);
	  InvalidateRect(HlavniOkno,NULL,FALSE);
	 }
	 else MessageBox(NULL,"Pozice není pøípustná","Chyba",MB_OK | MB_TASKMODAL);
	 } else
	if(((HWND)lParam)==bprazdna){
	for(y=0;y<=7;y++)memset(GlobPozice.sch+(a1+y*10),0,8);
	dc=GetDC(hwnd);
	WinTiskniSachovnici(dc, SchX, SchY, &(GlobPozice.sch));
	ReleaseDC(hwnd,dc);
	if(BST_CHECKED==SendMessage(Automat,BM_GETCHECK,0,0))
	NastavCheckboxy(false);
	}
	return 0;
   case WM_LBUTTONDOWN:
	x=LOWORD(lParam);
	y=HIWORD(lParam);
	if(x>=FGRX && x<FGRX+80 && y>=FGRY && y<FGRY+7*40)
	KliklNaTypy(x-FGRX,y-FGRY);
	else if(x>=SchX && x<SchX+320 && y>=SchY && y<SchY+320)
	KliklNaSch(x-SchX,y-SchY);
   return 0;
   default: return DefWindowProc(hwnd, uMsg, wParam, lParam);
  }
 }

void InitTriduOkna(void)
 {
   TridaOkna.style=0;
   TridaOkna.lpfnWndProc=PoziceWinProc;
   TridaOkna.cbClsExtra=0;
   TridaOkna.cbWndExtra=0;
   TridaOkna.hInstance=hInstance;
   TridaOkna.hIcon=NULL;
   TridaOkna.hCursor=LoadCursor(NULL,IDC_ARROW);
   TridaOkna.hbrBackground=GetStockObject(LTGRAY_BRUSH);
   TridaOkna.lpszMenuName=NULL;
   TridaOkna.lpszClassName=NazevTridyOkna;
   RegisterClass(&TridaOkna);
  }

#define StylOkna WS_POPUP|WS_CAPTION|WS_DLGFRAME|WS_VISIBLE

HWND VytvorButton(HWND otec, int *x, int *y, char *text, int typ){
 int dx;
 HWND w;


 dx=(strlen(text)+4)*zx;
 w=CreateWindow ("BUTTON",text, WS_CHILD|WS_VISIBLE|typ,
                *x,*y,dx,zy*2,
				otec,0, hInstance, NULL);
  (*x)+=(dx+10);
  (*y)+=(zy*2+10);
  return w;
 }
 void OknoPozice(HWND otec)
 {RECT r,r2;
  HDC dc;
  int x,y;
  
  Oznaceno=0;
  GlobPozice=uloha->pozice;
  GlobPozice.mimoch=0;
  GlobOtec=otec;
  GetWindowRect(otec,&r);
  r2.left=(r.left+r.right-OknoRozmerX)/2;
  r2.top=(r.top+r.bottom-OknoRozmerY)/2;
  r2.right=r2.left+OknoRozmerX;
  r2.bottom=r2.top+OknoRozmerY;
  AdjustWindowRect(&r2,StylOkna,FALSE);
  OProm=CreateWindow (NazevTridyOkna,"Nastavení pozice",
                StylOkna,
                r2.left,r2.top,r2.right-r2.left+1,r2.bottom-r2.top+1,
				otec,0, hInstance, NULL);
  ShowWindow(OProm,SW_SHOWMAXIMIZED);
  dc=GetDC(OProm);
  NastavXYZnaku(&zx,&zy,dc);
  ReleaseDC(OProm,dc);
/*HWND VytvorButton(HWND otec, int &x, int &y, char *text){*/
  x=10;
  y=SchY+330;
  bok=VytvorButton(OProm,&x,&y,"Budiž",0);
  y=SchY+330;
  bzrusit=VytvorButton(OProm,&x,&y,"Zrušit",0);
  y=SchY+330;
  bprazdna=VytvorButton(OProm,&x,&y,"Prázdná",0);
  x=FGRX+100;
  y=10;
  cbily=VytvorButton(OProm,&x,&y,"Hraje bílý",BS_AUTOCHECKBOX);
  Grupac=CreateWindow("BUTTON","Rošády",WS_CHILD|WS_VISIBLE|BS_GROUPBOX,
                FGRX+100,y,zx*19,zy*17,
				OProm,0, hInstance, NULL);
  x=FGRX+110;
  y+=zy;
  Automat=VytvorButton(OProm,&x,&y,"Automaticky",BS_AUTOCHECKBOX);
  y=zy*4;
  x=10;
  cmb=VytvorButton(Grupac,&x,&y,"Malá bílá",BS_AUTOCHECKBOX);
  x=10;
  cvb=VytvorButton(Grupac,&x,&y,"Velká bílá",BS_AUTOCHECKBOX);
  x=10;
  cmc=VytvorButton(Grupac,&x,&y,"Malá èerná",BS_AUTOCHECKBOX);
  x=10;
  cvc=VytvorButton(Grupac,&x,&y,"Velká èerná",BS_AUTOCHECKBOX);
  NastavCheckboxy(true);
  EnableWindow(otec,FALSE);
 }


#endif


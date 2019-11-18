/*********************************************************/
/* winmain.c - modul obsahujici WinMain - jen Windows    */
/* 10.1. 2001 Jan Nemec                                  */
/*********************************************************/
#include "volby.h"
#if Typ_Produktu==Win32_Program
#include <windows.h>
#include <windef.h>
#include <stdio.h>
#include "winmain.h"
#include "winio.h"
#include "winpos.h"
#include "globruti.h"
#include "ohodnoc.h"
#include "sachy.h"
#include "promdlg.h"
#include "generato.h"
#include "myslitel.h"
#include "winio.h"
#include "dlg.h"
#include "partiar.h"
#include "winmysl.h"
#include "soubvv.h"
#include "pgn.h"
#include "kontrola.h"
#include "chyba.h"
#include "hashtab.h"

// Hlavní menu
#define MKonec 1
#define MPredvedTahy 2
#define MTahniZpet 3
#define MTahniZnovu 4
#define MNastaveni 6
#define MNovaPartie 9
#define MUloz 10
#define MOtevri 11
#define MOtoc 12
#define MBarvaPozadi 20
#define MVsechnyZpet 13
#define MVsechnyZnovu 14
#define MNastavPozici 15
#define MHodnotaPozice 21
#define MOProgramu 50
#define MRozd 500
// Vedlejší menu
#define MHrajTed 7
#define MPristiTahClovek 8

HBITMAP hFigury,hPole;
HMENU HlavniMenu;
HMENU MysliciMenu;
TUloha *uloha;
TWinNastaveni Nastaveni = {1,1,0,20,20,5000,5000, RGB(100,200,150)};
const char * NazevTridy = "Hlavni trida";
HINSTANCE hInstance;
HWND HlavniOkno;
HACCEL Akcelerator;
static DWORD dwThreadId;
static HCURSOR PresypaciHodiny;
static HCURSOR Sipka;
static bool ReagujNaMys=false;


DWORD VlaknoMysleni(LPDWORD lpdwParam) { 
TTah1 t1;
/*bool b;*/
    
	
	 memcpy((void *)KSachovnice,(void *)uloha->pozice.sch,sizeof(TSch));
	 Myslim=true;
     if (DejTah(uloha,&t1,
		 uloha->pozice.bily ? 
		 Nastaveni.CasBileho : Nastaveni.CasCerneho, /*&b*/NULL))
	 {
	   Myslim=false; /*Dulezite !!! - Pokud to zavolam az
	   pozdeji, muze dojit k preruseni vlakna na samem konci
	   a pak se vykresli tah spatne*/
       PostMessage(HlavniOkno,WM_HrajTah,(WPARAM) t1.data,0);
	   }
	Myslim=false;
	/*if(b)MessageBox(NULL,"remízu","Pøijal bych",MB_OK);*/
	return 0; 
} 
 

void wmpripravtah(HWND hwnd)
 {s8 Ozn;

   if (uloha->KonecPartie)
    {
     Nastaveni.BilyClovek=1;
     Nastaveni.CernyClovek=1;
    }
   if(uloha->pozice.bily && Nastaveni.BilyClovek ||
     !uloha->pozice.bily && Nastaveni.CernyClovek )
/*Na tahu je èlovìk*/
    {
   NalezTahy(uloha);
   JenPripustne(uloha);
   SetClassLong(HlavniOkno,GCL_HCURSOR,(LONG)Sipka);
	SetCursor(Sipka);
	 //SendMessage(HlavniOkno,WM_KEYDOWN,VK_ESCAPE,65537);
	 SetMenu(HlavniOkno,HlavniMenu);
	 DrawMenuBar(HlavniOkno);
   ReagujNaMys=true;
    if (Oznaceno)
      {
       Ozn=Oznaceno;
       Oznaceno=0;
       TiskniNPoli(hwnd,Ozn,0);
      }
    }
   else
/*Na tahu je program*/
    {
		SetMenu(HlavniOkno,MysliciMenu);
		DrawMenuBar(HlavniOkno);
		SetClassLong(HlavniOkno,GCL_HCURSOR,(LONG)PresypaciHodiny);
		SetCursor(PresypaciHodiny);
      UpdateWindow(hwnd);
 //     Pokud totiz byl predtim zobrazen , okno by se nevykreslilo vcas
CreateThread( 
        NULL,                        // no security attributes         
        0,                           // use default stack size        
        (LPTHREAD_START_ROUTINE) VlaknoMysleni, // thread function       
        NULL,                // argument to thread function   
        0,                           // use default creation flags    
        &dwThreadId);                // returns the thread identifier      
    }
 }
void wmhrajtah(HWND hwnd,u16 t)
{
#ifdef Statistika
	 /*{char s[100];

		 sprintf(s,"Poèet uzlù: %i",UZ);
		 MessageBox(NULL,s,"Informace",MB_OK);
	 }*/
#endif
 GlobTahni(true,uloha,true,(unsigned)t);
 ZmenPartiar(uloha);
 Oznaceno=0;
 WinTiskniTah(hwnd, t);
 ZjistiTypKoncePartie(uloha);
 if(uloha->KonecPartie)
      MessageBox(NULL,NazvyVysledku[uloha->KonecPartie],
                "Konec partie",MB_OK | MB_TASKMODAL);
 PostMessage(hwnd,WM_PripravTah,0,0);
}
void NastavPozadi(){
	CHOOSECOLOR c={
	sizeof(c),
	NULL,
	NULL,
	Nastaveni.BarvaPozadi,
	Nastaveni.BarvyUzivatele,
	CC_RGBINIT,
	0l,
	NULL,
	NULL
	};

	if(ChooseColor(&c)){
		Nastaveni.BarvaPozadi=c.rgbResult;
		InvalidateRect(HlavniOkno, NULL, TRUE);
	}
}
void wmrbuttondown(){
	NastavPozadi();
}
// Reakce hlavního okna na WM_LBUTTONDOWN
LRESULT wmlbuttondown(HWND hwnd, int x, int y)
 {u16 t;

 if (!ReagujNaMys || !(Nastaveni.BilyClovek && uloha->pozice.bily ||
        Nastaveni.CernyClovek && ! uloha->pozice.bily)) return 0;
  /*  nemá co klikat */
 if(uloha->KonecPartie)
  {
   MessageBox(NULL,"Nemá smysl dál hrát.","Partie skonèila",MB_OK | MB_TASKMODAL);
   return 0;
  }
  x-=Nastaveni.PosunSchX;
  y-=Nastaveni.PosunSchY;
  if (x>=0 && x<8*40 && y>=0 && y<8*40)
  /*Trefil se do šachovnice*/
   {x/=40;y/=40;
    if (Nastaveni.BilyHrajeNahoru) y=7-y;else x=7-x;
    x+=21+10*y;
/* V x mám teï políèko, na které kliknul */
    if (uloha->pozice.sch[x]>0 && uloha->pozice.bily  ||
        uloha->pozice.sch[x]<0 && !uloha->pozice.bily)
/*Kliknul na figurku vlastní barvy*/
    {
/*   NalezTahy(uloha);
    JenPripustne(uloha); */
    if(JeTam1((u8)x,uloha))
     {
    y=Oznaceno;
    Oznaceno=(u8)x;
    TiskniNPoli(hwnd,Oznaceno,y,0);
     }
    else
     MessageBox(NULL,"Figurka nemá pøípustný tah","Chyba",MB_OK | MB_TASKMODAL);
    }
   else
 /*Kliknul na políèko neobsazené vlastní figurou*/
   {
    if (!Oznaceno) return 0;
/*  NalezTahy(uloha);
    JenPripustne(uloha);*/
    t=DoplnTah(hwnd,Oznaceno,(u8)x,uloha);
    if(t)
     {
	  ReagujNaMys=false;
      GlobTahni(true,uloha,true,(unsigned)t);
	  Oznaceno=0;
      WinTiskniTah(hwnd,t);
	  ZmenPartiar(uloha);
	  ZjistiTypKoncePartie(uloha);
 if(uloha->KonecPartie)
      MessageBox(NULL,NazvyVysledku[uloha->KonecPartie],
                "Konec partie",MB_OK | MB_TASKMODAL);
      PostMessage(hwnd,WM_PripravTah,0,0);
     }
    else
   MessageBox(NULL,"Tohle není pøípustný tah","Chyba",MB_OK | MB_TASKMODAL);
   }
   }
  return 0;
 };
// Reakce hlavního okna na WM_PAINT
LRESULT wmpaint(HWND hwnd)
 {HDC dc;
  HPEN pero,p1;
  HBRUSH brusz,br1;
  PAINTSTRUCT ps;

  pero=CreatePen(PS_SOLID,0,Nastaveni.BarvaPozadi);
  brusz=CreateSolidBrush(Nastaveni.BarvaPozadi);
  dc=BeginPaint(hwnd,&ps);
  p1=SelectObject(dc,pero);
  br1=SelectObject(dc,brusz);
  Rectangle(dc,ps.rcPaint.left,ps.rcPaint.top,ps.rcPaint.right,ps.rcPaint.bottom);
  WinTiskniSachovnici(dc,Nastaveni.PosunSchX,Nastaveni.PosunSchY,Myslim?(&KSachovnice):(&(uloha->pozice.sch)));
  SelectObject(dc,p1);
  SelectObject(dc,br1);
  EndPaint(hwnd,&ps);
  DeleteObject(pero);
  DeleteObject(brusz);
  return 0;
 }

void UlozPartii(){
char bafr[256]="";
char maska[]="Formát HŠ 1350 (*.txt)\000*.txt\000"
             "PGN (*.pgn)\000*.pgn\000";
 OPENFILENAME l=
{sizeof(OPENFILENAME),
 NULL,
 0,
 maska, // filtr
 NULL, // customfiltr
 0, // nMaxCustomFilter
 0,
 bafr,
 256,
 NULL,
 0,
 NULL,
 "Uložení",
 OFN_LONGNAMES|OFN_HIDEREADONLY,
 0,
 0,
 NULL,
 0,
 NULL
};
	if(GetSaveFileName(&l))
		switch(l.nFilterIndex){
		case 1:if(!UlozDoSouboru(bafr,uloha))
			MessageBox(NULL,bafr,"Nemùžu uložit",MB_OK);
			break;
		case 2:{
			TPGNInfo pgn;

			InitPGN(&pgn);
			if(DialogPGN(HlavniOkno,&pgn)&&!UlozDoPGN(bafr,uloha,&pgn))
			 MessageBox(NULL,bafr,"Nemùžu uložit",MB_OK);
			DonePGN(&pgn);
			break;
			   }

		}
		
	
}

void OtevriPartii(){
char bafr[256]="";
char maska[]="Textové soubory (*.txt)\000*.txt\000"
             "Všechny soubory (*)\000*\000";
 OPENFILENAME l=
{sizeof(OPENFILENAME),
 NULL,
 0,
 maska, // filtr
 NULL, // customfiltr
 0, // nMaxCustomFilter
 0,
 bafr,
 256,
 NULL,
 0,
 NULL,
 "Naètení partie",
 OFN_FILEMUSTEXIST|OFN_LONGNAMES|OFN_HIDEREADONLY,
 0,
 0,
 NULL,
 0,
 NULL
};
	if(GetOpenFileName(&l)){
		if(OtevriZeSouboru(bafr,uloha)){
		InvalidateRect(HlavniOkno,NULL,FALSE);
		Nastaveni.BilyClovek=1;
		Nastaveni.CernyClovek=1;
		}
		else MessageBox(NULL,"Neúspìch pøi otevøení","Chyba",MB_OK | MB_TASKMODAL);
	}
	wmpripravtah(HlavniOkno);
	/*
	A už se to povedlo nebo ne, mohou být tahy na zásobníku pøepsané
	*/
}
void PrekresliSachovnici(TUloha *uloha){
	HDC dc;

	dc=GetDC(HlavniOkno);
    WinTiskniSachovnici(dc,Nastaveni.PosunSchX,Nastaveni.PosunSchY,Myslim?(&KSachovnice):&(uloha->pozice.sch));
	ReleaseDC(HlavniOkno,dc);
}
void MoznaProhodHrace(TUloha *uloha){
	 if(!Nastaveni.BilyClovek && uloha->pozice.bily ||
			 !Nastaveni.CernyClovek && !uloha->pozice.bily){
			 int pom;
			 pom=Nastaveni.CernyClovek;
			 Nastaveni.CernyClovek=Nastaveni.BilyClovek;
			 Nastaveni.BilyClovek=pom;
		 }
}
/*Procedura dialogu "O Programu"*/
BOOL CALLBACK AboutDlgWinProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {
 switch(uMsg){
   case WM_INITDIALOG: 	return TRUE;
   case WM_COMMAND: 
     switch (LOWORD(wParam))
     {
	 case 1:  if(HIWORD(wParam)==BN_CLICKED) {EndDialog(hwnd,0);  return TRUE;}
	 }
	return FALSE;
   default: return FALSE;
  }
 }

// Procedura hlavního okna
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {
  switch (uMsg){
   case WM_COMMAND:
    switch(LOWORD(wParam)){
      case MNastaveni:if(Myslim)return 0;DialogNastaveni(hwnd,&Nastaveni); return 0;
	  case MRozd:{char s[20]; sprintf(s,"%i",Sum(5));
				MessageBox(NULL,s,"Náhoda",MB_OK);} return 0;
      case MKonec:PostQuitMessage(0);return(0);
	  case MOProgramu:
		DialogBox(hInstance,"OPROGRAMU",HlavniOkno,AboutDlgWinProc);
	   break;
	  case MHodnotaPozice:
		if(Myslim)return 0;
		SectiMaterialBmCm(uloha);
	uloha->zasobnik.hPechF[0]=HashPechF(&(uloha->pozice));
    uloha->zasobnik.hPechG[0]=HashPechG(&(uloha->pozice));
	{char s[50];
	 sprintf(s,"Z hlediska toho, kdo je na tahu: %i",(int)HodnotaPozice(uloha,-mat,mat));
	 MessageBox(NULL,s,"Hodnota pozice",MB_OK | MB_TASKMODAL);
	 }
		return 0;
	  case MOtevri:
		  if(Myslim)return 0;
		  OtevriPartii();
		  ZmenPartiar(uloha);
		  return 0;
	  case MBarvaPozadi:
		  NastavPozadi();
		  return 0;
	  case MUloz:
		if(Myslim)return 0;
		UlozPartii();
		return 0;
      case MTahniZpet:
		if(Myslim)return 0;
        if(uloha->prt->l)
        {
         GlobTahniZpet(uloha);
         WinTiskniTah(hwnd,uloha->prt->p->data.t);
		 ZmenPartiar(uloha);
		MoznaProhodHrace(uloha);
         wmpripravtah(hwnd);
        }
       else
        MessageBox(NULL,"Nemùžu vrátit nezahrané","Chyba",MB_OK | MB_TASKMODAL);
       return 0;
	  case MNastavPozici:
	   OknoPozice(hwnd);
		return 0;
	  case MVsechnyZpet:
		  if(Myslim)return 0;
		  while(uloha->prt->l) GlobTahniZpet(uloha);
		  ZmenPartiar(uloha);
		  MoznaProhodHrace(uloha);
		 PrekresliSachovnici(uloha);
         wmpripravtah(hwnd);
	  return 0;
	  case MVsechnyZnovu:
		  if(Myslim)return 0;
		  while(uloha->prt->p) GlobTahni(true,uloha,false);
		  ZmenPartiar(uloha);
		  MoznaProhodHrace(uloha);
		 PrekresliSachovnici(uloha);
         wmpripravtah(hwnd);
	  return 0;
	   
      case MTahniZnovu:
		if(Myslim)return 0;
       if(uloha->prt->p)
        {
         GlobTahni(true,uloha,false);
         WinTiskniTah(hwnd,uloha->prt->data.t);
		 ZmenPartiar(uloha);
		 MoznaProhodHrace(uloha);
         wmpripravtah(hwnd);
        }
       else
        MessageBox(NULL,"Nemùžu znovu zahrát nevrácené","Chyba",MB_OK | MB_TASKMODAL);
       return 0;
      case MPredvedTahy: 
		  if(Myslim)return 0;
		  ZobrazTahy(hwnd, uloha);
       return 0;
	  case MOtoc:
		  Nastaveni.BilyHrajeNahoru=!Nastaveni.BilyHrajeNahoru;
			InvalidateRect(hwnd,NULL,FALSE);
		  return 0;
      case MHrajTed:if(Myslim){uloha->StavPropoctu.MamKoncitMysleni=true; return 0;}
		  if(uloha->pozice.bily){
			 Nastaveni.CernyClovek=1;
			 Nastaveni.BilyClovek=0;}
		 else{
			 Nastaveni.CernyClovek=0;
			 Nastaveni.BilyClovek=1;}
		 wmpripravtah(hwnd);
		 return 0;
	  case MPristiTahClovek:
		  if(!Myslim)return 0;
		 if(uloha->pozice.bily)
			 Nastaveni.CernyClovek=1;
		 else
			 Nastaveni.BilyClovek=1;
		 return 0;
	  case MNovaPartie:
		  if(Myslim)return 0;
		  DoneUlohu(&uloha);
		  uloha=InitUlohu(18,17);
		  InvalidateRect(hwnd,NULL,FALSE);
		  wmpripravtah(hwnd);
		  ZmenPartiar(uloha);
	   return 0;
     default: return 0;
      }
   case WM_PripravTah: wmpripravtah(hwnd);   return 0;
   case WM_HrajTah: wmhrajtah(hwnd,LOWORD(wParam)); return 0;
   case WM_LBUTTONDOWN: return wmlbuttondown(hwnd,LOWORD(lParam),HIWORD(lParam));
	case WM_RBUTTONDOWN: wmrbuttondown(); return 0;
   case WM_PAINT: return wmpaint(hwnd);
   case WM_DESTROY:
	   SetMenu(hwnd, NULL);
	   DestroyMenu(HlavniMenu);
	   DestroyMenu(MysliciMenu);
	   PostQuitMessage(0);
	   return(0);
   default: return DefWindowProc(hwnd, uMsg, wParam, lParam);
  }
 }
// Hlavní program
int PASCAL WinMain(HINSTANCE hCurInstance, HINSTANCE hPrevInstance,
                    LPSTR lpCmdLine, int nCmdShow)
{MSG msg;
 WNDCLASS wc;

InitProgram(&uloha,"knihovna");
hInstance=hCurInstance;
hFigury=LoadBitmap(hCurInstance,"FIGURY");
hPole=LoadBitmap(hCurInstance,"POLE");
HlavniMenu=LoadMenu(hInstance,"HLAVNIMENU");
MysliciMenu=LoadMenu(hInstance,"MYSLICIMENU");
PresypaciHodiny=LoadCursor(NULL,IDC_WAIT);
Sipka=LoadCursor(NULL,IDC_ARROW);
// Inicializace CREATESTRUCT
 if (!hPrevInstance)
  {
   InitTriduDialogu();
   InitTriduPartiare();
   InitTriduVypisu();
   InitTriduOkna();
   wc.style=0;
   wc.lpfnWndProc=WindowProc;
   wc.cbClsExtra=0;
   wc.cbWndExtra=0;
   wc.hInstance=hCurInstance;
   wc.hIcon=LoadIcon(hCurInstance,"MAINICON");
   wc.hCursor=Sipka;
   wc.hbrBackground=GetStockObject(NULL_BRUSH);
   wc.lpszMenuName=NULL;
   wc.lpszClassName=NazevTridy;
// Registrace tøídy
   RegisterClass(&wc);
  }
// Vytvoøení hlavního okna
 HlavniOkno=CreateWindow(
  NazevTridy,
  "  Honzovy šachy",
  WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX,
  CW_USEDEFAULT,
  CW_USEDEFAULT,
  CW_USEDEFAULT,
  CW_USEDEFAULT,
  0,
  HlavniMenu,
  hCurInstance,
  NULL
  );
// Hlavní smyèka wokenního programu
 ShowWindow(HlavniOkno,SW_SHOWMAXIMIZED);
 UpdateWindow(HlavniOkno);
 ZobrazPartiar(HlavniOkno);
 ZmenPartiar(uloha);
 ZobrazVypisy(HlavniOkno);
 Akcelerator=LoadAccelerators(hInstance,"MYSLICIAKCELERATOR");	
 PostMessage(HlavniOkno,WM_PripravTah,0,0);
 while (GetMessage(&msg, NULL, 0, 0)==1)
 if (! TranslateAccelerator (HlavniOkno, Akcelerator, &msg))
  {TranslateMessage(&msg);
   DispatchMessage(&msg);
  }
 DoneUlohu(&uloha);
 DeleteObject(hFigury);
 DeleteObject(hPole);
 return 0;
}

#endif
/* Typ_Produktu==Win32_Program */


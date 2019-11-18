/***********************************************************/
/* dlg.c - dialog pro zakladni nastaveni - jen pro Windows */
/* 31.12. 2000 Jan Nemec                                   */
/***********************************************************/
#include "volby.h"
#if Typ_Produktu==Win32_Program
#include <windows.h>
#include <math.h>
#include <stdio.h>
#include "winmain.h"
#include "dlg.h"
#define NazevTridyDialogu "Nastavení"
/*#define DlgRozmerX 220
#define DlgRozmerY 230*/
#define IDOk 10
#define IDZrusit 20
#define IDCbhn 30
#define IDCbjc 40
#define IDCcjc 50
#define IDScnt 60
#define IDSb 70
#define IDSc 80
#define IDEb 90
#define IDEc 100
static WNDCLASS TridaDialogu;
/* Tøída oken vzhledem podobným dialogu */
static HWND GlobOtec;
static bool GlobPlatne;
//static int Konec;
static TWinNastaveni GlobNastaveni;

int Vyhodnot(HWND hdlg,TWinNastaveni *nastaveni)
 {char s[20];

  *nastaveni=GlobNastaveni; /* dùležité*/
  nastaveni->BilyHrajeNahoru=(IsDlgButtonChecked(hdlg,IDCbhn)==1);
  nastaveni->BilyClovek=(IsDlgButtonChecked(hdlg,IDCbjc)==1);
  nastaveni->CernyClovek=(IsDlgButtonChecked(hdlg,IDCcjc)==1);
  GetDlgItemText(hdlg,IDEb,s,19);
  nastaveni->CasBileho=atoi(s);
  GetDlgItemText(hdlg,IDEc,s,19);
  nastaveni->CasCerneho=atoi(s);
  if(nastaveni->CasBileho<=0 || nastaveni->CasBileho>4000000)
   { MessageBox(NULL,"Chybné zadání","Varování",MB_OK);SetFocus(GetDlgItem(hdlg,IDEb)); return 0;}
  if(nastaveni->CasCerneho<=0 || nastaveni->CasCerneho>4000000)
   { MessageBox(NULL,"Chybné zadání","Varování",MB_OK);SetFocus(GetDlgItem(hdlg,IDEc));return 0;}
   return 1;
 }

BOOL CALLBACK DlgWinProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
 {char s[20];
 
 switch(uMsg){
   case WM_INITDIALOG:
    sprintf(s,"%i",GlobNastaveni.CasBileho);
	SetDlgItemText(hwnd,IDEb,s);
	sprintf(s,"%i",GlobNastaveni.CasCerneho);
	SetDlgItemText(hwnd,IDEc,s);
    if(GlobNastaveni.BilyHrajeNahoru) CheckDlgButton(hwnd,IDCbhn,1);
    if(GlobNastaveni.BilyClovek) CheckDlgButton(hwnd,IDCbjc,1);
    if(GlobNastaveni.CernyClovek) CheckDlgButton(hwnd,IDCcjc,1);
	return TRUE;
   case WM_COMMAND:
    switch (LOWORD(wParam))
     {case IDOk:
       if(HIWORD(wParam)==BN_CLICKED)
        {if(Vyhodnot(hwnd,&GlobNastaveni))
          {
            InvalidateRect(GlobOtec,NULL,FALSE);
		    GlobPlatne=true;
            PostMessage(GlobOtec,WM_PripravTah,0,0);
			EndDialog(hwnd,0);
           }
         }
       return TRUE;
      case IDZrusit:
       if(HIWORD(wParam)==BN_CLICKED)
        {EndDialog(hwnd,0);
         }
       return TRUE;
      default: return FALSE;
    }
   default: return FALSE;
  }
 }

void DialogNastaveni(HWND otec, TWinNastaveni *nastaveni)
 {


  GlobOtec=otec;
  GlobNastaveni=*nastaveni;
  GlobPlatne=false;
  DialogBox(hInstance,"VOLITELNE",otec,DlgWinProc);
  if(GlobPlatne)*nastaveni=GlobNastaveni;
 }

#endif

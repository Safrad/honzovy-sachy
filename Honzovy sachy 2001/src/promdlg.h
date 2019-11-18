/*********************************************************/
/* promdlg.h - dialog promeny pesce - jen windows        */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef promdlgH
#define promdlgH
#if Typ_Produktu!=Win32_Program
#error PromDlg.h neinkludovat !
#endif
#include <windows.h>
void InitTriduDialogu(void);
int DialogPromeny(HWND otec, int bily);
#endif

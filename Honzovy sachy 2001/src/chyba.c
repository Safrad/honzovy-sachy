/*********************************************************/
/* chyba.c - ukonceni programu po kriticke chybe         */
/* 10.3. 2001 Jan Nemec                                  */
/*********************************************************/

#include "volby.h"
#if (Typ_Produktu==DOS_UNIX) || (Typ_Produktu==CGI_script) || (Typ_Produktu==Projekt)
#include <stdio.h>
#elif Typ_Produktu==Win32_DLL || Typ_Produktu==Win32_Program
#include <windows.h>
#endif
#include <stdlib.h>

#if (Typ_Produktu==Projekt)

#include "scio.h"

#endif
#include "chyba.h"

void Chyba(char *str)
/***********************************************************

 * Nasilne a nestandardne ukonci program a napise chybovou *

 * hlasku. Volat jen po katastrofalni chybe                *

 ***********************************************************/
#if (Typ_Produktu==DOS_UNIX)
{printf("Chyba: %s\n",str);exit(1);}

#elif  (Typ_Produktu==CGI_script)
 {printf("Content-type: text/plain\n\nChyba: %s\n",str);exit(1);}

#elif Typ_Produktu==Win32_DLL
{ MessageBox(0,str,"Chyba v SACHY.DLL",MB_OK | MB_TASKMODAL);abort();}

#elif Typ_Produktu==Win32_Program
{ MessageBox(0,str,"Chyba programu",MB_OK | MB_TASKMODAL);abort();}
#elif Typ_Produktu==Projekt
{ printf("Chyba: %s\n",str); exit(1);}
#endif

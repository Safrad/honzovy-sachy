/*********************************************************/
/* wwwio.h - pro variantu cgi-script                     */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef wwwioH
#define wwwioH
#include "volby.h"
#if Typ_Produktu != CGI_script
#error chybny inklud
#endif
#include "cotyvar.h"
void WWWZpracujData(u8 *data, TUloha *uloha);
bool StejneVM(char *s1, char *s2);
#endif

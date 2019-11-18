/*********************************************************/
/* strtah.h - prevod tahu na retezec a naopak            */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef strtahH
#define strtahH
#include "cotyvar.h"
#define J_Nic 0
/* Staci urceni Da1 */
#define J_Radka 1
/* Staci urceni D1a1 */
#define J_Sloupec 2
/* Staci urceni Dha1 */
bool JednoZnacny(u16 tah, TUloha *uloha,int urcen);
/**********************************************************************/
/* StrToTah - musi byt tesne pred provedenim tahu a na zasobniku musi */
/*            byt ty tahy nalezene                                    */
/**********************************************************************/
bool StrToTah(char *s, TUloha *uloha, u16 *tah1);
/**********************************************************************/
/* TahToStr - musi byt tesne pred provedenim tahu a na zasobniku musi */
/*            byt ty tahy nalezene                                    */
/**********************************************************************/
void TahToStr(u16 tah, TUloha *uloha, char *s);
#endif


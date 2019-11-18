/*********************************************************/
/* tabulky.h - prace s databazi koncovek                 */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef tabulkyH
#define tabulkyH
void generujKDK();
bool IntToTPozice(int i,TPozice *pos);
u16 TabDejTah(TUloha *u);
int TPoziceToInt(TPozice *pos);
#endif


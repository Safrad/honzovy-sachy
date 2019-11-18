/*********************************************************/
/* sachy.h - obsahuje main a zakladni init a done        */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef sachyH
#define sachyH
void InitProgram(TUloha **uloha, char *knihsoubor);
/*********************************************/
/* Provede inicializaci celeho programu      */
/* (srand, knihovna...)                      */
/*********************************************/
TUloha *InitUlohu(int DveNaXHash,int DveNaXHashPech);
/*********************************************/
/* Inicializace ulohy (Alokace tabulek atd)  */
/*********************************************/
void DoneUlohu(TUloha **uloha);
/**********************************/
/* mazani ulohy a jejich tabulek  */
/**********************************/
#endif

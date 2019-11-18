/*********************************************************/
/* chyba.h - ukonceni programu po kriticke chybe         */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
#ifndef chybaH
#define chybaH
void Chyba(char *str);
/***********************************************************
 * Nasilne a nestandardne ukonci program a napise chybovou *
 * hlasku. Volat jen po katastrofalni chybe                *
 ***********************************************************/
/*#define chladim*/
#ifdef chladim
#define hassert(X,S) {if(!(X))Chyba(S);}
#else
#define hassert(X,S)
#endif
/*Neco jako assert z <assert.h>, ale hlasi chybu tam, kam chci ja*/
#endif

/*********************************************************/
/* volby.h - nastaveni zpusobu prekladu                  */
/* 31.12. 2000 Jan Nemec                                 */
/*********************************************************/
/*Zdrojaky pujde ve vysledku pouzit na vice veci.
Je treba urcit, co ma byt cil.*/
#ifndef volbyH
#define volbyH
#define PHAVerze "30.5.2001"
#define Win32_Program 0
/* Program pro 32 bitove Windows */
#define Win32_DLL 1
/*DLL pro 32 bitove Windows  - tato varianta není implementována*/
#define DOS_UNIX 2
/*interaktivni program v textovem modu pro UNIX
nebo dvaatricetibitove WINDOWS*/
#define CGI_script 3
/* CGI script */
#define Projekt 4
/* Souèást projektu šachové centrum */
#ifdef _WINDOWS
#define Typ_Produktu Win32_Program
#else
#define Typ_Produktu /* Projekt */ DOS_UNIX /*CGI_script*/
#endif
#if Typ_Produktu==DOS_UNIX
/*#define BlbejOS /*Pokud prekladam pro MSDOS*/
#define Vypisy
/*#define ABVH 1*/
#endif
#if Typ_Produktu==DOS_UNIX ||Typ_Produktu==Win32_Program
#define Statistika
#endif
#if Typ_Produktu==Win32_Program
#define STRINGTAH /*Ukladani retezcu do partie*/
#endif
#endif
/*od #define volby*/

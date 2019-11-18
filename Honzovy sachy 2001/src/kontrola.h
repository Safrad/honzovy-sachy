/*********************************************************/
/* kontrola.h - test pripustnosti pozice                 */
/* 6.1. 2001 Jan Nemec                                   */
/*********************************************************/
#ifndef kontrolaH
#define kontrolaH
#include "volby.h"
#include "cotyvar.h"
#define K_VPoradku 0
#define K_ChybaOkraje 1
#define K_NeznamyKod 2
#define K_MocBilych 3
#define K_MocCernych 4
#define K_MocBilychPescu 5
#define K_MocBilychKoni 6
#define K_MocBilychStrelcu 7
#define K_MocBilychVezi 8
#define K_MocBilychDam 9
#define K_PocetBilychKralu 10
#define K_MocCernychPescu 11
#define K_MocCernychKoni 12
#define K_MocCernychStrelcu 13
#define K_MocCernychVezi 14
#define K_MocCernychDam 15
#define K_PocetCernychKralu 16
#define K_PesecNaOkraji 17
#define K_KralVSachu 18
#define K_MBRoch 19
#define K_VBRoch 20
#define K_MCRoch 21
#define K_VCRoch 22
#define K_Mimochodem 23
#define K_MocSachu 24
int PripustnaPozice(TPozice *pos);
/***********************************************************/
/* PripustnaPozice - otestuje pozici a vrati 0, pokud je   */
/* smysluplna a pripustna, jinak kladny chybovy kod		   */
/* podle typu chyby										   */
/***********************************************************/
#endif

/* ©achové centrum - Knihovna zahájení Petr Kuèera 2000*/
/* Deklarace konstant a maker pro chybová hlá¹ení */

#ifndef __CHYBA_H__
#define __CHYBA_H__

#define CH_NIC 0
#define CH_INICIALIZACE 1
#define CH_PAMET 2 /*nedostatek pamìti*/
#define CH_KON_SOUBORU 3
#define CH_CISLO_TAHU 4
#define CH_NENI_NA_TAHU 5
#define CH_NEPLATNE_CISLO_TAHU 6
#define CH_SYNTAX 7
#define CH_CHYBI_CISLO_TAHU 8
#define CH_NULL 9
#define CH_NELZE_ROCHOVAT 10
#define CH_POZICE 11
#define CH_TAH 12
#define CH_SPATNE_POLE 13
#define CH_KOLIZE_ECO 14
#define CH_KOLIZE_VAH 15
#define CH_NENI_VARIANTA 16
#define CH_SOUCET_VAH 17
#define CH_POCET_NEURCENYCH 18
#define CH_MAX_VAHA 19
#define CH_VYST_SOUBOR 20
#define CH_CT_SOUBOR 21
#define CH_NENI_STROM 22
#define CH_ZAC_NEBILYCH 23
#define CH_KON_NEBILYCH 24
#define CH_DRUHA_POZ_S_NENUL_TAHEM 25
#define CH_NEUKONCENE_VARIANTY 26
#define CH_MAX 27

#define CH_CT_FAIL (CH_MAX+1) /*Pozice pøi ètení nenalezena*/
#define CH_NEUKLADAT (CH_MAX+2) /*Daná pozice, blok nebudou ukládány*/

extern const char *chyby_str[CH_MAX];

#ifdef __GNUC__

#define hlas_chybu(__ZPRAVA__,__CHYBA__) fprintf(stderr,"%s:%d: (%s): %s {%s}\n",__FILE__,__LINE__,__FUNCTION__,chyby_str[__CHYBA__],__ZPRAVA__)

#else

#define hlas_chybu(__ZPRAVA__,__CHYBA__) fprintf(stderr,"%s:%d: %s (%s)\n",__FILE__,__LINE__,chyby_str[__CHYBA__],__ZPRAVA__)

#endif

#define jen_varovani(__KOD_CHYBY__) ((__KOD_CHYBY__)==CH_NENI_STROM||(__KOD_CHYBY__)==CH_DRUHA_POZ_S_NENUL_TAHEM)

#endif

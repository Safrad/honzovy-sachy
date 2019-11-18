/* Sachov� centrum - Knihovna zah�jen� Petr Ku�era 2000*/
/* Deklarace funkc� pot�ebn�ch pro p��stup do souboru s knihovnou zah�jen�
 */

#ifndef __CTENI_H__
#define __CTENI_H__ 1

#include <stdio.h>
#include "datastr.h"
#include "cotyvar.h"

/*Prom�nn� obsahuj�c� odkaz na �ten� soubor s knihovnou zah�jen�*/
extern FILE *cteni_soubor;

/*Funkce inicializuj�c� modul �ten� knihovny, nutno volat p�ed
  prvn�m pou�it�m n�kter� ze zbyl�ch funkc� �tec�ho modulu.

  parametr jmsoub jm�no souboru obsahuj�c�ho knihovnu zah�jen�
  vrac� 0 p�i �sp�n� inicializaci, jinak k�d chyby dan� konstantami
        v souboru obk_ch.h
 */
int init_cteni(char *jmsoub);

/*Funkce p�e�te blok adres��e ze souboru s knihovnou zah�jen�

  parametr blok_adr ukazuje na m�sto, kam se m� ulo�it p�e�ten� blok adres��e
  parametr adresa obsahuje adresu �ten�ho bloku v souboru vzta�enou k aktu�ln�mu
           obsahu konstanty ZAC_ADR deklarovan� v souboru datastr.h. Adresa 0L v�dy
           ukazuje na z�kladn� blok, z n�j� vedou odkazy d�l.
  vrac� 0 p�i �sp�n�m �ten�, jinak k�d chyby dan� konstantami
        v souboru obk_ch.h
 */
int cti_blok_adresare(f_blok_adresare_t *blok_adr, long adresa);
/*Funkce p�e�te blok s pozicemi ze souboru s knihovnou zah�jen�

  parametr blok ukazuje na m�sto, kam m� b�t p�e�ten� blok ulo�en
  parametr adresa obsahuje adresu �ten�ho bloku v souboru vzta�enou
           k aktu�ln�mu obsahu konstanty ZAC_POZIC deklarovan�
           v souboru datastr.h.
  vrac� 0 p�i �sp�n�m �ten�, jinak k�d chyby dan� konstantami
        v souboru obk_ch.h
 */
int cti_blok_pozic(f_blok_pozic_t *blok, long adresa);
/*Funkce p�e�te pozici ze souboru s knihovnou zah�jen�

  parametr blok ukazuje na m�sto, kam m� b�t p�e�ten� pozice ulo�ena
  parametr adresa obsahuje adresu �ten� pozice v souboru vzta�enou
           k aktu�ln�mu obsahu konstanty ZAC_POZIC deklarovan�
           v souboru datastr.h. 
  vrac� 0 p�i �sp�n�m �ten�, jinak k�d chyby dan� konstantami
        v souboru obk_ch.h
 */
int cti_pozice(f_pozice_t *pozice, long adresa);
/*Nalezne pozici v souboru s knihovnou zah�jen�.

  parametr pozice obsahuje pozici, kter� m� b�t nalezena v souboru
  parametr f_pozice ukazuje na m�sto, kam m� b�t ulo�ena p�e�ten�
           pozice
  vrac� 0, nedojde-li k ��dn� chyb� a pozice je �sp�n� nalezena
        CH_CT_FAIL, nedojde-li k ��dn� chyb�, ale pozice nebyla nalezena
        k�d chyby dan� jinou konstantou deklarovanou v souboru obk_ch.h,
        dojde-li k jin� chyb�.
 */
int hledej_pozici(TPozice *pozice, f_pozice_t *f_pozice);

#endif

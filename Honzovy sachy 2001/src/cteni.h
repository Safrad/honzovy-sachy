/* Sachové centrum - Knihovna zahájení Petr Kuèera 2000*/
/* Deklarace funkcí potøebných pro pøístup do souboru s knihovnou zahájení
 */

#ifndef __CTENI_H__
#define __CTENI_H__ 1

#include <stdio.h>
#include "datastr.h"
#include "cotyvar.h"

/*Promìnná obsahující odkaz na ètený soubor s knihovnou zahájení*/
extern FILE *cteni_soubor;

/*Funkce inicializující modul ètení knihovny, nutno volat pøed
  prvním pou¾itím nìkteré ze zbylých funkcí ètecího modulu.

  parametr jmsoub jméno souboru obsahujícího knihovnu zahájení
  vrací 0 pøi úspì¹né inicializaci, jinak kód chyby daný konstantami
        v souboru obk_ch.h
 */
int init_cteni(char *jmsoub);

/*Funkce pøeète blok adresáøe ze souboru s knihovnou zahájení

  parametr blok_adr ukazuje na místo, kam se má ulo¾it pøeètený blok adresáøe
  parametr adresa obsahuje adresu èteného bloku v souboru vzta¾enou k aktuálnímu
           obsahu konstanty ZAC_ADR deklarované v souboru datastr.h. Adresa 0L v¾dy
           ukazuje na základní blok, z nìj¾ vedou odkazy dál.
  vrací 0 pøi úspì¹ném ètení, jinak kód chyby daný konstantami
        v souboru obk_ch.h
 */
int cti_blok_adresare(f_blok_adresare_t *blok_adr, long adresa);
/*Funkce pøeète blok s pozicemi ze souboru s knihovnou zahájení

  parametr blok ukazuje na místo, kam má být pøeètený blok ulo¾en
  parametr adresa obsahuje adresu èteného bloku v souboru vzta¾enou
           k aktuálnímu obsahu konstanty ZAC_POZIC deklarované
           v souboru datastr.h.
  vrací 0 pøi úspì¹ném ètení, jinak kód chyby daný konstantami
        v souboru obk_ch.h
 */
int cti_blok_pozic(f_blok_pozic_t *blok, long adresa);
/*Funkce pøeète pozici ze souboru s knihovnou zahájení

  parametr blok ukazuje na místo, kam má být pøeètená pozice ulo¾ena
  parametr adresa obsahuje adresu ètené pozice v souboru vzta¾enou
           k aktuálnímu obsahu konstanty ZAC_POZIC deklarované
           v souboru datastr.h. 
  vrací 0 pøi úspì¹ném ètení, jinak kód chyby daný konstantami
        v souboru obk_ch.h
 */
int cti_pozice(f_pozice_t *pozice, long adresa);
/*Nalezne pozici v souboru s knihovnou zahájení.

  parametr pozice obsahuje pozici, která má být nalezena v souboru
  parametr f_pozice ukazuje na místo, kam má být ulo¾ena pøeètená
           pozice
  vrací 0, nedojde-li k ¾ádné chybì a pozice je úspì¹nì nalezena
        CH_CT_FAIL, nedojde-li k ¾ádné chybì, ale pozice nebyla nalezena
        kód chyby daný jinou konstantou deklarovanou v souboru obk_ch.h,
        dojde-li k jiné chybì.
 */
int hledej_pozici(TPozice *pozice, f_pozice_t *f_pozice);

#endif

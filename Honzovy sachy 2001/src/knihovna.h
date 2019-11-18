/* ©achové centrum - Knihovna zahájení Petr Kuèera 2000*/
/* Deklarace funkcí potøebných pro pøístup do knihovny zahájení na nejvy¹¹í úrovni
 */

#ifndef __KNIHOVNA_H__
#define __KNIHOVNA_H__ 1

#include "volby.h"
#include "cotyvar.h"

/*Pøed pou¾itím knihovny nutno volat init_knihovna()

  parametr jmsoub urèuje jméno souboru, v nìm¾ je obsa¾ena pøelo¾ená knihovna
  vrací 0 pøi úspì¹né inicializaci, jinak kód chyby urèený konstanatami
        v souboru obk_ch.h
 */
int init_knihovna(char *jmsoub);

/*Hledá tah ze zadané pozice

  parametr pozice obsahuje pozici, z ní¾ je tah hledán
  parametr pole eco musí být dlouhé alespoò 4, obsahuje pøi nalezení tahu
           ECO pozice vzniklé zahráním tahu.
  vrací 0 pokud nebyla pozice nalezena, nebo dvoubajtový popis tahu, pokud byl tah nalezen.
        tah je vybírán náhodnì s pravdìpodobností danou jeho vahou. V pøípadì nalezení tahu
        obsahuje pole eco ECO pozice vzniklé zahráním vráceného tahu
*/
u16 query_knihovna(TPozice *pozice, char *eco);

/*
  Hledá tah v knihovnì zahájení

  parametr pozice obsahuje pozici, z ní¾ je tah hledán
  vrací 0 pokud nebyla pozice nalezena, nebo dvoubajtový popis tahu, pokud byl tah nalezen.
        tah je vybírán náhodnì s pravdìpodobností danou jeho vahou.

  Poznámka: 0 není kód ¾ádného tahu.
*/
u16 KnihDejTah(TPozice *pozice);

#include "datastr.h"

/*
  Vrátí v¹echny tahy, které jsou v knihovnì zahájení k dispozici pro danou pozici.

  parametr pozice obsahuje pozici, z ní¾ jsou tahy hledány
  parametr tahy po úspì¹ném hledání obsahuje ukazatel na pole s tahy,
           které jsou k dispozici pro danou pozici. Pole je vytvoøeno
           voláním malloc ve funkci v pøípadì, ¾e je pozice v knihovnì
           nalezena a ¾e z ní vede nìjaký tah s nenulovou pravdìpodobností,
           v opaèném pøípadì je vráceno místo pole NULL.
           Pokud je parametr tahy NULL, je vrácena hodnota CH_NULL
  parametr pocet_tahu obsahuje pøi úspì¹ném nalezení pozice poèet vrácených
           tahù
  vrací 0 pokud nedojde k chybì (nenalezení pozice není bráno jako chyba,
          stejnì jako neinicializovaná knihovna v dobì volání), jinak kód
          chyby daný konstantami v souboru obk_ch.h
 */
int knih_dej_vsechny_tahy(TPozice *pozice, f_tah_t **tahy, int *pocet_tahu);

#endif

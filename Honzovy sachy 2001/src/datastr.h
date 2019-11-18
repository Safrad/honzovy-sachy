/* Sachové centrum - Knihovna zahájení Petr Kuèera 2000*/
/** Deklarace typù datových struktur pou¾itých k reprezentaci
    knihovny zahájení v pamìti.
  */

#ifndef __DATASTR_H__
#define __DATASTR_H__ 1

#include "cotyvar.h"

/** HLOUBKA_ADRESARE - urèuje hloubku jedné úrovnì adresáøe. */
#define HLOUBKA_ADRESARE 4
/** POCET_ADRES_V_BLOKU - urèuje poèet adres v jednom bloku adresáøe. */
#define POCET_ADRES_V_BLOKU 16 /*2^4*/
/*Konstanta urèující masku pro odmaskování prvních HLOUBKA_ADRESARE bitù
 */
#define ZAKLADNI_MASKA 15

/*urèuje, jestli mají být pozice v souboru pakovány, nebo má být ukládán
 pøímo datový typ TPozice*/
#define PAKUJ_POZICE 1

/** tah_t - popis tahu s ECO a váhou výbìru, pokud je váha men¹í ne¾ 0,
    jde o dosud nespecifikovanou váhu.
*/
typedef struct _tah {
  /*váha výbìru tahu*/
  char vaha;
  /*písmeno ze zápisu ECO pozice vzniklé tímto tahem*/
  char ECO_pismeno;
  /*èíslo ze zápisu ECO pozice vzniklé tímto tahem*/
  char ECO_cislo;
  /*dvoubajtový popis tahu*/
  u16 tah;
  /*poøadí partie ve zdrojovém souboru knihovny, v ní¾ byl tah naposledy
    pøidáván.*/
  int cis_partie;
  /*Souèet vah ze v¹ech partií, v nich¾ byl tah pøidáván*/
  int soucet_vah;
  /*1 pokud byl tah v poslední partii pøidáván a jeho váha nebyla explicitnì
    urèena.*/
  int neurcena;
} tah_t;

/*Poèáteèní velikost pole tahy ve struktuøe pozice_t*/
#define POZICE_TAHY_POCATECNI_VELIKOST 10
/*Pøírùstek velikosti pole tahy ve struktuøe pozice_t, pøi jejím pøekroèení*/
#define POZICE_TAHY_DELTA 10

/*Konstanta urèující, ¾e ECO pozice není implicitní A00*/
#define NENI_IMPL_A00 0
/*Konstanta urèující, ¾e ECO pozice je A00 implicitní v rámci knihovny*/
#define KNIH_IMPL_A00 1
/*Konstanta urèující, ¾e ECO pozice je A00 implicitní pouze v rámci dané partie*/
#define PART_IMPL_A00 2

/** pozice_t - struktura popisující pozici s tahy, které z ní vychází*/
typedef struct _pozice {
  /*Odkaz na dal¹í pozici v seznamu pozic*/
  struct _pozice *dalsi_pozice;
  /*Ha¹ovací klíè pozice popsané touto strukturou*/
  u32 hasovaci_klic;
  /*písmeno ze zápisu ECO popisované pozice*/
  char ECO_pismeno;
  /*èíslo ze zápisu ECO popisované pozice*/
  char ECO_cislo;
  /*Urèuje, jestli ECO pozice je implicitní A00,
    je-li NENI_IMPL_A00, pak nejde o implicitní A00,
    je-li ECO_A00&KNIH_IMPL_A00, pak jde o implicitní A00 v rámci celé knihovny,
    je-li ECO_A00&PART_IMPL_A00, pak se jedná o A00 implicitní pouze v rámci dané partie
  */
  char ECO_A00;
  /*popisovaná pozice*/
  TPozice pozice;
  /*poèet tahù vedoucích z této pozice*/
  int pocet_tahu;
  /*souèet vah urèených tahù v aktuální partii*/
  int soucet_vah;
  /*poèet tahù s neurèenou vahou v souèasné partii*/
  int pocet_neurcenych;
  /*poèet tahù s nenulovou vahou v souèasné partii*/
  int pocet_nenulovych;
  /*poèet partií, v nich¾ se pozice vyskytla*/
  int pocet_partii;
  /*velikost pole tahy*/
  int vel_tahu;
  /*pole obsahující tahy vedoucí z této pozice*/
  tah_t *tahy;
  /*vypoètená pozice v souboru*/
  long poloha;
  /*èíslo partie, v ní¾ byl pøidán poslední tah s nenulovou nebo neurèenou vahou,
    nebo -1, pokud tam takový tah není*/
  int part_nenul_tah;
} pozice_t;

/** blok_pozice_t - struktura popisující obsah bloku s pozicemi, které
    mají stejný ha¹ovací klíè.
 */
typedef struct _blok_pozic {
  /*Poèet pozic je¾ jsou ulo¾ené v této struktuøe*/
  int pocet_pozic;
  /*Ha¹ovací klíè spoleèný v¹em pozicím ulo¾eným v této struktuøe*/
  u32 hasovaci_klic;
  /*Poloha bloku v souboru s knihovnou (vypoèteno tìsnì pøed ulo¾ením)*/
  long poloha;
  /*Poèet bytù, které blok v souboru bude zabírat*/
  long delka_bloku;
  /*Ukazatel na hlavu spojového seznamu s pozicemi, které jsou v tomto bloku ulo¾eny.*/
  pozice_t *pozice;
} blok_pozic_t;

/** blok_adresare_t - struktura popisující obsah bloku s adresáøem v pamìti.*/
typedef struct _blok_adresare {
  /*Poloha bloku v souboru s knihovnou zahájení (vypoèteno tìsnì pøed ulo¾ením).*/
  long poloha;
  /*
    Úroveò bloku ve struktuøe popisující obsah knihovny, urèuje, která skupina
    bitù v ha¹ovacím klíèi se pou¾ije pøi pøechodu na dal¹í úroveò.
  */
  int uroven;
  /*
    Ukazatelé na bloky pozic, které jsou urèeny hodnotou ha¹ovacího klíèe.
    Ha¹ovací klíè je ulo¾en implicitnì pomocí indexu v poli, jde o 16 prvkové pole,
    na ka¾dé úrovni se tedy ¹tìpí podle ètveøice bitù, pokud poskládáme pøíslu¹né
    ètveøice za sebou, dostaneme prefix klíèe dlouhý 4*(uroven+1) bitù.
    Pokud je prvek pole NULL, znamená to buï, ¾e pozice s klíèem zaèínajícím
    daným prefixem se dosud nevyskytla, nebo ¾e je více pou¾itých klíèù s daným
    prefixem, v tom pøípadì musí být pøíslu¹ný prvek pole adresy_adresaru ne NULL.
    Pokud je prvek ne NULL, je jediný klíè s daným prefixem, v tom pøípadì musí
    být prvek v poli adresy_adresaru se stejným indexem NULL.
   */
  blok_pozic_t *adresy_pozic[POCET_ADRES_V_BLOKU];
  /*
    Ukazatele na bloky adresáøù dal¹ích úrovní v hierarchické struktuøe popisující
    knihovnu zahájení.
   */
  struct _blok_adresare *adresy_adresaru[POCET_ADRES_V_BLOKU];
} blok_adresare_t;


/*Následující typy slou¾í k popisu stavu souboru.*/

/*typ popisující tah ulo¾ený do souboru*/
typedef struct _f_tah {
  /*Pravdìpodobnost, s jakou má být tah vybírán*/
  char vaha;
  /*Písmeno z kódu ECO tahu*/
  char ECO_pismeno;
  /*Èíslo z kódu ECO tahu*/
  char ECO_cislo;
  /*Dvoubajtový popis tahu*/
  u16 tah;
} f_tah_t;

/*Struktura popisující pozici ulo¾enou v souboru s knohovnou zahájení.*/
typedef struct {
  /*
    Dal¹í pozice ve spojovém seznamu pozic z jednoho bloku.
    Skuteèná adresa dal¹í pozice je ZAC_ADR+dalsi_pozice.
   */
  long dalsi_pozice;
  /*
    Stav hry popisovaný touto pozicí.
   */
  TPozice pozice;
  /*char ECO_pismeno;*/
  /*char ECO_cislo;*/
  /*Poèet tahù, které vedou z této pozice.*/
  int pocet_tahu;
  /*Pole s tahy vedoucími z této pozice.*/
  f_tah_t *tahy;
} f_pozice_t;

/*Struktura popisující blok pozic ulo¾ený v souboru.*/
typedef struct _f_blok_pozic {
  /*Délka bloku v bytech (=sizeof(f_blok_pozic_t)+pocet_pozic*sizeof(f_pozice_t).*/
  long delka_bloku;
  /*Poèet pozic ulo¾ených v tomto bloku.*/
  int pocet_pozic;
  /*Ha¹ovací klíè spoleèný v¹em pozicím v bloku.*/
  u32 hasovaci_klic;
  /*
    Pozice první pozice bloku v souboru - posun od zaèátku pozic.
    Skuteèná adresa v souboru je ZAC_POZIC+adr_pozic.
   */
  long adr_pozic;
} f_blok_pozic_t;

/*Struktura popisující blok adresáøe ulo¾ený v souboru.*/
typedef struct _f_blok_adresare {
  /*Poloha pole adresy v souboru. Skuteèná adresa zaèátku pole je ZAC_POZIC+zac_adres.*/
  long zac_adres;
  /*Úroveò bloku v hierarchické struktuøe adresáøe.*/
  int uroven;
  /*
    Pole s adresami následujících blokù. Pokud je pøíslu¹ný prvek 0, nenásleduje
    v jeho smìru ¾ádný dal¹í blok. Pokud má bitový zápis hodnotu 0<adresa>,
    jde o adresu bloku adres, pokud má tvar 1<adresa>, pak jde o adresu bloku
    pozic. V¹echny adresy jsou relativní vzhledem k ZAC_ADR. Adresa 0 je tedy adresou
    základního bloku, na nìj¾ se v¹ak nemù¾e vyskytnout odkaz v ¾ádném bloku adres.
   */
  long adresy[POCET_ADRES_V_BLOKU];
} f_blok_adresare_t;

#if PAKUJ_POZICE

/*Struktura popisující typ TPozice (viz cotyvar.h) v souboru, je-li tento typ pakován*/
typedef struct {
  /*Stav ro¹ády - jako v TPozice*/
  u8 roch;
  /*Stav pole mimochodem - jako v TPozice*/
  u8 mimoch;
  /*Je-li bílý na tahu - jako v TPozice*/
  bool bily;
  /*
    Popis ¹achovnice - ¹achovnice 8*8 po øádcích - byte popisuje dvì následující pole.
    Obsah pole je zapsán jako 6+hodnota z TPozice.sch. 
  */
  char sch[32];
} f_tpozice_t;

/*
  Pøevede pozici ze struktury typu TPozice do struktury typu f_tpozice_t.

  parametr pozice vstupní pozice
  parametr fpozice výstupní pozice

  vrací 0 pokud nedojde k chybì, jinak kód chyby daný konstantami v souboru
          obkc.h
 */
int pakuj(TPozice *pozice, f_tpozice_t *fpozice);

/*
  Pøevede pozici ze struktury typu f_tpozice_t do struktury typu TPozice.

  parametr fpozice vstupní pozice
  parametr pozice výstupní pozice

  vrací 0 pokud nedojde k chybì, jinak kód chyby daný konstantami v souboru
          obkc.h
 */
int rozpakuj(f_tpozice_t *fpozice, TPozice *pozice);

#endif

/*Zaèátek blokù adresáøe v souboru - poloha základního bloku.*/
extern long ZAC_ADR;
/*Zaèátek blokù s pozicemi v souboru.*/
extern long ZAC_POZIC;

/*
  Maska, která odfiltruje z prvku pole adresy strutkury typu f_blok_adres_t adresu.
  (Zamaskuje pøípadnou 1 na zaèátku.)
 */
#define BL_MASKA ((long)(1<<(sizeof(long)*8-1)))

#include <stdio.h>

/*
  Porovná pozice a zjistí, jestli jsou shodné.

  parametr a první porovnávaná pozice
  parametr b druhá porovnávaná pozice

  vrací 1, jsou-li pozice stejné, jinak 0.
 */
int stejne_pozice(TPozice *a, TPozice *b);

/*
  Vrací znakový popis figury k èíselnému.

  parametr fig èíselný popis figury.
  vrací znak, který figuru popisuje, malé písmeno v pøípadì èerné figury,
        velké písmeno v pøípadì bílé figury.
 */
char zn_fig(int fig);
/*
  Vypí¹e obsah pozice pøeètené ze souboru.

  parametr file soubor, do nìj¾ bude pozice vypsána
  parametr pozice vypisovaná pozice
  vrací 0, nedojde-li k chybì, jinak kód chyby daný konstantou v obk_ch.h
 */
int dump_f_pozice(FILE *file, f_pozice_t *pozice);

/*
  Vypí¹e pozici do souboru.

  parametr file soubor, do nìj¾ bude pozice vypsána.
  parametr pozice vypisovaná pozice
  vrací 0, nedojde-li k chybì, jinak kód chyby daný konstantou v obk_ch.h
 */
int print_pozice(FILE *file, TPozice *pozice);

#endif

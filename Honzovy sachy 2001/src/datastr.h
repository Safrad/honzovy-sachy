/* Sachov� centrum - Knihovna zah�jen� Petr Ku�era 2000*/
/** Deklarace typ� datov�ch struktur pou�it�ch k reprezentaci
    knihovny zah�jen� v pam�ti.
  */

#ifndef __DATASTR_H__
#define __DATASTR_H__ 1

#include "cotyvar.h"

/** HLOUBKA_ADRESARE - ur�uje hloubku jedn� �rovn� adres��e. */
#define HLOUBKA_ADRESARE 4
/** POCET_ADRES_V_BLOKU - ur�uje po�et adres v jednom bloku adres��e. */
#define POCET_ADRES_V_BLOKU 16 /*2^4*/
/*Konstanta ur�uj�c� masku pro odmaskov�n� prvn�ch HLOUBKA_ADRESARE bit�
 */
#define ZAKLADNI_MASKA 15

/*ur�uje, jestli maj� b�t pozice v souboru pakov�ny, nebo m� b�t ukl�d�n
 p��mo datov� typ TPozice*/
#define PAKUJ_POZICE 1

/** tah_t - popis tahu s ECO a v�hou v�b�ru, pokud je v�ha men�� ne� 0,
    jde o dosud nespecifikovanou v�hu.
*/
typedef struct _tah {
  /*v�ha v�b�ru tahu*/
  char vaha;
  /*p�smeno ze z�pisu ECO pozice vznikl� t�mto tahem*/
  char ECO_pismeno;
  /*��slo ze z�pisu ECO pozice vznikl� t�mto tahem*/
  char ECO_cislo;
  /*dvoubajtov� popis tahu*/
  u16 tah;
  /*po�ad� partie ve zdrojov�m souboru knihovny, v n� byl tah naposledy
    p�id�v�n.*/
  int cis_partie;
  /*Sou�et vah ze v�ech parti�, v nich� byl tah p�id�v�n*/
  int soucet_vah;
  /*1 pokud byl tah v posledn� partii p�id�v�n a jeho v�ha nebyla explicitn�
    ur�ena.*/
  int neurcena;
} tah_t;

/*Po��te�n� velikost pole tahy ve struktu�e pozice_t*/
#define POZICE_TAHY_POCATECNI_VELIKOST 10
/*P��r�stek velikosti pole tahy ve struktu�e pozice_t, p�i jej�m p�ekro�en�*/
#define POZICE_TAHY_DELTA 10

/*Konstanta ur�uj�c�, �e ECO pozice nen� implicitn� A00*/
#define NENI_IMPL_A00 0
/*Konstanta ur�uj�c�, �e ECO pozice je A00 implicitn� v r�mci knihovny*/
#define KNIH_IMPL_A00 1
/*Konstanta ur�uj�c�, �e ECO pozice je A00 implicitn� pouze v r�mci dan� partie*/
#define PART_IMPL_A00 2

/** pozice_t - struktura popisuj�c� pozici s tahy, kter� z n� vych�z�*/
typedef struct _pozice {
  /*Odkaz na dal�� pozici v seznamu pozic*/
  struct _pozice *dalsi_pozice;
  /*Ha�ovac� kl�� pozice popsan� touto strukturou*/
  u32 hasovaci_klic;
  /*p�smeno ze z�pisu ECO popisovan� pozice*/
  char ECO_pismeno;
  /*��slo ze z�pisu ECO popisovan� pozice*/
  char ECO_cislo;
  /*Ur�uje, jestli ECO pozice je implicitn� A00,
    je-li NENI_IMPL_A00, pak nejde o implicitn� A00,
    je-li ECO_A00&KNIH_IMPL_A00, pak jde o implicitn� A00 v r�mci cel� knihovny,
    je-li ECO_A00&PART_IMPL_A00, pak se jedn� o A00 implicitn� pouze v r�mci dan� partie
  */
  char ECO_A00;
  /*popisovan� pozice*/
  TPozice pozice;
  /*po�et tah� vedouc�ch z t�to pozice*/
  int pocet_tahu;
  /*sou�et vah ur�en�ch tah� v aktu�ln� partii*/
  int soucet_vah;
  /*po�et tah� s neur�enou vahou v sou�asn� partii*/
  int pocet_neurcenych;
  /*po�et tah� s nenulovou vahou v sou�asn� partii*/
  int pocet_nenulovych;
  /*po�et parti�, v nich� se pozice vyskytla*/
  int pocet_partii;
  /*velikost pole tahy*/
  int vel_tahu;
  /*pole obsahuj�c� tahy vedouc� z t�to pozice*/
  tah_t *tahy;
  /*vypo�ten� pozice v souboru*/
  long poloha;
  /*��slo partie, v n� byl p�id�n posledn� tah s nenulovou nebo neur�enou vahou,
    nebo -1, pokud tam takov� tah nen�*/
  int part_nenul_tah;
} pozice_t;

/** blok_pozice_t - struktura popisuj�c� obsah bloku s pozicemi, kter�
    maj� stejn� ha�ovac� kl��.
 */
typedef struct _blok_pozic {
  /*Po�et pozic je� jsou ulo�en� v t�to struktu�e*/
  int pocet_pozic;
  /*Ha�ovac� kl�� spole�n� v�em pozic�m ulo�en�m v t�to struktu�e*/
  u32 hasovaci_klic;
  /*Poloha bloku v souboru s knihovnou (vypo�teno t�sn� p�ed ulo�en�m)*/
  long poloha;
  /*Po�et byt�, kter� blok v souboru bude zab�rat*/
  long delka_bloku;
  /*Ukazatel na hlavu spojov�ho seznamu s pozicemi, kter� jsou v tomto bloku ulo�eny.*/
  pozice_t *pozice;
} blok_pozic_t;

/** blok_adresare_t - struktura popisuj�c� obsah bloku s adres��em v pam�ti.*/
typedef struct _blok_adresare {
  /*Poloha bloku v souboru s knihovnou zah�jen� (vypo�teno t�sn� p�ed ulo�en�m).*/
  long poloha;
  /*
    �rove� bloku ve struktu�e popisuj�c� obsah knihovny, ur�uje, kter� skupina
    bit� v ha�ovac�m kl��i se pou�ije p�i p�echodu na dal�� �rove�.
  */
  int uroven;
  /*
    Ukazatel� na bloky pozic, kter� jsou ur�eny hodnotou ha�ovac�ho kl��e.
    Ha�ovac� kl�� je ulo�en implicitn� pomoc� indexu v poli, jde o 16 prvkov� pole,
    na ka�d� �rovni se tedy �t�p� podle �tve�ice bit�, pokud poskl�d�me p��slu�n�
    �tve�ice za sebou, dostaneme prefix kl��e dlouh� 4*(uroven+1) bit�.
    Pokud je prvek pole NULL, znamen� to bu�, �e pozice s kl��em za��naj�c�m
    dan�m prefixem se dosud nevyskytla, nebo �e je v�ce pou�it�ch kl��� s dan�m
    prefixem, v tom p��pad� mus� b�t p��slu�n� prvek pole adresy_adresaru ne NULL.
    Pokud je prvek ne NULL, je jedin� kl�� s dan�m prefixem, v tom p��pad� mus�
    b�t prvek v poli adresy_adresaru se stejn�m indexem NULL.
   */
  blok_pozic_t *adresy_pozic[POCET_ADRES_V_BLOKU];
  /*
    Ukazatele na bloky adres��� dal��ch �rovn� v hierarchick� struktu�e popisuj�c�
    knihovnu zah�jen�.
   */
  struct _blok_adresare *adresy_adresaru[POCET_ADRES_V_BLOKU];
} blok_adresare_t;


/*N�sleduj�c� typy slou�� k popisu stavu souboru.*/

/*typ popisuj�c� tah ulo�en� do souboru*/
typedef struct _f_tah {
  /*Pravd�podobnost, s jakou m� b�t tah vyb�r�n*/
  char vaha;
  /*P�smeno z k�du ECO tahu*/
  char ECO_pismeno;
  /*��slo z k�du ECO tahu*/
  char ECO_cislo;
  /*Dvoubajtov� popis tahu*/
  u16 tah;
} f_tah_t;

/*Struktura popisuj�c� pozici ulo�enou v souboru s knohovnou zah�jen�.*/
typedef struct {
  /*
    Dal�� pozice ve spojov�m seznamu pozic z jednoho bloku.
    Skute�n� adresa dal�� pozice je ZAC_ADR+dalsi_pozice.
   */
  long dalsi_pozice;
  /*
    Stav hry popisovan� touto pozic�.
   */
  TPozice pozice;
  /*char ECO_pismeno;*/
  /*char ECO_cislo;*/
  /*Po�et tah�, kter� vedou z t�to pozice.*/
  int pocet_tahu;
  /*Pole s tahy vedouc�mi z t�to pozice.*/
  f_tah_t *tahy;
} f_pozice_t;

/*Struktura popisuj�c� blok pozic ulo�en� v souboru.*/
typedef struct _f_blok_pozic {
  /*D�lka bloku v bytech (=sizeof(f_blok_pozic_t)+pocet_pozic*sizeof(f_pozice_t).*/
  long delka_bloku;
  /*Po�et pozic ulo�en�ch v tomto bloku.*/
  int pocet_pozic;
  /*Ha�ovac� kl�� spole�n� v�em pozic�m v bloku.*/
  u32 hasovaci_klic;
  /*
    Pozice prvn� pozice bloku v souboru - posun od za��tku pozic.
    Skute�n� adresa v souboru je ZAC_POZIC+adr_pozic.
   */
  long adr_pozic;
} f_blok_pozic_t;

/*Struktura popisuj�c� blok adres��e ulo�en� v souboru.*/
typedef struct _f_blok_adresare {
  /*Poloha pole adresy v souboru. Skute�n� adresa za��tku pole je ZAC_POZIC+zac_adres.*/
  long zac_adres;
  /*�rove� bloku v hierarchick� struktu�e adres��e.*/
  int uroven;
  /*
    Pole s adresami n�sleduj�c�ch blok�. Pokud je p��slu�n� prvek 0, nen�sleduje
    v jeho sm�ru ��dn� dal�� blok. Pokud m� bitov� z�pis hodnotu 0<adresa>,
    jde o adresu bloku adres, pokud m� tvar 1<adresa>, pak jde o adresu bloku
    pozic. V�echny adresy jsou relativn� vzhledem k ZAC_ADR. Adresa 0 je tedy adresou
    z�kladn�ho bloku, na n�j� se v�ak nem��e vyskytnout odkaz v ��dn�m bloku adres.
   */
  long adresy[POCET_ADRES_V_BLOKU];
} f_blok_adresare_t;

#if PAKUJ_POZICE

/*Struktura popisuj�c� typ TPozice (viz cotyvar.h) v souboru, je-li tento typ pakov�n*/
typedef struct {
  /*Stav ro��dy - jako v TPozice*/
  u8 roch;
  /*Stav pole mimochodem - jako v TPozice*/
  u8 mimoch;
  /*Je-li b�l� na tahu - jako v TPozice*/
  bool bily;
  /*
    Popis �achovnice - �achovnice 8*8 po ��dc�ch - byte popisuje dv� n�sleduj�c� pole.
    Obsah pole je zaps�n jako 6+hodnota z TPozice.sch. 
  */
  char sch[32];
} f_tpozice_t;

/*
  P�evede pozici ze struktury typu TPozice do struktury typu f_tpozice_t.

  parametr pozice vstupn� pozice
  parametr fpozice v�stupn� pozice

  vrac� 0 pokud nedojde k chyb�, jinak k�d chyby dan� konstantami v souboru
          obkc.h
 */
int pakuj(TPozice *pozice, f_tpozice_t *fpozice);

/*
  P�evede pozici ze struktury typu f_tpozice_t do struktury typu TPozice.

  parametr fpozice vstupn� pozice
  parametr pozice v�stupn� pozice

  vrac� 0 pokud nedojde k chyb�, jinak k�d chyby dan� konstantami v souboru
          obkc.h
 */
int rozpakuj(f_tpozice_t *fpozice, TPozice *pozice);

#endif

/*Za��tek blok� adres��e v souboru - poloha z�kladn�ho bloku.*/
extern long ZAC_ADR;
/*Za��tek blok� s pozicemi v souboru.*/
extern long ZAC_POZIC;

/*
  Maska, kter� odfiltruje z prvku pole adresy strutkury typu f_blok_adres_t adresu.
  (Zamaskuje p��padnou 1 na za��tku.)
 */
#define BL_MASKA ((long)(1<<(sizeof(long)*8-1)))

#include <stdio.h>

/*
  Porovn� pozice a zjist�, jestli jsou shodn�.

  parametr a prvn� porovn�van� pozice
  parametr b druh� porovn�van� pozice

  vrac� 1, jsou-li pozice stejn�, jinak 0.
 */
int stejne_pozice(TPozice *a, TPozice *b);

/*
  Vrac� znakov� popis figury k ��seln�mu.

  parametr fig ��seln� popis figury.
  vrac� znak, kter� figuru popisuje, mal� p�smeno v p��pad� �ern� figury,
        velk� p�smeno v p��pad� b�l� figury.
 */
char zn_fig(int fig);
/*
  Vyp�e obsah pozice p�e�ten� ze souboru.

  parametr file soubor, do n�j� bude pozice vyps�na
  parametr pozice vypisovan� pozice
  vrac� 0, nedojde-li k chyb�, jinak k�d chyby dan� konstantou v obk_ch.h
 */
int dump_f_pozice(FILE *file, f_pozice_t *pozice);

/*
  Vyp�e pozici do souboru.

  parametr file soubor, do n�j� bude pozice vyps�na.
  parametr pozice vypisovan� pozice
  vrac� 0, nedojde-li k chyb�, jinak k�d chyby dan� konstantou v obk_ch.h
 */
int print_pozice(FILE *file, TPozice *pozice);

#endif

/* �achov� centrum - Knihovna zah�jen� Petr Ku�era 2000*/
/* Deklarace funkc� pot�ebn�ch pro p��stup do knihovny zah�jen� na nejvy��� �rovni
 */

#ifndef __KNIHOVNA_H__
#define __KNIHOVNA_H__ 1

#include "volby.h"
#include "cotyvar.h"

/*P�ed pou�it�m knihovny nutno volat init_knihovna()

  parametr jmsoub ur�uje jm�no souboru, v n�m� je obsa�ena p�elo�en� knihovna
  vrac� 0 p�i �sp�n� inicializaci, jinak k�d chyby ur�en� konstanatami
        v souboru obk_ch.h
 */
int init_knihovna(char *jmsoub);

/*Hled� tah ze zadan� pozice

  parametr pozice obsahuje pozici, z n� je tah hled�n
  parametr pole eco mus� b�t dlouh� alespo� 4, obsahuje p�i nalezen� tahu
           ECO pozice vznikl� zahr�n�m tahu.
  vrac� 0 pokud nebyla pozice nalezena, nebo dvoubajtov� popis tahu, pokud byl tah nalezen.
        tah je vyb�r�n n�hodn� s pravd�podobnost� danou jeho vahou. V p��pad� nalezen� tahu
        obsahuje pole eco ECO pozice vznikl� zahr�n�m vr�cen�ho tahu
*/
u16 query_knihovna(TPozice *pozice, char *eco);

/*
  Hled� tah v knihovn� zah�jen�

  parametr pozice obsahuje pozici, z n� je tah hled�n
  vrac� 0 pokud nebyla pozice nalezena, nebo dvoubajtov� popis tahu, pokud byl tah nalezen.
        tah je vyb�r�n n�hodn� s pravd�podobnost� danou jeho vahou.

  Pozn�mka: 0 nen� k�d ��dn�ho tahu.
*/
u16 KnihDejTah(TPozice *pozice);

#include "datastr.h"

/*
  Vr�t� v�echny tahy, kter� jsou v knihovn� zah�jen� k dispozici pro danou pozici.

  parametr pozice obsahuje pozici, z n� jsou tahy hled�ny
  parametr tahy po �sp�n�m hled�n� obsahuje ukazatel na pole s tahy,
           kter� jsou k dispozici pro danou pozici. Pole je vytvo�eno
           vol�n�m malloc ve funkci v p��pad�, �e je pozice v knihovn�
           nalezena a �e z n� vede n�jak� tah s nenulovou pravd�podobnost�,
           v opa�n�m p��pad� je vr�ceno m�sto pole NULL.
           Pokud je parametr tahy NULL, je vr�cena hodnota CH_NULL
  parametr pocet_tahu obsahuje p�i �sp�n�m nalezen� pozice po�et vr�cen�ch
           tah�
  vrac� 0 pokud nedojde k chyb� (nenalezen� pozice nen� br�no jako chyba,
          stejn� jako neinicializovan� knihovna v dob� vol�n�), jinak k�d
          chyby dan� konstantami v souboru obk_ch.h
 */
int knih_dej_vsechny_tahy(TPozice *pozice, f_tah_t **tahy, int *pocet_tahu);

#endif

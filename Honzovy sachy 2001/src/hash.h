/* ©achové centrum - Knihovna zahájení Petr Kuèera 2000*/
/* ha¹ovací funkce pøevzata z hashtab.h - Jan Nìmec*/

#ifndef __HASH_H__
#define __HASH_H__

#include "cotyvar.h"

/*Struktura popisující konstanty pou¾ité pøi výpoètu ha¹ovacího klíèe
  - pøevzato od Jana Nìmce ze souboru hashtab.h
 */
typedef struct {
  u32 f[13][h8];
  u32 bily;
  u32 roch[16];
  u32 mimoch[h5+1];
} hash_nahoda_t;

/*Promìnná, která obsahuje konstanty pou¾ité pøi výpoètu ha¹ovacího klíèe
 */
extern hash_nahoda_t hash_nahoda;

/*Funkce puèítá ha¹ovací klíè pro pozici
  - pøevzato od Jana Nìmce ze souboru hashtab.h
  
  parametr poz pozice, pro ni¾ je poèítán ha¹vací klíè
  vrací ha¹ovací klíè pozice poz
 */
u32 obk_hash(TPozice *poz);

/*Provede inicializaci mechanismu výpoètu ha¹ovacího klíèe
  vyplnìním promìnné hash_nahoda náhodnými velièinami

  vrací 0 pøi úspì¹né inicializaci, jinak kód chyby daný souborem obk_ch.h
 */
int obk_init_hash();

#endif

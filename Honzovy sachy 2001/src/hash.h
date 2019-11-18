/* �achov� centrum - Knihovna zah�jen� Petr Ku�era 2000*/
/* ha�ovac� funkce p�evzata z hashtab.h - Jan N�mec*/

#ifndef __HASH_H__
#define __HASH_H__

#include "cotyvar.h"

/*Struktura popisuj�c� konstanty pou�it� p�i v�po�tu ha�ovac�ho kl��e
  - p�evzato od Jana N�mce ze souboru hashtab.h
 */
typedef struct {
  u32 f[13][h8];
  u32 bily;
  u32 roch[16];
  u32 mimoch[h5+1];
} hash_nahoda_t;

/*Prom�nn�, kter� obsahuje konstanty pou�it� p�i v�po�tu ha�ovac�ho kl��e
 */
extern hash_nahoda_t hash_nahoda;

/*Funkce pu��t� ha�ovac� kl�� pro pozici
  - p�evzato od Jana N�mce ze souboru hashtab.h
  
  parametr poz pozice, pro ni� je po��t�n ha�vac� kl��
  vrac� ha�ovac� kl�� pozice poz
 */
u32 obk_hash(TPozice *poz);

/*Provede inicializaci mechanismu v�po�tu ha�ovac�ho kl��e
  vypln�n�m prom�nn� hash_nahoda n�hodn�mi veli�inami

  vrac� 0 p�i �sp�n� inicializaci, jinak k�d chyby dan� souborem obk_ch.h
 */
int obk_init_hash();

#endif

/* ©achové centrum - Knihovna zahájení Petr Kuèera 2000*/
/* ha¹ovací funkce pøevzatá z hashtab.c - Jan Nìmec*/

#include <stdlib.h>

#include "hash.h"
#include "cotyvar.h"

/*Struktura s konstantami pou¾itými pøi výpoètu ha¹ovacího klíèe*/
hash_nahoda_t hash_nahoda;

u32 obk_hash(TPozice *pos)
{
  int i,j;
  u32 navrat;
  
  navrat=0;
  for(i=0;i<=7;i++)
    for(j=0;j<=7;j++)
      navrat^=hash_nahoda.f[pos->sch[a1+j+i*10]+6][a1+j+i*10];
  navrat^=hash_nahoda.mimoch[pos->mimoch];
  navrat^=hash_nahoda.roch[pos->roch];
  if(pos->bily)navrat^=hash_nahoda.bily;
  return navrat;
}

#define MOJE_RAND() (((rand()&255)<<24)|((rand()&255)<<16)|((rand()&255)<<8)|(rand()&255))

int obk_init_hash()
{
  int i,k;
#if defined(OBK_SRAND)&&OBK_SRAND>0
  srand(30245);
#endif
  for(i=0;i<=12;i++) {
    for(k=a1;k<=h8;k++) {
	hash_nahoda.f[i][k]=MOJE_RAND();
    }
  }
  for(i=0;i<=h5;i++) {
    hash_nahoda.mimoch[i]=MOJE_RAND();
  }
  hash_nahoda.bily=MOJE_RAND();
  for(i=0;i<=15;i++) {
    hash_nahoda.roch[i]=MOJE_RAND();
  }
  return 0;
}


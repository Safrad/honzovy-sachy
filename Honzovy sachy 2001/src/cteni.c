#include <stdio.h>
#include <stdlib.h>

#include "hash.h"
#include "obk_ch.h"
#include "datastr.h"
#include "cteni.h"
#include "cotyvar.h"

FILE *cteni_soubor=NULL;

int init_cteni(char *jmsoub)
{
  /*int i,j;*/
  cteni_soubor=fopen(jmsoub,"rb");
  if(cteni_soubor==NULL) {
    return CH_CT_SOUBOR;
  }
  fread(&ZAC_ADR,sizeof(long),1,cteni_soubor);
  fread(&ZAC_POZIC,sizeof(long),1,cteni_soubor);
  fread(&hash_nahoda,sizeof(hash_nahoda_t),1,cteni_soubor);
  /*fprintf(stderr,"hash_nahoda:\n");
  for(i=0; i<13; i++) {
    for(j=0; j<h8; j++)
      fprintf(stderr,"%d ",hash_nahoda.f[i][j]);
    fprintf(stderr,"\n");
  }
  fprintf(stderr,"%d\n",hash_nahoda.bily);
  for(i=0; i<16; i++) {
    fprintf(stderr,"%d ",hash_nahoda.roch[i]);
  }
  fprintf(stderr,"\n");
  for(i=0; i<h5+1; i++) {
    fprintf(stderr,"%d ",hash_nahoda.mimoch[i]);
  }
  fprintf(stderr,"\n");*/
  return 0;
}

int cti_blok_adresare(f_blok_adresare_t *blok_adr, long adresa)
{
  FILE *file=cteni_soubor;
  int i;
  fseek(file,ZAC_ADR+adresa,SEEK_SET);
  fread(&(blok_adr->uroven),sizeof(int),1,file);
  blok_adr->zac_adres=ftell(file)-ZAC_ADR;
  for(i=0; i<POCET_ADRES_V_BLOKU; i++) {
    fread(blok_adr->adresy+i,sizeof(long),1,file);
  }
  return 0;
}

int cti_blok_pozic(f_blok_pozic_t *blok, long adresa)
{
  FILE *file=cteni_soubor;
  fseek(file,ZAC_POZIC+adresa,SEEK_SET);
  fread(&(blok->delka_bloku),sizeof(long),1,file);
  fread(&(blok->pocet_pozic),sizeof(int),1,file);
  fread(&(blok->hasovaci_klic),sizeof(u32),1,file);
  blok->adr_pozic=ftell(file)-ZAC_POZIC;
  return 0;
}

int cti_pozice(f_pozice_t *pozice, long adresa)
{
  FILE *file=cteni_soubor;
#if PAKUJ_POZICE
  f_tpozice_t fpozice;
  int ch;
#endif
  fseek(file,ZAC_POZIC+adresa,SEEK_SET);
#if PAKUJ_POZICE
  fread(&fpozice,sizeof(f_tpozice_t),1,file);
  ch=rozpakuj(&fpozice,&(pozice->pozice));
  if(ch)
    return ch;
#else
  fread(&(pozice->pozice),sizeof(TPozice),1,file);
#endif
  /*fread(&(pozice->ECO_pismeno),1,1,file);
    fread(&(pozice->ECO_cislo),1,1,file);*/
  fread(&(pozice->pocet_tahu),sizeof(int),1,file);
  pozice->tahy=(f_tah_t*)malloc(sizeof(f_tah_t)*pozice->pocet_tahu);
  fread(pozice->tahy,sizeof(f_tah_t),pozice->pocet_tahu,file);
  pozice->dalsi_pozice=ftell(file)-ZAC_POZIC;
  return 0;
}

int hledej_pozici(TPozice *pozice, f_pozice_t *f_pozice)
{
  u32 hasovaci_klic=obk_hash(pozice);
  u32 maska=ZAKLADNI_MASKA;
  f_blok_adresare_t blok_adr;
  int i,j,ch;
  u32 cast_klice=(hasovaci_klic&maska);
  /*printf("hk=%d\n",hasovaci_klic);*/

  ch=cti_blok_adresare(&blok_adr,0);
  for(i=0; i<sizeof(u32)*8; i+=HLOUBKA_ADRESARE) {
    cast_klice=((hasovaci_klic&maska)>>i);
    maska<<=HLOUBKA_ADRESARE;
    if(blok_adr.adresy[cast_klice]&BL_MASKA) {
      f_blok_pozic_t blok;
      long adr;
      ch=cti_blok_pozic(&blok,((~BL_MASKA)&blok_adr.adresy[cast_klice]));
      if(ch)
        return ch;
      if(blok.hasovaci_klic!=hasovaci_klic)
        return CH_CT_FAIL;
      adr=blok.adr_pozic;
      for(j=0; j<blok.pocet_pozic; j++) {
        ch=cti_pozice(f_pozice,adr);
        if(stejne_pozice(pozice,&(f_pozice->pozice))) {
          return 0;
        }
        adr=f_pozice->dalsi_pozice;
      }
      break;
    }
    else if(blok_adr.adresy[cast_klice]) {
      ch=cti_blok_adresare(&blok_adr,blok_adr.adresy[cast_klice]);
      if(ch)
        return ch;
      continue;
    }
    else
      break;
  }
  return CH_CT_FAIL;
}




/* ©achové centrum - Knihovna zahájení Petr Kuèera 2000*/

#include "datastr.h"
#include "obk_ch.h"
#include "hash.h"
#include <stdlib.h>

long ZAC_ADR;
long ZAC_POZIC;

int stejne_pozice(TPozice *a, TPozice *b)
{
    int i;
    if(a->mimoch!=b->mimoch||
       a->roch!=b->roch||
       a->bily!=b->bily)
	return 0;
    for(i=20;i<h8;i++) {
	if(i%10>0&&i%10<9&&a->sch[i]!=b->sch[i])
	    return 0;
    }
    return 1;
}

char zn_fig(int fig)
{
  int ret=0;
  switch(abs(fig)) {
  case 0:
    ret='-';
    break;
  case 1:
    ret=(fig<0?'p':'P');
    break;
  case 2:
    ret=(fig<0?'j':'J');
    break;
  case 3:
    ret=(fig<0?'s':'S');
    break;
  case 4:
    ret=(fig<0?'v':'V');
    break;
  case 5:
    ret=(fig<0?'d':'D');
    break;
  case 6:
    ret=(fig<0?'k':'K');
    break;    
  default:
    ret='@';
  }
  return ret;
}

int dump_f_pozice(FILE *file,f_pozice_t *pozice)
{
  int i;
  /*fprintf(file,"ECO=%c%d%d\n",pozice->ECO_pismeno,
    pozice->ECO_cislo/10,pozice->ECO_cislo%10);*/
  fprintf(file,"pocet_tahu=%d\n",pozice->pocet_tahu);
  fprintf(file,"tahy:\n");
  for(i=0; i<pozice->pocet_tahu; i++) {
    fprintf(file,"%d (ECO=%c%c%c) (vaha=%d)\n",(int)pozice->tahy[i].tah,
            pozice->tahy[i].ECO_pismeno, (char)('0'+pozice->tahy[i].ECO_cislo/10),
            (char)('0'+pozice->tahy[i].ECO_cislo%10),(int)pozice->tahy[i].vaha);
  }
  fprintf(file,"bily=%d\n",pozice->pozice.bily);
  fprintf(file,"mimoch=%d\n",pozice->pozice.mimoch);
  fprintf(file,"roch=");
  if(8&pozice->pozice.roch)
    fputc('v',file);
  else
    fputc('x',file);
  if(4&pozice->pozice.roch)
    fputc('m',file);
  else
    fputc('x',file);
  if(2&pozice->pozice.roch)
    fputc('V',file);
  else
    fputc('x',file);
  if(1&pozice->pozice.roch)
    fputc('M',file);
  else
    fputc('x',file);
  fputc('\n',file);
  for(i=99; i>=20; i--) {
    if(i%10>0&&i%10<9) {
      fprintf(file," %c",zn_fig(pozice->pozice.sch[(i/10)*10+9-i%10]));
      if(i%10==1)
	fprintf(file,"\n");
    }
  }
  fprintf(file,"\n");
  return 0;
}

int print_pozice(FILE *file,TPozice *pozice)
{
  int i;
  fprintf(file,"bily=%d\n",pozice->bily);
  fprintf(file,"mimoch=%d\n",pozice->mimoch);
  fprintf(file,"roch=");
  if(8&pozice->roch)
    fputc('v',file);
  else
    fputc('x',file);
  if(4&pozice->roch)
    fputc('m',file);
  else
    fputc('x',file);
  if(2&pozice->roch)
    fputc('V',file);
  else
    fputc('x',file);
  if(1&pozice->roch)
    fputc('M',file);
  else
    fputc('x',file);
  fputc('\n',file);
  for(i=20; i<100; i++) {
    if(i%10>0&&i%10<9) {
      fprintf(file," %c",zn_fig(pozice->sch[i]));
      if(i%10==8)
	fprintf(file,"\n");
    }
  }
  fprintf(file,"\n");
  return 0;
}

#if PAKUJ_POZICE

int pakuj(TPozice *pozice, f_tpozice_t *fpozice)
{
  int i,j;
  
  fpozice->roch=pozice->roch;;
  fpozice->mimoch=pozice->mimoch;
  fpozice->bily=pozice->bily;
  j=0;
  for(i=21; i<99; i++) {
    if(i%10==0||i%10==9)
      continue;
    if((i%10)%2) { /*liché*/
      fpozice->sch[j]=6+pozice->sch[i];
    }
    else { /*sudé*/
      fpozice->sch[j++]|=((6+pozice->sch[i])<<4);
    }
  }
  return 0;
}

int rozpakuj(f_tpozice_t *fpozice, TPozice *pozice)
{
  int i,j,maska=15;
  
  pozice->roch=fpozice->roch;
  pozice->mimoch=fpozice->mimoch;
  pozice->bily=fpozice->bily;
  j=0;
  for(i=0; i<21; i++) {
    pozice->sch[i]=pozice->sch[119-i]=100;
  }
  for(i=21; i<99; i++) {
    if(i%10==0||i%10==9) {
      pozice->sch[i]=100;
    }
    else {
      pozice->sch[i++]=(maska&fpozice->sch[j])-6;
      pozice->sch[i]=(((maska<<4)&fpozice->sch[j++])>>4)-6;
    }
  }
  return 0;
}

#endif

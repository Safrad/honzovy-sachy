/*********************************************************/
/* kontrola.c - test pripustnosti pozice                 */
/* 6.1. 2001 Jan Nemec                                   */
/*********************************************************/
#include <stdlib.h>
#include "volby.h"
#include "cotyvar.h"
#include "globruti.h"
#include "generato.h"
#include "lokruti.h"
#include "kontrola.h"
int MultiSach(TPozice *pos, bool bilemu){
/***********************************************************/
/* Vice nez dvojsach neni pripustny                        */
/***********************************************************/
 s8 k;
 s8 *p;

 if (bilemu) k=6; else k=-6;
 for(p=pos->sch+a1;*p!=k;p++);
 return PocetOhrozeni(p, !bilemu);
}
int PripustnaPozice(TPozice *pos)
/***********************************************************/
/* PripustnaPozice - otestuje pozici a vrati 0, pokud je   */
/* smysluplna a pripustna, jinak kladny chybovy kod		   */
/* podle typu chyby										   */
/***********************************************************/
 { s8 fgr[13];
   int x,y;

 for (y=0;y<=11;(y==1) ? y=10 : y++) 
  for (x=0;x<10;x++) 
   if(pos->sch[x+y*10]!=100) return(K_ChybaOkraje);
 /*nahore a dole v rantlu museji byt stovky*/
 for(y=2;y<=9;y++)  
  for(x=0;x<=9;x+=9) 
   if(pos->sch[x+y*10]!=100) return(K_ChybaOkraje);
/*na stranach v rantlu museji byt stovky*/
 for(y=2;y<=9;y++)
  for(x=1;x<=8;x++)
   if(pos->sch[x+y*10]>6 || pos->sch[x+y*10]<-6) 
    return(K_NeznamyKod);
/*uvnitr museji byt figurky nebo prazdna policka*/
for (x=0;x<=12;x++) fgr[x]=0; 
for (x=0;x<=119;x++) 
  if (pos->sch[x]>-7 && pos->sch[x]<7) fgr[pos->sch[x]+6]++;
if (fgr[0]!=1) return K_PocetCernychKralu;
if (fgr[1]+fgr[5]>9) return K_MocCernychDam;
if (fgr[2]+fgr[5]>10) return K_MocCernychVezi;
if (fgr[3]+fgr[5]>10) return K_MocCernychStrelcu;
if (fgr[4]+fgr[5]>10) return K_MocCernychKoni;
if (fgr[5]>8) return K_MocCernychPescu;
if (fgr[7]>8) return K_MocBilychPescu;
if (fgr[8]+fgr[7]>10) return K_MocBilychKoni;
if (fgr[9]+fgr[7]>10) return K_MocBilychStrelcu;
if (fgr[10]+fgr[7]>10) return K_MocBilychVezi;
if (fgr[11]+fgr[7]>9) return K_MocBilychDam;
if (fgr[12]!=1) return K_PocetBilychKralu;
for (y=0,x=0;x<=5;x++)y+=fgr[x];
if (y>16) return K_MocCernych;
for (y=0,x=7;x<=12;x++)y+=fgr[x];
if (y>16) return K_MocBilych;
for (x=a1;x<=h1;x++) if (abs(pos->sch[x])==1) return K_PesecNaOkraji;
for (x=a8;x<=h8;x++) if (abs(pos->sch[x])==1) return K_PesecNaOkraji;
if (pos->bily && Sach(false,&(pos->sch[0]))) return K_KralVSachu;
if (!pos->bily && Sach(true,&(pos->sch[0]))) return K_KralVSachu;
if ((pos->roch & 8) && (pos->sch[a8]!=-4 || pos->sch[e8]!=-6)) return K_VCRoch;
if ((pos->roch & 2) && (pos->sch[a1]!=4 || pos->sch[e1]!=6)) return K_VBRoch;
if ((pos->roch & 4) && (pos->sch[h8]!=-4 || pos->sch[e8]!=-6)) return K_MCRoch;
if ((pos->roch & 1) && (pos->sch[h1]!=4 || pos->sch[e1]!=6)) return K_MBRoch;
if((x=MultiSach(pos, pos->bily))>2)return K_MocSachu;
return K_VPoradku;}

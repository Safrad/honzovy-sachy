/* ©achové centrum - Knihovna zahájení Petr Kuèera 2000*/
/* Definice øetìzcù se slovním popisem chybových hlá¹ení programu
 */

#include "obk_ch.h"

const char *chyby_str[CH_MAX]={
  "Zadna chyba.",
  "Chyba pri inicializaci",
  "Nedostatek pameti",
  "Predcasny konec souboru",
  "Spatne zapsane cislo tahu",
  "Pokus o tah hrace, ktery neni na tahu",
  "Cislo tahu neni platne",
  "Syntakticka chyba",
  "Neocislovany tah bileho",
  "Volana funkce dostala neocekavany NULL",
  "Za soucasneho stavu nelze provest rosadu",
  "Tah neni konzistentni se zadanou pozici",
  "Tah nelze na dane pozici zahrat",
  "Prazdne pole, pole mimo sachovnici nebo cizi kamen na poli",
  "Kolize ECO (stejne pozice, ruzne ECO)",
  "Kolize vah u tahu",
  "Konec varianty, kdyz zadna varianta neni",
  "Soucet vah tahu presahl 100",
  "Nesouhlasi pocet neurcenych",
  "Soucet vah!=100",
  "Nepodarilo se otevrit vystupni soubor",
  "Nepodarilo se otevrit vstupni soubor",
  "Jedna partie musi tvorit strom!",
  "Varovani! Nebile znaky mezi partiemi (zacatek)",
  "Varovani! Nebile znaky mezi partiemi (konec)",
  "Varovani! Pozice, z niz vede tento tah, se jiz vyskytla a vede z ni tah s nenulovou vahou",
  "Varianty musi byt ukonceny pred ukoncenim partie"
};

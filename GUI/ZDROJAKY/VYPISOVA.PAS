unit Vypisova;
interface
uses StdCtrls,Forms,WinTypes,WinProcs,SysUtils,VypisCfg,Myslitel,Sachovni,Form;
Type
TVypisovac=class
 public
  Krokovat:Boolean;
  cfg:TVypisCfg;
  Memo:TMemo;
  JmenoSouboru:String[80];
  f:TextFile;
  otevren:boolean;
  constructor create(nMemo:TMemo);
  destructor destroy;
  procedure ZavriSoubor;
  procedure SouborDlg;
  procedure Prepis(co:string);
  procedure Pokracuj(co:string);
  procedure writestr(co:string);
  procedure writestrodsaz(co:string;odsaz:Integer);
  procedure writeZacatekIterace(var MeziData:TMeziData);
  procedure writeZacatekAlfaBeta(Alfa,Beta:Longint;Hloubka,HloubkaRekurze:Integer);
  procedure writeZacatekAlfaBetaIterace(Alfa,Beta:Longint;Hloubka,HloubkaRekurze:Integer);
  procedure WriteDobryTah(var Mezidata:TMeziData);
  procedure WritePocitamTah(var Mezidata:TMezidata;odsaz:Integer);
 end;
var Vypisovac:TVypisovac;
implementation
uses vypform, vypSoub;
 constructor TVypisovac.Create(nMemo:TMemo);
  begin
   inherited create;
   Memo:=nMemo;
   Cfg:=NormalVypisCfg;
   Krokovat:=False;
  end;
 destructor TVypisovac.Destroy;
  begin
   if otevren then ZavriSoubor;
   inherited destroy
  end;
 procedure TVypisovac.Pokracuj(co:string);
  begin
   ZavriSoubor;
   JmenoSouboru:=co;
   assign(f,co);
   {$I-}
   append(f);
   {$I+}
   if IOResult<>0 then rewrite(f);
   otevren:=true
  end;
 procedure TVypisovac.Prepis(co:string);
  begin
   ZavriSoubor;
   JmenoSouboru:=co;
   assign(f,co);
   rewrite(f);
   otevren:=true;
  end;
 procedure TVypisovac.ZavriSoubor;
  begin
   if otevren then begin otevren:=false;close(f) end
  end;
 procedure TVypisovac.SouborDlg;
  Var V:TViditelnost;
  begin
   UlozStavFormu(V);
   SkryjFormy;
   vypsoubform.ShowModal;
   ObnovStavFormu(V);
  end;
 procedure TVypisovac.WriteStr(co:string);
  begin
   if not Cfg.osPovoleno then
    begin
    { ZpravovaKrabice(' procedure TVypisovac.WriteStr','Chyba programu',mb_ok or mb_iconhand);

     Tady nebylo správné hlásit chybu. Jeden pøíkaz pro výpis
     mùže zpùsobit 2 øádky, po prvním mùže uživatel
     (pøi režimu krokování) vypnout výpisy
     a na druhém by to tady hodilo nesmyslné chybové hlášení.
    }
     exit;
    end;
   if Cfg.osDoSouboru then
    begin
     if not Otevren then SouborDlg;
     if Cfg.osDoSouboru then
      begin
       writeln(f,co)
      end
    end;
   if Cfg.osDoOkna then
    begin
     if Cfg.osRadkuOkna<=Memo.Lines.Count then Memo.Lines.Delete(0);
     Memo.Lines.Add(co)
    end;
   if Krokovat then VypisForm.Stuj
  end;
 procedure TVypisovac.writestrodsaz(co:string;odsaz:Integer);
 var s:string[50];
  begin
   s:='';
   for odsaz:=Odsaz downto 1 do s:=s+' ';
   Writestr(s+co)
  end;
 procedure TVypisovac.writeZacatekAlfaBeta(Alfa,Beta:Longint;Hloubka,HloubkaRekurze:Integer);
  begin
   writeStrOdsaz('Alfa_Beta do hloubky '+IntToStr(Hloubka),HloubkaRekurze+2);
   writeStrOdsaz('Alfa='+HodnotaToStr(Alfa)+' Beta='+HodnotaToStr(Beta),HloubkaRekurze+2)
  end;
 procedure TVypisovac.writeZacatekAlfaBetaIterace(Alfa,Beta:Longint;Hloubka,HloubkaRekurze:Integer);
  begin
   writeStrOdsaz('Iterace Alfa_Beta do hloubky '+IntToStr(Hloubka),HloubkaRekurze+3);
   writeStrOdsaz('Alfa='+HodnotaToStr(Alfa)+' Beta='+HodnotaToStr(Beta),HloubkaRekurze+3)
  end;
 procedure TVypisovac.writeZacatekIterace(var MeziData:TMeziData);
  begin
   writeStr('  Zaèínám iteraci do hloubky '+IntToStr(MeziData.Hloubka));
   writeStr('  Alfa='+HodnotaToStr(Mezidata.Alfa)+' Beta='+HodnotaToStr(Mezidata.Beta))
  end;
 procedure TVypisovac.WriteDobryTah(var Mezidata:TMeziData);
  begin
   writestr('   Tah '+TTah1ToStr(Mezidata.Tahy.T[1],Mezidata.Pozice)+' je zlepšující');
   writestr('   Alfa='+HodnotaToStr(Mezidata.Alfa)+' Beta='+HodnotaToStr(Mezidata.Beta))
  end;
 procedure TVypisovac.WritePocitamTah(var Mezidata:TMezidata;odsaz:Integer);
  begin
   writeStrOdsaz('Poèítám tah '+TTah1ToStr(Mezidata.Tahy.T[Mezidata.I],Mezidata.Pozice),odsaz);
  end;
end.

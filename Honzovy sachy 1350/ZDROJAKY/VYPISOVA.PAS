unit Vypisova;

interface

uses StdCtrls, Forms, WinTypes, WinProcs, SysUtils, VypisCfg, Myslitel,
  Sachovni, Form;

Type
  TVypisovac = class
  public
    Krokovat: Boolean;
    cfg: TVypisCfg;
    Memo: TMemo;
    JmenoSouboru: String[80];
    f: TextFile;
    otevren: Boolean;
    constructor create(nMemo: TMemo);
    destructor Destroy; override;
    procedure ZavriSoubor;
    procedure SouborDlg;
    procedure Prepis(co: string);
    procedure Pokracuj(co: string);
    procedure writestr(co: string);
    procedure writestrodsaz(co: string; odsaz: Integer);
    procedure writeZacatekIterace(var MeziData: TMeziData);
    procedure writeZacatekAlfaBeta(Alfa, Beta: Longint;
      Hloubka, HloubkaRekurze: Integer);
    procedure writeZacatekAlfaBetaIterace(Alfa, Beta: Longint;
      Hloubka, HloubkaRekurze: Integer);
    procedure WriteDobryTah(var MeziData: TMeziData);
    procedure WritePocitamTah(var MeziData: TMeziData; odsaz: Integer);
  end;

var
  Vypisovac: TVypisovac;

implementation

uses vypform, vypSoub;

constructor TVypisovac.create(nMemo: TMemo);
begin
  inherited create;
  Memo := nMemo;
  cfg := NormalVypisCfg;
  Krokovat := False;
end;

destructor TVypisovac.Destroy;
begin
  if otevren then
    ZavriSoubor;
  inherited Destroy
end;

procedure TVypisovac.Pokracuj(co: string);
begin
  ZavriSoubor;
  JmenoSouboru := co;
  assign(f, co);
{$I-}
  append(f);
{$I+}
  if IOResult <> 0 then
    rewrite(f);
  otevren := true
end;

procedure TVypisovac.Prepis(co: string);
begin
  ZavriSoubor;
  JmenoSouboru := co;
  assign(f, co);
  rewrite(f);
  otevren := true;
end;

procedure TVypisovac.ZavriSoubor;
begin
  if otevren then
  begin
    otevren := False;
    close(f)
  end
end;

procedure TVypisovac.SouborDlg;
Var
  V: TViditelnost;
begin
  UlozStavFormu(V);
  SkryjFormy;
  vypsoubform.ShowModal;
  ObnovStavFormu(V);
end;

procedure TVypisovac.writestr(co: string);
begin
  if not cfg.osPovoleno then
  begin
    { ZpravovaKrabice(' procedure TVypisovac.WriteStr','Chyba programu',mb_ok or mb_iconhand);

      Tady nebylo správné hlásit chybu. Jeden pøíkaz pro výpis
      mùže zpùsobit 2 øádky, po prvním mùže uživatel
      (pøi režimu krokování) vypnout výpisy
      a na druhém by to tady hodilo nesmyslné chybové hlášení.
    }
    exit;
  end;
  if cfg.osDoSouboru then
  begin
    if not otevren then
      SouborDlg;
    if cfg.osDoSouboru then
    begin
      writeln(f, co)
    end
  end;
  if cfg.osDoOkna then
  begin
    if cfg.osRadkuOkna <= Memo.Lines.Count then
      Memo.Lines.Delete(0);
    Memo.Lines.Add(co)
  end;
  if Krokovat then
    VypisForm.Stuj
end;

procedure TVypisovac.writestrodsaz(co: string; odsaz: Integer);
var
  s: string[50];
begin
  s := '';
  for odsaz := odsaz downto 1 do
    s := s + ' ';
  writestr(s + co)
end;

procedure TVypisovac.writeZacatekAlfaBeta(Alfa, Beta: Longint;
  Hloubka, HloubkaRekurze: Integer);
begin
  writestrodsaz('Alfa_Beta do hloubky ' + IntToStr(Hloubka),
    HloubkaRekurze + 2);
  writestrodsaz('Alfa=' + HodnotaToStr(Alfa) + ' Beta=' + HodnotaToStr(Beta),
    HloubkaRekurze + 2)
end;

procedure TVypisovac.writeZacatekAlfaBetaIterace(Alfa, Beta: Longint;
  Hloubka, HloubkaRekurze: Integer);
begin
  writestrodsaz('Iterace Alfa_Beta do hloubky ' + IntToStr(Hloubka),
    HloubkaRekurze + 3);
  writestrodsaz('Alfa=' + HodnotaToStr(Alfa) + ' Beta=' + HodnotaToStr(Beta),
    HloubkaRekurze + 3)
end;

procedure TVypisovac.writeZacatekIterace(var MeziData: TMeziData);
begin
  writestr('  Zaèínám iteraci do hloubky ' + IntToStr(MeziData.Hloubka));
  writestr('  Alfa=' + HodnotaToStr(MeziData.Alfa) + ' Beta=' +
    HodnotaToStr(MeziData.Beta))
end;

procedure TVypisovac.WriteDobryTah(var MeziData: TMeziData);
begin
  writestr('   Tah ' + TTah1ToStr(MeziData.Tahy.T[1], MeziData.Pozice) +
    ' je zlepšující');
  writestr('   Alfa=' + HodnotaToStr(MeziData.Alfa) + ' Beta=' +
    HodnotaToStr(MeziData.Beta))
end;

procedure TVypisovac.WritePocitamTah(var MeziData: TMeziData; odsaz: Integer);
begin
  writestrodsaz('Poèítám tah ' + TTah1ToStr(MeziData.Tahy.T[MeziData.I],
    MeziData.Pozice), odsaz);
end;

end.

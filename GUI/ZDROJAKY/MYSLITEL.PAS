unit Myslitel;
{$DEFINE JENBRANI}

interface

uses coty;

type
  TStyl = (Nulovy, Normalni, OnDopredu, JaDopredu);
  { Nulovy     - û·dnÈ v˝pisy
    Normalni   - myslÌm na sv˘j tah
    OnDopredu  - odhaduji soupe¯˘v tah p¯i myölenÌ dop¯edu
    JaDopredu  - poËÌt·m svou odpovÏÔ na oËek·van˝ soupe¯˘v tah p¯i myölenÌ
    dop¯edu
  }
  TAkce = procedure;
  TDejtahProc = procedure(t1: ttah1);
  THodnotyTahu = array [1 .. maxtah] of longint;
  THloubkyTahu = array [1 .. maxtah] of byte;

  TMeziData = record
    Alfa, Beta: longint;
    { Alfa a Beta PÿED poËÌt·nÌm prvnÌho nedopoËtenÈho tahu;
      Cena je hodnota poslednÌho zlepöujÌcÌho tahu }
    Hloubka, I, Platnych: Integer;
    { PoslednÌ nedopoËten· hloubka; PrvnÌ nedopoËten˝ tah v Hloubce,
      PoËet tah˘, pro nÏû m· smysl Hodnoty }
    Dojeto: Boolean;
    Pozice: TPozice;
    { Pozice, k nÌû vede tah uûivatele, na kter˝ se p¯ipravuji }
    Tahy: TTahy; { Vöechny tahy z pozice, dosavadnÌ nejlepöÌ je prvnÌ,
      prvnÌch Platnych je set¯ÌdÏno podle v˝hodnosti. }
    Hodnoty: array [1 .. maxtah] of longint;
  end;

  PMeziSeznam = ^TMeziSeznam;

  TMeziSeznam = record
    Data: TMeziData;
    n: PMeziSeznam;
  end;

  PMezivypocet = ^TMezivypocet;

  TMezivypocet = class
  public
    Seznam: PMeziSeznam;
    procedure Pridej(var Data: TMeziData); { InteligentnÏ p¯id· do Seznamu
      InteligentnÏ znamen·: Nejsou-li tam, p¯id· je
      Jsou-li tam do menöÌ hloubky, p¯epÌöe jimi ten ˙daj
      Jsou-li tam do stejnÈ nebo vÏtöÌ hloubky, neudÏl· nic }
    procedure DejInfo(var Pozice: TPozice; var AlgCfg: TAlgCfg;
      var Data: TMeziData);
    { InteligentnÏ najde v Seznamu informace o Pozici.
      InteligentnÏ znamen·, ûe pokud tam nejsou, tak rozumnÏ doplnÌ ˙daje s·m.
      Hloubka a I budou 0, tahy budou platnÈ tahy a Cena hodnota Pozice }
    procedure SmazSeznam;
    destructor Destroy; override;
  end;

  TMyslitel = class
  private
    VolanoMusimKoncit: word; { Abych mÏl kontrolu nad Ëasem v dobÏ v˝poËtu,
      vol·m metodu MusimKoncit:boolean. Ta otestuje Ëas a jednou za n vol·nÌ
      p¯ed· ¯ÌzenÌ Wokn˘m, aby mohly distribuovat ËekajÌcÌ zpr·vy.
      Ve VolanoMusimKoncit je poËet tÏch vol·nÌ. M˘ûe obËas p¯etÈct, ale to
      v˘bec nevadÌ. }
    KoncovyCas: longint; { »as, kdy musÌm ukonËit v˝poËet a t·hnout. }
    Ukoncit: Boolean; { VypröÌ-li Ëas, vynutÌ-li si uûivatel tah nebo myslÌm-li
      dop¯edu a v d˘sledku uûivatelova tahu se zaavol· PrestanDopredu }
    AkceKonecDopredu: TAkce; { Co m·m p¯i ukonËenÌ myölenÌ dop¯edu udÏlat,
      pointer naproceduru bez parametr˘. Je-li nil, nevol· se (tj. û·dn· akce).
      V˝znam: Chci udÏlat nÏco, kv˘li Ëemu je t¯eba p¯estat myslet dop¯edu
      nap¯. ukonËit program nebo p¯em˝ölet norm·lnÏ. MyölenÌ dop¯edu
      ale nejde jen tak z procedury zastavit. Je t¯eba zavolat
      PrestanDopredu, to nastavÌ Ukoncit na true a aû se zpracujÌ ve
      Windows vöechny zpr·vy, dostane se k lÌzu myölenÌ dop¯edu a samo
      se ukonËÌ (neboù Ukoncit=true). Jako poslednÌ akci zavol· tuto
      proceduru, kter· vykon· to, co se p˘vodnÏ mÏlo udÏlat. }
    Partie: PJednoPartie;
    { musÌm si pamatovat kus historie, kv˘li pravidlu 50 tah˘
      a pravidlu opakov·nÌ pozic (a abych t¯eba v˘bec poznal vÏËn˝ öach).
      Sem si p¯ekopÌruji pot¯ebnou Ë·st partie z objektu öachovnice p¯i kaûdÈm
      vol·nÌ myslÌcÌ procedury (DejTah nebo MysliOTahDopredu). }
    Pozice: TPozice; { Sem si p¯ekopÌruji pozici z objektu öachovnice
      p¯i kaûdÈm vol·nÌ myslÌcÌ procedury (DejTah nebo MysliOTahDopredu). }
    MeziVypocet: TMezivypocet; { Sem si uloûÌm v˝sledky MysliOTahDopredu.
      MusÌ b˝t nil, pokud jsem nic nevypoËÌtal !!!! NenÌ-li nil, dealokuje se.
      Pouûije se v DejTah a to pokud platÌ a) i b)
      a) MeziVypocet <> nil
      b) Pozice "=" nPozice (nap¯. uûivatel mohl zmÏnit pozici) }
    Hraji: TDejtahProc; { Tuhle procedure zavol·m kdyû t·hnu. Tato procedura by
      mÏla jen poslat zpr·vu na okno, v LParam bude zakÛdovan˝ tah. }
    function Transformuj(co: longint): longint;
    { P¯evede hodnotu pozice tak aby z n. p˘ltahem mat bylo (n+1). p˘ltahem
      mat. Jinak by algoritmus nepreferoval vûdy nejkratöÌ cestu k vÌtÏzstvÌ. }
    function MusimKoncit: Boolean;
    function Alfa_Beta(Alfa, Beta: longint; Hloubka: Integer;
      var Dojeto: Boolean; HloubkaRekurze: Integer; Styl: TStyl;
      var pocitam, Nejlepsi: ShortString): longint;
    { Alfa-beta metoda do zadanÈ hloubky s dopoËtem do tichÈ pozice
      s kask·dovit˝m pr˘chodem a se zapamatov·v·nÌm hodnot tah˘ vypoËten˝ch aû
      do konce. }
    function Alfa_Beta_Vrazi(Alfa, Beta: longint; Hloubka: Integer;
      var Dojeto: Boolean; HloubkaRekurze: Integer; Styl: TStyl): longint;
    { DopoËet do tichÈ pozice, nejv˝öe vöak do zadanÈ hloubky. Alfa-beta metoda
      s kask·dovit˝m pr˘chodem a se zapamatov·v·nÌm hodnot tah˘ vypoËten˝ch aû
      do tichÈho konce. }
    Procedure globBIterace(var MeziData: TMeziData; HorsiTahy: longint;
      Styl: TStyl; var pocitam, Nejlepsi: ShortString);
    Procedure globCIterace(var MeziData: TMeziData; HorsiTahy: longint;
      Styl: TStyl; var pocitam, Nejlepsi: ShortString);
    Procedure VypisVariantu(Tah1: ttah1; Var pocitam: ShortString; PocPos: byte;
      Styl: TStyl; Hloubka: Integer);
    Procedure VypisNejlepsi(Tah1: ttah1; Var Nejlepsi: ShortString;
      Styl: TStyl);
  public
    MyslimDopredu, Myslim: Boolean; { Stav }
    CasNaTah: longint;
    AlgCfg: TAlgCfg; { Konfigurace algoritmu. }
    constructor Create(nHraji: TDejtahProc);
    destructor Destroy; override;
    procedure DejTah(var npozice: TPozice; var npartie: ppartie);
    { P¯ekopÌruje si parametry, p¯em˝ölÌ. Aû uplyne Ëas nebo je zavol·no
      HrajTed, zavol· Hraji(nejlepöÌ tah) a hned potom se ukonËÌ.
    }
    procedure HrajTed;
    { Jen nastavÌ private promÏnnÈ a procedura konËÌ. V d˘sledku nastavenÌ
      promÏnn˝ch objekt okamûitÏ t·hne (je-li na tahu). }
    procedure MysliOTahDopredu(var npozice: TPozice; npartie: ppartie);
    { Dealokuje MeziVypocet (nenÌ-li nil) a znovu vytvo¯Ì.
      MusÌ b˝t explicitnÏ zastaveno n·sledujÌcÌ metodou. V nÏkter˝ch p¯Ìpadech
      se ale ukonËÌ sama (pokud t¯eba najde cestu k matu na vöechny soupe¯ovy
      tahy). Dealokuje MeziVypocet (nenÌ-li nil). }
    procedure PrestanDopredu(nAkceKonecDopredu: TAkce);
    { ZastavÌ v˝poËet dop¯edu. To co vypoËÌtal si pamatuje v MeziVypocet.
      Myslitel konËÌcÌ v˝poËet pak zavol· AkceKonecDopredu. }
  end;

function HodnotaToStr(hodnota: longint): string22;

implementation

uses WinTypes, WinProcs, Forms, Rutiny, Rychle, Ohodnoc, Form, SysUtils,
  Sachovni, UKnih, Dialogs, Vypisova, NormForm, DoprForm;

const
  mat = 2147483645;
  NeHodnota = -2147483647;

  { procedure Ladena;
    var w:word;
    begin
    asm
    mov ax,sp
    mov w,ax
    end;
    form1.label33.caption:=inttostr(w);
    end; }
function HodnotaToStr(hodnota: longint): string22;
begin
  if (hodnota < mat - 100) and (hodnota > 100 - mat) then
    result := IntToStr(hodnota)
  else
  begin { blÌûÌ se mat }
    if hodnota = NeHodnota then
    begin
      result := 'NedopoËteno';
      exit
    end;
    if mat + 1 = hodnota then
    begin
      result := '+NekoneËno';
      exit
    end;
    if -mat - 1 = hodnota then
    begin
      result := '-NekoneËno';
      exit
    end;
    if hodnota > 0 then
      result := 'BÌl˝'
    else
      result := '»ern˝';
    if (hodnota = mat) or (hodnota = -mat) then
    begin
      result := result + ' vyhr·l';
      exit;
    end;
    if hodnota > 0 then
      hodnota := mat - hodnota
    else
      hodnota := mat + hodnota;
    hodnota := (hodnota + 1) shr 1;
    result := result + ' d· mat ' + IntToStr(hodnota) + '. tahem.'
  end
end;

{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
{ !!!                  Procedury pro pr·ci s PJednoPartie               !!! }
{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
procedure CopyKusPartie(Kde: TPozice; Odkud: ppartie; var Kam: PJednoPartie);
{ ZkopÌruje Ë·st partie. Jde od souËasnÈho stavu doleva aû po prvnÌ tah
  pÏöcem nebo branÌ. Budoucnost tj. to, co je vpravo nezkopÌruje.
  Je-li poslednÌ tah branÌ nebo tah pÏöcem bude Kam Nil. }
var
  pom, pom2: PJednoPartie;
begin
  Kam := Nil;
  if (Odkud <> nil) { MÏlo by nastat vûdy... } then
  begin
    while (Odkud^.l <> nil) and not trvalaa_zmena(Kde, Odkud^.t2) do
    begin
      new(pom);

      pom^.l := Kam;
      pom^.t2 := Odkud^.t2;
      Kam := pom;
      Odkud := Odkud^.l;
      tahni_zpet(Kde, Kam^.t2);
    end; { TeÔ m·m spoj·k v kam, ale je t¯eba ho otoËit }
    pom := nil;
    while Kam <> nil do
    begin
      pom2 := Kam^.l;
      Kam^.l := pom;
      pom := Kam;
      Kam := pom2;
    end;
    Kam := pom;
    { OtoËenÌ dokonËeno }
  end
end;

procedure DonePJednoPartie(var p: PJednoPartie);
{ Dealokace celÈho spoj·ku }
var
  pom: PJednoPartie;
begin
  while p <> nil do
  begin
    pom := p^.l;
    dispose(p);

    p := pom;
  end
end;

procedure PridejTah(var Kam: PJednoPartie; co: ttah2);
var
  pom: PJednoPartie;
begin
  new(pom);

  pom^.t2 := co;
  pom^.l := Kam;
  Kam := pom
end;

procedure UberTah(var Odkud: PJednoPartie);
var
  pom: PJednoPartie;
begin
  if Odkud <> nil then
  begin
    pom := Odkud^.l;
    dispose(Odkud);

    Odkud := pom
  end
end;

function PoloRemis(Partie: PJednoPartie; var Pozice: TPozice): Boolean;
{ Doch·zÌ v Partii k opakov·nÌ poslednÌ Pozice nebo aspoÚ k 50 tich˝m tah˘m ? }
  function stejne(var pos1, pos2: TPozice): Boolean;
  var
    x: byte;
  begin
    result := true;
    if pos1.stav.b <> pos2.stav.b then
      result := false
    else if pos1.stav.mimoch <> pos2.stav.mimoch then
      result := false
    else
      for x := 0 to 63 do
        if pos1.sch[0, x] <> pos2.sch[0, x] then
        begin
          result := false;
          exit
        end;
  end;

var
  th: shortint;
  pompos: TPozice;
begin
  th := 100;
  result := false;
  pompos := Pozice;
  while (Partie <> nil) and (th > 0) do
  begin
    dec(th);
    if trvalaa_zmena(pompos, Partie^.t2) then
      break;
    tahni_zpet(pompos, Partie^.t2);
    if stejne(Pozice, pompos) then
    begin
      result := true;
      break
    end;
    Partie := Partie^.l;
  end;
  if th = 0 then
    result := true
end;

{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
{ !!!                            TMeziVypocet                           !!! }
{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
procedure TMezivypocet.Pridej(var Data: TMeziData);
var
  pom: PMeziSeznam;
begin
  pom := Seznam;
  while (pom <> nil) and (CMPPozice(Data.Pozice, pom^.Data.Pozice) <> 0) do
    pom := pom^.n;
  if pom = nil then
  begin
    new(pom);
    pom^.Data := Data;
    pom^.n := Seznam;
    Seznam := pom
  end
  else
  begin
    if (Data.Hloubka > pom^.Data.Hloubka) or (Data.Hloubka = pom^.Data.Hloubka)
      and (Data.I > pom^.Data.I) then
      pom^.Data := Data
  end
end;

procedure TMezivypocet.DejInfo(var Pozice: TPozice; var AlgCfg: TAlgCfg;
  var Data: TMeziData);
var
  pom: PMeziSeznam;
begin
  pom := Seznam;
  while (pom <> nil) and (CMPPozice(Pozice, pom^.Data.Pozice) <> 0) do
    pom := pom^.n;
  if pom = nil then
  begin
    Data.Hloubka := 0;
    Data.Dojeto := false;
    Data.I := 1;
    Rychle.NalezTahy(Pozice, Data.Tahy);
    Data.Pozice := Pozice; { asi zbyteËnÈ, ale pro jistotu }
    Data.Platnych := 1;
    Data.Hodnoty[1] := HodnotaPozice(Pozice, AlgCfg);
    if Data.Hodnoty[1] > mat - AlgCfg.Okno then
    begin
      Data.Beta := Data.Hodnoty[1] + 1;
      Data.Alfa := Data.Hodnoty[1] - AlgCfg.Okno
    end
    else if Data.Hodnoty[1] < -mat + AlgCfg.Okno then
    begin
      Data.Alfa := Data.Hodnoty[1] - 1;
      Data.Beta := Data.Hodnoty[1] + AlgCfg.Okno
    end
    else
    begin
      Data.Alfa := Data.Hodnoty[1] - AlgCfg.Okno;
      Data.Beta := Data.Hodnoty[1] + AlgCfg.Okno
    end;
  end
  else
    Data := pom^.Data
end;

procedure TMezivypocet.SmazSeznam;
var
  pom: PMeziSeznam;
begin
  while Seznam <> nil do
  begin
    pom := Seznam^.n;
    dispose(Seznam);
    Seznam := pom
  end
end;

destructor TMezivypocet.Destroy;
begin
  SmazSeznam;
  inherited Destroy;
end;

{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
{ !!!                               TMyslitel                           !!! }
{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }
constructor TMyslitel.Create(nHraji: TDejtahProc);
begin
  inherited Create;
  MeziVypocet := TMezivypocet.Create;
  CasNaTah := 5000;
  Hraji := nHraji;
end;

destructor TMyslitel.Destroy;
begin
  MeziVypocet.Free;
  inherited Destroy;
end;

procedure TMyslitel.MysliOTahDopredu(var npozice: TPozice; npartie: ppartie);
var
  MeziDataJeho: TMeziData;
  Procedure Jedeme(bily: Boolean);
  var
    poprve: Boolean;
    t2: ttah2;
    MeziDataMoje: TMeziData;
    PomHloubka, K, Dobrych: Integer;
    pocitam, Nejlepsi: ShortString;
  label SkoroKonec;
  begin
    pocitam := '';
    Nejlepsi := '';
    poprve := true;
    repeat
      PomHloubka := MeziDataJeho.Hloubka;
      if poprve or (MeziDataJeho.Tahy.Poctah > 1) then
      begin
        { <LadÌcÌ v˝pisy> }
        if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDopredu then
          Vypisovac.WriteStr(' P¯em˝ölÌm co soupe¯ zahraje...');
        { </LadÌcÌ v˝pisy> }
        { <BÏûnÈ v˝pisy> }
        if Vypisovac.Cfg.mdPovoleno then
          MysDopForm.Label4.Caption := 'VÏötÌm soupe¯˘v tah.';
        { </BÏûnÈ v˝pisy> }
        poprve := false;
      end;
      if MeziDataJeho.Tahy.Poctah > 1 then
        repeat
          if bily then
            globBIterace(MeziDataJeho, AlgCfg.DoprHorsiTahy, OnDopredu, pocitam,
              Nejlepsi)
          else
            globCIterace(MeziDataJeho, AlgCfg.DoprHorsiTahy, OnDopredu, pocitam,
              Nejlepsi) until Ukoncit or MeziDataJeho.Dojeto or
              (MeziDataJeho.Hloubka > PomHloubka)
        else
          MeziDataJeho.Dojeto := true;

      Application.Processmessages;

      { <LadÌcÌ v˝pisy> }
      if MeziDataJeho.Platnych < 1 then
        MeziDataJeho.Platnych := 1;
      Dobrych := 0;
      repeat
        inc(Dobrych)
      until (Dobrych = MeziDataJeho.Tahy.Poctah) or
        (Dobrych = MeziDataJeho.Platnych) or
        (MeziDataJeho.Hodnoty[1] < -mat + 100) or
        (MeziDataJeho.Hodnoty[1] > mat - 100) or
      { MusÌm si d·vat pozor na p¯eteËenÌ LongIntu }
        (MeziDataJeho.Hodnoty[Dobrych + 1] < MeziDataJeho.Hodnoty[1] -
        AlgCfg.DoprHorsiTahy) or
        (MeziDataJeho.Hodnoty[Dobrych + 1] > MeziDataJeho.Hodnoty[1] +
        AlgCfg.DoprHorsiTahy);
      for K := 1 to Dobrych do
      begin
        if Ukoncit then
          break;
        if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDopredu then
          Vypisovac.WriteStr(' Chyst·m se na soupe¯˘v tah ' +
            TTah1ToStr(MeziDataJeho.Tahy.t[K], Pozice));
        { </LadÌcÌ v˝pisy> }
        { <BÏûnÈ v˝pisy> }
        if Vypisovac.Cfg.mdPovoleno then
          MysDopForm.Label4.Caption := 'PoËÌt·m odpovÏÔ na ' +
            TTah1ToStr(MeziDataJeho.Tahy.t[K], Pozice) + '.';
        { </BÏûnÈ v˝pisy> }
        DoplnTah(MeziDataJeho.Tahy.t[K], Pozice, t2);
        PridejTah(Partie, t2);
        tahni(Pozice, MeziDataJeho.Tahy.t[K]);
        { A teÔ myslÌm na odpovÏÔ }
        MeziVypocet.DejInfo(Pozice, AlgCfg, MeziDataMoje);
        if (not Ukoncit) and (not MeziDataMoje.Dojeto) and
          (MeziDataMoje.Hloubka <= MeziDataJeho.Hloubka) and
          (MeziDataMoje.Tahy.Poctah > 0) then
        begin
          repeat
            if bily then
              globCIterace(MeziDataMoje, AlgCfg.NormHorsiTahy, JaDopredu,
                pocitam, Nejlepsi)
            else
              globBIterace(MeziDataMoje, AlgCfg.DoprHorsiTahy, JaDopredu,
                pocitam, Nejlepsi) until (Ukoncit) or (MeziDataMoje.Dojeto) or
                (MeziDataMoje.Hloubka >= MeziDataJeho.Hloubka);
            MeziVypocet.Pridej(MeziDataMoje);
            if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDopredu then
              Vypisovac.WriteStr(' Moje odpovÏÔ: ' +
                TTah1ToStr(MeziDataMoje.Tahy.t[1], Pozice));
          end;
          tahni_zpet(Pozice, t2);
          UberTah(Partie);
        end
        until Ukoncit;
      end;

      var
        I: Integer;
        t2: ttah2;
        t1: ttah1;
      begin
        { !!!!!!!!!!!!!!LadÏnÌ!!!!!!!!!!!! }
        if form1.sachovnice.bilyalg.MyslimDopredu or
          form1.sachovnice.cernyalg.MyslimDopredu or
          form1.sachovnice.bilyalg.Myslim or form1.sachovnice.cernyalg.Myslim
        then { jeden z nich jsem j·, ale to nevadÌ }
          ZpravovaKrabice('M·m myslet dop¯edu a zatÌm se uû myslÌ',
            'Hrozn· chyba !!!', mb_ok);
        { !!!!!!!!!!!!!!!!!!!!!!!!!! }
        KoncovyCas := mat + 2;
        MyslimDopredu := true;
        { Mat+2 je totiû z·roveÚ nejvÏtöÌ LongInt, m˘ûu tedy myslet po¯·d. }
        if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
          Vypisovac.WriteStr('ZaËÌn·m myslet dop¯edu...');
        AkceKonecDopredu := nil;
        Ukoncit := false;
        MeziVypocet.SmazSeznam; { Seznam m˘ûe b˝t nil, ale to nevadÌ. }
        Pozice := npozice;
        CopyKusPartie(Pozice, npartie, Partie);
        MeziVypocet.DejInfo(Pozice, AlgCfg, MeziDataJeho);
        { Je sice jistÈ, ûe Pozice v meziv˝poËtu nebude, to ale nevadÌ, stejnÏ to
          najde tahy atd... }
        if MeziDataJeho.Tahy.Poctah > 0 then
        begin
          if AlgCfg.PouzitKnihovnu then
          begin
            I := 1;
            while I <= MeziDataJeho.Tahy.Poctah do
            begin
              DoplnTah(MeziDataJeho.Tahy.t[I], Pozice, t2);
              tahni(Pozice, MeziDataJeho.Tahy.t[I]);
              if Knihovna.DejTah(Pozice, t1) then
              begin
                { nebudu poËÌtat odpovÏÔ na tah, kter˝ vede k pozici, co m·m v knihovnÏ }
                MeziDataJeho.Tahy.t[I] := MeziDataJeho.Tahy.t
                  [MeziDataJeho.Tahy.Poctah];
                dec(MeziDataJeho.Tahy.Poctah);
                dec(I)
              end;
              tahni_zpet(Pozice, t2);
              inc(I)
            end;
            Application.Processmessages;
          end; { Od PouzitKnihovnu }
          { Asi nenÌ nutnÈ, ale to osek·v·nÌ p¯ece jen chvÌli trvalo... }
          if (MeziDataJeho.Tahy.Poctah > 0) and not Ukoncit
          then { mohl jsem totiû vymazat vöechny tahy }
            if hb in Pozice.stav.b then
              Jedeme(true)
            else
              Jedeme(false);
        end;
        DonePJednoPartie(Partie);
        if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
          Vypisovac.WriteStr('KonËÌm myölenÌ dop¯edu');
        Vypisovac.ZavriSoubor; { NevadÌ, jestli nenÌ otev¯en˝ }
        if assigned(AkceKonecDopredu) then
          postmessage(form1.handle, wm_Zavolej, 0, longint(@AkceKonecDopredu));
        MyslimDopredu := false;
      end;

      Procedure TMyslitel.VypisVariantu(Tah1: ttah1; Var pocitam: ShortString;
        PocPos: byte; Styl: TStyl; Hloubka: Integer);
      begin
        { <BÏûnÈ v˝pisy> }
        case Styl of
          Normalni:
            if Vypisovac.Cfg.mnPovoleno and (Vypisovac.Cfg.mnpHloubka >= Hloubka)
            then
            begin
              pocitam[0] := AnsiChar(PocPos);
              pocitam := pocitam + ' ' + TTah1ToStr(Tah1, Pozice);
              MysNormForm.Label6.Caption := pocitam;
            end;
          OnDopredu:
            if Vypisovac.Cfg.mdPovoleno and (Vypisovac.Cfg.mdpHloubka >= Hloubka)
            then
            begin
              pocitam[0] := AnsiChar(PocPos);
              pocitam := pocitam + ' ' + TTah1ToStr(Tah1, Pozice);
              MysDopForm.Label7.Caption := pocitam;
            end;
          JaDopredu:
            if Vypisovac.Cfg.mdPovoleno and (Vypisovac.Cfg.mdpHloubka >= Hloubka)
            then
            begin
              pocitam[0] := AnsiChar(PocPos);
              pocitam := pocitam + ' ' + TTah1ToStr(Tah1, Pozice);
              MysDopForm.Label20.Caption := pocitam;
            end;
        end;
        { </BÏûnÈ v˝pisy> }
      end;

      Procedure TMyslitel.VypisNejlepsi(Tah1: ttah1; Var Nejlepsi: ShortString;
        Styl: TStyl);
      begin
        { <BÏûnÈ v˝pisy> }
        case Styl of
          Normalni:
            if Vypisovac.Cfg.mnPovoleno then
              if Vypisovac.Cfg.mnnHloubka > 0 then
                MysNormForm.Label8.Caption := TTah1ToStr(Tah1, Pozice)
                  + Nejlepsi;
          OnDopredu:
            if Vypisovac.Cfg.mdPovoleno then
              if Vypisovac.Cfg.mdnHloubka > 0 then
                MysDopForm.Label9.Caption := TTah1ToStr(Tah1, Pozice) +
                  Nejlepsi;
          JaDopredu:
            if Vypisovac.Cfg.mdPovoleno then
              if Vypisovac.Cfg.mnnHloubka > 0 then
                MysDopForm.Label22.Caption := TTah1ToStr(Tah1, Pozice)
                  + Nejlepsi;
        end;
        { </BÏûnÈ v˝pisy> }
      end;

      Procedure TMyslitel.globBIterace(var MeziData: TMeziData;
        HorsiTahy: longint; Styl: TStyl; var pocitam, Nejlepsi: ShortString);
      { Volat pouze hraje-li bÌl˝.
        ProvedenÌ jednÈ iterace v OkÈnku (Alfa,Beta). }
      var
        JeTah, Dj: Boolean;
        I, K: Integer;
        PocPos: byte;
        t2: ttah2;
        { hodnota:LongInt; }
        PomTah: ttah1;
        PomHodnota: longint;
      begin
        if MeziData.Dojeto then
          exit;
        PocPos := length(pocitam);
        Nejlepsi := '';
        { <BÏûnÈ v˝pisy> }
        case Styl of
          Normalni:
            if Vypisovac.Cfg.mnPovoleno then
              MysNormForm.Label2.Caption := IntToStr(MeziData.Hloubka);
          OnDopredu:
            if Vypisovac.Cfg.mdPovoleno then
              MysDopForm.Label11.Caption := IntToStr(MeziData.Hloubka);
          JaDopredu:
            if Vypisovac.Cfg.mdPovoleno then
              MysDopForm.Label16.Caption := IntToStr(MeziData.Hloubka);
        end;
        { </BÏûnÈ v˝pisy> }
        { <LadÌcÌ v˝pisy> }
        if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
          (Vypisovac.Cfg.osHloubka > 0) then
          case Styl of
            Normalni:
              if Vypisovac.Cfg.osNormalni then
                Vypisovac.WriteZacatekIterace(MeziData);
            OnDopredu, JaDopredu:
              if Vypisovac.Cfg.osDopredu then
                Vypisovac.WriteZacatekIterace(MeziData);
          end;
        { </LadÌcÌ v˝pisy> }
        MeziData.Dojeto := true;
        JeTah := false;
        if MeziData.I = 1 then
          MeziData.Platnych := 1;
        for I := MeziData.I to MeziData.Tahy.Poctah do
        begin
          MeziData.I := I;
          { <BÏûnÈ v˝pisy> }
          VypisVariantu(MeziData.Tahy.t[I], pocitam, PocPos, Styl, 1);
          { </BÏûnÈ v˝pisy> }
          { <LadÌcÌ v˝pisy> }
          if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
            (Vypisovac.Cfg.osHloubka > 1) then
            if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
              Vypisovac.Cfg.osDopredu and
              ((Styl = OnDopredu) or (Styl = JaDopredu)) then
            begin
              Vypisovac.WritePocitamTah(MeziData, 4)
            end;
          { </LadÌcÌ v˝pisy> }
          DoplnTah(MeziData.Tahy.t[I], Pozice, t2);
          tahni(Pozice, MeziData.Tahy.t[I]);
          PridejTah(Partie, t2);
          if PoloRemis(Partie, Pozice) then
            MeziData.Hodnoty[I] := 0
          else
          begin
            MeziData.Hodnoty[I] := Alfa_Beta(MeziData.Alfa, MeziData.Beta,
              MeziData.Hloubka, Dj, 2, Styl, pocitam, Nejlepsi);
            if MeziData.Hodnoty[I] <> NeHodnota then
              if MeziData.Hodnoty[I] > mat - 100 then
                dec(MeziData.Hodnoty[I])
              else if MeziData.Hodnoty[I] < -mat + 100 then
                inc(MeziData.Hodnoty[I]);
            if not Dj then
              MeziData.Dojeto := false; { nedopoËetl-li jsem aspoÚ 1 tah,
              je to celÈ nedopoËtenÈ }
          end;
          UberTah(Partie);
          tahni_zpet(Pozice, t2);
          if MeziData.Hodnoty[I] = NeHodnota then
          begin
            MeziData.Dojeto := false;
            pocitam[0] := AnsiChar(PocPos);
            exit
          end;
          if MeziData.Hodnoty[I] > MeziData.Alfa then
          begin
            { 2. zmÏna } { probubl·m dobr˝m tahem dop¯edu a to i v p¯ÌpadÏ, ûe nenÌ v (alfa,beta) }
            K := I;
            while (K > 1) and (MeziData.Hodnoty[K - 1] < MeziData.Hodnoty[K]) do
            begin
              PomTah := MeziData.Tahy.t[K];
              PomHodnota := MeziData.Hodnoty[K];
              MeziData.Tahy.t[K] := MeziData.Tahy.t[K - 1];
              MeziData.Hodnoty[K] := MeziData.Hodnoty[K - 1];
              MeziData.Tahy.t[K - 1] := PomTah;
              MeziData.Hodnoty[K - 1] := PomHodnota;
              dec(K)
            end;
            if MeziData.Hodnoty[1] >= MeziData.Beta then
            begin
              { <LadÌcÌ v˝pisy> }
              if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                (Vypisovac.Cfg.osHloubka > 0) then
                if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                  Vypisovac.Cfg.osDopredu and
                  ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                begin
                  Vypisovac.WriteStr('  Ne˙spÏch iterace');
                  Vypisovac.WriteStr('  P¯elezl jsem okÈnko tahem ' +
                    TTah1ToStr(MeziData.Tahy.t[1], Pozice))
                end;
              { </LadÌcÌ v˝pisy> }
              MeziData.I := 1;
              MeziData.Alfa := MeziData.Beta - 1;
              MeziData.Beta := mat;
              pocitam[0] := AnsiChar(PocPos);
              exit { OkÈnko moc dole }
            end; { od p¯elezenÌ okÈnka }
            JeTah := true;
            if I <> 1 then
              inc(MeziData.Platnych);
            { 3. zmÏna } If K = 1 then
            begin
              { Tah je nejen v intervalu (alfa, beta), ale je skuteËnÏ nejlepöÌ }
              if (MeziData.Hodnoty[1] > mat - 100) or
                (MeziData.Hodnoty[1] < -mat + 100) then
                MeziData.Alfa := MeziData.Hodnoty[1]
              else if MeziData.Alfa < MeziData.Hodnoty[1] - HorsiTahy then
                MeziData.Alfa := MeziData.Hodnoty[1] - HorsiTahy;
              { <BÏûnÈ v˝pisy> }
              VypisNejlepsi(MeziData.Tahy.t[1], Nejlepsi, Styl);
              case Styl of
                Normalni:
                  if Vypisovac.Cfg.mnPovoleno then
                    MysNormForm.Label4.Caption :=
                      HodnotaToStr(MeziData.Hodnoty[1]);
                OnDopredu:
                  if Vypisovac.Cfg.mdPovoleno then
                    MysDopForm.Label13.Caption :=
                      HodnotaToStr(MeziData.Hodnoty[1]);
                JaDopredu:
                  if Vypisovac.Cfg.mdPovoleno then
                    MysDopForm.Label18.Caption :=
                      HodnotaToStr(MeziData.Hodnoty[1]);
              end;
              { </BÏûnÈ v˝pisy> }
              { <LadÌcÌ v˝pisy> }
              if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                (Vypisovac.Cfg.osHloubka > 0) then
                if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                  Vypisovac.Cfg.osDopredu and
                  ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                  Vypisovac.WriteDobryTah(MeziData) { je to dob¯e ? };
              { </LadÌcÌ v˝pisy> }
            end;

            if JeTah and (MeziData.Alfa >= mat - MeziData.Hloubka) then
            begin
              MeziData.Dojeto := true;
              pocitam[0] := AnsiChar(PocPos);
              exit;
            end
          end
        end; { od for cyklu p¯es tahy }
        if not JeTah then
        begin
          { <LadÌcÌ v˝pisy> }
          if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
            (Vypisovac.Cfg.osHloubka > 0) then
            if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
              Vypisovac.Cfg.osDopredu and
              ((Styl = OnDopredu) or (Styl = JaDopredu)) then
            begin
              Vypisovac.WriteStr('  Ne˙spÏch iterace');
              Vypisovac.WriteStr('  Vöechny tahy byly pod okÈnkem')
            end;
          { </LadÌcÌ v˝pisy> }
          MeziData.Alfa := -mat;
          MeziData.Beta := MeziData.Hodnoty[1] + 1;
          MeziData.I := 1;
          { OkÈnko moc naho¯e }
        end
        else
        begin
          if (MeziData.Alfa <= -mat + MeziData.Hloubka) then
          begin
            MeziData.Dojeto := true;
            pocitam[0] := AnsiChar(PocPos);
            exit;
          end;
          MeziData.I := 1;
          if MeziData.Hodnoty[1] < -mat + AlgCfg.Okno then
            MeziData.Alfa := MeziData.Hodnoty[1] - 1
          else
            MeziData.Alfa := MeziData.Hodnoty[1] - AlgCfg.Okno;
          if MeziData.Hodnoty[1] > mat - AlgCfg.Okno then
            MeziData.Beta := MeziData.Hodnoty[1] + 1
          else
            MeziData.Beta := MeziData.Hodnoty[1] + AlgCfg.Okno;
          inc(MeziData.Hloubka)
        end;
        pocitam[0] := AnsiChar(PocPos);
      end; { Konec BIterace }

      Procedure TMyslitel.globCIterace(var MeziData: TMeziData;
        HorsiTahy: longint; Styl: TStyl; var pocitam, Nejlepsi: ShortString);
      { Volat pouze hraje-li Ëern˝.
        ProvedenÌ jednÈ iterace v OkÈnku (Alfa,Beta). }
      var
        JeTah, Dj: Boolean;
        I, K: Integer;
        PocPos: byte;
        t2: ttah2;
        PomTah: ttah1;
        PomHodnota: longint;
      begin
        if MeziData.Dojeto then
          exit;
        PocPos := length(pocitam);
        Nejlepsi := '';
        { <BÏûnÈ v˝pisy> }
        case Styl of
          Normalni:
            if Vypisovac.Cfg.mnPovoleno then
              MysNormForm.Label2.Caption := IntToStr(MeziData.Hloubka);
          OnDopredu:
            if Vypisovac.Cfg.mdPovoleno then
              MysDopForm.Label11.Caption := IntToStr(MeziData.Hloubka);
          JaDopredu:
            if Vypisovac.Cfg.mdPovoleno then
              MysDopForm.Label16.Caption := IntToStr(MeziData.Hloubka);
        end;
        { </BÏûnÈ v˝pisy> }
        { <LadÌcÌ v˝pisy> }
        if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
          (Vypisovac.Cfg.osHloubka > 0) then
          case Styl of
            Normalni:
              if Vypisovac.Cfg.osNormalni then
                Vypisovac.WriteZacatekIterace(MeziData);
            OnDopredu, JaDopredu:
              if Vypisovac.Cfg.osDopredu then
                Vypisovac.WriteZacatekIterace(MeziData);
          end;
        { </LadÌcÌ v˝pisy> }
        MeziData.Dojeto := true;
        JeTah := false;
        if MeziData.I = 1 then
          MeziData.Platnych := 1;
        for I := MeziData.I to MeziData.Tahy.Poctah do
        begin
          MeziData.I := I;
          { <BÏûnÈ v˝pisy> }
          VypisVariantu(MeziData.Tahy.t[I], pocitam, PocPos, Styl, 1);
          { </BÏûnÈ v˝pisy> }
          { <LadÌcÌ v˝pisy> }
          if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
            (Vypisovac.Cfg.osHloubka > 1) then
            if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
              Vypisovac.Cfg.osDopredu and
              ((Styl = OnDopredu) or (Styl = JaDopredu)) then
            begin
              Vypisovac.WritePocitamTah(MeziData, 4)
            end;
          { </LadÌcÌ v˝pisy> }
          DoplnTah(MeziData.Tahy.t[I], Pozice, t2);
          tahni(Pozice, MeziData.Tahy.t[I]);
          PridejTah(Partie, t2);
          if PoloRemis(Partie, Pozice) then
            MeziData.Hodnoty[I] := 0
          else
          begin
            MeziData.Hodnoty[I] := Alfa_Beta(MeziData.Alfa, MeziData.Beta,
              MeziData.Hloubka, Dj, 2, Styl, pocitam, Nejlepsi);
            if MeziData.Hodnoty[I] <> NeHodnota then
              if MeziData.Hodnoty[I] > mat - 100 then
                dec(MeziData.Hodnoty[I])
              else if MeziData.Hodnoty[I] < -mat + 100 then
                inc(MeziData.Hodnoty[I]);
            if not Dj then
              MeziData.Dojeto := false; { nedopoËetl-li jsem aspoÚ 1 tah,
              je to celÈ nedopoËtenÈ }
          end;
          UberTah(Partie);
          tahni_zpet(Pozice, t2);
          if MeziData.Hodnoty[I] = NeHodnota then
          begin
            MeziData.Dojeto := false;
            pocitam[0] := AnsiChar(PocPos);
            exit
          end;
          if MeziData.Hodnoty[I] < MeziData.Beta then
          begin
            { 2. zmÏna } { probubl·m dobr˝m tahem dop¯edu a to i v p¯ÌpadÏ, ûe nenÌ v (alfa,beta) }
            K := I;
            while (K > 1) and (MeziData.Hodnoty[K - 1] > MeziData.Hodnoty[K]) do
            begin
              PomTah := MeziData.Tahy.t[K];
              PomHodnota := MeziData.Hodnoty[K];
              MeziData.Tahy.t[K] := MeziData.Tahy.t[K - 1];
              MeziData.Hodnoty[K] := MeziData.Hodnoty[K - 1];
              MeziData.Tahy.t[K - 1] := PomTah;
              MeziData.Hodnoty[K - 1] := PomHodnota;
              dec(K)
            end;
            if MeziData.Hodnoty[1] <= MeziData.Alfa then
            begin
              { <LadÌcÌ v˝pisy> }
              if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                (Vypisovac.Cfg.osHloubka > 0) then
                if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                  Vypisovac.Cfg.osDopredu and
                  ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                begin
                  Vypisovac.WriteStr('  Ne˙spÏch iterace');
                  Vypisovac.WriteStr('  Podlezl jsem okÈnko tahem ' +
                    TTah1ToStr(MeziData.Tahy.t[1], Pozice))
                end;
              { </LadÌcÌ v˝pisy> }
              MeziData.I := 1;
              MeziData.Beta := MeziData.Alfa + 1;
              MeziData.Alfa := -mat;
              pocitam[0] := AnsiChar(PocPos);
              exit { OkÈnko moc naho¯e }
            end; { od podlezenÌ okÈnka }
            JeTah := true;
            if I <> 1 then
              inc(MeziData.Platnych);
            { 3. zmÏna } If K = 1 then
            begin
              { Tah je nejen v intervalu (alfa, beta), ale je skuteËnÏ nejlepöÌ }
              if (MeziData.Hodnoty[1] > mat - 100) or
                (MeziData.Hodnoty[1] < -mat + 100) then
                MeziData.Beta := MeziData.Hodnoty[1]
              else if MeziData.Beta > MeziData.Hodnoty[1] + HorsiTahy then
                MeziData.Beta := MeziData.Hodnoty[1] + HorsiTahy;
              { <BÏûnÈ v˝pisy> }
              VypisNejlepsi(MeziData.Tahy.t[1], Nejlepsi, Styl);
              case Styl of
                Normalni:
                  if Vypisovac.Cfg.mnPovoleno then
                    MysNormForm.Label4.Caption :=
                      HodnotaToStr(MeziData.Hodnoty[1]);
                OnDopredu:
                  if Vypisovac.Cfg.mdPovoleno then
                    MysDopForm.Label13.Caption :=
                      HodnotaToStr(MeziData.Hodnoty[1]);
                JaDopredu:
                  if Vypisovac.Cfg.mdPovoleno then
                    MysDopForm.Label18.Caption :=
                      HodnotaToStr(MeziData.Hodnoty[1]);
              end;
              { </BÏûnÈ v˝pisy> }
              { <LadÌcÌ v˝pisy> }
              if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                (Vypisovac.Cfg.osHloubka > 0) then
                if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                  Vypisovac.Cfg.osDopredu and
                  ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                  Vypisovac.WriteDobryTah(MeziData);
              { </LadÌcÌ v˝pisy> }
            end;

            if JeTah and (MeziData.Beta <= -mat + MeziData.Hloubka) then
            begin
              MeziData.Dojeto := true;
              pocitam[0] := AnsiChar(PocPos);
              exit;
            end
          end
        end; { od for cyklu p¯es tahy }
        if not JeTah then
        begin
          { <LadÌcÌ v˝pisy> }
          if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
            (Vypisovac.Cfg.osHloubka > 0) then
            if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
              Vypisovac.Cfg.osDopredu and
              ((Styl = OnDopredu) or (Styl = JaDopredu)) then
            begin
              Vypisovac.WriteStr('  Ne˙spÏch iterace');
              Vypisovac.WriteStr('  Vöechny tahy byly nad okÈnkem')
            end;
          { </LadÌcÌ v˝pisy> }
          MeziData.Beta := mat;
          MeziData.Alfa := MeziData.Hodnoty[1] - 1;
          MeziData.I := 1;
          { OkÈnko moc dole }
        end
        else
        begin
          { if (Mezidata.alfa<=-mat+Mezidata.hloubka) then
            begin
            Mezidata.dojeto:=true;
            Pocitam[0]:=char(PocPos);
            exit;
            end; }
          if (MeziData.Beta >= mat - MeziData.Hloubka) then
          begin
            MeziData.Dojeto := true;
            pocitam[0] := AnsiChar(PocPos);
            exit;
          end;
          MeziData.I := 1;
          if MeziData.Hodnoty[1] < -mat + AlgCfg.Okno then
            MeziData.Alfa := MeziData.Hodnoty[1] - 1
          else
            MeziData.Alfa := MeziData.Hodnoty[1] - AlgCfg.Okno;
          if MeziData.Hodnoty[1] > mat - AlgCfg.Okno then
            MeziData.Beta := MeziData.Hodnoty[1] + 1
          else
            MeziData.Beta := MeziData.Hodnoty[1] + AlgCfg.Okno;
          inc(MeziData.Hloubka)
        end;
        pocitam[0] := AnsiChar(PocPos);
      end; { Konec CIterace }

      procedure TMyslitel.DejTah(var npozice: TPozice; var npartie: ppartie);
      var
        MeziData: TMeziData;
        Procedure Jedeme(bily: Boolean);
        var
          pocitam, Nejlepsi: ShortString;
        begin
          pocitam := '';
          Nejlepsi := '';
          repeat
            if bily then
              globBIterace(MeziData, AlgCfg.NormHorsiTahy, Normalni,
                pocitam, Nejlepsi)
            else
              globCIterace(MeziData, AlgCfg.NormHorsiTahy, Normalni, pocitam,
                Nejlepsi) until Ukoncit or MeziData.Dojeto;
          end;
          Label konec;
          var
            Dobrych, K: Integer;
          begin { DejTah }
            { !!!!!!!!!!!!!!LadÏnÌ!!!!!!!!!!!! }
            if form1.sachovnice.bilyalg.MyslimDopredu or
              form1.sachovnice.cernyalg.MyslimDopredu or
              form1.sachovnice.bilyalg.Myslim or form1.sachovnice.cernyalg.Myslim
            then { jeden z nich jsem j·, ale to nevadÌ }
              ZpravovaKrabice('M·m myslet a zatÌm se uû myslÌ',
                'Hrozn· chyba !!!', mb_ok);
            { !!!!!!!!!!!!!!!!!!!!!!!!!! }
            KoncovyCas := CasNaTah + GetTickCount;
            if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
              Vypisovac.WriteStr('ZaËÌn·m myslet...');
            Myslim := true;
            Ukoncit := false;
            Pozice := npozice;
            if AlgCfg.PouzitKnihovnu and Knihovna.DejTah(Pozice,
              MeziData.Tahy.t[1]) then
              goto konec;

            MeziVypocet.DejInfo(Pozice, AlgCfg, MeziData);
            CopyKusPartie(Pozice, npartie, Partie);
            if MeziData.Tahy.Poctah > 1 then { Pokud m· smysl p¯em˝ölet tak }
              if hb in Pozice.stav.b then
                Jedeme(true)
              else
                Jedeme(false);
            { ..else m·m jen jeden p¯Ìpustn˝ tah }
            DonePJednoPartie(Partie);
            if MeziData.Platnych < 1 then
              MeziData.Platnych := 1;
            Dobrych := 0;
            repeat
              inc(Dobrych)
            until (Dobrych = MeziData.Tahy.Poctah) or
              (Dobrych = MeziData.Platnych) or
              (MeziData.Hodnoty[1] < -mat + 100) or
              (MeziData.Hodnoty[1] > mat - 100) or
              (MeziData.Hodnoty[Dobrych + 1] < MeziData.Hodnoty[1] -
              AlgCfg.Nedeterminismus) or
              (MeziData.Hodnoty[Dobrych + 1] > MeziData.Hodnoty[1] +
              AlgCfg.Nedeterminismus);
            if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osNormalni then
            begin
              Vypisovac.WriteStr('Celkem platn˝ch tah˘: ' +
                IntToStr(MeziData.Platnych));
              Vypisovac.WriteStr('DobrÈ tahy:');
              for K := 1 to Dobrych do
                Vypisovac.WriteStr('Tah: ' + TTah1ToStr(MeziData.Tahy.t[K],
                  Pozice) + ' cena ' + HodnotaToStr(MeziData.Hodnoty[1]));
            end;
            K := random(Dobrych) + 1;
            { if k<>1 then zpravovakrabice('','Nehraji nejlepöÌ tah',mb_ok); }
            MeziData.Tahy.t[1] := MeziData.Tahy.t[K];
          konec:;
            if Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osZakladni then
              Vypisovac.WriteStr('MyölenÌ ukonËeno. Zahraji ' +
                TTah1ToStr(MeziData.Tahy.t[1], Pozice) + '.');
            Vypisovac.ZavriSoubor; { NevadÌ, jestli nenÌ otev¯en˝ }
            Hraji(MeziData.Tahy.t[1]);
            Myslim := false;
          end;

          procedure TMyslitel.HrajTed;
          begin
            Ukoncit := true
          end;

          procedure TMyslitel.PrestanDopredu(nAkceKonecDopredu: TAkce);
          begin
            AkceKonecDopredu := nAkceKonecDopredu;
            if MyslimDopredu then
              Ukoncit := true
            else if assigned(AkceKonecDopredu) then
              postmessage(form1.handle, wm_Zavolej, 0,
                longint(@AkceKonecDopredu));
          end;

          function TMyslitel.Transformuj(co: longint): longint;
          begin
            if co = NeHodnota then
              result := NeHodnota
            else if co > mat - 100 then
              result := co - 1
            else if co < -mat + 100 then
              result := co + 1
            else
              result := co;
          end;

          function TMyslitel.MusimKoncit: Boolean;
          begin
            result := false;
            inc(VolanoMusimKoncit);
            if Ukoncit = true then
              result := true
            else if { (VolanoMusimKoncit and $F)=0 } true then
              if GetTickCount > KoncovyCas then
              begin
                Ukoncit := true;
                result := true
              end;
            if { (VolanoMusimKoncit and $F)=0 } true then
              Application.Processmessages
          end;

          function TMyslitel.Alfa_Beta_Vrazi(Alfa, Beta: longint;
            Hloubka: Integer; var Dojeto: Boolean; HloubkaRekurze: Integer;
            Styl: TStyl): longint;
          var
            Tahy: TTahy;
            t2: ttah2;
            pomtah1: ttah1;
            HodnotyTahu: THodnotyTahu;
            sach, Dj: Boolean;
            hodnota, HodPos, sAlfa, sBeta, pomlongint: longint;
            h: Integer;
            I: byte;
          begin
            Dojeto := false;
            if (Alfa < -mat + 100) and (Alfa >= -mat) then
              Alfa := Alfa - 1;
            if (Beta > mat - 100) and (Beta <= mat) then
              Beta := Beta + 1;
            if MusimKoncit then
              result := NeHodnota
            else
            begin
              sach := {$IFDEF JENBRANI}nalezbrani{$ELSE}nalezvrahy{$ENDIF}(Pozice, Tahy);
              if Tahy.Poctah = 0 then
              begin
                Dojeto := true;
                if sach then { Je-li nÏkdo v öachu a nem· p¯Ìpustn˝ vrah (a zde je
                    vrahem kaûd˝ tah), je v matu. }
                  if hb in Pozice.stav.b then
                    result := -mat
                  else
                    result := mat
                else
                  result := HodnotaPozice(Pozice, AlgCfg);
              end { Od Tahy.poctah=0 }
              else
              begin
                if Hloubka = 0 then
                begin
                  result := HodnotaPozice(Pozice, AlgCfg);
                  Dojeto := false { vraûedn· variata pokraËuje, ale nedopoËetl jsem ji }
                end
                else
                begin
                  sAlfa := Alfa;
                  sBeta := Beta; { V kask·dovÈm pr˘chodu bych si je rozhasil }
                  if not sach then
                  begin
                    { NenÌ-li hr·Ë v öachu, nemusÌ nutnÏ pokraËovat ve vraûednÈ variantÏ a m˘ûe
                      se od nÌ odch˝lit. Aneb jinak bych poËÌtal, jako by se v öach·ch muselo
                      br·t. Je-li ale v öachu, je jeho dalöÌ tah vûdy vrah, takûe mu dalöÌm
                      propoËtem nek¯ivdÌm. }
                    HodPos := HodnotaPozice(Pozice, AlgCfg);
                    if (hb in Pozice.stav.b) and (HodPos >= sBeta) or
                      not(hb in Pozice.stav.b) and (HodPos <= sAlfa) then
                    begin
                      Dojeto := true;
                      result := HodPos;
                      exit { neveöel jsem se do (alfa, beta), navÌc öpatn˝m smÏrem }
                    end;
                  end;
                  for I := 1 to Tahy.Poctah do
                    HodnotyTahu[I] := NeHodnota;
                  if hb in Pozice.stav.b then { Hraje bÌl˝ }
                  begin
                    if (not sach) and (HodPos > sAlfa) then
                    begin
                      sAlfa := HodPos;
                      if sAlfa >= sBeta then
                      begin
                        result := HodPos;
                        Dojeto := true;
                        exit
                      end
                    end;
                    for h := 0 to Hloubka - 1 do
                    begin
                      Dojeto := true;
                      Alfa := sAlfa;
                      Beta := sBeta;
                      for I := 1 to Tahy.Poctah do
                      begin
                        if HodnotyTahu[I] <> NeHodnota then
                          hodnota := HodnotyTahu[I]
                          { tj. if poËÌtal bych jiû vypoËtenÈ, p¯eËtu si ti z pole }
                        else
                        begin { musÌm poËÌtat }
                          DoplnTah(Tahy.t[I], Pozice, t2);
                          tahni(Pozice, Tahy.t[I]);
                          PridejTah(Partie, t2);
                          if PoloRemis(Partie, Pozice) then
                            hodnota := 0
                          else
                            Dj := true;
                          hodnota :=
                            Transformuj(Alfa_Beta_Vrazi(Alfa, Beta, h, Dj,
                            HloubkaRekurze + 1, Styl));
                          UberTah(Partie);
                          if Dj then
                            HodnotyTahu[I] := hodnota
                            { Tah je dopoËÌt·n, zapamatuji si hodnotu }
                          else
                            Dojeto := false; { nedopoËetl-li jsem aspoÚ 1 tah,
                            je to celÈ nedopoËtenÈ }
                          tahni_zpet(Pozice, t2);
                          if hodnota = NeHodnota then
                          begin
                            result := NeHodnota;
                            exit
                          end;
                        end; { od musÌm poËÌtat }
                        if hodnota > Alfa then
                        begin
                          Alfa := hodnota;
                          if Alfa >= Beta then
                            if h = Hloubka - 1 then
                            begin
                              result := Alfa;
                              Dojeto := false;
                              exit
                            end
                            else
                            begin
                              break
                            end;
                          pomtah1 := Tahy.t[I];
                          pomlongint := HodnotyTahu[I];
                          Tahy.t[I] := Tahy.t[1];
                          HodnotyTahu[I] := HodnotyTahu[1];
                          Tahy.t[1] := pomtah1;
                          HodnotyTahu[1] := pomlongint;
                        end
                      end; { od for cyklu p¯es tahy }
                      result := Alfa;
                      if Dojeto then
                        break; { DopoËÌtal jsem to aû do konce. Zv˝öenÌ
                        hloubky propoËtu nem· smysl (poËÌtal bych jiû vypoËtenÈ). }
                    end { od cyklu p¯es hloubku }
                  end { od hb in pozice.stav.b }
                  else { Hraje Ëern˝ }
                  begin
                    if (not sach) and (HodPos < sBeta) then
                    begin
                      sBeta := HodPos;
                      if sAlfa >= sBeta then
                      begin
                        result := HodPos;
                        Dojeto := true;
                        exit
                      end
                    end;
                    for h := 0 to Hloubka - 1 do
                    begin
                      Dojeto := true;
                      Alfa := sAlfa;
                      Beta := sBeta;
                      for I := 1 to Tahy.Poctah do
                      begin
                        if HodnotyTahu[I] <> NeHodnota then
                          hodnota := HodnotyTahu[I]
                          { tj. if poËÌtal bych jiû vypoËtenÈ, p¯eËtu si ti z pole }
                        else
                        begin { musÌm poËÌtat }
                          DoplnTah(Tahy.t[I], Pozice, t2);
                          tahni(Pozice, Tahy.t[I]);
                          PridejTah(Partie, t2);
                          Dj := true;
                          if PoloRemis(Partie, Pozice) then
                            hodnota := 0
                          else
                            hodnota :=
                              Transformuj(Alfa_Beta_Vrazi(Alfa, Beta, h, Dj,
                              HloubkaRekurze + 1, Styl));
                          UberTah(Partie);
                          if Dj then
                            HodnotyTahu[I] := hodnota
                            { Tah je dopoËÌt·n, zapamatuji si hodnotu }
                          else
                            Dojeto := false; { nedopoËetl-li jsem aspoÚ 1 tah,
                            je to celÈ nedopoËtenÈ }
                          tahni_zpet(Pozice, t2);
                          if hodnota = NeHodnota then
                          begin
                            result := NeHodnota;
                            exit
                          end;
                        end; { od musÌm poËÌtat }
                        if hodnota < Beta then
                        begin
                          Beta := hodnota;
                          if Alfa >= Beta then
                            if h = Hloubka - 1 then
                            begin
                              result := Alfa;
                              Dojeto := false;
                              exit
                            end
                            else
                            begin
                              break
                            end;
                          pomtah1 := Tahy.t[I];
                          pomlongint := HodnotyTahu[I];
                          Tahy.t[I] := Tahy.t[1];
                          HodnotyTahu[I] := HodnotyTahu[1];
                          Tahy.t[1] := pomtah1;
                          HodnotyTahu[1] := pomlongint;
                        end
                      end; { od for cyklu p¯es tahy }
                      result := Beta;
                      if Dojeto then
                        break; { DopoËÌtal jsem to aû do konce. Zv˝öenÌ
                        hloubky propoËtu nem· smysl (poËÌtal bych jiû vypoËtenÈ). }
                    end; { Od cyklu p¯es hloubku }
                  end { Od hraje Ëern˝ }
                end { od not(hloubka=0) }
              end { od not(tahy.poctah=0) }
            end { Od not MusimKoncit }
          end; { Od Alfa_Beta_Vrazi }

          { AËkoliv jsem vÌcemÈnÏ vyznavaËem Pascalu, kdyû vidÌm tolik end˘ za sebou... }
          function TMyslitel.Alfa_Beta(Alfa, Beta: longint; Hloubka: Integer;
            var Dojeto: Boolean; HloubkaRekurze: Integer; Styl: TStyl;
            var pocitam, Nejlepsi: ShortString): longint;
          var
            Tahy: TTahy;
            t2: ttah2;
            pomtah1: ttah1;
            HodnotyTahu: THodnotyTahu;
            sach, Dj: Boolean;
            hodnota, sAlfa, sBeta, pomlongint: longint;
            h: Integer;
            I, PocPos, NejPos: byte;
            PomStr: ShortString;
          begin
            if (Alfa < -mat + 100) and (Alfa >= -mat) then
              Alfa := Alfa - 1;
            if (Beta > mat - 100) and (Beta <= mat) then
              Beta := Beta + 1;
            PocPos := length(pocitam);
            NejPos := length(Nejlepsi);
            if MusimKoncit then
              result := NeHodnota
            else
            begin { nemusÌm konËit }
              Dojeto := false;
              if Hloubka = 0 then
              begin
                result := { HodnotaPozice(Pozice,AlgCfg); }
                  Transformuj(Alfa_Beta_Vrazi(Alfa, Beta, HloubkaRekurze + 1,
                  sach { nÏjak˝ nepouûit˝ boolean } ,
                  HloubkaRekurze + 1, Styl));
                if result = mat - 1 then
                  result := mat
                else if result = -mat + 1 then
                  result := -mat;
                if (result = mat) or (result = -mat) then
                  Dojeto := true { Jsem v matu }
                else
                  Dojeto := false; { variata pokraËuje, ale nedopoËetl jsem ji }
                { <LadÌcÌ v˝pisy> }
                if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                  (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                  if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                    Vypisovac.Cfg.osDopredu and
                    ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                  begin
                    Vypisovac.writeStrOdsaz('DopoËet do tichÈ pozice: ' +
                      HodnotaToStr(result), HloubkaRekurze + 2)
                  end;
                { </LadÌcÌ v˝pisy> }

              end { od hloubka=0 }
              else
              begin { hloubka>0 }
                { <LadÌcÌ v˝pisy> }
                if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                  (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                  if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                    Vypisovac.Cfg.osDopredu and
                    ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                  begin
                    Vypisovac.writeZacatekAlfaBeta(Alfa, Beta, Hloubka,
                      HloubkaRekurze)
                  end;
                { </LadÌcÌ v˝pisy> }
                sach := Rychle.NalezTahy(Pozice, Tahy);
                if Tahy.Poctah = 0 then
                begin
                  if sach then { Je-li nÏkdo v öachu a nem· p¯Ìpustn˝ tah je v matu. }
                    if hb in Pozice.stav.b then
                      result := -mat
                    else
                      result := mat
                  else
                    result := 0; { remis }
                  Dojeto := true;
                end { Od Tahy.poctah=0 }
                else
                begin
                  for I := 1 to Tahy.Poctah do
                    HodnotyTahu[I] := NeHodnota;
                  sAlfa := Alfa;
                  sBeta := Beta;
                  if hb in Pozice.stav.b then { Hraje bÌl˝ }
                  begin
                    result := Alfa;
                    for h := 0 to Hloubka - 1 do
                    begin
                      { <LadÌcÌ v˝pisy> }
                      if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                        (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                        if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                          Vypisovac.Cfg.osDopredu and
                          ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                        begin
                          Vypisovac.writeZacatekAlfaBetaIterace(sAlfa, sBeta, h,
                            HloubkaRekurze)
                        end;
                      { </LadÌcÌ v˝pisy> }
                      pocitam[0] := AnsiChar(PocPos);
                      Dojeto := true;
                      Alfa := sAlfa;
                      Beta := sBeta;
                      for I := 1 to Tahy.Poctah do
                      begin
                        { <BÏûnÈ v˝pisy> }
                        VypisVariantu(Tahy.t[I], pocitam, PocPos, Styl,
                          HloubkaRekurze);
                        { </BÏûnÈ v˝pisy> }
                        { <LadÌcÌ v˝pisy> }
                        if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                          (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                          if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                            Vypisovac.Cfg.osDopredu and
                            ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                          begin
                            Vypisovac.writeStrOdsaz
                              (TTah1ToStr(Tahy.t[I], Pozice),
                              3 + HloubkaRekurze)
                          end;
                        { </LadÌcÌ v˝pisy> }

                        if HodnotyTahu[I] <> NeHodnota then
                        begin
                          hodnota := HodnotyTahu[I];
                          PomStr := '';
                        end
                        { tj. if poËÌtal bych jiû vypoËtenÈ, p¯eËtu si to z pole }
                        else
                        begin { musÌm poËÌtat }
                          DoplnTah(Tahy.t[I], Pozice, t2);
                          tahni(Pozice, Tahy.t[I]);
                          PridejTah(Partie, t2);
                          Dj := true;
                          if PoloRemis(Partie, Pozice) then
                            hodnota := 0
                          else
                          begin
                            PomStr := '';
                            hodnota :=
                              Transformuj(Alfa_Beta(Alfa, Beta, h, Dj,
                              HloubkaRekurze + 1, Styl, pocitam, PomStr));
                          end;
                          UberTah(Partie);
                          if Dj then
                            HodnotyTahu[I] := hodnota
                            { Tah je dopoËÌt·n, zapamatuji si hodnotu }
                          else
                            Dojeto := false; { nedopoËetl-li jsem aspoÚ 1 tah,
                            je to celÈ nedopoËtenÈ }
                          tahni_zpet(Pozice, t2);
                          if hodnota = NeHodnota then
                          begin
                            result := NeHodnota;
                            pocitam[0] := AnsiChar(PocPos);
                            exit
                          end;
                        end; { od musÌm poËÌtat }
                        if hodnota > Alfa then
                        begin
                          Alfa := hodnota;
                          result := Alfa;
                          { <LadÌcÌ v˝pisy> }
                          if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                            (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                            if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                              Vypisovac.Cfg.osDopredu and
                              ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                            begin
                              Vypisovac.writeStrOdsaz('ZlepöujÌcÌ tah, Alfa=' +
                                HodnotaToStr(Alfa), 3 + HloubkaRekurze)
                            end;
                          { </LadÌcÌ v˝pisy> }
                          if Alfa >= Beta then
                            if h = Hloubka - 1 then
                            begin
                              result := Beta;
                              Dojeto := false;
                              pocitam[0] := AnsiChar(PocPos);
                              exit
                            end
                            else
                              break;
                          pomtah1 := Tahy.t[I];
                          pomlongint := HodnotyTahu[I];
                          Tahy.t[I] := Tahy.t[1];
                          HodnotyTahu[I] := HodnotyTahu[1];
                          Tahy.t[1] := pomtah1;
                          HodnotyTahu[1] := pomlongint;
                          if h = Hloubka - 1 then
                            case Styl of
                              Normalni:
                                if HloubkaRekurze <= Vypisovac.Cfg.mnnHloubka
                                then
                                begin
                                  Nejlepsi :=
                                    ' ' + TTah1ToStr(pomtah1, Pozice) + PomStr;
                                end;
                              OnDopredu, JaDopredu:
                                if HloubkaRekurze <= Vypisovac.Cfg.mdnHloubka
                                then
                                begin
                                  Nejlepsi :=
                                    ' ' + TTah1ToStr(pomtah1, Pozice) + PomStr;
                                end;
                            end;
                        end
                      end; { od for cyklu p¯es tahy }
                      result := Alfa;
                      if Dojeto then
                        break; { DopoËÌtal jsem to aû do konce. Zv˝öenÌ
                        hloubky propoËtu nem· smysl (poËÌtal bych jiû vypoËtenÈ). }
                    end { od cyklu p¯es hloubku }
                  end { od hb in pozice.stav.b }
                  else { Hraje Ëern˝ }
                  begin
                    result := Beta;
                    for h := 0 to Hloubka - 1 do
                    begin
                      { <LadÌcÌ v˝pisy> }
                      if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                        (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                        if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                          Vypisovac.Cfg.osDopredu and
                          ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                        begin
                          Vypisovac.writeZacatekAlfaBetaIterace(sAlfa, sBeta, h,
                            HloubkaRekurze)
                        end;
                      { </LadÌcÌ v˝pisy> }
                      pocitam[0] := AnsiChar(PocPos);
                      Dojeto := true;
                      Alfa := sAlfa;
                      Beta := sBeta;
                      for I := 1 to Tahy.Poctah do
                      begin
                        { <LadÌcÌ v˝pisy> }
                        if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                          (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                          if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                            Vypisovac.Cfg.osDopredu and
                            ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                          begin
                            Vypisovac.writeStrOdsaz
                              (TTah1ToStr(Tahy.t[I], Pozice),
                              3 + HloubkaRekurze)
                          end;
                        { </LadÌcÌ v˝pisy> }
                        { <BÏûnÈ v˝pisy> }
                        VypisVariantu(Tahy.t[I], pocitam, PocPos, Styl,
                          HloubkaRekurze);
                        { </BÏûnÈ v˝pisy> }
                        if HodnotyTahu[I] <> NeHodnota then
                        begin
                          PomStr := '';
                          hodnota := HodnotyTahu[I]
                        end
                        { tj. if poËÌtal bych jiû vypoËtenÈ, p¯eËtu si ti z pole }
                        else
                        begin { musÌm poËÌtat }
                          DoplnTah(Tahy.t[I], Pozice, t2);
                          tahni(Pozice, Tahy.t[I]);
                          PridejTah(Partie, t2);
                          Dj := true;
                          if PoloRemis(Partie, Pozice) then
                            hodnota := 0
                          else
                          begin
                            PomStr := '';
                            hodnota :=
                              Transformuj(Alfa_Beta(Alfa, Beta, h, Dj,
                              HloubkaRekurze + 1, Styl, pocitam, PomStr));
                          end;
                          UberTah(Partie);
                          if Dj then
                            HodnotyTahu[I] := hodnota
                            { Tah je dopoËÌt·n, zapamatuji si hodnotu }
                          else
                            Dojeto := false; { nedopoËetl-li jsem aspoÚ 1 tah,
                            je to celÈ nedopoËtenÈ }
                          tahni_zpet(Pozice, t2);
                          if hodnota = NeHodnota then
                          begin
                            result := NeHodnota;
                            pocitam[0] := AnsiChar(PocPos);
                            exit
                          end;
                        end; { od musÌm poËÌtat }
                        if hodnota < Beta then
                        begin
                          Beta := hodnota;
                          { <LadÌcÌ v˝pisy> }
                          if Vypisovac.Cfg.osPovoleno and (Styl <> Nulovy) and
                            (Vypisovac.Cfg.osHloubka > HloubkaRekurze) then
                            if (Styl = Normalni) and Vypisovac.Cfg.osNormalni or
                              Vypisovac.Cfg.osDopredu and
                              ((Styl = OnDopredu) or (Styl = JaDopredu)) then
                            begin
                              Vypisovac.writeStrOdsaz('ZlepöujÌcÌ tah, Beta=' +
                                HodnotaToStr(Beta), 3 + HloubkaRekurze)
                            end;
                          { </LadÌcÌ v˝pisy> }
                          result := Beta;
                          if Alfa >= Beta then
                            if h = Hloubka - 1 then
                            begin
                              result := Alfa;
                              Dojeto := false;
                              pocitam[0] := AnsiChar(PocPos);
                              exit
                            end
                            else
                              break;
                          pomtah1 := Tahy.t[I];
                          pomlongint := HodnotyTahu[I];
                          Tahy.t[I] := Tahy.t[1];
                          HodnotyTahu[I] := HodnotyTahu[1];
                          Tahy.t[1] := pomtah1;
                          HodnotyTahu[1] := pomlongint;
                          if h = Hloubka - 1 then
                            case Styl of
                              Normalni:
                                if HloubkaRekurze <= Vypisovac.Cfg.mnnHloubka
                                then
                                begin
                                  Nejlepsi :=
                                    ' ' + TTah1ToStr(pomtah1, Pozice) + PomStr;
                                end;
                              OnDopredu, JaDopredu:
                                if HloubkaRekurze <= Vypisovac.Cfg.mdnHloubka
                                then
                                begin
                                  Nejlepsi :=
                                    ' ' + TTah1ToStr(pomtah1, Pozice) + PomStr;
                                end;
                            end;
                        end
                      end; { od for cyklu p¯es tahy }
                      result := Beta;

                      if Dojeto then
                        break; { DopoËÌtal jsem to aû do konce. Zv˝öenÌ
                        hloubky propoËtu nem· smysl (poËÌtal bych jiû vypoËtenÈ). }
                    end; { Od cyklu p¯es hloubku }
                  end { Od hraje Ëern˝ }
                end { od not(tahy.poctah=0) }
              end { od not(hloubka=0) }
            end; { Od not MusimKoncit }
            pocitam[0] := AnsiChar(PocPos);
          end; { Od Alfa_Beta }

end.

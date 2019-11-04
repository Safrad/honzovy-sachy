unit Myslitel;
{$DEFINE JENBRANI}

interface

uses
  coty,
  uPartie,
  uETypes,
  uMezivypocet,
  Uknih,
  uEngineOutput,
  uCommonEngineOptions,
  uStopManager,
  uAnalysisInfo,
  uRootMoves,
  uSxRandomGenerator;

type
  TMyslitel = class
  private
    FRandomGenerator: TSxRandomGenerator;
    FPartie: PJednoPartie;
    { musím si pamatovat kus historie, kvůli pravidlu 50 tahů
      a pravidlu opakování pozic (a abych třeba vůbec poznal věčný šach).
      Sem si překopíruji potřebnou část partie z objektu šachovnice při každém
      volání myslící procedury (DejTah nebo MysliOTahDopredu). }
    FPozice: TPozice; { Sem si překopíruji pozici z objektu šachovnice
      při každém volání myslící procedury (DejTah nebo MysliOTahDopredu). }
    // Hraji: TDejtahProc;
    FKnihovna: TKnihovna;
    FRemisValue: THScore;
    FEngineOutput: TEngineOutput;
    FAnalysisInfo: TAnalysisInfo;
    FStopManager: TStopManager;
    FAspirationWindowSize: THScore;
    FOptions: TCommonEngineOptions;
    FRootMoves: TRootMoves;
    { Tuhle procedure zavolám když táhnu. Tato procedura by
      měla jen poslat zprávu na okno, v LParam bude zakódovaný tah. }
    function Transformuj(co: THScore): THScore;
    { Převede hodnotu pozice tak aby z n. půltahem mat bylo (n+1). půltahem
      mat. Jinak by algoritmus nepreferoval vždy nejkratší cestu k vítězství. }
    function MusimKoncit: Boolean;
    function Alfa_Beta(Alfa, Beta: THScore; Hloubka: Integer;
      var Dojeto: Boolean; HloubkaRekurze: Integer;
      var Nejlepsi: ShortString): THScore;
    { Alfa-beta metoda do zadané hloubky s dopočtem do tiché pozice
      s kaskádovitým průchodem a se zapamatováváním hodnot tahů vypočtených až
      do konce. }
    function Alfa_Beta_Vrazi(Alfa, Beta: THScore; Hloubka: Integer;
      out Dojeto: Boolean; HloubkaRekurze: Integer): THScore;
    { Dopočet do tiché pozice, nejvýše však do zadané hloubky. Alfa-beta metoda
      s kaskádovitým průchodem a se zapamatováváním hodnot tahů vypočtených až
      do tichého konce. }
    Procedure globBIterace(var MeziData: TMeziData; HorsiTahy: THScore;
      var Nejlepsi: ShortString);
    Procedure globCIterace(var MeziData: TMeziData; HorsiTahy: THScore;
      var Nejlepsi: ShortString);
    Procedure VypisVariantu(Tah1: ttah1; PocPos: byte;
      Hloubka: Integer; const Index: Integer);
    Procedure VypisNejlepsi(const Tah1: ttah1; const Nejlepsi: string;
      const Score: THScore; const AScoreBound: TScoreBound);
    procedure SetEngineOutput(const Value: TEngineOutput);
    procedure writestrodsaz(co: string; odsaz: Integer);
    procedure writeZacatekAlfaBeta(Alfa, Beta: THScore;
      Hloubka, HloubkaRekurze: Integer);
    procedure writeZacatekAlfaBetaIterace(Alfa, Beta: THScore;
      Hloubka, HloubkaRekurze: Integer);
    procedure writeZacatekIterace(var MeziData: TMeziData);
    procedure WriteDobryTah(var MeziData: TMeziData);
    procedure WritePocitamTah(var MeziData: TMeziData; odsaz: Integer);

    procedure SetAnalysisInfo(const Value: TAnalysisInfo);
    procedure SetStopManager(const Value: TStopManager);
    procedure SetPozice(const Value: TPozice);
    procedure SetAspirationWindowSize(const Value: THScore);
    procedure SetOptions(const Value: TCommonEngineOptions);
    procedure SetRootMoves(const Value: TRootMoves);
  public
    MeziVypocet: TMezivypocet; { Sem si uložím výsledky MysliOTahDopredu.
      Musí být nil, pokud jsem nic nevypočítal !!!! Není-li nil, dealokuje se.
      Použije se v DejTah a to pokud platí a) i b)
      a) MeziVypocet <> nil
      b) Pozice "=" nPozice (např. uživatel mohl změnit pozici) }
    pocitam: ShortString; // CurrLine
    constructor Create;
    destructor Destroy; override;
    procedure BookMoves;
    procedure DejTah;
    { Jen nastaví private proměnné a procedura končí. V důsledku nastavení
      proměnných objekt okamžitě táhne (je-li na tahu). }
    procedure MysliOTahDopredu;
    { Dealokuje MeziVypocet (není-li nil) a znovu vytvoří.
      Musí být explicitně zastaveno následující metodou. V některých případech
      se ale ukončí sama (pokud třeba najde cestu k matu na všechny soupeřovy
      tahy). Dealokuje MeziVypocet (není-li nil). }

    property Pozice: TPozice read FPozice write SetPozice;
    property Partie: PJednoPartie read FPartie;
    procedure SetPartie(const APartie: PJednoPartie);
    property EngineOutput: TEngineOutput read FEngineOutput
      write SetEngineOutput;
    property StopManager: TStopManager read FStopManager write SetStopManager;
    property AnalysisInfo: TAnalysisInfo read FAnalysisInfo write SetAnalysisInfo;
    property RootMoves: TRootMoves read FRootMoves write SetRootMoves;

    property Options: TCommonEngineOptions read FOptions write SetOptions;
    property AspirationWindowSize: THScore read FAspirationWindowSize write SetAspirationWindowSize;
  end;

implementation

uses
  uTypes,
  uMath,
  uStrings,
  Rutiny, Rychle, Ohodnoc, SysUtils, uStopCause;

type
  THodnotyTahu = array [1 .. maxtah] of SG;
const
  DetailedDebug = False;

function HodnotaToStr(hodnota: THScore): string;
begin
  if (hodnota < mat - 100) and (hodnota > 100 - mat) then
    result := IntToStr(hodnota)
  else
  begin { blíží se mat }
    if hodnota = NeHodnota then
    begin
      result := '?';
      exit
    end;
    if mat + 1 = hodnota then
    begin
      result := '+infinity';
      exit
    end;
    if -mat - 1 = hodnota then
    begin
      result := '-infinity';
      exit
    end;
    result := 'mate ';
    if hodnota < 0 then
      result := result + '-';
    if (hodnota = mat) or (hodnota = -mat) then
    begin
      result := result + '0';
      exit;
    end;
    if hodnota > 0 then
      hodnota := mat - hodnota
    else
      hodnota := mat + hodnota;
    hodnota := (hodnota + 1) shr 1;
    result := result + IntToStr(hodnota);
  end;
end;

function S4ToS2(const hodnota: THScore): S2;
begin
  if hodnota = NeHodnota then
  begin
    result := -32768;
  end
  else if hodnota >= mat - 100 then
    Result := hodnota - mat + 32767
  else if hodnota <= 100 - mat then
    Result := hodnota + mat - 32767
  else
    Result := RoundDiv(hodnota, 10);
end;

{ TMyslitel }

constructor TMyslitel.Create;
begin
  inherited Create;

  FRandomGenerator := TSxRandomGenerator.Create;
  MeziVypocet := TMezivypocet.Create;
  FAspirationWindowSize := 250;
  // Hraji := nHraji;
end;

destructor TMyslitel.Destroy;
begin
  try
    FRandomGenerator.Free;
    MeziVypocet.Free;
    FKnihovna.Free;
    DonePJednoPartie(FPartie);
  finally
    inherited Destroy;
  end;
end;

procedure TMyslitel.BookMoves;
var
  Tahy1: TTahy1;
  i: Integer;
  BookVariantName: string;
begin
  if FKnihovna = nil then
  begin
    FKnihovna := TKnihovna.Create;
    FKnihovna.otevri(FOptions.BookFile.Value);
    if EngineOutput.DebugMode then
      EngineOutput.TellGUIDebug('Book nodes: ' + IntToStr(FKnihovna.NodeCount) + '; Book depth: ' + IntToStr(FKnihovna.HloubkaStromu));
  end;
  Tahy1 := FKnihovna.DejTahy(FPozice, BookVariantName);
  if BookVariantName <> '' then
    EngineOutput.TellGUIInfo('Book variant: ' + BookVariantName);
  for i := 0 to Length(Tahy1) - 1 do
  begin
    VypisNejlepsi(Tahy1[i], '', 0, sbExact);
  end;
end;

procedure TMyslitel.MysliOTahDopredu;
var
  MeziDataJeho: TMeziData;
  Procedure Jedeme(bily: Boolean);
  var
    poprve: Boolean;
    t2: ttah2;
    MeziDataMoje: TMeziData;
    PomHloubka, K, Dobrych: Integer;
    Nejlepsi: ShortString;
  begin
    Nejlepsi := '';
    poprve := true;
    repeat
      PomHloubka := MeziDataJeho.Hloubka;
      if poprve or (MeziDataJeho.Tahy.Poctah > 1) then
      begin
        { <Ladící výpisy> }
        if EngineOutput.DebugMode then
          EngineOutput.TellGUIDebug('Přemýšlím co soupeř zahraje...');
        { </Ladící výpisy> }
        { <Běžné výpisy> }
        // if Vypisovac.Cfg.mdPovoleno then
        // MysDopForm.Label4.Caption := 'Věštím soupeřův tah.';
        { </Běžné výpisy> }
        poprve := false;
      end;
      if MeziDataJeho.Tahy.Poctah > 1 then
        repeat
          if bily then
            globBIterace(MeziDataJeho, AlgCfg.DoprHorsiTahy, Nejlepsi)
          else
            globCIterace(MeziDataJeho, AlgCfg.DoprHorsiTahy, Nejlepsi);
        until (FStopManager.Cause <> scNone) or MeziDataJeho.Dojeto or (MeziDataJeho.Hloubka > PomHloubka)
      else
      begin
        MeziDataJeho.Dojeto := true;
      end;

      { <Ladící výpisy> }
      if MeziDataJeho.Platnych < 1 then
        MeziDataJeho.Platnych := 1;
      Dobrych := 0;
      repeat
        inc(Dobrych)
      until (Dobrych = MeziDataJeho.Tahy.Poctah) or
        (Dobrych = MeziDataJeho.Platnych) or
        (MeziDataJeho.Hodnoty[1] < -mat + 100) or
        (MeziDataJeho.Hodnoty[1] > mat - 100) or
      { Musím si dávat pozor na přetečení }
        (MeziDataJeho.Hodnoty[Dobrych + 1] < MeziDataJeho.Hodnoty[1] - AlgCfg.DoprHorsiTahy) or
        (MeziDataJeho.Hodnoty[Dobrych + 1] > MeziDataJeho.Hodnoty[1] + AlgCfg.DoprHorsiTahy);
      for K := 1 to Dobrych do
      begin
        if (FStopManager.Cause <> scNone) then
          break;
        if EngineOutput.DebugMode then
          EngineOutput.TellGUIDebug('Chystám se na soupeřův tah ' + string(TTah1ToLongStr(MeziDataJeho.Tahy.t[K])));
        { </Ladící výpisy> }
        { <Běžné výpisy> }
        { if Vypisovac.Cfg.mdPovoleno then
          MysDopForm.Label4.Caption := 'Počítám odpověď na ' +
          TTah1ToStr(MeziDataJeho.Tahy.t[K], Pozice) + '.'; }
        { </Běžné výpisy> }
        DoplnTah(MeziDataJeho.Tahy.t[K], FPozice, t2);
        PridejTah(FPartie, t2);
        tahni(FPozice, MeziDataJeho.Tahy.t[K]);
        { A teď myslím na odpověď }
        MeziVypocet.DejInfo(FPozice, MeziDataMoje);
        if (FStopManager.Cause = scNone) and (not MeziDataMoje.Dojeto) and
          (MeziDataMoje.Hloubka <= MeziDataJeho.Hloubka) and
          (MeziDataMoje.Tahy.Poctah > 0) then
        begin
          repeat
            if bily then
              globCIterace(MeziDataMoje, AlgCfg.NormHorsiTahy, Nejlepsi)
            else
              globBIterace(MeziDataMoje, AlgCfg.DoprHorsiTahy, Nejlepsi);
          until (FStopManager.Cause <> scNone) or (MeziDataMoje.Dojeto) or
            (MeziDataMoje.Hloubka >= MeziDataJeho.Hloubka);
          MeziVypocet.Pridej(MeziDataMoje);
          if EngineOutput.DebugMode then
            EngineOutput.TellGUIDebug(' Moje odpověď: ' + string(TTah1ToLongStr(MeziDataMoje.Tahy.t[1])));
        end;
        tahni_zpet(FPozice, t2);
        UberTah(FPartie);
      end;
    until (FStopManager.Cause <> scNone);
  end;

var
  I: Integer;
  t2: ttah2;
  Name: string;
  Tahy1: TTahy1;
begin
  { Mat+2 je totiž zároveň největší LongInt, můžu tedy myslet pořád. }
  if EngineOutput.DebugMode then
    EngineOutput.TellGUIDebug('Začínám myslet dopředu...');
  MeziVypocet.SmazSeznam; { Seznam může být nil, ale to nevadí. }
  MeziVypocet.DejInfo(FPozice, MeziDataJeho);
  { Je sice jisté, že Pozice v mezivýpočtu nebude, to ale nevadí, stejně to
    najde tahy atd... }
  if MeziDataJeho.Tahy.Poctah > 0 then
  begin
    if FOptions.OwnBook.Value then
    begin
      I := 1;
      while I <= MeziDataJeho.Tahy.Poctah do
      begin
        DoplnTah(MeziDataJeho.Tahy.t[I], FPozice, t2);
        tahni(FPozice, MeziDataJeho.Tahy.t[I]);
        Tahy1 := FKnihovna.DejTahy(FPozice, Name);
        if Length(Tahy1) > 0 then
        begin
          { nebudu počítat odpověď na tah, který vede k pozici, co mám v knihovně }
          MeziDataJeho.Tahy.t[I] := MeziDataJeho.Tahy.t
            [MeziDataJeho.Tahy.Poctah];
          dec(MeziDataJeho.Tahy.Poctah);
          dec(I)
        end;
        tahni_zpet(FPozice, t2);
        inc(I)
      end;
    end; { Od PouzitKnihovnu }
    { Asi není nutné, ale to osekávání přece jen chvíli trvalo... }
    if (MeziDataJeho.Tahy.Poctah > 0) and (FStopManager.Cause = scNone)
    then { mohl jsem totiž vymazat všechny tahy }
      if hb in FPozice.stav.b then
        Jedeme(true)
      else
        Jedeme(false);
  end;
  DonePJednoPartie(FPartie);
  if EngineOutput.DebugMode then
    EngineOutput.TellGUIDebug('Končím myšlení dopředu');
end;

Procedure TMyslitel.VypisVariantu(Tah1: ttah1;
  PocPos: byte; Hloubka: Integer; const Index: Integer);
{const
  Period = 1000;}
begin
  { <Ladící výpisy> }
  if (DetailedDebug and EngineOutput.DebugMode) or (Options.ShowCurrLine.Value) then
  begin
    pocitam := Copy(pocitam, 1, PocPos) + TTah1ToLongStr(Tah1) + ' ';
//    if (DetailedDebug and EngineOutput.DebugMode) then
//      if (AnalysisInfo.Nodes mod Period = 0) then
//        EngineOutput.DrawCurrLine(string(pocitam));
  end;
  { </Ladící výpisy> }
end;

{
procedure Check(const AMoveString: string);
var
  i: Integer;
begin
  for i := 1 to Length(AMoveString) do
  begin
    if not (AMoveString[i] in ['0'..'9', 'a'..'h', ' ']) then
      raise Exception.Create('Invalid move');
  end;
end;
}
Procedure TMyslitel.VypisNejlepsi(const Tah1: ttah1; const Nejlepsi: string;
  const Score: THScore; const AScoreBound: TScoreBound);
var
  BestStatus: TSubtreeStatus;
  Moves: array of string;
  InLineIndex: SG;
begin
  BestStatus.Score := S4ToS2(Score);
  BestStatus.ScoreBound := AScoreBound;
  BestStatus.VariationCut := vcNone;
  BestStatus.MoveCount := 1;

  SetLength(Moves, 1);
  Moves[0] := string(TTah1ToLongStr(Tah1));
  InLineIndex := 2; // Skip first space
  while InLineIndex <= Length(Nejlepsi) do
  begin
    SetLength(Moves, BestStatus.MoveCount + 1);
    Moves[BestStatus.MoveCount] := ReadToChar(Nejlepsi, InLineIndex, CharSpace);
    Inc(BestStatus.MoveCount);
  end;

  FAnalysisInfo.AddAnalysis(BestStatus, Moves);
  { <Běžné výpisy> }
  EngineOutput.DrawAMoves;
  StopManager.UpdateStopAnalysis;
  { </Běžné výpisy> }
end;

Procedure TMyslitel.globBIterace(var MeziData: TMeziData; HorsiTahy: THScore;
  var Nejlepsi: ShortString);
{ Volat pouze hraje-li bílý.
  Provedení jedné iterace v Okénku (Alfa,Beta). }
var
  JeTah, Dj: Boolean;
  I, K: Integer;
  PocPos: byte;
  t2: ttah2;
  PomTah: ttah1;
  PomHodnota: THScore;
  MoveStr: string;
begin
  if MeziData.Dojeto then
    exit;
  PocPos := length(pocitam);
  Nejlepsi := '';
  { <Ladící výpisy> }
  if EngineOutput.DebugMode then
    WriteZacatekIterace(MeziData);
  { </Ladící výpisy> }
  MeziData.Dojeto := true;
  JeTah := false;
  if MeziData.I = 1 then
    MeziData.Platnych := 1;
  for I := MeziData.I to MeziData.Tahy.Poctah do
  begin
    MoveStr := string(TTah1ToLongStr(MeziData.Tahy.t[I]));
    if not FRootMoves.AcceptMove(MoveStr) then
      Continue;
    MeziData.I := I;
    { <Běžné výpisy> }
    VypisVariantu(MeziData.Tahy.t[I], PocPos, 1, I);
    FAnalysisInfo.SetCurrentMove(I - 1, MoveStr);
    EngineOutput.DrawMove1;
    FStopManager.UpdateStopMove;
    { </Běžné výpisy> }
    { <Ladící výpisy> }
    if EngineOutput.DebugMode then
      WritePocitamTah(MeziData, 4);
    { </Ladící výpisy> }
    DoplnTah(MeziData.Tahy.t[I], FPozice, t2);
    tahni(FPozice, MeziData.Tahy.t[I]);
    PridejTah(FPartie, t2);
    if PoloRemis(FPartie, FPozice) then
      MeziData.Hodnoty[I] := FRemisValue
    else
    begin
      MeziData.Hodnoty[I] := Alfa_Beta(MeziData.Alfa, MeziData.Beta,
        MeziData.Hloubka, Dj, 2, Nejlepsi);
      if MeziData.Hodnoty[I] <> NeHodnota then
        if MeziData.Hodnoty[I] > mat - 100 then
          dec(MeziData.Hodnoty[I])
        else if MeziData.Hodnoty[I] < -mat + 100 then
          inc(MeziData.Hodnoty[I]);
      if not Dj then
        MeziData.Dojeto := false; { nedopočetl-li jsem aspoň 1 tah, je to celé nedopočtené }
    end;
    UberTah(FPartie);
    tahni_zpet(FPozice, t2);
    if MeziData.Hodnoty[I] = NeHodnota then
    begin
      MeziData.Dojeto := false;
      pocitam[0] := AnsiChar(PocPos);
      exit
    end;
    if MeziData.Hodnoty[I] > MeziData.Alfa then
    begin
      { 2. změna } { probublám dobrým tahem dopředu a to i v případě, že není v (alfa,beta) }
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
        { <Ladící výpisy> }
        if EngineOutput.DebugMode then
        begin
          EngineOutput.TellGUIDebug('  Neúspěch iterace, přelezl jsem okénko tahem ' + string(TTah1ToLongStr(MeziData.Tahy.t[1])))
        end;
        { </Ladící výpisy> }
        VypisNejlepsi(MeziData.Tahy.t[1], '', MeziData.Hodnoty[1], sbLower);
        MeziData.I := 1;
        MeziData.Alfa := MeziData.Beta - 1;
        MeziData.Beta := mat;
        pocitam[0] := AnsiChar(PocPos);
        AnalysisInfo.BadMove := True;
        exit { Okénko moc dole }
      end; { od přelezení okénka }
      JeTah := true;
      if I <> 1 then
        inc(MeziData.Platnych);
      { 3. změna } If K = 1 then
      begin
        { Tah je nejen v intervalu (alfa, beta), ale je skutečně nejlepší }
        if (MeziData.Hodnoty[1] > mat - 100) or
          (MeziData.Hodnoty[1] < -mat + 100) then
          MeziData.Alfa := MeziData.Hodnoty[1]
        else if MeziData.Alfa < MeziData.Hodnoty[1] - HorsiTahy then
          MeziData.Alfa := MeziData.Hodnoty[1] - HorsiTahy;
        if MeziData.I <> 1 then
        begin
          AnalysisInfo.ChangedMove := True;
          if EngineOutput.DebugMode then
            EngineOutput.TellGUIDebug('Best move is changed.');
        end;
        { <Běžné výpisy> }
        VypisNejlepsi(MeziData.Tahy.t[1], string(Nejlepsi), MeziData.Hodnoty[1], sbExact);
        { </Běžné výpisy> }
        { <Ladící výpisy> }
        if EngineOutput.DebugMode then
          WriteDobryTah(MeziData) { je to dobře ? };
        { </Ladící výpisy> }
      end;

      if JeTah and (MeziData.Alfa >= mat - MeziData.Hloubka) then
      begin
        MeziData.Dojeto := true;
        pocitam[0] := AnsiChar(PocPos);
        exit;
      end;
    end;
  end; { od for cyklu přes tahy }
  if not JeTah then
  begin
    { <Ladící výpisy> }
    if EngineOutput.DebugMode then
    begin
      EngineOutput.TellGUIDebug('  Neúspěch iterace, všechny tahy byly pod okénkem');
    end;
    { </Ladící výpisy> }
    MeziData.Alfa := -mat;
    MeziData.Beta := MeziData.Hodnoty[1] + 1;
    MeziData.I := 1;
    { Okénko moc nahoře }
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
    if MeziData.Hodnoty[1] < -mat + FAspirationWindowSize then
      MeziData.Alfa := MeziData.Hodnoty[1] - 1
    else
      MeziData.Alfa := MeziData.Hodnoty[1] - FAspirationWindowSize;
    if MeziData.Hodnoty[1] > mat - FAspirationWindowSize then
      MeziData.Beta := MeziData.Hodnoty[1] + 1
    else
      MeziData.Beta := MeziData.Hodnoty[1] + FAspirationWindowSize;
    inc(MeziData.Hloubka)
  end;
  pocitam[0] := AnsiChar(PocPos);
end; { Konec BIterace }

Procedure TMyslitel.globCIterace(var MeziData: TMeziData; HorsiTahy: THScore;
  var Nejlepsi: ShortString);
{ Volat pouze hraje-li černý.
  Provedení jedné iterace v Okénku (Alfa,Beta). }
var
  JeTah, Dj: Boolean;
  I, K: Integer;
  PocPos: byte;
  t2: ttah2;
  PomTah: ttah1;
  PomHodnota: THScore;
  MoveStr: string;
begin
  if MeziData.Dojeto then
    exit;
  PocPos := length(pocitam);
  Nejlepsi := '';
  { <Ladící výpisy> }
  if EngineOutput.DebugMode then
    WriteZacatekIterace(MeziData);
  { </Ladící výpisy> }
  MeziData.Dojeto := true;
  JeTah := false;
  if MeziData.I = 1 then
    MeziData.Platnych := 1;
  for I := MeziData.I to MeziData.Tahy.Poctah do
  begin
    MoveStr := string(TTah1ToLongStr(MeziData.Tahy.t[I]));
    if not FRootMoves.AcceptMove(MoveStr) then
      Continue;
    MeziData.I := I;
    { <Běžné výpisy> }
    VypisVariantu(MeziData.Tahy.t[I], PocPos, 1, I);
    FAnalysisInfo.SetCurrentMove(I - 1, MoveStr);
    EngineOutput.DrawMove1;
    FStopManager.UpdateStopMove;
    { </Běžné výpisy> }
    { <Ladící výpisy> }
    if EngineOutput.DebugMode then
      WritePocitamTah(MeziData, 4);
    { </Ladící výpisy> }
    DoplnTah(MeziData.Tahy.t[I], FPozice, t2);
    tahni(FPozice, MeziData.Tahy.t[I]);
    PridejTah(FPartie, t2);
    if PoloRemis(FPartie, FPozice) then
      MeziData.Hodnoty[I] := FRemisValue
    else
    begin
      MeziData.Hodnoty[I] := Alfa_Beta(MeziData.Alfa, MeziData.Beta,
        MeziData.Hloubka, Dj, 2, Nejlepsi);
      if MeziData.Hodnoty[I] <> NeHodnota then
        if MeziData.Hodnoty[I] > mat - 100 then
          dec(MeziData.Hodnoty[I])
        else if MeziData.Hodnoty[I] < -mat + 100 then
          inc(MeziData.Hodnoty[I]);
      if not Dj then
        MeziData.Dojeto := false; { nedopočetl-li jsem aspoň 1 tah,
        je to celé nedopočtené }
    end;
    UberTah(FPartie);
    tahni_zpet(FPozice, t2);
    if MeziData.Hodnoty[I] = NeHodnota then
    begin
      MeziData.Dojeto := false;
      pocitam[0] := AnsiChar(PocPos);
      exit
    end;
    if MeziData.Hodnoty[I] < MeziData.Beta then
    begin
      { 2. změna } { probublám dobrým tahem dopředu a to i v případě, že není v (alfa,beta) }
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
        { <Ladící výpisy> }
          if EngineOutput.DebugMode then
          begin
            EngineOutput.TellGUIDebug('  Neúspěch iterace, podlezl jsem okénko tahem ' + string(TTah1ToLongStr(MeziData.Tahy.t[1])))
          end;
        { </Ladící výpisy> }
        VypisNejlepsi(MeziData.Tahy.t[1], '', -MeziData.Hodnoty[1], sbUpper);
        MeziData.I := 1;
        MeziData.Beta := MeziData.Alfa + 1;
        MeziData.Alfa := -mat;
        pocitam[0] := AnsiChar(PocPos);
        AnalysisInfo.BadMove := True;
        exit { Okénko moc nahoře }
      end; { od podlezení okénka }
      JeTah := true;
      if I <> 1 then
        inc(MeziData.Platnych);
      { 3. změna } If K = 1 then
      begin
        { Tah je nejen v intervalu (alfa, beta), ale je skutečně nejlepší }
        if (MeziData.Hodnoty[1] > mat - 100) or
          (MeziData.Hodnoty[1] < -mat + 100) then
          MeziData.Beta := MeziData.Hodnoty[1]
        else if MeziData.Beta > MeziData.Hodnoty[1] + HorsiTahy then
          MeziData.Beta := MeziData.Hodnoty[1] + HorsiTahy;
        { <Běžné výpisy> }
        VypisNejlepsi(MeziData.Tahy.t[1], string(Nejlepsi), -MeziData.Hodnoty[1], sbExact);
        { </Běžné výpisy> }
        { <Ladící výpisy> }
        if EngineOutput.DebugMode then
          WriteDobryTah(MeziData) { je to dobře ? };
        { </Ladící výpisy> }
      end;

      if JeTah and (MeziData.Beta <= -mat + MeziData.Hloubka) then
      begin
        MeziData.Dojeto := true;
        pocitam[0] := AnsiChar(PocPos);
        exit;
      end
    end
  end; { od for cyklu přes tahy }
  if not JeTah then
  begin
    { <Ladící výpisy> }
    if EngineOutput.DebugMode then
    begin
      EngineOutput.TellGUIDebug('  Neúspěch iterace, Všechny tahy byly nad okénkem');
    end;
    { </Ladící výpisy> }
    MeziData.Beta := mat;
    MeziData.Alfa := MeziData.Hodnoty[1] - 1;
    MeziData.I := 1;
    { Okénko moc dole }
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
    if MeziData.Hodnoty[1] < -mat + FAspirationWindowSize then
      MeziData.Alfa := MeziData.Hodnoty[1] - 1
    else
      MeziData.Alfa := MeziData.Hodnoty[1] - FAspirationWindowSize;
    if MeziData.Hodnoty[1] > mat - FAspirationWindowSize then
      MeziData.Beta := MeziData.Hodnoty[1] + 1
    else
      MeziData.Beta := MeziData.Hodnoty[1] + FAspirationWindowSize;
    inc(MeziData.Hloubka)
  end;
  pocitam[0] := AnsiChar(PocPos);
end; { Konec CIterace }

procedure TMyslitel.DejTah;
var
  MeziData: TMeziData;

  Procedure Jedeme(bily: Boolean);
  var
    Nejlepsi: ShortString;
  begin
    Nejlepsi := '';
    repeat
      if AnalysisInfo.Depth <> MeziData.Hloubka + 1 then
      begin
        FStopManager.UpdateStopDepth;
        if FStopManager.Cause <> scNone then
          exit;
        AnalysisInfo.Depth := MeziData.Hloubka + 1;
        EngineOutput.DrawDepth;
      end;
      if bily then
        globBIterace(MeziData, AlgCfg.NormHorsiTahy, Nejlepsi)
      else
        globCIterace(MeziData, AlgCfg.NormHorsiTahy, Nejlepsi);
    until (FStopManager.Cause <> scNone) or MeziData.Dojeto;
    DonePJednoPartie(FPartie);
  end;

var
  Dobrych: Integer;
  K: Integer;
  RandomValue: THScore;
  Score: THScore;
begin { DejTah }
  try
    if EngineOutput.DebugMode then
      EngineOutput.TellGUIDebug('Start');

    if (FAnalysisInfo.AnalysisCount = 0) or (FStopManager.LevelManager.InfiniteAnalysis) then
    begin
      MeziVypocet.DejInfo(FPozice, MeziData);
      AnalysisInfo.MoveCount := MeziData.Tahy.Poctah;
      if MeziData.Tahy.Poctah = 0 then
      begin
        EngineOutput.TellGUIInfo('No move available.');
        Exit;
      end
      else if (MeziData.Tahy.Poctah > 1) or (FStopManager.LevelManager.InfiniteAnalysis) then { Pokud má smysl přemýšlet tak }
      begin
        if hb in FPozice.stav.b then
        begin
          FRemisValue := FOptions.ContemptValue.Value * 10;
          Jedeme(true)
        end
        else
        begin
          FRemisValue := -FOptions.ContemptValue.Value * 10;
          Jedeme(false);
        end;

        if FOptions.RandomPlay.Value then
          RandomValue := FOptions.RandomValue.Value * 10
        else
          RandomValue := 0;

        if (RandomValue > 0) and (MeziData.Tahy.Poctah > 1) and (MeziData.Platnych > 1) {abort on start of depth X} then
        begin
          Dobrych := 0;
          repeat
            inc(Dobrych)
          until (Dobrych = MeziData.Tahy.Poctah) or (Dobrych = MeziData.Platnych) or
            (MeziData.Hodnoty[1] < -mat + 100) or (MeziData.Hodnoty[1] > mat - 100) or
            (MeziData.Hodnoty[Dobrych + 1] < MeziData.Hodnoty[1] - RandomValue) or
            (MeziData.Hodnoty[Dobrych + 1] > MeziData.Hodnoty[1] + RandomValue);

          if Dobrych > 1 then
          begin
            EngineOutput.TellGUIInfo('Good moves: ' + IntToStr(Dobrych) + ' / ' + IntToStr(MeziData.Platnych) + ' / ' + IntToStr(MeziData.Tahy.Poctah));
            for K := 1 to Dobrych do
              EngineOutput.TellGUIInfo(string(TTah1ToLongStr(MeziData.Tahy.t[K]))
                + ' (' + EngineOutput.ScoreToStr(S4ToS2(MeziData.Hodnoty[K]), sbExact) + ')');
            K := FRandomGenerator.RangeU4(Dobrych - 1) + 1;
            if k > 1 then
            begin
              if hb in FPozice.stav.b then
                Score := MeziData.Hodnoty[k]
              else
                Score := -MeziData.Hodnoty[k];

              VypisNejlepsi(MeziData.Tahy.t[k], '', Score, sbExact);
              EngineOutput.TellGUIInfo('I play ' + IntToStr(k) + '. best move.');
            end;
          end;
        end;
      end;

      if (AnalysisInfo.AnalysisCount = 0) then
      begin
        { mám jen jeden přípustný tah or abort on Depth 0}
        VypisNejlepsi(MeziData.Tahy.t[1], '', MeziData.Hodnoty[1], sbExact);
      end;
    end;
  except
    on E: Exception do
      EngineOutput.TellGUIError(E.Message);
  end;
end;

procedure TMyslitel.SetAnalysisInfo(const Value: TAnalysisInfo);
begin
  FAnalysisInfo := Value;
end;

procedure TMyslitel.SetAspirationWindowSize(const Value: THScore);
begin
  FAspirationWindowSize := Value;
  MeziVypocet.AspirationWindowSize := Value;
end;

procedure TMyslitel.SetEngineOutput(const Value: TEngineOutput);
begin
  FEngineOutput := Value;
end;

procedure TMyslitel.SetOptions(const Value: TCommonEngineOptions);
begin
  FOptions := Value;
end;

procedure TMyslitel.SetPartie(const APartie: PJednoPartie);
var
  ClaimMoves: Integer;
begin
  DonePJednoPartie(FPartie);
  ClaimMoves := CopyKusPartie(FPozice, APartie, FPartie);
  Assert(ClaimMoves >= 0);
  if DetailedDebug and EngineOutput.DebugMode then
    EngineOutput.TellGUIDebug('Claim moves: ' + IntToStr(ClaimMoves));
end;

procedure TMyslitel.SetPozice(const Value: TPozice);
begin
  FPozice := Value;
end;

procedure TMyslitel.SetRootMoves(const Value: TRootMoves);
begin
  FRootMoves := Value;
end;

procedure TMyslitel.SetStopManager(const Value: TStopManager);
begin
  FStopManager := Value;
end;

function TMyslitel.Transformuj(co: THScore): THScore;
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
  if (FStopManager.Cause <> scNone) then
    result := true
  else
  begin
    StopManager.UpdateStopNode;
    if StopManager.Cause <> scNone then
    begin
      result := true
    end;
  end;
end;

function TMyslitel.Alfa_Beta_Vrazi(Alfa, Beta: THScore; Hloubka: Integer;
  out Dojeto: Boolean; HloubkaRekurze: Integer): THScore;
var
  Tahy: TTahy;
  t2: ttah2;
  pomtah1: ttah1;
  HodnotyTahu: THodnotyTahu;
  sach, Dj: Boolean;
  hodnota, HodPos, sAlfa, sBeta, pomlongint: THScore;
  h: Integer;
  I: byte;
begin
  Result := NeHodnota; // Used?
  FAnalysisInfo.NextNode;
  if HloubkaRekurze > AnalysisInfo.SelDepth then
  begin
    AnalysisInfo.SelDepth := HloubkaRekurze;
    FEngineOutput.DrawSelDepth;
  end;
  Dojeto := false;
  if (Alfa < -mat + 100) and (Alfa >= -mat) then
    Alfa := Alfa - 1;
  if (Beta > mat - 100) and (Beta <= mat) then
    Beta := Beta + 1;
  if MusimKoncit then
    result := NeHodnota
  else
  begin
    sach := {$IFDEF JENBRANI}nalezbrani{$ELSE}nalezvrahy{$ENDIF}(FPozice, Tahy);
    if Tahy.Poctah = 0 then
    begin
      Dojeto := true;
      if sach then { Je-li někdo v šachu a nemá přípustný vrah (a zde je
          vrahem každý tah), je v matu. }
        if hb in FPozice.stav.b then
          result := -mat
        else
          result := mat
      else
        result := HodnotaPozice(FPozice);
    end { Od Tahy.poctah=0 }
    else
    begin
      if Hloubka = 0 then
      begin
        result := HodnotaPozice(FPozice);
        Dojeto := false { vražedná variata pokračuje, ale nedopočetl jsem ji }
      end
      else
      begin
        sAlfa := Alfa;
        sBeta := Beta; { V kaskádovém průchodu bych si je rozhasil }
        if not sach then
        begin
          { Není-li hráč v šachu, nemusí nutně pokračovat ve vražedné variantě a může
            se od ní odchýlit. Aneb jinak bych počítal, jako by se v šachách muselo
            brát. Je-li ale v šachu, je jeho další tah vždy vrah, takže mu dalším
            propočtem nekřivdím. }
          HodPos := HodnotaPozice(FPozice);
          if (hb in FPozice.stav.b) and (HodPos >= sBeta) or
            not(hb in FPozice.stav.b) and (HodPos <= sAlfa) then
          begin
            Dojeto := true;
            result := HodPos;
            exit { nevešel jsem se do (alfa, beta), navíc špatným směrem }
          end;
        end
        else
          HodPos := 0; // Not used
        for I := 1 to Tahy.Poctah do
          HodnotyTahu[I] := NeHodnota;
        if hb in FPozice.stav.b then { Hraje bílý }
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
                { tj. if počítal bych již vypočtené, přečtu si ti z pole }
              else
              begin { musím počítat }
                DoplnTah(Tahy.t[I], FPozice, t2);
                tahni(FPozice, Tahy.t[I]);
                PridejTah(FPartie, t2);
                if PoloRemis(FPartie, FPozice) then
                begin
                  hodnota := FRemisValue;
                  Dj := true;
                end
                else
                  hodnota := Transformuj(Alfa_Beta_Vrazi(Alfa, Beta, h, Dj, HloubkaRekurze + 1));
                UberTah(FPartie);
                if Dj then
                  HodnotyTahu[I] := hodnota
                  { Tah je dopočítán, zapamatuji si hodnotu }
                else
                  Dojeto := false; { nedopočetl-li jsem aspoň 1 tah,
                  je to celé nedopočtené }
                tahni_zpet(FPozice, t2);
                if hodnota = NeHodnota then
                begin
                  result := NeHodnota;
                  exit
                end;
              end; { od musím počítat }
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
            end; { od for cyklu přes tahy }
            result := Alfa;
            if Dojeto then
              break; { Dopočítal jsem to až do konce. Zvýšení
              hloubky propočtu nemá smysl (počítal bych již vypočtené). }
          end { od cyklu přes hloubku }
        end { od hb in pozice.stav.b }
        else { Hraje černý }
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
                { tj. if počítal bych již vypočtené, přečtu si ti z pole }
              else
              begin { musím počítat }
                DoplnTah(Tahy.t[I], FPozice, t2);
                tahni(FPozice, Tahy.t[I]);
                PridejTah(FPartie, t2);
                if PoloRemis(FPartie, FPozice) then
                begin
                  hodnota := FRemisValue;
                  Dj := true;
                end
                else
                  hodnota := Transformuj(Alfa_Beta_Vrazi(Alfa, Beta, h, Dj, HloubkaRekurze + 1));
                UberTah(FPartie);
                if Dj then
                  HodnotyTahu[I] := hodnota
                  { Tah je dopočítán, zapamatuji si hodnotu }
                else
                  Dojeto := false; { nedopočetl-li jsem aspoň 1 tah,
                  je to celé nedopočtené }
                tahni_zpet(FPozice, t2);
                if hodnota = NeHodnota then
                begin
                  result := NeHodnota;
                  exit
                end;
              end; { od musím počítat }
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
            end; { od for cyklu přes tahy }
            result := Beta;
            if Dojeto then
              break; { Dopočítal jsem to až do konce. Zvýšení
              hloubky propočtu nemá smysl (počítal bych již vypočtené). }
          end; { Od cyklu přes hloubku }
        end; { Od hraje černý }
      end; { od not(hloubka=0) }
    end; { od not(tahy.poctah=0) }
  end; { Od not MusimKoncit }
end;

{ Od Alfa_Beta_Vrazi }

{ Ačkoliv jsem víceméně vyznavačem Pascalu, když vidím tolik endů za sebou... }
function TMyslitel.Alfa_Beta(Alfa, Beta: THScore; Hloubka: Integer;
  var Dojeto: Boolean; HloubkaRekurze: Integer;
  var Nejlepsi: ShortString): THScore;
var
  Tahy: TTahy;
  t2: ttah2;
  pomtah1: ttah1;
  HodnotyTahu: THodnotyTahu;
  sach, Dj: Boolean;
  hodnota, sAlfa, sBeta, pomlongint: THScore;
  h: Integer;
  I, PocPos: byte;
  PomStr: ShortString;
begin
  FAnalysisInfo.NextNode;
  if HloubkaRekurze > AnalysisInfo.SelDepth then
  begin
    AnalysisInfo.SelDepth := HloubkaRekurze;
    FEngineOutput.DrawSelDepth;
  end;

  if (Alfa < -mat + 100) and (Alfa >= -mat) then
    Alfa := Alfa - 1;
  if (Beta > mat - 100) and (Beta <= mat) then
    Beta := Beta + 1;
  PocPos := length(pocitam);
//  NejPos := length(Nejlepsi);
  if MusimKoncit then
    result := NeHodnota
  else
  begin { nemusím končit }
    Dojeto := false;
    if Hloubka = 0 then
    begin
      result := { HodnotaPozice(Pozice,AlgCfg); }
        Transformuj(Alfa_Beta_Vrazi(Alfa, Beta, HloubkaRekurze + 1,
        sach { nějaký nepoužitý boolean } , HloubkaRekurze + 1));
      if result = mat - 1 then
        result := mat
      else if result = -mat + 1 then
        result := -mat;
      if (result = mat) or (result = -mat) then
        Dojeto := true { Jsem v matu }
      else
        Dojeto := false; { variata pokračuje, ale nedopočetl jsem ji }
      { <Ladící výpisy> }
      if DetailedDebug and EngineOutput.DebugMode then
        writeStrOdsaz('Dopočet do tiché pozice: ' + HodnotaToStr(result), HloubkaRekurze + 2);
      { </Ladící výpisy> }
    end { od hloubka=0 }
    else
    begin { hloubka>0 }
      { <Ladící výpisy> }
      if DetailedDebug and EngineOutput.DebugMode then
        writeZacatekAlfaBeta(Alfa, Beta, Hloubka, HloubkaRekurze);
      { </Ladící výpisy> }
      sach := Rychle.NalezTahy(FPozice, Tahy);
      if Tahy.Poctah = 0 then
      begin
        if sach then { Je-li někdo v šachu a nemá přípustný tah je v matu. }
          if hb in FPozice.stav.b then
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
        if hb in FPozice.stav.b then { Hraje bílý }
        begin
          result := Alfa;
          for h := 0 to Hloubka - 1 do
          begin
            { <Ladící výpisy> }
            if DetailedDebug and EngineOutput.DebugMode then
              writeZacatekAlfaBetaIterace(sAlfa, sBeta, h, HloubkaRekurze);
            { </Ladící výpisy> }
            pocitam[0] := AnsiChar(PocPos);
            Dojeto := true;
            Alfa := sAlfa;
            Beta := sBeta;
            for I := 1 to Tahy.Poctah do
            begin
              { <Běžné výpisy> }
              VypisVariantu(Tahy.t[I], PocPos, HloubkaRekurze, I);
              { </Běžné výpisy> }
              { <Ladící výpisy> }
              if DetailedDebug and EngineOutput.DebugMode then
                writeStrOdsaz(string(TTah1ToLongStr(Tahy.t[I])), 3 + HloubkaRekurze);
              { </Ladící výpisy> }

              if HodnotyTahu[I] <> NeHodnota then
              begin
                hodnota := HodnotyTahu[I];
                PomStr := '';
              end
              { tj. if počítal bych již vypočtené, přečtu si to z pole }
              else
              begin { musím počítat }
                DoplnTah(Tahy.t[I], FPozice, t2);
                tahni(FPozice, Tahy.t[I]);
                PridejTah(FPartie, t2);
                Dj := true;
                PomStr := '';
                if PoloRemis(FPartie, FPozice) then
                begin
                  hodnota := FRemisValue
                end
                else
                begin
                  hodnota := Transformuj(Alfa_Beta(Alfa, Beta, h, Dj,
                    HloubkaRekurze + 1, PomStr));
                end;
                UberTah(FPartie);
                if Dj then
                  HodnotyTahu[I] := hodnota
                  { Tah je dopočítán, zapamatuji si hodnotu }
                else
                  Dojeto := false; { nedopočetl-li jsem aspoň 1 tah,
                  je to celé nedopočtené }
                tahni_zpet(FPozice, t2);
                if hodnota = NeHodnota then
                begin
                  result := NeHodnota;
                  pocitam[0] := AnsiChar(PocPos);
                  exit
                end;
              end; { od musím počítat }
              if hodnota > Alfa then
              begin
                Alfa := hodnota;
                // result := Alfa; TODO : not used
                { <Ladící výpisy> }
                if DetailedDebug and EngineOutput.DebugMode then
                  writeStrOdsaz('Zlepšující tah, Alfa=' + HodnotaToStr(Alfa), 3 + HloubkaRekurze);
                { </Ladící výpisy> }
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
                begin
                  if HloubkaRekurze <= AnalysisInfo.Depth + 2 then
                  begin
                    Nejlepsi := ' ' + TTah1ToLongStr(pomtah1) + PomStr;
                  end;
                end;
              end
            end; { od for cyklu přes tahy }
            result := Alfa;
            if Dojeto then
              break; { Dopočítal jsem to až do konce. Zvýšení
              hloubky propočtu nemá smysl (počítal bych již vypočtené). }
          end { od cyklu přes hloubku }
        end { od hb in pozice.stav.b }
        else { Hraje černý }
        begin
          result := Beta;
          for h := 0 to Hloubka - 1 do
          begin
            { <Ladící výpisy> }
            if DetailedDebug and EngineOutput.DebugMode then
              writeZacatekAlfaBetaIterace(sAlfa, sBeta, h, HloubkaRekurze);
            { </Ladící výpisy> }
            pocitam[0] := AnsiChar(PocPos);
            Dojeto := true;
            Alfa := sAlfa;
            Beta := sBeta;
            for I := 1 to Tahy.Poctah do
            begin
              { <Ladící výpisy> }
              if DetailedDebug and EngineOutput.DebugMode then
                writeStrOdsaz(string(TTah1ToLongStr(Tahy.t[I])), 3 + HloubkaRekurze);
              { </Ladící výpisy> }
              { <Běžné výpisy> }
              VypisVariantu(Tahy.t[I], PocPos, HloubkaRekurze, I);
              { </Běžné výpisy> }
              if HodnotyTahu[I] <> NeHodnota then
              begin
                PomStr := '';
                hodnota := HodnotyTahu[I]
              end
              { tj. if počítal bych již vypočtené, přečtu si ti z pole }
              else
              begin { musím počítat }
                DoplnTah(Tahy.t[I], FPozice, t2);
                tahni(FPozice, Tahy.t[I]);
                PridejTah(FPartie, t2);
                Dj := true;
                PomStr := '';
                if PoloRemis(FPartie, FPozice) then
                  hodnota := FRemisValue
                else
                begin
                  hodnota := Transformuj(Alfa_Beta(Alfa, Beta, h, Dj, HloubkaRekurze + 1, PomStr));
                end;
                UberTah(FPartie);
                if Dj then
                  HodnotyTahu[I] := hodnota
                  { Tah je dopočítán, zapamatuji si hodnotu }
                else
                  Dojeto := false; { nedopočetl-li jsem aspoň 1 tah,
                  je to celé nedopočtené }
                tahni_zpet(FPozice, t2);
                if hodnota = NeHodnota then
                begin
                  result := NeHodnota;
                  pocitam[0] := AnsiChar(PocPos);
                  exit
                end;
              end; { od musím počítat }
              if hodnota < Beta then
              begin
                Beta := hodnota;
                { <Ladící výpisy> }
                if DetailedDebug and EngineOutput.DebugMode then
                  writeStrOdsaz('Zlepšující tah, Beta=' + HodnotaToStr(Beta), 3 + HloubkaRekurze);
                { </Ladící výpisy> }
                //result := Beta; TODO : not used
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
                begin
                  if HloubkaRekurze <= AnalysisInfo.Depth + 2 then
                  begin
                    Nejlepsi := ' ' + TTah1ToLongStr(pomtah1) + PomStr;
                  end;
                end;
              end
            end; { od for cyklu přes tahy }
            result := Beta;

            if Dojeto then
              break; { Dopočítal jsem to až do konce. Zvýšení
              hloubky propočtu nemá smysl (počítal bych již vypočtené). }
          end; { Od cyklu přes hloubku }
        end; { Od hraje černý }
      end; { od not(tahy.poctah=0) }
    end; { od not(hloubka=0) }
  end; { Od not MusimKoncit }
  pocitam[0] := AnsiChar(PocPos);
end; { Od Alfa_Beta }

procedure TMyslitel.writestrodsaz(co: string; odsaz: Integer);
var
  s: string;
begin
  s := '';
  for odsaz := odsaz downto 1 do
    s := s + ' ';
  EngineOutput.TellGUIDebug(s + co)
end;

procedure TMyslitel.writeZacatekAlfaBeta(Alfa, Beta: THScore;
  Hloubka, HloubkaRekurze: Integer);
begin
  writestrodsaz('Alfa_Beta do hloubky ' + IntToStr(Hloubka + 1),
    HloubkaRekurze + 2);
  writestrodsaz('Alfa=' + HodnotaToStr(Alfa) + ' Beta=' + HodnotaToStr(Beta),
    HloubkaRekurze + 2)
end;

procedure TMyslitel.writeZacatekAlfaBetaIterace(Alfa, Beta: THScore;
  Hloubka, HloubkaRekurze: Integer);
begin
  writestrodsaz('Iterace Alfa_Beta do hloubky ' + IntToStr(Hloubka + 1),
    HloubkaRekurze + 3);
  writestrodsaz('Alfa=' + HodnotaToStr(Alfa) + ' Beta=' + HodnotaToStr(Beta),
    HloubkaRekurze + 3)
end;

procedure TMyslitel.writeZacatekIterace(var MeziData: TMeziData);
begin
  EngineOutput.TellGUIDebug('  Začínám iteraci do hloubky ' +
    IntToStr(MeziData.Hloubka + 1));
  EngineOutput.TellGUIDebug('  Alfa=' + HodnotaToStr(MeziData.Alfa) + ' Beta=' +
    HodnotaToStr(MeziData.Beta))
end;

procedure TMyslitel.WriteDobryTah(var MeziData: TMeziData);
begin
  EngineOutput.TellGUIDebug('   Tah ' + string(TTah1ToLongStr(MeziData.Tahy.t[1])) + ' je zlepšující');
  EngineOutput.TellGUIDebug('   Alfa=' + HodnotaToStr(MeziData.Alfa) + ' Beta='
    + HodnotaToStr(MeziData.Beta))
end;

procedure TMyslitel.WritePocitamTah(var MeziData: TMeziData; odsaz: Integer);
begin
  writestrodsaz('Počítám tah ' + string(TTah1ToLongStr(MeziData.Tahy.t[MeziData.I])), odsaz);
end;

end.

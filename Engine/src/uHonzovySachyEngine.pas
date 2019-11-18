unit uHonzovySachyEngine;

interface

uses
  Classes,

	uTypes,
  uNumericalIntervalArgument,

	uInternalEngine,

  Myslitel,
  CoTy,
  uPartie;

type
	THonzovySachyEngine = class(TInternalEngine)
	private
    FMyslitel: TMyslitel;
    FPozice: Tpozice;
    FPartie: PJednoPartie;
    FEngineThread: TThread;
    FAspirationWindowSize: TNumericalIntervalArgument;
    procedure CreateOptions;
    function GetPerftInternal(const AMaximalDepth: SG): U8;
  protected
    function GetRemainMoveCount: SG; override;
 	public
    constructor Create;
    destructor Destroy; override;

    procedure GetPerft(const AMaximalDepth: SG); override;
    procedure DoMove(const AMove: string); override;
    procedure Undo; override;
    procedure SetPositionFromStringSpecific(const AString: string; out ASideToMove: SG); override;
    procedure SetStartPos; override;

    function GetCurrentLine: string; override;
    procedure EngineStateToConsole; override;

    procedure Start; override;
    procedure BookMoves; override;
 	end;

implementation

uses
	SysUtils,

  uNewThread,
  uStopwatch,
  uOutputFormat,
  uMath,

  Rutiny,
  uMezivypocet;

{ THonzovySachyEngine }

procedure THonzovySachyEngine.SetPositionFromStringSpecific(const AString: string; out ASideToMove: SG);
var
  Errors: string;
begin
  inherited;

  if FPartie <> nil then
    DonePJednoPartie(FPartie);

  Errors := StrToPozice(AString, FPozice);
  if hb in FPozice.stav.b then
    ASideToMove := 0
  else
    ASideToMove := 1;
  if Errors <> '' then
    Output.TellGUIError(Errors);
end;

procedure THonzovySachyEngine.SetStartPos;
begin
  inherited;

  if FPartie <> nil then
    DonePJednoPartie(FPartie);

  SideToMove := 0;
  FPozice := zakladni_postaveni;
  ClaimMoves := 100;
end;

procedure THonzovySachyEngine.BookMoves;
begin
  inherited;

  FMyslitel.StopManager.AnalysisInfo := AnalysisInfo;
  FMyslitel.AnalysisInfo := AnalysisInfo;
  FMyslitel.EngineOutput := Output;
  FMyslitel.Pozice := FPozice;
  FMyslitel.SetPartie(FPartie);

  FMyslitel.BookMoves;
end;

constructor THonzovySachyEngine.Create;
begin
	inherited;

  FMyslitel := TMyslitel.Create;
  FMyslitel.Options := CommonOptions;
  FMyslitel.StopManager := StopManager;
  FMyslitel.AnalysisInfo := AnalysisInfo;

  CreateOptions;
end;

procedure THonzovySachyEngine.CreateOptions;
begin
  FAspirationWindowSize := TNumericalIntervalArgument.Create;
  FAspirationWindowSize.Shortcut := 'Aspiration Window Size';
  FAspirationWindowSize.Description := '[centi pawn] Aspiration Window Size.';
  FAspirationWindowSize.DefaultValue := 250; // cp
  FAspirationWindowSize.NumericalInterval.MinimalValue := 0;
  FAspirationWindowSize.NumericalInterval.MaximalValue := 10000;
  FAspirationWindowSize.Value := FAspirationWindowSize.DefaultValue;
  Options.Add(FAspirationWindowSize);
end;

destructor THonzovySachyEngine.Destroy;
begin
  try
    if FEngineThread <> nil then
    begin
      StopManager.Abort;
      FEngineThread.WaitFor;
      FreeAndNil(FEngineThread);
    end;

    FreeAndNil(FMyslitel);
    if FPartie <> nil then
      DonePJednoPartie(FPartie);
  finally
    inherited;
  end;
end;

procedure THonzovySachyEngine.DoMove(const AMove: string);
var
  t1: TTah1;
  t2: TTah2;
begin
  t1 := StrToTTah1(AMove, SideToMove);
  doplntah(t1, FPozice, t2);
  tahni(FPozice, t1);
  PridejTah(FPartie, t2);

  inherited; // Change SideToMove
end;

procedure THonzovySachyEngine.EngineStateToConsole;
begin
  inherited;

end;

function THonzovySachyEngine.GetCurrentLine: string;
begin
  Result := string(FMyslitel.pocitam);
end;

procedure THonzovySachyEngine.GetPerft(const AMaximalDepth: SG);
var
  NodeCount: U8;
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.Create;
  try
    Stopwatch.Start;

    NodeCount := GetPerftInternal(AMaximalDepth);

    Stopwatch.Stop;
    if Terminated then
    begin
      Output.TellGUIInfo('Aborted')
    end
    else
    begin
      Output.TellGUIInfo('Nodes Searched: ' + NToS(NodeCount, ofIO));
      if Stopwatch.Elapsed.Ticks > 0 then
        Output.TellGUIInfo('Nodes/second: ' + NToS(RoundU8(NodeCount / Stopwatch.Elapsed.SecondsAsF)));
    end;
    Output.TellGUIInfo('Elapsed Time: ' + Stopwatch.Elapsed.ToStringInSeconds);
  finally
    Stopwatch.Free;
  end;
end;

function THonzovySachyEngine.GetPerftInternal(const AMaximalDepth: SG): U8;
var
  MeziData: TMeziData;
  I: SG;
  t1: TTah1;
  t2: TTah2;
begin
  FMyslitel.Mezivypocet.DejInfo(FPozice, MeziData);
  if AMaximalDepth <= 1 then
  begin
    Result := MeziData.Tahy.poctah;
    Exit;
  end;

  Result := 0;
  for I := 1 to MeziData.Tahy.poctah do
  begin
    t1 := MeziData.Tahy.t[i];
    DoplnTah(t1, FPozice, t2);
    tahni(FPozice, t1);

    Inc(Result, GetPerftInternal(AMaximalDepth - 1));

    tahni_zpet(FPozice, t2);
  end;
end;

function THonzovySachyEngine.GetRemainMoveCount: SG;
begin
  Result := 35;
end;

procedure Run(AInstance: TObject; ANewThread: TThread);
var
  HonzovySachyEngine: THonzovySachyEngine;
begin
  HonzovySachyEngine := THonzovySachyEngine(AInstance);
  try
    try
      HonzovySachyEngine.FMyslitel.DejTah;
    except
      on E: Exception do
        HonzovySachyEngine.Output.TellGUIError(E.Message);
    end;
  finally
    HonzovySachyEngine.DoBestMove;
  end;
end;

procedure THonzovySachyEngine.Start;
begin
  inherited;

  FMyslitel.AspirationWindowSize := FAspirationWindowSize.Value;
  FMyslitel.StopManager := StopManager;
  FMyslitel.AnalysisInfo := AnalysisInfo;
  FMyslitel.EngineOutput := Output;
  FMyslitel.RootMoves := RootMoves;
  FMyslitel.Pozice := FPozice;
  FMyslitel.SetPartie(FPartie);

  FEngineThread := RunInNewThread(Self, Run, tpNormal, False);
end;

procedure THonzovySachyEngine.Undo;
begin
  inherited;

  if FPartie <> nil then
  begin
    tahni_zpet(FPozice, FPartie.t2);
    UberTah(FPartie);
  end
  else
    Output.TellGUIError('No move for undo available.');
end;

end.

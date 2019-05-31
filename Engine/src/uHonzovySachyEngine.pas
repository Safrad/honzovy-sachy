unit uHonzovySachyEngine;

interface

uses
  Classes,

	uTypes,
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
 	public
    constructor Create;
    destructor Destroy; override;

    procedure DoMove(const AMove: string; const ANullMoveStr: string); override;
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

  Rutiny;

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
  FMyslitel.Options := Options;
  FMyslitel.StopManager := StopManager;
  FMyslitel.AnalysisInfo := AnalysisInfo;
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

procedure THonzovySachyEngine.DoMove(const AMove, ANullMoveStr: string);
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

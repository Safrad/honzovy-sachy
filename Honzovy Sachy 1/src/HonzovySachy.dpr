program HonzovySachy;

{$APPTYPE CONSOLE}

uses
  uConsoleEngine,
  CoTy in 'CoTy.pas',
  Rutiny in 'Rutiny.pas',
  Rychle in 'Rychle.pas',
  Ohodnoc in 'Ohodnoc.pas',
  Myslitel in 'Myslitel.pas',
  Uknih in 'Uknih.pas',
  uHonzovySachyEngine in 'uHonzovySachyEngine.pas',
  uPartie in 'uPartie.pas',
  uMezivypocet in 'uMezivypocet.pas',
  Sachovni in 'Sachovni.pas';

{$R *.RES}

var
  ConsoleEngine: TConsoleEngine;
  HonzovySachyEngine: THonzovySachyEngine;
begin
  ConsoleEngine := TConsoleEngine.Create;
  try
    if ConsoleEngine.Initialized then
    begin
      HonzovySachyEngine := THonzovySachyEngine.Create;
      try
        HonzovySachyEngine.SetStartPos;
        ConsoleEngine.InternalEngine := HonzovySachyEngine;
        ConsoleEngine.Run;
      finally
        HonzovySachyEngine.Free;
      end;
    end;
  finally
    ConsoleEngine.Free;
  end;
end.

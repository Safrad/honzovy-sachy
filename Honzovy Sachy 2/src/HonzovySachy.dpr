program HonzovySachy;

{$APPTYPE CONSOLE}

uses
  uHonzovySachyEngine in 'uHonzovySachyEngine.pas',
  uHonzovySachyApplication in 'uHonzovySachyApplication.pas';

{$R *.RES}

var
  HonzovySachyApplication: THonzovySachyApplication;
begin
  HonzovySachyApplication := THonzovySachyApplication.Create;
  try
    HonzovySachyApplication.Run;
  finally
    HonzovySachyApplication.Free;
  end;
end.

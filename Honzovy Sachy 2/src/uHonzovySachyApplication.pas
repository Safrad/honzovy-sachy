unit uHonzovySachyApplication;

interface

uses
  uConsoleEngine,

  uHonzovySachyEngine;

type
  THonzovySachyApplication = class(TConsoleEngine)
  private
    FHonzovySachyEngine: THonzovySachyEngine;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  end;

implementation

{ THonzovySachyApplication }

procedure THonzovySachyApplication.Finalize;
begin
  try
    FHonzovySachyEngine.Free;
  finally
    inherited;
  end;
end;

procedure THonzovySachyApplication.Initialize;
begin
  inherited;

  FHonzovySachyEngine := THonzovySachyEngine.Create;
  FHonzovySachyEngine.Initialize;
  InternalEngine := FHonzovySachyEngine;
  FHonzovySachyEngine.SetStartPos;
end;

end.

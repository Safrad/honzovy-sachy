unit uHonzovySachyEngine;

interface

uses
  Classes,

  uTypes,

  uDllEngine;

type
  THonzovySachyEngine = class(TDllEngine)
  private
    procedure CreateOptions;
    procedure AddInternalOptions;
  protected
    function GetRemainMoveCount: SG; override;
  public
    constructor Create;

    procedure Initialize; override;
 	end;

implementation

uses
  uFiles,
  uProjectInfo,
  uPlugin;

{ THonzovySachyEngine }

constructor THonzovySachyEngine.Create;
begin
	inherited;

  CreateOptions;
end;

procedure THonzovySachyEngine.CreateOptions;
begin
  Options.DeleteAll;
  AddInternalOptions;
  CommonOptions.AddTimeManagementOptions(Options);
end;

function THonzovySachyEngine.GetRemainMoveCount: SG;
begin
  Result := 35;
end;

procedure THonzovySachyEngine.Initialize;
begin
  inherited;

  DllName := WorkDir + GetProjectInfo(piInternalName) + TPlugin.GetSuffix;
end;

procedure THonzovySachyEngine.AddInternalOptions;
begin
  Options.Add(CommonOptions.OwnBook);
  Options.Add(CommonOptions.HashSizeInMB);
  Options.Add(CommonOptions.ClearHash);
end;

end.

unit Normform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TMysNormForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MysNormForm: TMysNormForm;

implementation

{$R *.DFM}
 uses Vypisova;
procedure TMysNormForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Vypisovac.Cfg.mnPovoleno:=false;
end;

end.

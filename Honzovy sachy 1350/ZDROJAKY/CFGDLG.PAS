unit Cfgdlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TCfgform = class(TForm)
    FontDialog1: TFontDialog;
    Button1: TButton;
    Button2: TButton;
    RadioButton1: TRadioButton;
    Button3: TButton;
    Button4: TButton;
    GroupBox1: TGroupBox;
    Button5: TButton;
    Button6: TButton;
    GroupBox2: TGroupBox;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Cfgform: TCfgform;

implementation

{$R *.DFM}

procedure TCfgform.Button2Click(Sender: TObject);
begin
 close
end;

end.

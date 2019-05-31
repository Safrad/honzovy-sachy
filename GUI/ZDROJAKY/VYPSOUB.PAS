unit Vypsoub;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TVypSoubForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button5: TButton;
    SaveDialog1: TSaveDialog;
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    lzekoncit: Boolean;
    procedure nastavtlacidla;
  end;

var
  VypSoubForm: TVypSoubForm;

implementation

uses Form, Vypisova;
{$R *.DFM}

procedure TVypSoubForm.nastavtlacidla;
var
  f: textfile;
begin
  system.assign(f, Label3.caption);
{$I-}
  append(f);
{$I+}
  if ioresult <> 0 then
    Button2.enabled := false
  else
  begin
    system.close(f);
    Button2.enabled := true
  end
end;

procedure TVypSoubForm.Button4Click(Sender: TObject);
Var
  V: TViditelnost;
begin
  UlozStavFormu(V);
  SkryjFormy;
  SaveDialog1.filename := '';
  SaveDialog1.execute;
  if SaveDialog1.filename <> '' then
    Label3.caption := SaveDialog1.filename;
  ObnovStavFormu(V);
  nastavtlacidla
end;

procedure TVypSoubForm.Button3Click(Sender: TObject);
begin
  vypisovac.cfg.osDoSouboru := false;
  if not vypisovac.cfg.osDoOkna then
    vypisovac.cfg.osPovoleno := false;
  lzekoncit := true;
  close
end;

procedure TVypSoubForm.Button2Click(Sender: TObject);
begin
  vypisovac.prepis(Label3.caption);
  lzekoncit := true;
  close
end;

procedure TVypSoubForm.Button1Click(Sender: TObject);
begin
  vypisovac.pokracuj(Label3.caption);
  lzekoncit := true;
  close
end;

procedure TVypSoubForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := lzekoncit
end;

procedure TVypSoubForm.FormShow(Sender: TObject);
begin
  lzekoncit := false;
  nastavtlacidla
end;

procedure TVypSoubForm.Button5Click(Sender: TObject);
begin
  application.helpcontext(18)
end;

end.

unit Vypform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus;

type
  TVypisForm = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button7Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    procedure NastavMemo;
  public
    Stojim: Boolean;
    MamKoncit: Boolean;
    procedure Stuj;
  end;

var
  VypisForm: TVypisForm;

implementation

uses Vypisova, Form, Partiar;
{$R *.DFM}

procedure TVypisForm.Stuj;
var
  pommenu: TMainmenu;
  sb1, sb2: Boolean;
begin
  Stojim := True;
  Button1.enabled := false;
  Button2.enabled := True;
  Button3.enabled := True;
  pommenu := Form1.Menu;
  Form1.Menu := Form1.MainMenu3;
  sb1 := PartiarForm.Speedbutton1.enabled;
  sb2 := PartiarForm.Speedbutton2.enabled;
  PartiarForm.Speedbutton1.enabled := false;
  PartiarForm.Speedbutton2.enabled := false;
  repeat
    application.processmessages
  until not Stojim;
  PartiarForm.Speedbutton1.enabled := sb1;
  PartiarForm.Speedbutton2.enabled := sb2;
  Form1.Menu := pommenu;
  Button1.enabled := True;
  Button2.enabled := false;
  Button3.enabled := false;
  if MamKoncit then
  begin
    MamKoncit := false;
    Button7Click(nil)
  end
end;

procedure TVypisForm.NastavMemo;
begin
  Memo1.Left := 0;
  Memo1.Top := 85;
  Memo1.Width := Width - 8;
  if Height - 25 - 85 > 0 then
    Memo1.Height := Height - 25 - 85
  else
    Memo1.Height := 0;
end;

procedure TVypisForm.FormShow(Sender: TObject);
begin
  NastavMemo
end;

procedure TVypisForm.FormResize(Sender: TObject);
begin
  NastavMemo
end;

procedure TVypisForm.FormCreate(Sender: TObject);
begin
  Vypisovac := TVypisovac.Create(Memo1);
end;

procedure TVypisForm.FormDestroy(Sender: TObject);
begin
  Vypisovac.Destroy
end;

procedure TVypisForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Vypisovac.Krokovat := false;
  Vypisovac.Cfg.osDoOkna := false;
  if not Vypisovac.Cfg.osDoSouboru then
    Vypisovac.Cfg.osPovoleno := false;
end;

procedure TVypisForm.Button7Click(Sender: TObject);
begin
  if Stojim then
  begin
    Stojim := false;
    MamKoncit := True;
  End
  else
    close
end;

procedure TVypisForm.Button4Click(Sender: TObject);
begin
  Memo1.clear
end;

procedure TVypisForm.Button5Click(Sender: TObject);
begin
  Form1.VpisyAlgoritmu1Click(Sender)
end;

procedure TVypisForm.Button1Click(Sender: TObject);
begin
  Stuj
end;

procedure TVypisForm.Button3Click(Sender: TObject);
begin
  Stojim := false;
  Vypisovac.Krokovat := false;
end;

procedure TVypisForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Stojim then
  begin
    CanClose := false;
    ZpravovaKrabice('Teï nejde zavøít ladící okno.' +
      ' Musíte nejdøív ukonèit režim krokování (napø. tlaèítkem Rozjeï)',
      'Varování', Mb_Ok or Mb_IconStop)
  end
end;

procedure TVypisForm.Button2Click(Sender: TObject);
begin
  Vypisovac.Krokovat := True;
  Stojim := false
end;

procedure TVypisForm.Button6Click(Sender: TObject);
begin
  application.helpcontext(17)
end;

end.

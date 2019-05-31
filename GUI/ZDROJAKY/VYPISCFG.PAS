unit Vypiscfg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TVypisCfg=record
     osPovoleno,
     osDoOkna:Boolean;
     osRadkuOkna:Integer;
     osDoSouboru,
     osZakladni,
     osDopredu,
     osNormalni:Boolean;
     osHloubka:Integer;
     mdPovoleno:Boolean;
     mdnHloubka,mdpHloubka:Integer;
     mnPovoleno:Boolean;
     mnnHloubka,mnpHloubka:Integer
   end;
  const NormalVypisCfg:TVypisCfg=
  (  osPovoleno: False;
     osDoOkna:   True;
     osRadkuOkna:500;
     osDoSouboru:False;
     osZakladni: True;
     osDopredu:  True;
     osNormalni: True;
     osHloubka:  1;
     mdPovoleno: True;
     mdnHloubka: 6;
     mdpHloubka: 1;
     mnPovoleno: True;
     mnnHloubka: 6;
     mnpHloubka: 1
     );
 Type
  TVypisCfgForm = class(TForm)
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    CheckBox7: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Edit2: TEdit;
    CheckBox6: TCheckBox;
    CheckBox8: TCheckBox;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure CheckBox7Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  public
   hodnoty:TVypisCfg;
   constructor create(AOwner:TComponent); override;
   procedure Nastav(kym:TVypisCfg);
   function Vyhodnot:Boolean;
  end;

var
  VypisCfgForm: TVypisCfgForm;

implementation
 uses ualgdlg, Vypisova, VypForm, DoprForm, NormForm,Form;
{$R *.DFM}
constructor TVypisCfgForm.create(AOwner:TComponent);
 begin
  inherited create(AOwner);
 end;
procedure TVypisCfgForm.Nastav(kym:TVypisCfg);
 begin
  Hodnoty:=Kym;
  Checkbox6.Checked:=Hodnoty.osPovoleno;
  Checkbox4.Checked:=Hodnoty.osDoOkna;
  Edit1.Text:=IntToStr(Hodnoty.osRadkuOkna);
  Checkbox5.Checked:=Hodnoty.osDoSouboru;
  Checkbox1.Checked:=Hodnoty.osZakladni;
  Checkbox2.Checked:=Hodnoty.osDopredu;
  Checkbox3.Checked:=Hodnoty.osNormalni;
  Edit2.Text:=IntToStr(Hodnoty.osHloubka);
  Checkbox7.Checked:=Hodnoty.mnPovoleno;
  Edit3.Text:=IntToStr(Hodnoty.mnnHloubka);
  Edit4.Text:=IntToStr(Hodnoty.mnpHloubka);
  Checkbox8.Checked:=Hodnoty.mdPovoleno;
  Edit5.Text:=IntToStr(Hodnoty.mdnHloubka);
  Edit6.Text:=IntToStr(Hodnoty.mdpHloubka);
 end;
 {function VyhodnotEdit(var kam:integer;co:TEdit):boolean;}
function TVypisCfgForm.Vyhodnot:Boolean;
 begin
  result:=true;
  Hodnoty.osPovoleno:=Checkbox6.Checked;
  Hodnoty.osDoOkna:=Checkbox4.Checked;
    If not(Hodnoty.osPovoleno and hodnoty.osDoOkna)and VypisForm.Stojim then
   begin
    Hodnoty.osPovoleno:=true;
    Hodnoty.osDoOkna:=true;
    ZpravovaKrabice('Teï nejde zakázat výpisy do okna. Musíte nejdøív ukonèit režim krokování výpisù.'
     ,'Varování',Mb_ok or Mb_IconHand);
   end;
  if not VyhodnotEdit(Hodnoty.osRadkuOkna,Edit1) then result:=false else
  if (Hodnoty.osRadkuOkna>500) then
   begin
    Hodnoty.osRadkuOkna:=500;
    ZpravovaKrabice('Zadal jste moc øádkù okna.'+
    ' Místo zadané hodnoty doplòuji 500.',
     'Informace',mb_ok)
   end else
  if Hodnoty.osRadkuOkna<5 then
   begin
    Hodnoty.osRadkuOkna:=5;
    ZpravovaKrabice('Zadal jste moc malý poèet øádkù okna.'+
    ' Místo zadané hodnoty doplòuji 5.',
     'Informace',mb_ok)
   end;
  Hodnoty.osDoSouboru:=Checkbox5.Checked;
  Hodnoty.osZakladni:=Checkbox1.Checked;
  Hodnoty.osDopredu:=Checkbox2.Checked;
  Hodnoty.osNormalni:=Checkbox3.Checked;
  if not VyhodnotEdit(Hodnoty.osHloubka,Edit2) then result:=false else
  if Hodnoty.osHloubka<0 then
   begin
    Hodnoty.osHloubka:=0;
    ZpravovaKrabice('Zadal jste zápornou hloubku ladících výpisù.'+
    ' Místo zadané hodnoty doplòuji 0.',
     'Informace',mb_ok)
   end;
  Hodnoty.mnPovoleno:=Checkbox7.Checked;
  Hodnoty.mdPovoleno:=Checkbox8.Checked;
  if not VyhodnotEdit(Hodnoty.mnnHloubka,Edit3) then result:=false else
  if Hodnoty.mnnHloubka<0 then
   begin
    Hodnoty.mnnHloubka:=0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty '+
    'pro normální myšlení. '+' Místo zadané hodnoty doplòuji 0.',
     'Informace',mb_ok)
   end;
  if not VyhodnotEdit(Hodnoty.mnpHloubka,Edit4) then result:=false else
  if Hodnoty.mnpHloubka<0 then
   begin
    Hodnoty.mnpHloubka:=0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty '+
    'pro normální myšlení. '+' Místo zadané hodnoty doplòuji 0.',
     'Informace',mb_ok)
   end;
  if not VyhodnotEdit(Hodnoty.mdnHloubka,Edit5) then result:=false else
  if Hodnoty.mdnHloubka<0 then
   begin
    Hodnoty.mdnHloubka:=0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty '+
    'pro normální myšlení. '+' Místo zadané hodnoty doplòuji 0.',
     'Informace',mb_ok)
   end;
  if not VyhodnotEdit(Hodnoty.mdpHloubka,Edit6) then result:=false else
  if Hodnoty.mdpHloubka<0 then
   begin
    Hodnoty.mdpHloubka:=0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty '+
    'pro normální myšlení. '+' Místo zadané hodnoty doplòuji 0.',
     'Informace',mb_ok)
   end;
 end;
procedure TVypisCfgForm.Button2Click(Sender: TObject);
begin
 Close
end;
procedure TVypisCfgForm.Button1Click(Sender: TObject);
begin
 if vyhodnot then
  begin
   Vypisovac.Cfg:=Hodnoty;
   with MysDopForm do
    begin
     label11.caption:='';
     label13.caption:='';
     label16.caption:='';
     label18.caption:='';
     label20.caption:='';
     label22.caption:='';
     label4.caption:='';
     label7.caption:='';
     label9.caption:='';
    end;
   with MysNormForm do
    begin
     label2.caption:='';
     label4.caption:='';
     label6.caption:='';
     label8.caption:='';
    end;
{  if Hodnoty.mdPovoleno then MysDopForm.Show else MysDopForm.Close;
   if Hodnoty.mnPovoleno then MysNormForm.Show else MysNormForm.Close;
   if Hodnoty.osPovoleno and Hodnoty.osDoOkna then VypisForm.Show else VypisForm.Close;}
   if not Hodnoty.osPovoleno or not Hodnoty.osDoSouboru then Vypisovac.ZavriSoubor;
   close;
  end
 else ZpravovaKrabice(
 'Do editovacích øádkù musíte zadat pøirozená èísla',
 'Chybné zadání',mb_ok or mb_iconhand)
end;
procedure TVypisCfgForm.Button4Click(Sender: TObject);
begin
 nastav(NormalVypisCfg)
end;

procedure TVypisCfgForm.CheckBox6Click(Sender: TObject);
var h:boolean;
begin
 h:=checkbox6.Checked;
 checkbox4.enabled:=h;
 checkbox5.enabled:=h;
 checkbox1.enabled:=h;
 checkbox2.enabled:=h;
 checkbox3.enabled:=h;
 edit1.enabled:=h;
 edit2.enabled:=h;
end;

procedure TVypisCfgForm.CheckBox7Click(Sender: TObject);
begin
 edit3.enabled:=checkbox7.Checked;
 edit4.enabled:=checkbox7.Checked;
end;

procedure TVypisCfgForm.CheckBox8Click(Sender: TObject);
begin
 edit5.enabled:=checkbox8.Checked;
 edit6.enabled:=checkbox8.Checked;
end;

procedure TVypisCfgForm.FormShow(Sender: TObject);
begin
 nastav(Vypisovac.cfg)
end;

procedure TVypisCfgForm.Button3Click(Sender: TObject);
begin
 application.helpcontext(16)
end;

end.

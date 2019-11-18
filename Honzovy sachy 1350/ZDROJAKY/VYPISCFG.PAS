unit Vypiscfg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TVypisCfg = record
    osPovoleno, osDoOkna: Boolean;
    osRadkuOkna: Integer;
    osDoSouboru, osZakladni, osDopredu, osNormalni: Boolean;
    osHloubka: Integer;
    mdPovoleno: Boolean;
    mdnHloubka, mdpHloubka: Integer;
    mnPovoleno: Boolean;
    mnnHloubka, mnpHloubka: Integer end;

  const
    NormalVypisCfg: TVypisCfg = (osPovoleno: False; osDoOkna: True;
      osRadkuOkna: 500; osDoSouboru: False; osZakladni: True; osDopredu: True;
      osNormalni: True; osHloubka: 1; mdPovoleno: True; mdnHloubka: 6;
      mdpHloubka: 1; mnPovoleno: True; mnnHloubka: 6; mnpHloubka: 1);

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
      hodnoty: TVypisCfg;
      constructor create(AOwner: TComponent); override;
      procedure Nastav(kym: TVypisCfg);
      function Vyhodnot: Boolean;
    end;

  var
    VypisCfgForm: TVypisCfgForm;

implementation

uses ualgdlg, Vypisova, VypForm, DoprForm, NormForm, Form;
{$R *.DFM}

constructor TVypisCfgForm.create(AOwner: TComponent);
begin
  inherited create(AOwner);
end;

procedure TVypisCfgForm.Nastav(kym: TVypisCfg);
begin
  hodnoty := kym;
  CheckBox6.Checked := hodnoty.osPovoleno;
  CheckBox4.Checked := hodnoty.osDoOkna;
  Edit1.Text := IntToStr(hodnoty.osRadkuOkna);
  CheckBox5.Checked := hodnoty.osDoSouboru;
  CheckBox1.Checked := hodnoty.osZakladni;
  CheckBox2.Checked := hodnoty.osDopredu;
  CheckBox3.Checked := hodnoty.osNormalni;
  Edit2.Text := IntToStr(hodnoty.osHloubka);
  CheckBox7.Checked := hodnoty.mnPovoleno;
  Edit3.Text := IntToStr(hodnoty.mnnHloubka);
  Edit4.Text := IntToStr(hodnoty.mnpHloubka);
  CheckBox8.Checked := hodnoty.mdPovoleno;
  Edit5.Text := IntToStr(hodnoty.mdnHloubka);
  Edit6.Text := IntToStr(hodnoty.mdpHloubka);
end;

{ function VyhodnotEdit(var kam:integer;co:TEdit):boolean; }
function TVypisCfgForm.Vyhodnot: Boolean;
begin
  result := True;
  hodnoty.osPovoleno := CheckBox6.Checked;
  hodnoty.osDoOkna := CheckBox4.Checked;
  If not(hodnoty.osPovoleno and hodnoty.osDoOkna) and VypisForm.Stojim then
  begin
    hodnoty.osPovoleno := True;
    hodnoty.osDoOkna := True;
    ZpravovaKrabice
      ('Teï nejde zakázat výpisy do okna. Musíte nejdøív ukonèit režim krokování výpisù.',
      'Varování', Mb_ok or Mb_IconHand);
  end;
  if not VyhodnotEdit(hodnoty.osRadkuOkna, Edit1) then
    result := False
  else if (hodnoty.osRadkuOkna > 500) then
  begin
    hodnoty.osRadkuOkna := 500;
    ZpravovaKrabice('Zadal jste moc øádkù okna.' +
      ' Místo zadané hodnoty doplòuji 500.', 'Informace', Mb_ok)
  end
  else if hodnoty.osRadkuOkna < 5 then
  begin
    hodnoty.osRadkuOkna := 5;
    ZpravovaKrabice('Zadal jste moc malý poèet øádkù okna.' +
      ' Místo zadané hodnoty doplòuji 5.', 'Informace', Mb_ok)
  end;
  hodnoty.osDoSouboru := CheckBox5.Checked;
  hodnoty.osZakladni := CheckBox1.Checked;
  hodnoty.osDopredu := CheckBox2.Checked;
  hodnoty.osNormalni := CheckBox3.Checked;
  if not VyhodnotEdit(hodnoty.osHloubka, Edit2) then
    result := False
  else if hodnoty.osHloubka < 0 then
  begin
    hodnoty.osHloubka := 0;
    ZpravovaKrabice('Zadal jste zápornou hloubku ladících výpisù.' +
      ' Místo zadané hodnoty doplòuji 0.', 'Informace', Mb_ok)
  end;
  hodnoty.mnPovoleno := CheckBox7.Checked;
  hodnoty.mdPovoleno := CheckBox8.Checked;
  if not VyhodnotEdit(hodnoty.mnnHloubka, Edit3) then
    result := False
  else if hodnoty.mnnHloubka < 0 then
  begin
    hodnoty.mnnHloubka := 0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty ' +
      'pro normální myšlení. ' + ' Místo zadané hodnoty doplòuji 0.',
      'Informace', Mb_ok)
  end;
  if not VyhodnotEdit(hodnoty.mnpHloubka, Edit4) then
    result := False
  else if hodnoty.mnpHloubka < 0 then
  begin
    hodnoty.mnpHloubka := 0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty ' +
      'pro normální myšlení. ' + ' Místo zadané hodnoty doplòuji 0.',
      'Informace', Mb_ok)
  end;
  if not VyhodnotEdit(hodnoty.mdnHloubka, Edit5) then
    result := False
  else if hodnoty.mdnHloubka < 0 then
  begin
    hodnoty.mdnHloubka := 0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty ' +
      'pro normální myšlení. ' + ' Místo zadané hodnoty doplòuji 0.',
      'Informace', Mb_ok)
  end;
  if not VyhodnotEdit(hodnoty.mdpHloubka, Edit6) then
    result := False
  else if hodnoty.mdpHloubka < 0 then
  begin
    hodnoty.mdpHloubka := 0;
    ZpravovaKrabice('Zadal jste zápornou hloubku výpisù nejlepší varianty ' +
      'pro normální myšlení. ' + ' Místo zadané hodnoty doplòuji 0.',
      'Informace', Mb_ok)
  end;
end;

procedure TVypisCfgForm.Button2Click(Sender: TObject);
begin
  Close
end;

procedure TVypisCfgForm.Button1Click(Sender: TObject);
begin
  if Vyhodnot then
  begin
    Vypisovac.Cfg := hodnoty;
    with MysDopForm do
    begin
      label11.caption := '';
      label13.caption := '';
      label16.caption := '';
      label18.caption := '';
      label20.caption := '';
      label22.caption := '';
      Label4.caption := '';
      Label7.caption := '';
      label9.caption := '';
    end;
    with MysNormForm do
    begin
      Label2.caption := '';
      Label4.caption := '';
      Label6.caption := '';
      Label8.caption := '';
    end;
    { if Hodnoty.mdPovoleno then MysDopForm.Show else MysDopForm.Close;
      if Hodnoty.mnPovoleno then MysNormForm.Show else MysNormForm.Close;
      if Hodnoty.osPovoleno and Hodnoty.osDoOkna then VypisForm.Show else VypisForm.Close; }
    if not hodnoty.osPovoleno or not hodnoty.osDoSouboru then
      Vypisovac.ZavriSoubor;
    Close;
  end
  else
    ZpravovaKrabice('Do editovacích øádkù musíte zadat pøirozená èísla',
      'Chybné zadání', Mb_ok or Mb_IconHand)
end;

procedure TVypisCfgForm.Button4Click(Sender: TObject);
begin
  Nastav(NormalVypisCfg)
end;

procedure TVypisCfgForm.CheckBox6Click(Sender: TObject);
var
  h: Boolean;
begin
  h := CheckBox6.Checked;
  CheckBox4.enabled := h;
  CheckBox5.enabled := h;
  CheckBox1.enabled := h;
  CheckBox2.enabled := h;
  CheckBox3.enabled := h;
  Edit1.enabled := h;
  Edit2.enabled := h;
end;

procedure TVypisCfgForm.CheckBox7Click(Sender: TObject);
begin
  Edit3.enabled := CheckBox7.Checked;
  Edit4.enabled := CheckBox7.Checked;
end;

procedure TVypisCfgForm.CheckBox8Click(Sender: TObject);
begin
  Edit5.enabled := CheckBox8.Checked;
  Edit6.enabled := CheckBox8.Checked;
end;

procedure TVypisCfgForm.FormShow(Sender: TObject);
begin
  Nastav(Vypisovac.Cfg)
end;

procedure TVypisCfgForm.Button3Click(Sender: TObject);
begin
  application.helpcontext(16)
end;

end.

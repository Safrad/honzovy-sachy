unit Form;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Menus, sachovni, coty, StdCtrls;

const
  wm_PripravTah = wm_User + 0;
  wm_HrajTah = wm_User + 1;
  wm_DokMysDop = wm_User + 2; { Dokonèeno myšlení dopøedu }
  wm_Zavolej = wm_User + 3;
  FormCaption = 'Honzovy šachy 1350';

Type
  TForm1 = class(TForm)
    poleimg: TImage;
    figuryimg: TImage;
    MainMenu1: TMainMenu;
    Program1: TMenuItem;
    Konec1: TMenuItem;
    achovnice1: TMenuItem;
    Oto1: TMenuItem;
    Partie1: TMenuItem;
    Nov1: TMenuItem;
    Ulo1: TMenuItem;
    Otevi1: TMenuItem;
    Bl1: TMenuItem;
    lovk1: TMenuItem;
    Pota1: TMenuItem;
    Nastavalgoritmus1: TMenuItem;
    ern1: TMenuItem;
    lovk2: TMenuItem;
    Pota2: TMenuItem;
    Nastavalgoritmus2: TMenuItem;
    Tah1: TMenuItem;
    Zpt1: TMenuItem;
    Znovu1: TMenuItem;
    MainMenu2: TMainMenu;
    Monosti1: TMenuItem;
    Hrajte1: TMenuItem;
    Pttahlovk1: TMenuItem;
    Thni1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Ulojako1: TMenuItem;
    Nastavpozici1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Npovda1: TMenuItem;
    Obsah1: TMenuItem;
    Dobamylen1: TMenuItem;
    DobaMylen2: TMenuItem;
    Knihovna: TMenuItem;
    Pidejpozici1: TMenuItem;
    Pidejpartii1: TMenuItem;
    Prohldniknihovnu1: TMenuItem;
    Smapozici1: TMenuItem;
    Ulo2: TMenuItem;
    Voliteln1: TMenuItem;
    Vpisyalgoritmu1: TMenuItem;
    Panel3: TPanel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label27: TLabel;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Panel4: TPanel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Panel2: TPanel;
    Label19: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    ListBox4: TListBox;
    ListBox5: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Edit1: TEdit;
    MainMenu3: TMainMenu;
    N1: TMenuItem;
    Cinkn1: TMenuItem;
    vod1: TMenuItem;
    Npovda2: TMenuItem;
    Obsah2: TMenuItem;
    Kontext1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Oto1Click(Sender: TObject);
    procedure Konec1Click(Sender: TObject);
    procedure Nov1Click(Sender: TObject);
    procedure Zpt1Click(Sender: TObject);
    procedure Znovu1Click(Sender: TObject);
    procedure Nastavalgoritmus1Click(Sender: TObject);
    procedure Nastavalgoritmus2Click(Sender: TObject);
    procedure Pttahlovk1Click(Sender: TObject);
    procedure Thni1Click(Sender: TObject);
    procedure lovk1Click(Sender: TObject);
    procedure Pota1Click(Sender: TObject);
    procedure lovk2Click(Sender: TObject);
    procedure Pota2Click(Sender: TObject);
    procedure Hrajte1Click(Sender: TObject);
    procedure Ulo1Click(Sender: TObject);
    procedure Ulojako1Click(Sender: TObject);
    procedure Nastavpozici1Click(Sender: TObject);
    procedure Otevi1Click(Sender: TObject);
    procedure Obsah1Click(Sender: TObject);
    procedure DobaMylen1Click(Sender: TObject);
    procedure DobaMylen2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Pidejpozici1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Pidejpartii1Click(Sender: TObject);
    procedure Prohldniknihovnu1Click(Sender: TObject);
    procedure Smapozici1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Ulo2Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Zobrazvpisy1Click(Sender: TObject);
    procedure Vpisyalgoritmu1Click(Sender: TObject);
    procedure Prosted1Click(Sender: TObject);
    procedure Cinkn1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure vod1Click(Sender: TObject);
    procedure Obsah2Click(Sender: TObject);
    procedure Kontext1Click(Sender: TObject);
  private
    procedure wmPripravTah(var msg: tmessage); message wm_PripravTah;
    procedure wmHrajTah(var msg: tmessage); message wm_HrajTah;
    procedure wmDokMysDop(var msg: tmessage); message wm_DokMysDop;
    procedure wmZavolej(var msg: tmessage); message wm_Zavolej;
  public
    sachovnice: tsachovnice;
    procedure KnihMenu(Povolit: Boolean);
  end;

  { !!!!!!!!!!!!!!!!!!!!!!!!!!! Èachry se skrývání StayOnTop formù !!!!!!!!!! }
type
  TViditelnost = record
    pa, mn, md, vy: Boolean;
  end;

Procedure UlozStavFormu(Var Viditelnost: TViditelnost);
Procedure SkryjFormy;
Procedure ObnovStavFormu(Var Viditelnost: TViditelnost);
Function ZpravovaKrabice(Text, Titulek: Pchar; Typ: Word): Integer;

{ Delfy by potøebovaly ještì poøádnì ladit. Je-li nìkde form
  typu StayOnTop, je zhruba 15% pravdìpodobnost (+- epsilon napø.
  i podle toho jestli se  kompiluje poprve po spuštìní Delf),
  že MessageBox bude POD (!!!!) formem. Tato funkce to snad øeší. }
var
  Form1: TForm1;

implementation

{$R *.DFM}

uses ualgdlg, uschedit, rychle, rutiny, CasNaTah,
  UKnih, Myslitel, VypForm, VypisCfg, Vypisova, DoprForm, NormForm,
  Partiar, CfgDlg;

Procedure UlozStavFormu(Var Viditelnost: TViditelnost);
begin
  with Viditelnost do
  begin
    pa := PartiarForm.visible;
    md := MysDopForm.visible;
    mn := MysNormForm.visible;
    vy := VypisForm.visible
  end
end;

Procedure SkryjFormy;
begin
  PartiarForm.visible := false;
  MysDopForm.visible := false;
  MysNormForm.visible := false;
  VypisForm.visible := false;
end;

Procedure ObnovStavFormu(Var Viditelnost: TViditelnost);
begin
  with Viditelnost do
  begin
    PartiarForm.visible := pa;
    MysDopForm.visible := md;
    MysNormForm.visible := mn;
    VypisForm.visible := vy
  end
end;

Function ZpravovaKrabice(Text, Titulek: Pchar; Typ: Word): Integer;
var
  v: TViditelnost;
begin
  UlozStavFormu(v);
  SkryjFormy;
  Result := application.messagebox(Text, Titulek, Typ);
  ObnovStavFormu(v);
end;

{ !!!!!!!!!!!!!!!!!!!!!!!!! }
{ Globální far procedury }
{ !!!!!!!!!!!!!!!!!!!!!!!!! }
procedure PripravTah; far;
begin
  Form1.sachovnice.PripravTah
end;

procedure ProgramKonec; far;
begin
  postquitmessage(0);
end;

procedure BilyClovek; far;
begin
  Form1.sachovnice.Bily := Clovek;
  postmessage(Form1.handle, wm_PripravTah, 0, 0);
end;

procedure BilyPocitac; far;
begin
  Form1.sachovnice.Bily := Pocitac;
  postmessage(Form1.handle, wm_PripravTah, 0, 0);
end;

procedure CernyClovek; far;
begin
  Form1.sachovnice.Cerny := Clovek;
  postmessage(Form1.handle, wm_PripravTah, 0, 0);
end;

procedure CernyPocitac; far;
begin
  Form1.sachovnice.Cerny := Pocitac;
  postmessage(Form1.handle, wm_PripravTah, 0, 0);
end;

procedure PartieNova; far;
begin
  Form1.sachovnice.nova_hra(zakladni_postaveni)
end;

procedure PartieOtevri; far;
begin
  Form1.sachovnice.Otevri;
end;

procedure TahZpet; far;
begin
  Form1.sachovnice.zpet;
end;

procedure TahZnovu; far;
begin
  Form1.sachovnice.znovu;
end;

procedure TahTahni; far;
begin
  Form1.sachovnice.ProgrameTahni
end;

{ !!!!!!!!!!!!!!!!!!!!!! }
procedure TForm1.wmZavolej(var msg: tmessage);
begin
  if msg.lparam <> 0 then
    TAkce(msg.lparam);
end;

Procedure Vykonej(Co: TAkce);
{ Zavraždí myšlení dopøedu a vyvolá akci }
begin
  if Form1.sachovnice.BilyAlg.Myslim or Form1.sachovnice.CernyAlg.Myslim then
  begin
    ZpravovaKrabice('Form.pas Vykonej.', 'Chyba', mb_ok);
    exit;
  end;
  if Form1.sachovnice.BilyAlg.MyslimDopredu then
    Form1.sachovnice.BilyAlg.PrestanDopredu(Co)
  else if Form1.sachovnice.CernyAlg.MyslimDopredu then
    Form1.sachovnice.CernyAlg.PrestanDopredu(Co)
  else
    Co;
end;

{ !!!!!!!!!!!!!!!!!!!!!! }
procedure TForm1.FormCreate(Sender: TObject);
begin
  application.helpfile := 'sachy.hlp';
  sachovnice := tsachovnice.create(10, 10, canvas);
  randomize;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  sachovnice.destroy;
end;

procedure TForm1.wmPripravTah(var msg: tmessage);
begin
  Vykonej(PripravTah);
end;

procedure TForm1.wmHrajTah(var msg: tmessage);
begin
  sachovnice.BeznyTah(LongIntToTTah1(msg.lparam))
end;

procedure TForm1.wmDokMysDop(var msg: tmessage);
begin
  sachovnice.BeznyTah(sachovnice.tahuzivatele)
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  sachovnice.paint
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  sachovnice.MouseButtonDown(Button, Shift, X, Y)
end;

procedure TForm1.Oto1Click(Sender: TObject);
begin
  sachovnice.otoc
end;

procedure TForm1.Konec1Click(Sender: TObject);
begin
  { vykonej(ProgramKonec) } Close
end;

procedure TForm1.Nov1Click(Sender: TObject);
begin
  Vykonej(PartieNova);
end;

procedure TForm1.Zpt1Click(Sender: TObject);
begin
  Vykonej(TahZpet);
end;

procedure TForm1.Znovu1Click(Sender: TObject);
begin
  Vykonej(TahZnovu);
end;

procedure TForm1.Nastavalgoritmus1Click(Sender: TObject);
var
  v: TViditelnost;
begin
  algdlg.init(sachovnice.BilyAlg.algcfg);
  algdlg.caption := 'Nastavení algoritmu bílého';
  algdlg.Button2.caption := 'Vše jako èerný';
  algdlg.JsemBily := True;
  UlozStavFormu(v);
  SkryjFormy;
  algdlg.showmodal;
  ObnovStavFormu(v);
  if algdlg.platne then
    sachovnice.BilyAlg.algcfg := algdlg.algcfg;
end;

procedure TForm1.Nastavalgoritmus2Click(Sender: TObject);
var
  v: TViditelnost;
begin
  algdlg.init(sachovnice.CernyAlg.algcfg);
  algdlg.caption := 'Nastavení algoritmu èerného';
  algdlg.Button2.caption := 'Vše jako bílý';
  algdlg.JsemBily := false;
  UlozStavFormu(v);
  SkryjFormy;
  algdlg.showmodal;
  ObnovStavFormu(v);
  if algdlg.platne then
    sachovnice.CernyAlg.algcfg := algdlg.algcfg;
end;

procedure TForm1.Pttahlovk1Click(Sender: TObject);
begin
  sachovnice.prerus;
end;

procedure TForm1.Thni1Click(Sender: TObject);
begin
  Vykonej(TahTahni)
end;

procedure TForm1.lovk1Click(Sender: TObject);
begin
  if sachovnice.Bily <> Clovek then
    Vykonej(BilyClovek)
end;

procedure TForm1.Pota1Click(Sender: TObject);
begin
  if sachovnice.Bily <> Pocitac then
    Vykonej(BilyPocitac)
end;

procedure TForm1.lovk2Click(Sender: TObject);
begin
  if sachovnice.Cerny <> Clovek then
    Vykonej(CernyClovek)
end;

procedure TForm1.Pota2Click(Sender: TObject);
begin
  if sachovnice.Cerny <> Pocitac then
    Vykonej(CernyPocitac)
end;

procedure TForm1.Hrajte1Click(Sender: TObject);
begin
  sachovnice.HrajTed;
end;

procedure TForm1.Ulo1Click(Sender: TObject);
begin
  sachovnice.uloz
end;

procedure TForm1.Ulojako1Click(Sender: TObject);
begin
  sachovnice.ulozjako;
end;

procedure TForm1.Nastavpozici1Click(Sender: TObject);
var
  v: TViditelnost;
begin
  SChEdit.sachovnice.Pozice := sachovnice.Pozice;
  UlozStavFormu(v);
  SkryjFormy;
  SChEdit.showmodal;
  ObnovStavFormu(v);
  PartiarForm.NakresliTahy(sachovnice.Partie, sachovnice.Pozice);
end;

procedure TForm1.Otevi1Click(Sender: TObject);
begin
  Vykonej(PartieOtevri);
end;

procedure TForm1.Obsah1Click(Sender: TObject);
begin
  application.helpcontext(0)
end;

procedure TForm1.DobaMylen1Click(Sender: TObject);
var
  v: TViditelnost;
begin
  UlozStavFormu(v);
  SkryjFormy;
  FormCasNaTah.showmodal;
  ObnovStavFormu(v);
end;

procedure TForm1.DobaMylen2Click(Sender: TObject);
begin
  DobaMylen1Click(Sender)
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if VypisForm.Stojim then
  begin
    ZpravovaKrabice
      ('Ukonèete nejdøív režim krokování algoritmu (napøíklad tlaèítkem Rozjeï).',
      'Teï se nemùžu ukonèit', mb_ok);
    CanClose := false;
    exit
  end;
  if sachovnice.CernyAlg.Myslim or sachovnice.BilyAlg.Myslim then
  begin
    ZpravovaKrabice
      ('Ukonèete nejdøív myšlení algoritmu (napøíklad Ctrl+C a potom Enter). ',
      'Teï se nemùžu ukonèit', mb_ok);
    CanClose := false;
    exit
  end;
  application.helpcommand(HELP_QUIT, 0);
  Vykonej(ProgramKonec);
end;

procedure TForm1.KnihMenu(Povolit: Boolean);
begin
  Nov1.enabled := Povolit;
  Otevi1.enabled := Povolit;
  Nastavpozici1.enabled := Povolit;
  if not Povolit or (sachovnice.Partie^.l <> nil) then
    Zpt1.enabled := Povolit;
  if not Povolit or (sachovnice.Partie^.l <> nil) then
    Znovu1.enabled := Povolit;
  Thni1.enabled := Povolit;
  Pota1.enabled := Povolit;
  Pota2.enabled := Povolit;
  Pidejpozici1.enabled := Povolit;
  Smapozici1.enabled := Povolit;
  Pidejpartii1.enabled := Povolit;
  Prohldniknihovnu1.enabled := Povolit;
  Vpisyalgoritmu1.enabled := Povolit;
  if Povolit then
  begin
    MysNormForm.visible := Vypisovac.Cfg.mnPovoleno;
    MysDopForm.visible := Vypisovac.Cfg.mdPovoleno;
    VypisForm.visible := Vypisovac.Cfg.osPovoleno;
    PartiarForm.visible := True;
  end
  else
  begin
    MysNormForm.visible := false;
    MysDopForm.visible := false;
    VypisForm.visible := false;
    PartiarForm.visible := false;
  end
end;

procedure TForm1.Pidejpozici1Click(Sender: TObject);
begin
  sachovnice.stav := KnihEdit;
  KnihMenu(false);
  sachovnice.PridejPoziciDoKnihovny;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  sachovnice.OKPoziciDoKnihovny;
  Panel2.visible := false;
  if sachovnice.stav = KnihEdit then
  begin
    sachovnice.stav := normal;
    KnihMenu(True);
  end
  else if sachovnice.stav = KnihEditZProhl then
  begin
    sachovnice.stav := KnihEdit;
    Panel3.visible := True;
    sachovnice.ProhledniPozici(0)
  end

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Panel2.visible := false;
  if sachovnice.stav = KnihEdit then
  begin
    sachovnice.stav := normal;
    KnihMenu(True);
  end
  else if sachovnice.stav = KnihEditZProhl then
  begin
    sachovnice.stav := KnihEdit;
    Panel3.visible := True;
  end
end;

procedure TForm1.Pidejpartii1Click(Sender: TObject);
begin
  sachovnice.PridejPartiiDoKnihovny
end;

procedure TForm1.Prohldniknihovnu1Click(Sender: TObject);
begin
  sachovnice.stav := KnihProhl;
  KnihMenu(false);
  sachovnice.ProhledniKnihovnu
end;

procedure TForm1.Smapozici1Click(Sender: TObject);
begin
  sachovnice.SmazpozicivKnihovne
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  sachovnice.stav := KnihEditZProhl;
  Panel3.visible := false;
  Panel2.visible := True;
  sachovnice.PridejPoziciDoKnihovny;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Panel3.visible := false;
  KnihMenu(True);
  sachovnice.stav := normal;
  sachovnice.Pozice := sachovnice.StaraPozice;
  sachovnice.paint
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  sachovnice.ProhledniPozici(1);
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  sachovnice.ProhledniPozici(-1);
end;

procedure TForm1.Ulo2Click(Sender: TObject);
begin
  UKnih.Knihovna.uloz;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  sachovnice.SmazpozicivKnihovne;
  if UKnih.Knihovna.PocetPozic = 0 then
  begin
    ZpravovaKrabice('V knihovnì už není ani jedna pozice',
      'Je konec prohlížení', mb_ok);
    Button6Click(Sender); { Jako by zmáèkl ukonèi }
  end
  else
    sachovnice.ProhledniPozici(0);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if UKnih.Knihovna.zmeneno then
    if ZpravovaKrabice('Mám zmìny uložit na disk ?',
      'Došlo ke zmìnì knihovny zahájení', mb_yesNo) = id_yes then
      UKnih.Knihovna.uloz;
end;

procedure TForm1.Zobrazvpisy1Click(Sender: TObject);
begin
  VypisForm.Show
end;

procedure TForm1.Vpisyalgoritmu1Click(Sender: TObject);
var
  v: TViditelnost;
begin
  UlozStavFormu(v);
  SkryjFormy;
  VypisCfgForm.showmodal;
  v.md := Vypisovac.Cfg.mdPovoleno;
  v.mn := Vypisovac.Cfg.mnPovoleno;
  v.vy := Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDoOkna;
  ObnovStavFormu(v);
end;

procedure TForm1.Prosted1Click(Sender: TObject);
var
  v: TViditelnost;
begin
  UlozStavFormu(v);
  SkryjFormy;
  CfgForm.showmodal;
  ObnovStavFormu(v);
end;

procedure TForm1.Cinkn1Click(Sender: TObject);
begin
  if ZpravovaKrabice('Mám cinknout po zahrání tahu ?', 'Dotaz',
    mb_yesNo or mb_iconquestion) = id_yes then
    sachovnice.cinkat := True
  else
    sachovnice.cinkat := false
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  application.helpcontext(15)
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  application.helpcontext(15)
end;

procedure TForm1.vod1Click(Sender: TObject);
begin
  application.helpcontext(3)
end;

procedure TForm1.Obsah2Click(Sender: TObject);
begin
  application.helpcontext(0)
end;

procedure TForm1.Kontext1Click(Sender: TObject);
begin
  application.helpcontext(20)
end;

end.

unit Form;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Menus, sachovni,coty , StdCtrls;
const wm_PripravTah=wm_User+0;
      wm_HrajTah=wm_User+1;
      wm_DokMysDop=wm_User+2;{Dokonèeno myšlení dopøedu}
      wm_Zavolej=wm_User+3;
      FormCaption='Honzovy šachy 1350';

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
    procedure wmPripravTah(var msg:tmessage); message wm_pripravTah;
    procedure wmHrajTah(var msg:tmessage); message wm_HrajTah;
    procedure wmDokMysDop(var msg:tmessage); message wm_DokMysDop;
    procedure wmZavolej(var msg:tmessage); message wm_Zavolej;
  public
    sachovnice:tsachovnice;
    procedure KnihMenu(Povolit:boolean);
  end;
{!!!!!!!!!!!!!!!!!!!!!!!!!!! Èachry se skrývání StayOnTop formù !!!!!!!!!!}
type
  TViditelnost=record
   pa,mn,md,vy:boolean;
  end;
Procedure UlozStavFormu(Var Viditelnost:TViditelnost);
Procedure SkryjFormy;
Procedure ObnovStavFormu(Var Viditelnost:TViditelnost);
Function ZpravovaKrabice(Text,Titulek:Pchar;Typ:Word):Integer;
 {Delfy by potøebovaly ještì poøádnì ladit. Je-li nìkde form
 typu StayOnTop, je zhruba 15% pravdìpodobnost (+- epsilon napø.
  i podle toho jestli se  kompiluje poprve po spuštìní Delf),
  že MessageBox bude POD (!!!!) formem. Tato funkce to snad øeší.}
var
  Form1: TForm1;

implementation
{$R *.DFM}
uses ualgdlg, uschedit, rychle, rutiny, CasNaTah,
UKnih,Myslitel, VypForm, VypisCfg, Vypisova, DoprForm, NormForm,
Partiar, CfgDlg;
Procedure UlozStavFormu(Var Viditelnost:TViditelnost);
 begin
  with Viditelnost do
   begin
    Pa:=PartiarForm.visible;
    Md:=MysDopForm.visible;
    Mn:=MysNormForm.visible;
    Vy:=VypisForm.Visible
   end
 end;
Procedure SkryjFormy;
 begin
  PartiarForm.visible:=false;
  MysDopForm.visible:=false;
  MysNormForm.visible:=false;
  VypisForm.Visible:=false;
 end;
Procedure ObnovStavFormu(Var Viditelnost:TViditelnost);
 begin
  with Viditelnost do
   begin
    PartiarForm.visible:=Pa;
    MysDopForm.visible:=Md;
    MysNormForm.visible:=Mn;
    VypisForm.Visible:=Vy
   end
 end;
Function ZpravovaKrabice(Text,Titulek:Pchar;Typ:Word):Integer;
 var v:TViditelnost;
 begin
  UlozStavFormu(v);
  SkryjFormy;
  Result:=application.messagebox(Text,Titulek,Typ);
  ObnovStavFormu(v);
 end;
{!!!!!!!!!!!!!!!!!!!!!!!!!}
{ Globální far procedury  }
{!!!!!!!!!!!!!!!!!!!!!!!!!}
procedure PripravTah;far;
 begin
  form1.sachovnice.PripravTah
 end;
procedure ProgramKonec;far;
 begin
  postquitmessage(0);
 end;
procedure BilyClovek;far;
 begin
  Form1.Sachovnice.Bily:=Clovek;
  postmessage(form1.handle,wm_pripravtah,0,0);
 end;
procedure BilyPocitac;far;
 begin
  Form1.Sachovnice.Bily:=Pocitac;
  postmessage(form1.handle,wm_pripravtah,0,0);
 end;
procedure CernyClovek;far;
 begin
  Form1.Sachovnice.Cerny:=Clovek;
  postmessage(form1.handle,wm_pripravtah,0,0);
 end;
procedure CernyPocitac;far;
 begin
  Form1.Sachovnice.Cerny:=Pocitac;
  postmessage(form1.handle,wm_pripravtah,0,0);
 end;
procedure PartieNova;far;
 begin
  form1.sachovnice.nova_hra(zakladni_postaveni)
 end;
procedure PartieOtevri;far;
 begin
  form1.sachovnice.Otevri;
 end;
procedure TahZpet;far;
 begin
  form1.sachovnice.zpet;
 end;
procedure TahZnovu;far;
 begin
  form1.sachovnice.znovu;
 end;
procedure TahTahni;far;
 begin
  form1.sachovnice.ProgrameTahni
 end;
{!!!!!!!!!!!!!!!!!!!!!!}
procedure TForm1.wmZavolej(var msg:tmessage);
 begin
  if msg.lparam<>0 then TAkce(msg.lparam);
 end;
Procedure Vykonej(Co:TAkce);
 {Zavraždí myšlení dopøedu a vyvolá akci}
 begin
  if Form1.Sachovnice.BilyAlg.Myslim or
     Form1.Sachovnice.CernyAlg.Myslim then
      begin
       ZpravovaKrabice('Form.pas Vykonej.','Chyba',mb_ok);
       exit;
      end;
  if Form1.Sachovnice.BilyAlg.MyslimDopredu then
   Form1.Sachovnice.BilyAlg.PrestanDopredu(Co) else
    if Form1.Sachovnice.CernyAlg.MyslimDopredu then
     Form1.Sachovnice.CernyAlg.PrestanDopredu(Co) else Co;
 end;
{!!!!!!!!!!!!!!!!!!!!!!}
procedure TForm1.FormCreate(Sender: TObject);
begin
 application.helpfile:='sachy.hlp';
 sachovnice:=tsachovnice.create(10,10,canvas);
 randomize;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 sachovnice.destroy;
end;

procedure TForm1.wmPripravTah(var msg:tmessage);
 begin
  vykonej(PripravTah);
 end;
procedure TForm1.wmHrajTah(var msg:tmessage);
 begin
  sachovnice.BeznyTah(LongIntToTTah1(msg.lparam))
 end;
procedure TForm1.wmDokMysDop(var msg:tmessage);
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
 sachovnice.MouseButtonDown(Button,Shift,X,Y)
end;

procedure TForm1.Oto1Click(Sender: TObject);
begin
 sachovnice.otoc
end;

procedure TForm1.Konec1Click(Sender: TObject);
begin
  {vykonej(ProgramKonec)}Close
end;

procedure TForm1.Nov1Click(Sender: TObject);
begin
 vykonej(PartieNova);
end;

procedure TForm1.Zpt1Click(Sender: TObject);
begin
 vykonej(TahZpet);
end;

procedure TForm1.Znovu1Click(Sender: TObject);
begin
 vykonej(TahZnovu);
end;

procedure TForm1.Nastavalgoritmus1Click(Sender: TObject);
var v:TViditelnost;
begin
 algdlg.init(sachovnice.BilyAlg.algcfg);
 algdlg.caption:='Nastavení algoritmu bílého';
 algdlg.button2.caption:='Vše jako èerný';
 algdlg.JsemBily:=True;
 UlozStavFormu(v);
 SkryjFormy;
 algdlg.showmodal;
 ObnovStavFormu(v);
 if AlgDlg.platne then sachovnice.BilyAlg.algcfg:=AlgDlg.AlgCfg;
end;

procedure TForm1.Nastavalgoritmus2Click(Sender: TObject);
var v:TViditelnost;
begin
 algdlg.init(sachovnice.CernyAlg.algcfg);
 algdlg.caption:='Nastavení algoritmu èerného';
 algdlg.button2.caption:='Vše jako bílý';
 algdlg.JsemBily:=False;
 UlozStavFormu(v);
 SkryjFormy;
 algdlg.showmodal;
 ObnovStavFormu(v);
 if AlgDlg.platne then sachovnice.CernyAlg.algcfg:=AlgDlg.AlgCfg;
end;

procedure TForm1.Pttahlovk1Click(Sender: TObject);
begin
 sachovnice.prerus;
end;

procedure TForm1.Thni1Click(Sender: TObject);
begin
 vykonej(TahTahni)
end;

procedure TForm1.lovk1Click(Sender: TObject);
begin
  if sachovnice.bily<>clovek then
  vykonej(BilyClovek)
end;

procedure TForm1.Pota1Click(Sender: TObject);
begin
 if sachovnice.bily<>pocitac then
  vykonej(BilyPocitac)
end;

procedure TForm1.lovk2Click(Sender: TObject);
begin
 if sachovnice.cerny<>clovek then
  vykonej(CernyClovek)
end;

procedure TForm1.Pota2Click(Sender: TObject);
begin
 if sachovnice.cerny<>pocitac then
  vykonej(CernyPocitac)
end;

procedure TForm1.Hrajte1Click(Sender: TObject);
begin
 sachovnice.HrajTed;
end;

procedure TForm1.Ulo1Click(Sender: TObject);
 begin
  Sachovnice.uloz
 end;

procedure TForm1.Ulojako1Click(Sender: TObject);
begin
 sachovnice.ulozjako;
end;

procedure TForm1.Nastavpozici1Click(Sender: TObject);
var v:TViditelnost;
begin
 SChEdit.Sachovnice.Pozice:=Sachovnice.pozice;
 UlozStavFormu(V);
 SkryjFormy;
 SChEdit.ShowModal;
 ObnovStavFormu(V);
 PartiarForm.NakresliTahy(Sachovnice.Partie,Sachovnice.Pozice);
end;

procedure TForm1.Otevi1Click(Sender: TObject);
begin
 vykonej(PartieOtevri);
end;

procedure TForm1.Obsah1Click(Sender: TObject);
begin
 application.helpcontext(0)
end;

procedure TForm1.DobaMylen1Click(Sender: TObject);
 var v:TViditelnost;
begin
 UlozStavFormu(v);
 SkryjFormy;
 FormCasNaTah.ShowModal;
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
   ZpravovaKrabice('Ukonèete nejdøív režim krokování algoritmu (napøíklad tlaèítkem Rozjeï).',
   'Teï se nemùžu ukonèit',mb_ok);
   canclose:=false;
   exit
  end;
 if sachovnice.CernyAlg.Myslim or sachovnice.BilyAlg.Myslim then
  begin
   ZpravovaKrabice('Ukonèete nejdøív myšlení algoritmu (napøíklad Ctrl+C a potom Enter). ',
    'Teï se nemùžu ukonèit',mb_ok);
   canclose:=false;
   exit
  end;
 application.helpcommand(HELP_QUIT,0);
 vykonej(ProgramKonec);
end;
procedure TForm1.KnihMenu(Povolit:boolean);
 begin
 Nov1.enabled:=Povolit;
 Otevi1.enabled:=Povolit;
 NastavPozici1.enabled:=Povolit;
 if not povolit or (sachovnice.partie^.l<>nil) then Zpt1.enabled:=Povolit;
 if not povolit or (sachovnice.partie^.l<>nil) then Znovu1.enabled:=Povolit;
 Thni1.enabled:=Povolit;
 Pota1.enabled:=Povolit;
 Pota2.enabled:=Povolit;
 PidejPozici1.enabled:=Povolit;
 SmaPozici1.enabled:=Povolit;
 PidejPartii1.enabled:=Povolit;
 ProhldniKnihovnu1.enabled:=Povolit;
 VpisyAlgoritmu1.enabled:=Povolit;
 if povolit then
  begin
   MysNormForm.Visible:=Vypisovac.Cfg.mnPovoleno;
   MysDopForm.Visible:=Vypisovac.Cfg.mdPovoleno;
   VypisForm.Visible:=Vypisovac.Cfg.osPovoleno;
   PartiarForm.Visible:=True;
  end
 else
 begin
  MysNormForm.Visible:=False;
  MysDopForm.Visible:=False;
  VypisForm.Visible:=False;
  PartiarForm.Visible:=False;
 end
 end;
procedure TForm1.Pidejpozici1Click(Sender: TObject);
begin
 sachovnice.stav:=KnihEdit;
 KnihMenu(False);
 sachovnice.PridejPoziciDoKnihovny;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 sachovnice.OKPoziciDoKnihovny;
 panel2.visible:=false;
 if sachovnice.stav=KnihEdit then
  begin
   sachovnice.stav:=normal;
   KnihMenu(True);
  end
  else
 if sachovnice.stav=KnihEditZProhl then
  begin
   sachovnice.stav:=KnihEdit;
   panel3.visible:=true;
   Sachovnice.ProhledniPozici(0)
  end

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 panel2.visible:=false;
 if sachovnice.stav=KnihEdit then
  begin
   sachovnice.stav:=normal;
   KnihMenu(True);
  end
   else
 if sachovnice.stav=KnihEditZProhl then
  begin
   sachovnice.stav:=KnihEdit;
   panel3.visible:=true;
  end
end;

procedure TForm1.Pidejpartii1Click(Sender: TObject);
begin
 Sachovnice.PridejPartiiDoKnihovny
end;

procedure TForm1.Prohldniknihovnu1Click(Sender: TObject);
begin
 sachovnice.stav:=KnihProhl;
 KnihMenu(False);
 Sachovnice.ProhledniKnihovnu
end;
procedure TForm1.Smapozici1Click(Sender: TObject);
begin
 Sachovnice.SmazpozicivKnihovne
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
 sachovnice.stav:=KnihEditZProhl;
 panel3.visible:=false;
 panel2.visible:=true;
 sachovnice.PridejPoziciDoKnihovny;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
 panel3.visible:=false;
 KnihMenu(true);
 sachovnice.stav:=normal;
 sachovnice.pozice:=sachovnice.StaraPozice;
 Sachovnice.paint
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
 Sachovnice.ProhledniPozici(1);
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
 Sachovnice.ProhledniPozici(-1);
end;

procedure TForm1.Ulo2Click(Sender: TObject);
begin
 Uknih.Knihovna.Uloz;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
 Sachovnice.SmazpoziciVKnihovne;
 if Uknih.Knihovna.PocetPozic=0 then
  begin
   ZpravovaKrabice('V knihovnì už není ani jedna pozice','Je konec prohlížení',mb_Ok);
   Button6Click(Sender);{Jako by zmáèkl ukonèi}
  end else
  Sachovnice.ProhledniPozici(0);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if uknih.knihovna.zmeneno then
 if ZpravovaKrabice('Mám zmìny uložit na disk ?','Došlo ke zmìnì knihovny zahájení',
    mb_yesNo)=id_yes then uknih.knihovna.uloz;
end;

procedure TForm1.Zobrazvpisy1Click(Sender: TObject);
begin
 VypisForm.Show
end;

procedure TForm1.Vpisyalgoritmu1Click(Sender: TObject);
var V:TViditelnost;
begin
 UlozStavFormu(V);
 SkryjFormy;
 VypisCfgForm.showmodal;
 V.Md:=Vypisovac.Cfg.mdPovoleno;
 V.Mn:=Vypisovac.Cfg.mnPovoleno;
 V.Vy:=Vypisovac.Cfg.osPovoleno and Vypisovac.Cfg.osDoOkna;
 ObnovStavFormu(V);
end;

procedure TForm1.Prosted1Click(Sender: TObject);
var v:TViditelnost;
begin
 UlozStavFormu(V);
 SkryjFormy;
 CfgForm.showModal;
 ObnovStavFormu(V);
end;

procedure TForm1.Cinkn1Click(Sender: TObject);
begin
 if zpravovaKrabice('Mám cinknout po zahrání tahu ?','Dotaz',mb_YesNo or mb_iconquestion)
  =id_yes then sachovnice.cinkat:=true else sachovnice.cinkat:=false
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

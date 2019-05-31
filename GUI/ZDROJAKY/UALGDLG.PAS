unit Ualgdlg;
{$R-}{$B-}
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, TabNotBk, StdCtrls, CoTy, Vcl.ComCtrls;
function VyhodnotEdit(var kam:integer;co:TEdit):boolean;
type
  TAlgDlg = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    StringGrid0: TStringGrid;
    pstdbtn: TButton;
    Ok: TButton;
    Zruit: TButton;
    StdBtn: TButton;
    Npovda: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    Button1: TButton;
    StringGrid4: TStringGrid;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Label12: TLabel;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Edit18: TEdit;
    Label20: TLabel;
    Label21: TLabel;
    Label19: TLabel;
    CheckBox1: TCheckBox;
    Button2: TButton;
    Label22: TLabel;
    CheckBox2: TCheckBox;
    Edit19: TEdit;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Edit20: TEdit;
    Edit21: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure ZruitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure pstdbtnClick(Sender: TObject);
    procedure StdBtnClick(Sender: TObject);
    procedure NpovdaClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
  public
   platne,JsemBily:boolean;
   algcfg:TAlgCfg;
   procedure init(const kym:talgcfg);
   procedure InitOstatni(const kym:talgcfg);
   procedure InitPesce(const kym:talgcfg);
   function vyhodnot:boolean;
  end;

var
  AlgDlg: TAlgDlg;

implementation
 uses form;
{$R *.DFM}
procedure InitStringGrid8x8(const cim:THodnoty64;koho:tstringgrid);
 var i,j:integer;
 begin
  for i:=0 to 7 do
   for j:=0 to 7 do
     koho.cells[i+1,8-j]:=inttostr(cim[i,j])
 end;
procedure InitStringGridPesci(var cim:TAlgCfg;koho:TStringGrid);
 var i:Integer;
 begin
  for i:=1 to 6 do
   begin
    koho.Cells[i,1]:=inttostr(cim.NormalniPesciVepredu[i]);
    koho.Cells[i,2]:=inttostr(cim.VolniPesciVepredu[i]);
    koho.Cells[i,3]:=inttostr(cim.KrytiPesciVepredu[i]);
    koho.Cells[i,4]:=inttostr(cim.VolniAKrytiPesciVepredu[i]);
   end
 end;
function VyhodnotStringGrid8x8(var kam:THodnoty64;koho:tstringgrid):boolean;
 var i,j:integer;
     code:integer;
 begin
  result:=true;
  for i:=0 to 7 do
   for j:=0 to 7 do
    begin
     val(koho.cells[i+1,8-j],kam[i,j],code);
     if code<>0 then
      begin
       koho.cells[i+1,8-j]:='Chyba';
       result:=false
      end
    end
 end;
function VyhodnotStringGridPesci(var kam:TAlgCfg;koho:TStringGrid):boolean;
 var i,code:Integer;
 begin
  result:=true;
  for i:=1 to 6 do
   begin
    val(koho.Cells[i,1],kam.NormalniPesciVepredu[i],code);
    if code<>0 then
     begin
      koho.Cells[i,1]:='Chyba';
      result:=false
     end;
    val(koho.Cells[i,2],kam.VolniPesciVepredu[i],code);
    if code<>0 then
     begin
      koho.Cells[i,2]:='Chyba';
      result:=false
     end;
    val(koho.Cells[i,3],kam.KrytiPesciVepredu[i],code);
    if code<>0 then
     begin
      koho.Cells[i,3]:='Chyba';
      result:=false
     end;
    val(koho.Cells[i,4],kam.VolniAKrytiPesciVepredu[i],code);
    if code<>0 then
     begin
      koho.Cells[i,4]:='Chyba';
      result:=false
     end;
   end
 end;
function VyhodnotEdit(var kam:integer;co:TEdit):boolean;
 var code:integer;
 begin
  result:=true;
  val(co.text,kam,code);
  if code<>0 then
   begin
    co.text:='Chyba';
    result:=false
   end
 end;
procedure TAlgDlg.FormCreate(Sender: TObject);
var i:integer;
begin
 for i:=1 to 8 do
  begin
   stringgrid0.cells[i,0]:='      '+chr(ord('a')+i-1);
   stringgrid0.cells[0,i]:='      '+chr(ord('9')-i);
   stringgrid1.cells[i,0]:='      '+chr(ord('a')+i-1);
   stringgrid1.cells[0,i]:='      '+chr(ord('9')-i);
   stringgrid2.cells[i,0]:='      '+chr(ord('a')+i-1);
   stringgrid2.cells[0,i]:='      '+chr(ord('9')-i);
   stringgrid3.cells[i,0]:='      '+chr(ord('a')+i-1);
   stringgrid3.cells[0,i]:='      '+chr(ord('9')-i);
  end;
 for i:=1 to 6 do stringgrid4.cells[i,0]:='      '+chr(ord('1')+i);
 stringgrid4.colwidths[0]:=100;
 stringgrid4.cells[0,1]:=' Normální';
 stringgrid4.cells[0,2]:=' Volný';
 stringgrid4.cells[0,3]:=' Krytý';
 stringgrid4.cells[0,4]:=' Volný a krytý';
end;

procedure TAlgDlg.ZruitClick(Sender: TObject);
begin
 close
end;
function TalgDlg.vyhodnot:boolean;
 begin
  result:=true;
  AlgCfg.PouzitKnihovnu:=Checkbox1.Checked;
  if not VyhodnotStringGrid8x8(AlgCfg.pesci,StringGrid0) then result:=false;
  if not VyhodnotStringGrid8x8(AlgCfg.jezdci,StringGrid1) then result:=false;
  if not VyhodnotStringGrid8x8(AlgCfg.strelci,StringGrid2) then result:=false;
  if not VyhodnotStringGrid8x8(AlgCfg.kral,StringGrid3) then result:=false;
  if not VyhodnotStringGridPesci(AlgCfg,StringGrid4) then result:=false;
  if not VyhodnotEdit(AlgCfg.CenyFigur[1],Edit1) then result:=false;
  if not VyhodnotEdit(AlgCfg.CenyFigur[2],Edit2) then result:=false;
  if not VyhodnotEdit(AlgCfg.CenyFigur[3],Edit3) then result:=false;
  if not VyhodnotEdit(AlgCfg.CenyFigur[4],Edit4) then result:=false;
  if not VyhodnotEdit(AlgCfg.CenyFigur[5],Edit5) then result:=false;
  if not VyhodnotEdit(AlgCfg.Dvojpech,Edit6) then result:=false;
  if not VyhodnotEdit(AlgCfg.Izolant,Edit7) then result:=false;
  if not VyhodnotEdit(AlgCfg.Volny,Edit8) then result:=false;
  if not VyhodnotEdit(AlgCfg.Kryty,Edit9) then result:=false;
  if not VyhodnotEdit(AlgCfg.VolnyAKryty,Edit10) then result:=false;
  if not VyhodnotEdit(AlgCfg.VezNaSloupci,Edit11) then result:=false;
  if not VyhodnotEdit(AlgCfg.DvojiceStrelcu,Edit12) then result:=false;
  if not VyhodnotEdit(AlgCfg.ZnicenaRosada,Edit13) then result:=false;
  if not VyhodnotEdit(AlgCfg.VedleKolegy,Edit14) then result:=false;
  if not VyhodnotEdit(AlgCfg.MaticiDama,Edit15) then result:=false;
  if not VyhodnotEdit(AlgCfg.KralOdKrale,Edit16) then result:=false;
  if not VyhodnotEdit(AlgCfg.KralOdStredu,Edit17) then result:=false;
  if not VyhodnotEdit(AlgCfg.Okno,Edit18) then result:=false;
  if not VyhodnotEdit(AlgCfg.Nedeterminismus,Edit19) then result:=false;
  if not VyhodnotEdit(AlgCfg.NormHorsiTahy,Edit20) then result:=false;
  if not VyhodnotEdit(AlgCfg.DoprHorsiTahy,Edit21) then result:=false;
  AlgCfg.MysletDopredu:=Checkbox2.checked;
 end;
procedure TAlgDlg.InitPesce(const kym:talgcfg);
 begin
  edit6.text:=inttostr(kym.Dvojpech);
  edit7.text:=inttostr(kym.Izolant);
  edit8.text:=inttostr(kym.Volny);
  edit9.text:=inttostr(kym.Kryty);
  edit10.text:=inttostr(kym.VolnyAKryty);
  edit14.text:=inttostr(kym.VedleKolegy);
  initStringGridPesci(algcfg,stringgrid4);
 end;
procedure TAlgDlg.InitOstatni(const kym:talgcfg);
 begin
  edit1.text:=inttostr(kym.cenyfigur[1]);
  edit2.text:=inttostr(kym.cenyfigur[2]);
  edit3.text:=inttostr(kym.cenyfigur[3]);
  edit4.text:=inttostr(kym.cenyfigur[4]);
  edit5.text:=inttostr(kym.cenyfigur[5]);
  edit11.text:=inttostr(kym.VezNaSloupci);
  edit12.text:=inttostr(kym.DvojiceStrelcu);
  edit13.text:=inttostr(kym.ZnicenaRosada);
  edit15.text:=inttostr(kym.MaticiDama);
  edit16.text:=inttostr(kym.KralOdKrale);
  edit17.text:=inttostr(kym.KralOdStredu);
  edit18.text:=inttostr(kym.Okno);
  Checkbox1.Checked:=AlgCfg.PouzitKnihovnu;
  Checkbox2.Checked:=AlgCfg.MysletDopredu;
  edit19.text:=inttostr(kym.Nedeterminismus);
  edit20.text:=inttostr(kym.NormHorsiTahy);
  edit21.text:=inttostr(kym.DoprHorsiTahy);
 end;
procedure TAlgDlg.init(const kym:talgcfg);
 begin
  algcfg:=kym;
  initOstatni(algcfg);
  initPesce(algcfg);
  initstringgrid8x8(algcfg.pesci,stringgrid0);
  initstringgrid8x8(algcfg.jezdci,stringgrid1);
  initstringgrid8x8(algcfg.strelci,stringgrid2);
  initstringgrid8x8(algcfg.kral,stringgrid3);
 end;
procedure TAlgDlg.FormShow(Sender: TObject);
begin
 platne:=false;
end;

procedure TAlgDlg.OkClick(Sender: TObject);
begin
 if Vyhodnot then begin platne:=true;close end else
  begin
   ZpravovaKrabice('Všechny údaje musí být celá èísla '+
   'mezi -32768 a 32767.','Chybné zadání',mb_OK)
  end
end;

procedure TAlgDlg.pstdbtnClick(Sender: TObject);
begin
 if TabbedNotebook1.activepage='Ostatní' then initOstatni(defalgcfg) else
 if TabbedNotebook1.activepage='Pìšci' then initstringgrid8x8(defalgcfg.pesci,stringgrid0) else
 if TabbedNotebook1.activepage='Jezdci' then initstringgrid8x8(defalgcfg.jezdci,stringgrid1) else
 if TabbedNotebook1.activepage='Støelci' then initstringgrid8x8(defalgcfg.strelci,stringgrid2) else
 if TabbedNotebook1.activepage='Král' then initstringgrid8x8(defalgcfg.kral,stringgrid3) else
 if TabbedNotebook1.activepage='Postup pìšcù' then initPesce(defalgcfg) else
 ZpravovaKrabice('Chyba programu','Varování',mb_ok or mb_iconhand)
end;

procedure TAlgDlg.StdBtnClick(Sender: TObject);
begin
 init(defalgcfg)
end;

procedure TAlgDlg.NpovdaClick(Sender: TObject);
begin
  application.helpcontext(12)
end;

procedure TAlgDlg.Button2Click(Sender: TObject);
begin
 if JsemBily then init(form1.sachovnice.CernyAlg.Algcfg)
  else init(form1.sachovnice.BilyAlg.Algcfg)
end;

procedure TAlgDlg.Button1Click(Sender: TObject);
 var f:file of TAlgCfg;
begin
 if not Vyhodnot then
 begin
  ZpravovaKrabice('Všechny údaje musí být celá èísla '+
   'mezi -32768 a 32767.','Chybné zadání',mb_OK);
  exit
 end;
 if JsemBily then system.assign(f,JS_BAlgCfg) else
  system.assign(f,JS_CAlgCfg);
 system.rewrite(f);
 system.write(f,AlgCfg);
 system.close(f)
end;

end.

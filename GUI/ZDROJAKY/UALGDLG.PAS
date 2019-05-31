unit Ualgdlg;
{$R-}{$B-}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, TabNotBk, StdCtrls, CoTy, Vcl.ComCtrls;
function VyhodnotEdit(var kam: integer; co: TEdit): boolean;

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
    platne, JsemBily: boolean;
    algcfg: TAlgCfg;
    procedure init(const kym: TAlgCfg);
    procedure InitOstatni(const kym: TAlgCfg);
    procedure InitPesce(const kym: TAlgCfg);
    function vyhodnot: boolean;
  end;

var
  AlgDlg: TAlgDlg;

implementation

uses form;
{$R *.DFM}

procedure InitStringGrid8x8(const cim: THodnoty64; koho: TStringGrid);
var
  i, j: integer;
begin
  for i := 0 to 7 do
    for j := 0 to 7 do
      koho.cells[i + 1, 8 - j] := inttostr(cim[i, j])
end;

procedure InitStringGridPesci(var cim: TAlgCfg; koho: TStringGrid);
var
  i: integer;
begin
  for i := 1 to 6 do
  begin
    koho.cells[i, 1] := inttostr(cim.NormalniPesciVepredu[i]);
    koho.cells[i, 2] := inttostr(cim.VolniPesciVepredu[i]);
    koho.cells[i, 3] := inttostr(cim.KrytiPesciVepredu[i]);
    koho.cells[i, 4] := inttostr(cim.VolniAKrytiPesciVepredu[i]);
  end
end;

function VyhodnotStringGrid8x8(var kam: THodnoty64; koho: TStringGrid): boolean;
var
  i, j: integer;
  code: integer;
begin
  result := true;
  for i := 0 to 7 do
    for j := 0 to 7 do
    begin
      val(koho.cells[i + 1, 8 - j], kam[i, j], code);
      if code <> 0 then
      begin
        koho.cells[i + 1, 8 - j] := 'Chyba';
        result := false
      end
    end
end;

function VyhodnotStringGridPesci(var kam: TAlgCfg; koho: TStringGrid): boolean;
var
  i, code: integer;
begin
  result := true;
  for i := 1 to 6 do
  begin
    val(koho.cells[i, 1], kam.NormalniPesciVepredu[i], code);
    if code <> 0 then
    begin
      koho.cells[i, 1] := 'Chyba';
      result := false
    end;
    val(koho.cells[i, 2], kam.VolniPesciVepredu[i], code);
    if code <> 0 then
    begin
      koho.cells[i, 2] := 'Chyba';
      result := false
    end;
    val(koho.cells[i, 3], kam.KrytiPesciVepredu[i], code);
    if code <> 0 then
    begin
      koho.cells[i, 3] := 'Chyba';
      result := false
    end;
    val(koho.cells[i, 4], kam.VolniAKrytiPesciVepredu[i], code);
    if code <> 0 then
    begin
      koho.cells[i, 4] := 'Chyba';
      result := false
    end;
  end
end;

function VyhodnotEdit(var kam: integer; co: TEdit): boolean;
var
  code: integer;
begin
  result := true;
  val(co.text, kam, code);
  if code <> 0 then
  begin
    co.text := 'Chyba';
    result := false
  end
end;

procedure TAlgDlg.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := 1 to 8 do
  begin
    StringGrid0.cells[i, 0] := '      ' + chr(ord('a') + i - 1);
    StringGrid0.cells[0, i] := '      ' + chr(ord('9') - i);
    StringGrid1.cells[i, 0] := '      ' + chr(ord('a') + i - 1);
    StringGrid1.cells[0, i] := '      ' + chr(ord('9') - i);
    StringGrid2.cells[i, 0] := '      ' + chr(ord('a') + i - 1);
    StringGrid2.cells[0, i] := '      ' + chr(ord('9') - i);
    StringGrid3.cells[i, 0] := '      ' + chr(ord('a') + i - 1);
    StringGrid3.cells[0, i] := '      ' + chr(ord('9') - i);
  end;
  for i := 1 to 6 do
    StringGrid4.cells[i, 0] := '      ' + chr(ord('1') + i);
  StringGrid4.colwidths[0] := 100;
  StringGrid4.cells[0, 1] := ' Normální';
  StringGrid4.cells[0, 2] := ' Volný';
  StringGrid4.cells[0, 3] := ' Krytý';
  StringGrid4.cells[0, 4] := ' Volný a krytý';
end;

procedure TAlgDlg.ZruitClick(Sender: TObject);
begin
  close
end;

function TAlgDlg.vyhodnot: boolean;
begin
  result := true;
  algcfg.PouzitKnihovnu := CheckBox1.Checked;
  if not VyhodnotStringGrid8x8(algcfg.pesci, StringGrid0) then
    result := false;
  if not VyhodnotStringGrid8x8(algcfg.jezdci, StringGrid1) then
    result := false;
  if not VyhodnotStringGrid8x8(algcfg.strelci, StringGrid2) then
    result := false;
  if not VyhodnotStringGrid8x8(algcfg.kral, StringGrid3) then
    result := false;
  if not VyhodnotStringGridPesci(algcfg, StringGrid4) then
    result := false;
  if not VyhodnotEdit(algcfg.CenyFigur[1], Edit1) then
    result := false;
  if not VyhodnotEdit(algcfg.CenyFigur[2], Edit2) then
    result := false;
  if not VyhodnotEdit(algcfg.CenyFigur[3], Edit3) then
    result := false;
  if not VyhodnotEdit(algcfg.CenyFigur[4], Edit4) then
    result := false;
  if not VyhodnotEdit(algcfg.CenyFigur[5], Edit5) then
    result := false;
  if not VyhodnotEdit(algcfg.Dvojpech, Edit6) then
    result := false;
  if not VyhodnotEdit(algcfg.Izolant, Edit7) then
    result := false;
  if not VyhodnotEdit(algcfg.Volny, Edit8) then
    result := false;
  if not VyhodnotEdit(algcfg.Kryty, Edit9) then
    result := false;
  if not VyhodnotEdit(algcfg.VolnyAKryty, Edit10) then
    result := false;
  if not VyhodnotEdit(algcfg.VezNaSloupci, Edit11) then
    result := false;
  if not VyhodnotEdit(algcfg.DvojiceStrelcu, Edit12) then
    result := false;
  if not VyhodnotEdit(algcfg.ZnicenaRosada, Edit13) then
    result := false;
  if not VyhodnotEdit(algcfg.VedleKolegy, Edit14) then
    result := false;
  if not VyhodnotEdit(algcfg.MaticiDama, Edit15) then
    result := false;
  if not VyhodnotEdit(algcfg.KralOdKrale, Edit16) then
    result := false;
  if not VyhodnotEdit(algcfg.KralOdStredu, Edit17) then
    result := false;
  if not VyhodnotEdit(algcfg.Okno, Edit18) then
    result := false;
  if not VyhodnotEdit(algcfg.Nedeterminismus, Edit19) then
    result := false;
  if not VyhodnotEdit(algcfg.NormHorsiTahy, Edit20) then
    result := false;
  if not VyhodnotEdit(algcfg.DoprHorsiTahy, Edit21) then
    result := false;
  algcfg.MysletDopredu := CheckBox2.Checked;
end;

procedure TAlgDlg.InitPesce(const kym: TAlgCfg);
begin
  Edit6.text := inttostr(kym.Dvojpech);
  Edit7.text := inttostr(kym.Izolant);
  Edit8.text := inttostr(kym.Volny);
  Edit9.text := inttostr(kym.Kryty);
  Edit10.text := inttostr(kym.VolnyAKryty);
  Edit14.text := inttostr(kym.VedleKolegy);
  InitStringGridPesci(algcfg, StringGrid4);
end;

procedure TAlgDlg.InitOstatni(const kym: TAlgCfg);
begin
  Edit1.text := inttostr(kym.CenyFigur[1]);
  Edit2.text := inttostr(kym.CenyFigur[2]);
  Edit3.text := inttostr(kym.CenyFigur[3]);
  Edit4.text := inttostr(kym.CenyFigur[4]);
  Edit5.text := inttostr(kym.CenyFigur[5]);
  Edit11.text := inttostr(kym.VezNaSloupci);
  Edit12.text := inttostr(kym.DvojiceStrelcu);
  Edit13.text := inttostr(kym.ZnicenaRosada);
  Edit15.text := inttostr(kym.MaticiDama);
  Edit16.text := inttostr(kym.KralOdKrale);
  Edit17.text := inttostr(kym.KralOdStredu);
  Edit18.text := inttostr(kym.Okno);
  CheckBox1.Checked := algcfg.PouzitKnihovnu;
  CheckBox2.Checked := algcfg.MysletDopredu;
  Edit19.text := inttostr(kym.Nedeterminismus);
  Edit20.text := inttostr(kym.NormHorsiTahy);
  Edit21.text := inttostr(kym.DoprHorsiTahy);
end;

procedure TAlgDlg.init(const kym: TAlgCfg);
begin
  algcfg := kym;
  InitOstatni(algcfg);
  InitPesce(algcfg);
  InitStringGrid8x8(algcfg.pesci, StringGrid0);
  InitStringGrid8x8(algcfg.jezdci, StringGrid1);
  InitStringGrid8x8(algcfg.strelci, StringGrid2);
  InitStringGrid8x8(algcfg.kral, StringGrid3);
end;

procedure TAlgDlg.FormShow(Sender: TObject);
begin
  platne := false;
end;

procedure TAlgDlg.OkClick(Sender: TObject);
begin
  if vyhodnot then
  begin
    platne := true;
    close
  end
  else
  begin
    ZpravovaKrabice('Všechny údaje musí být celá èísla ' +
      'mezi -32768 a 32767.', 'Chybné zadání', mb_OK)
  end
end;

procedure TAlgDlg.pstdbtnClick(Sender: TObject);
begin
  if TabbedNotebook1.activepage = 'Ostatní' then
    InitOstatni(defalgcfg)
  else if TabbedNotebook1.activepage = 'Pìšci' then
    InitStringGrid8x8(defalgcfg.pesci, StringGrid0)
  else if TabbedNotebook1.activepage = 'Jezdci' then
    InitStringGrid8x8(defalgcfg.jezdci, StringGrid1)
  else if TabbedNotebook1.activepage = 'Støelci' then
    InitStringGrid8x8(defalgcfg.strelci, StringGrid2)
  else if TabbedNotebook1.activepage = 'Král' then
    InitStringGrid8x8(defalgcfg.kral, StringGrid3)
  else if TabbedNotebook1.activepage = 'Postup pìšcù' then
    InitPesce(defalgcfg)
  else
    ZpravovaKrabice('Chyba programu', 'Varování', mb_OK or mb_iconhand)
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
  if JsemBily then
    init(form1.sachovnice.CernyAlg.algcfg)
  else
    init(form1.sachovnice.BilyAlg.algcfg)
end;

procedure TAlgDlg.Button1Click(Sender: TObject);
var
  f: file of TAlgCfg;
begin
  if not vyhodnot then
  begin
    ZpravovaKrabice('Všechny údaje musí být celá èísla ' +
      'mezi -32768 a 32767.', 'Chybné zadání', mb_OK);
    exit
  end;
  if JsemBily then
    system.assign(f, JS_BAlgCfg)
  else
    system.assign(f, JS_CAlgCfg);
  system.rewrite(f);
  system.write(f, algcfg);
  system.close(f)
end;

end.

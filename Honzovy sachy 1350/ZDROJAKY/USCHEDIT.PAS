unit Uschedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons, StdCtrls, schabstr, CoTy;

type
  TMujSpeedButton = class(TSpeedButton)
  public
    CisloFigury: shortint;
    procedure OnKlik(Sender: TObject);
  end;

  TEdSachovnice = class(TschAbstrakt)
  public
    cf: shortint;
    procedure mousedown(X, Y: integer);
  end;

function PripustnaPozice(var pozice: tpozice): integer;

type
  TSchEdit = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Panel2: TPanel;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Button5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NastavRosady;
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
  private

  public
    sachovnice: TEdSachovnice;
  end;

var
  SchEdit: TSchEdit;
  fgrbtn: array [0 .. 1, 1 .. 6] of TMujSpeedButton;
  polebtn: TMujSpeedButton;

implementation

uses form, rutiny;
{$R *.DFM}

procedure TMujSpeedButton.OnKlik(Sender: TObject);
begin
  SchEdit.sachovnice.cf := self.CisloFigury
end;

procedure TEdSachovnice.mousedown(X, Y: integer);
var
  i, j: integer;
begin
  if klik(X, Y, i, j) then
  begin
    pozice.sch[i, j] := cf;
    zobraz_pole(i + j shl 4)
  end;
end;

const
  VPoradku = 0;
  MocBilychFigur = 1;
  MocCernychFigur = 2;
  MocBilychPescu = 3;
  MocBilychJezdcu = 4;
  MocBilychStrelcu = 5;
  MocBilychVezi = 6;
  MocBilychDam = 7;
  PocetBilychKralu = 8;
  MocCernychPescu = 9;
  MocCernychJezdcu = 10;
  MocCernychStrelcu = 11;
  MocCernychVezi = 12;
  MocCernychDam = 13;
  PocetCernychKralu = 14;
  PesecNa1Nebo8Rade = 15;
  NehrajiciKralVSachu = 16;
  NelzeMRB = 17;
  NelzeVRB = 18;
  NelzeMRC = 19;
  NelzeVRC = 20;

const
  ChybyPozice: array [1 .. 20] of pchar = ('Moc bílých figur',
    'Moc èerných figur', 'Moc bílých pìscù', 'Moc bílých jezdcù',
    'Moc bílých støelcù', 'Moc bílých vìži', 'Moc bílých dam',
    'Poèet bílých králu není 1', 'Moc èerných pìšcù', 'Moc èerných jezdcù',
    'Moc èerných støelcù', 'Moc èerných vìží', 'Moc èerných dam',
    'Poèet èerných králù není 1', 'Pìsec nesmí být na 1. ani 8. øadì',
    'Král nehrající strany nesmí být v šachu',
    'Bílý nemùže rochovat na krátko, zakažte to',
    'Bílý nemùže rochovat na dlouho, zakažte to',
    'Èerný nemùže rochovat na krátko, zakažte to',
    'Èerný nemùže rochovat na dlouho, zakažte to');

function PripustnaPozice(var pozice: tpozice): integer;
var
  PocFgr: array [0 .. 1, 1 .. 6] of integer;
  X, Y: shortint;
begin
  fillchar(PocFgr, sizeof(PocFgr), 0);
  for X := 0 to 7 do
    for Y := 0 to 7 do
      if pozice.sch[X, Y] > 0 then
        inc(PocFgr[0, pozice.sch[X, Y]])
      else if pozice.sch[X, Y] < 0 then
        inc(PocFgr[1, -pozice.sch[X, Y]]);
  X := 0;
  for Y := 1 to 6 do
    X := X + PocFgr[0, Y];
  if X > 16 then
  begin
    result := MocBilychFigur;
    exit
  end;
  X := 0;
  for Y := 1 to 6 do
    X := X + PocFgr[1, Y];
  if X > 16 then
  begin
    result := MocCernychFigur;
    exit
  end;
  if PocFgr[0, 1] > 8 then
  begin
    result := MocBilychPescu;
    exit
  end;
  if PocFgr[0, 2] > 2 + 8 - PocFgr[0, 1] then
  begin
    result := MocBilychJezdcu;
    exit
  end;
  if PocFgr[0, 3] > 2 + 8 - PocFgr[0, 1] then
  begin
    result := MocBilychStrelcu;
    exit
  end;
  if PocFgr[0, 4] > 2 + 8 - PocFgr[0, 1] then
  begin
    result := MocBilychVezi;
    exit
  end;
  if PocFgr[0, 5] > 1 + 8 - PocFgr[0, 1] then
  begin
    result := MocBilychDam;
    exit
  end;
  if PocFgr[0, 6] <> 1 then
  begin
    result := PocetBilychKralu;
    exit
  end;
  if PocFgr[1, 1] > 8 then
  begin
    result := MocBilychPescu;
    exit
  end;
  if PocFgr[1, 2] > 2 + 8 - PocFgr[1, 1] then
  begin
    result := MocCernychJezdcu;
    exit
  end;
  if PocFgr[1, 3] > 2 + 8 - PocFgr[1, 1] then
  begin
    result := MocCernychStrelcu;
    exit
  end;
  if PocFgr[1, 4] > 2 + 8 - PocFgr[1, 1] then
  begin
    result := MocCernychVezi;
    exit
  end;
  if PocFgr[1, 5] > 1 + 8 - PocFgr[1, 1] then
  begin
    result := MocCernychDam;
    exit
  end;
  if PocFgr[1, 6] <> 1 then
  begin
    result := PocetCernychKralu;
    exit
  end;
  for X := 0 to 7 do
    if (abs(pozice.sch[X, 0]) = 1) or (abs(pozice.sch[X, 7]) = 1) then
    begin
      result := PesecNa1Nebo8Rade;
      exit
    end;
  if (hb in pozice.stav.b) and sach(pozice.sch, false) or
    (not(hb in pozice.stav.b) and sach(pozice.sch, true)) then
  begin
    result := NehrajiciKralVSachu;
    exit
  end;
  if (mrb in pozice.stav.b) and
    ((pozice.sch[7, 0] <> 4) or (pozice.sch[4, 0] <> 6)) then
  begin
    result := NelzeMRB;
    exit
  end;
  if (vrb in pozice.stav.b) and
    ((pozice.sch[0, 0] <> 4) or (pozice.sch[4, 0] <> 6)) then
  begin
    result := NelzeVRB;
    exit
  end;
  if (mrc in pozice.stav.b) and
    ((pozice.sch[7, 7] <> -4) or (pozice.sch[4, 7] <> -6)) then
  begin
    result := NelzeMRC;
    exit
  end;
  if (vrc in pozice.stav.b) and
    ((pozice.sch[0, 7] <> -4) or (pozice.sch[4, 7] <> -6)) then
  begin
    result := NelzeVRC;
    exit
  end;
  result := 0;
end;

procedure TSchEdit.FormCreate(Sender: TObject);
var
  i, j: integer;
begin
  sachovnice := TEdSachovnice.create(20, 20, canvas);
  for i := 0 to 1 do
    for j := 1 to 6 do
    begin
      fgrbtn[i, j] := TMujSpeedButton.create(Panel1);
      with fgrbtn[i, j] do
      begin
        CisloFigury := j * (2 * (1 - i) - 1);
        onclick := fgrbtn[i, j].OnKlik;
        parent := Panel1;
        left := 10 + i * 50;
        top := 10 + (j - 1) * 50;
        width := 45;
        height := 45;
        glyph.height := 40;
        glyph.width := 40;
        kresli_figuru(j * (2 * (1 - i) - 1), 2, 2, glyph.canvas)
      end
    end;
  polebtn := TMujSpeedButton.create(Panel1);
  with polebtn do
  begin
    CisloFigury := 0;
    parent := Panel1;
    left := 35;
    top := 310;
    width := 45;
    height := 45;
    onclick := OnKlik;
  end;
end;

procedure TSchEdit.FormDestroy(Sender: TObject);
begin
  sachovnice.free
end;

procedure TSchEdit.FormPaint(Sender: TObject);
begin
  sachovnice.paint
end;

procedure TSchEdit.Button2Click(Sender: TObject);
begin
  close
end;

procedure TSchEdit.Button1Click(Sender: TObject);
var
  chyba: integer;
begin
  chyba := PripustnaPozice(sachovnice.pozice);
  if chyba = 0 then
  begin
    form1.sachovnice.nova_hra(sachovnice.pozice);
    close
  end
  else
    ZpravovaKrabice(ChybyPozice[chyba], 'Chybná pozice !!!',
      mb_ok or mb_IconHand)
end;

procedure TSchEdit.Button3Click(Sender: TObject);
begin
  application.helpcontext(11)
end;

procedure TSchEdit.Button4Click(Sender: TObject);
var
  i, j: integer;
begin
  for i := 0 to 7 do
    for j := 0 to 7 do
      sachovnice.pozice.sch[i, j] := 0;
  sachovnice.paint
end;

procedure TSchEdit.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  sachovnice.mousedown(X, Y);
  if RadioButton1.checked then
    NastavRosady
end;

procedure TSchEdit.Button5Click(Sender: TObject);
begin
  if hb in sachovnice.pozice.stav.b then
  begin
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b - [hb];
    Button5.caption := 'Hraje èerný'
  end
  else
  begin
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b + [hb];
    Button5.caption := 'Hraje bílý'
  end
end;

procedure TSchEdit.NastavRosady;
begin
  CheckBox1.checked := false;
  CheckBox2.checked := false;
  CheckBox3.checked := false;
  CheckBox4.checked := false;
  if (sachovnice.pozice.sch[7, 0] = 4) and (sachovnice.pozice.sch[4, 0] = 6)
  then
    CheckBox1.checked := true
  else
    CheckBox1.checked := false;
  if (sachovnice.pozice.sch[0, 0] = 4) and (sachovnice.pozice.sch[4, 0] = 6)
  then
    CheckBox2.checked := true
  else
    CheckBox2.checked := false;
  if (sachovnice.pozice.sch[7, 7] = -4) and (sachovnice.pozice.sch[4, 7] = -6)
  then
    CheckBox3.checked := true
  else
    CheckBox3.checked := false;
  if (sachovnice.pozice.sch[0, 7] = -4) and (sachovnice.pozice.sch[4, 7] = -6)
  then
    CheckBox4.checked := true
  else
    CheckBox4.checked := false;
end;

procedure TSchEdit.FormShow(Sender: TObject);
begin
  sachovnice.cf := 0;
  if hb in sachovnice.pozice.stav.b then
    Button5.caption := 'Hraje bílý'
  else
    Button5.caption := 'Hraje èerný';
  RadioButton2.checked := true;
  RadioButton1.checked := true;
end;

procedure TSchEdit.RadioButton2Click(Sender: TObject);
begin
  CheckBox1.enabled := true;
  CheckBox2.enabled := true;
  CheckBox3.enabled := true;
  CheckBox4.enabled := true;
end;

procedure TSchEdit.RadioButton1Click(Sender: TObject);
begin
  CheckBox1.enabled := false;
  CheckBox2.enabled := false;
  CheckBox3.enabled := false;
  CheckBox4.enabled := false;
  NastavRosady;
end;

procedure TSchEdit.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.checked then
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b + [mrb]
  else
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b - [mrb]
end;

procedure TSchEdit.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.checked then
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b + [vrb]
  else
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b - [vrb]
end;

procedure TSchEdit.CheckBox3Click(Sender: TObject);
begin
  if CheckBox3.checked then
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b + [mrc]
  else
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b - [mrc]
end;

procedure TSchEdit.CheckBox4Click(Sender: TObject);
begin
  if CheckBox4.checked then
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b + [vrc]
  else
    sachovnice.pozice.stav.b := sachovnice.pozice.stav.b - [vrc]
end;

end.

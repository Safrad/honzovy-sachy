unit Promena;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls;

type
  TPromenaDlg = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    procedure Image4Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    prm: integer;
    bily: boolean;
  end;

var
  PromenaDlg: TPromenaDlg;

implementation

uses Schabstr;
{$R *.DFM}

procedure TPromenaDlg.Image4Click(Sender: TObject);
begin
  prm := 5;
  close;
end;

procedure TPromenaDlg.Image3Click(Sender: TObject);
begin
  prm := 4;
  close;
end;

procedure TPromenaDlg.Image2Click(Sender: TObject);
begin
  prm := 3;
  close;
end;

procedure TPromenaDlg.Image1Click(Sender: TObject);
begin
  prm := 2;
  close;
end;

procedure TPromenaDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not bily then
    prm := -prm;
end;

procedure TPromenaDlg.FormActivate(Sender: TObject);
begin
  kresli_pole(true, false, 0, 0, Image1.canvas);
  kresli_pole(false, false, 0, 0, Image2.canvas);
  kresli_pole(true, false, 0, 0, Image3.canvas);
  kresli_pole(false, false, 0, 0, Image4.canvas);
  if bily then
  begin
    kresli_figuru(2, 2, 2, Image1.canvas);
    kresli_figuru(3, 2, 2, Image2.canvas);
    kresli_figuru(4, 2, 2, Image3.canvas);
    kresli_figuru(5, 2, 2, Image4.canvas);
  end
  else
  begin
    kresli_figuru(-2, 2, 2, Image1.canvas);
    kresli_figuru(-3, 2, 2, Image2.canvas);
    kresli_figuru(-4, 2, 2, Image3.canvas);
    kresli_figuru(-5, 2, 2, Image4.canvas);
  end;
  prm := 5; { Kdyby zm·Ëknul alt F4... }
end;

end.

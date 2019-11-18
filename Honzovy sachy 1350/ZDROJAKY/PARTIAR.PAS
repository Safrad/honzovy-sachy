unit Partiar;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, StdCtrls, Seznam, CoTy, ExtCtrls;

type
  TPartiarForm = class(TForm)
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure NakresliTahy(Partie: PPartie; Pozice: TPozice);
  end;

var
  PartiarForm: TPartiarForm;

implementation

{$R *.DFM}

uses Sachovni, Rutiny, Form;

procedure TPartiarForm.NakresliTahy(Partie: PPartie; Pozice: TPozice);
var
  pom: PPartie;
  Delka, Pos, Korekce: Integer;
  T1: TTah1;
  stringy: array [-1 .. 1] of string[15];
  bilemu: boolean;
begin
  bilemu := hb in Pozice.stav.b;
  Delka := 0;
  pom := Partie;
  While pom^.l <> nil do
  begin
    pom := pom^.l;
    inc(Delka)
  end;
  if (hb in Pozice.stav.b) = odd(Delka) then
    Korekce := 1
  else
    Korekce := 0;
  { Zaèínal-li èerný partii, je trochu jiné èíslování tahù }
  pom := Partie;
  For Pos := -1 to 1 do
    stringy[Pos] := '';
  Pos := 1;
  If pom^.l <> nil Then
  begin
    Tahni_Zpet(Pozice, pom^.T2);
    Dec(Pos);
    pom := pom^.l;
    if pom^.l <> nil then
    begin
      Tahni_Zpet(Pozice, pom^.T2);
      pom := pom^.l;
      Dec(Pos)
    end
  end;
  pom := pom^.r;
  while (Pos <= 1) and (pom <> nil) do
  begin
    OsekejTah(pom^.T2, T1);
    stringy[Pos] := IntToStr((Delka + 1 + Pos + Korekce) shr 1) + '.';
    if not(hb in Pozice.stav.b) then
      stringy[Pos] := stringy[Pos] + '..';
    stringy[Pos] := stringy[Pos] + ' ' + TTah1ToStr(T1, Pozice);
    Tahni(Pozice, T1);
    inc(Pos);
    pom := pom^.r
  end;
  if bilemu then
  begin
    Label1.Caption := stringy[-1];
    Label2.Caption := '';
    Label3.Caption := '';
    Label4.Caption := stringy[0];
    Label5.Caption := stringy[1];
    Label6.Caption := '';
  end
  else
  begin
    Label2.Caption := stringy[-1];
    Label1.Caption := '';
    Label4.Caption := '';
    Label3.Caption := stringy[0];
    Label6.Caption := stringy[1];
    Label5.Caption := '';
  end
end;

procedure TPartiarForm.SpeedButton2Click(Sender: TObject);
begin
  Form1.Znovu1Click(Sender);
end;

procedure TPartiarForm.SpeedButton1Click(Sender: TObject);
begin
  Form1.Zpt1Click(Sender);
end;

end.

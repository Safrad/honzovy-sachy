
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
   procedure NakresliTahy(Partie:PPartie;Pozice:TPozice);
  end;

var
  PartiarForm: TPartiarForm;

implementation
{$R *.DFM}
uses Sachovni, Rutiny, Form;
procedure TPartiarForm.NakresliTahy(Partie:PPartie;Pozice:TPozice);
 var pom:PPartie;
  Delka,Pos,Korekce:Integer;
  T1:TTah1;
  stringy:array[-1..1] of string[15];
  bilemu:boolean;
 begin
  Bilemu:=hb in Pozice.stav.b;
  Delka:=0;
  Pom:=Partie;
  While Pom^.l<>nil do begin Pom:=Pom^.l; inc(Delka) end;
  if (hb in Pozice.Stav.B)= odd(Delka) then
   Korekce:=1 else Korekce:=0;
{Zaèínal-li èerný partii, je trochu jiné èíslování tahù}
  Pom:=Partie;
  For pos:=-1 to 1 do Stringy[Pos]:='';
  Pos:=1;
  If Pom^.l<>nil Then
   begin
    Tahni_Zpet(Pozice,Pom^.T2);Dec(Pos);Pom:=Pom^.l;
    if Pom^.l<>nil then
     begin
      Tahni_Zpet(Pozice,Pom^.T2);
      Pom:=Pom^.l;
      Dec(Pos)
     end
   end;
  Pom:=Pom^.r;
  while (pos<=1) and (Pom<>nil) do
   begin
    OsekejTah(Pom^.T2,T1);
    Stringy[Pos]:=IntToStr((Delka+1+Pos+Korekce)shr 1)+'.';
    if not(hb in Pozice.Stav.b) then Stringy[Pos]:=Stringy[Pos]+'..';
    Stringy[Pos]:=Stringy[Pos]+' '+TTah1ToStr(T1,Pozice);
    Tahni(Pozice,T1);
    Inc(Pos);
    Pom:=Pom^.r
   end;
  if Bilemu then
   begin
    Label1.Caption:=Stringy[-1]; Label2.Caption:='';
    Label3.Caption:=''; Label4.Caption:=Stringy[0];
    Label5.Caption:=Stringy[1]; Label6.Caption:='';
   end else
   begin
    Label2.Caption:=Stringy[-1]; Label1.Caption:='';
    Label4.Caption:=''; Label3.Caption:=Stringy[0];
    Label6.Caption:=Stringy[1]; Label5.Caption:='';
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

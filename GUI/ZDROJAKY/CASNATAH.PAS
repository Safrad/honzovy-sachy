unit Casnatah;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TFormCasNaTah = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Button3: TButton;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
   BilyCas,CernyCas:LongInt;
  public
    { Public declarations }
  end;

var
  FormCasNaTah: TFormCasNaTah;

implementation

{$R *.DFM}
uses form;
procedure TFormCasNaTah.FormShow(Sender: TObject);
begin
 with form1.sachovnice do
  begin
   BilyCas:=BilyAlg.CasNaTah;
   CernyCas:=CernyAlg.CasNaTah;
  end;
 Edit1.Text:=IntToStr(BilyCas);
 Edit2.Text:=IntToStr(CernyCas);
end;

procedure TFormCasNaTah.Button2Click(Sender: TObject);
begin
 close
end;

procedure TFormCasNaTah.Button1Click(Sender: TObject);
var kod1,kod2:integer;
begin
 val(Edit1.Text,BilyCas,kod1);
 if kod1<>0 then Edit1.Text:='Chyba';
 val(Edit2.Text,CernyCas,kod2);
 if kod2<>0 then Edit2.Text:='Chyba';
 if (kod1<>0) or (kod2<>0) or (BilyCas>10000000) or (CernyCas>10000000)
 or (BilyCas<0) or (CernyCas<0)
 then ZpravovaKrabice('Je tøeba zadat pøirozená èísla do deseti milionù.',
 'Chyba údajù',mb_ok or mb_iconstop) else
 begin
  with form1.sachovnice do
   begin
    BilyAlg.CasNaTah:=BilyCas;
    CernyAlg.CasNaTah:=CernyCas;
   end;
  close
 end
end;

procedure TFormCasNaTah.Button3Click(Sender: TObject);
begin
 application.helpcontext(14)
end;

end.

unit Uppdlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TPridejPartiiForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
   potvrzeno:boolean;
  end;

var
  PridejPartiiForm: TPridejPartiiForm;

implementation

{$R *.DFM}

procedure TPridejPartiiForm.Button1Click(Sender: TObject);
begin
 potvrzeno:=true;
 close
end;

procedure TPridejPartiiForm.Button2Click(Sender: TObject);
begin
 close
end;

procedure TPridejPartiiForm.FormShow(Sender: TObject);
begin
 potvrzeno:=false
end;

procedure TPridejPartiiForm.Button3Click(Sender: TObject);
begin
 application.helpcontext(15)
end;

end.

program Sachy;
uses
  Forms,
  Form in 'FORM.PAS' {Form1},
  Promena in 'PROMENA.PAS' {PromenaDlg},
  UAlgDlg in 'UALGDLG.PAS' {AlgDlg},
  CoTy in 'COTY.PAS',
  Rutiny in 'RUTINY.PAS',
  Seznam in 'SEZNAM.PAS',
  Rychle in 'RYCHLE.PAS',
  Sachovni in 'SACHOVNI.PAS',
  Ohodnoc in 'OHODNOC.PAS',
  SChabstr in 'SCHABSTR.PAS',
  USChedit in 'USCHEDIT.PAS',
  Myslitel in 'MYSLITEL.PAS',
  Casnatah in 'CASNATAH.PAS' {FormCasNaTah},
  Uknih in 'UKNIH.PAS',
  Uppdlg in 'UPPDLG.PAS' {PridejPartiiForm},
  Vypform in 'VYPFORM.PAS' {VypisForm},
  Vypisova in 'VYPISOVA.PAS',
  Vypiscfg in 'VYPISCFG.PAS' {VypisCfgForm},
  Doprform in 'DOPRFORM.PAS' {MysDopForm},
  Normform in 'NORMFORM.PAS' {MysNormForm},
  Partiar in 'PARTIAR.PAS' {PartiarForm},
  Vypsoub in 'VYPSOUB.PAS' {VypSoubForm};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TAlgDlg, AlgDlg);
  Application.CreateForm(TPromenaDlg, PromenaDlg);
  Application.CreateForm(TSchEdit, SchEdit);
  Application.CreateForm(TFormCasNaTah, FormCasNaTah);
  Application.CreateForm(TPridejPartiiForm, PridejPartiiForm);
  Application.CreateForm(TVypisForm, VypisForm);
  Application.CreateForm(TVypisCfgForm, VypisCfgForm);
  Application.CreateForm(TMysDopForm, MysDopForm);
  Application.CreateForm(TMysNormForm, MysNormForm);
  Application.CreateForm(TPartiarForm, PartiarForm);
  Application.CreateForm(TVypSoubForm, VypSoubForm);
  Application.Run;
end.

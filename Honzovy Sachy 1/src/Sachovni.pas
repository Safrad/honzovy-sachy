unit Sachovni;

interface

uses
  CoTy;

procedure ZapisPozici(const f: Text; const Pozice: TPozice);

implementation


const
  nazvy: array [1 .. 6] of char = ('P', 'J', 'S', 'V', 'D', 'K');

function PoleToStr(X, Y: byte): string2;
begin
  result := char(byte('a') + X) + char(byte('1') + Y)
end;

procedure ZapisPozici(const f: Text; const Pozice: TPozice);
var
  i, x, y: Integer;
begin
  writeln(f, 'B�l�:');
  for i := 1 to 6 do
    for X := 0 to 7 do
      for Y := 0 to 7 do
        if Pozice.sch[X, Y] = i then
          write(f, nazvy[i] + PoleToStr(X, Y) + ' ');
  writeln(f);
  write(f, 'Mal� ro��da: ');
  if mrb in Pozice.Stav.b then
    writeln(f, 'Ano')
  else
    writeln(f, 'Ne');
  write(f, 'Velk� ro��da: ');
  if vrb in Pozice.Stav.b then
    writeln(f, 'Ano')
  else
    writeln(f, 'Ne');
  writeln(f, '�ern�:');
  for i := 1 to 6 do
    for X := 0 to 7 do
      for Y := 0 to 7 do
        if Pozice.sch[X, Y] = -i then
          write(f, nazvy[i] + PoleToStr(X, Y) + ' ');
  writeln(f);
  write(f, 'Mal� ro��da: ');
  if mrc in Pozice.Stav.b then
    writeln(f, 'Ano')
  else
    writeln(f, 'Ne');
  write(f, 'Velk� ro��da: ');
  if vrc in Pozice.Stav.b then
    writeln(f, 'Ano')
  else
    writeln(f, 'Ne');
  write(f, 'Na tahu je: ');
  if hb in Pozice.Stav.b then
    writeln(f, 'B�l�')
  else
    writeln(f, '�ern�');
end;

end.

unit uMezivypocet;

interface

uses
  CoTy;

type
  TMeziData = record
    Alfa, Beta: longint;
    { Alfa a Beta P�ED po��t�n�m prvn�ho nedopo�ten�ho tahu;
      Cena je hodnota posledn�ho zlep�uj�c�ho tahu }
    Hloubka, I, Platnych: Integer;
    { Posledn� nedopo�ten� hloubka; Prvn� nedopo�ten� tah v Hloubce,
      Po�et tah�, pro n� m� smysl Hodnoty }
    Dojeto: Boolean;
    Pozice: TPozice;
    { Pozice, k n� vede tah u�ivatele, na kter� se p�ipravuji }
    Tahy: TTahy; { V�echny tahy z pozice, dosavadn� nejlep�� je prvn�,
      prvn�ch Platnych je set��d�no podle v�hodnosti. }
    Hodnoty: array [1 .. maxtah] of longint;
  end;

  PMeziSeznam = ^TMeziSeznam;

  TMeziSeznam = record
    Data: TMeziData;
    n: PMeziSeznam;
  end;

  PMezivypocet = ^TMezivypocet;

  TMezivypocet = class
  private
    FAspirationWindowSize: LongInt;
    procedure SetAspirationWindowSize(const Value: LongInt);
  public
    Seznam: PMeziSeznam;
    procedure Pridej(var Data: TMeziData); { Inteligentn� p�id� do Seznamu
      Inteligentn� znamen�: Nejsou-li tam, p�id� je
      Jsou-li tam do men�� hloubky, p�ep�e jimi ten �daj
      Jsou-li tam do stejn� nebo v�t�� hloubky, neud�l� nic }
    procedure DejInfo(var Pozice: TPozice; var Data: TMeziData);
    { Inteligentn� najde v Seznamu informace o Pozici.
      Inteligentn� znamen�, �e pokud tam nejsou, tak rozumn� dopln� �daje s�m.
      Hloubka a I budou 0, tahy budou platn� tahy a Cena hodnota Pozice }
    procedure SmazSeznam;
    destructor Destroy; override;

    property AspirationWindowSize: LongInt read FAspirationWindowSize write SetAspirationWindowSize;
  end;

implementation

uses
  Rychle,
  Ohodnoc;

{ TMezivypocet }

procedure TMezivypocet.Pridej(var Data: TMeziData);
var
  pom: PMeziSeznam;
begin
  pom := Seznam;
  while (pom <> nil) and (CMPPozice(Data.Pozice, pom^.Data.Pozice) <> 0) do
    pom := pom^.n;
  if pom = nil then
  begin
    new(pom);
    pom^.Data := Data;
    pom^.n := Seznam;
    Seznam := pom
  end
  else
  begin
    if (Data.Hloubka > pom^.Data.Hloubka) or (Data.Hloubka = pom^.Data.Hloubka)
      and (Data.I > pom^.Data.I) then
      pom^.Data := Data
  end
end;

procedure TMezivypocet.DejInfo(var Pozice: TPozice; var Data: TMeziData);
var
  pom: PMeziSeznam;
begin
  pom := Seznam;
  while (pom <> nil) and (CMPPozice(Pozice, pom^.Data.Pozice) <> 0) do
    pom := pom^.n;
  if pom = nil then
  begin
    Data.Hloubka := 0;
    Data.Dojeto := false;
    Data.I := 1;
    Rychle.NalezTahy(Pozice, Data.Tahy);
    Data.Pozice := Pozice; { asi zbyte�n�, ale pro jistotu }
    Data.Platnych := 1;
    Data.Hodnoty[1] := HodnotaPozice(Pozice);
    if Data.Hodnoty[1] > mat - FAspirationWindowSize then
    begin
      Data.Beta := Data.Hodnoty[1] + 1;
      Data.Alfa := Data.Hodnoty[1] - FAspirationWindowSize;
    end
    else if Data.Hodnoty[1] < -mat + FAspirationWindowSize then
    begin
      Data.Alfa := Data.Hodnoty[1] - 1;
      Data.Beta := Data.Hodnoty[1] + FAspirationWindowSize;
    end
    else
    begin
      Data.Alfa := Data.Hodnoty[1] - FAspirationWindowSize;
      Data.Beta := Data.Hodnoty[1] + FAspirationWindowSize;
    end;
  end
  else
    Data := pom^.Data
end;

procedure TMezivypocet.SetAspirationWindowSize(const Value: LongInt);
begin
  FAspirationWindowSize := Value;
end;

procedure TMezivypocet.SmazSeznam;
var
  pom: PMeziSeznam;
begin
  while Seznam <> nil do
  begin
    pom := Seznam^.n;
    dispose(Seznam);
    Seznam := pom
  end
end;

destructor TMezivypocet.Destroy;
begin
  SmazSeznam;
  inherited Destroy;
end;

end.

{Knihovna pozic}
unit Uknih;
interface
 uses CoTy;
 const JmenoSouboruKnihovny='knihovna.kz';
 type
  TKnihData=record
   Pozice:TPozice;
   Tahy:array[1..5] of ttah1; {je-li p1=255, tah "není zadán"}
   Nazev:string30;
  end;
  PKnihStrom=^TKnihStrom;
  TKnihStrom=record
    L,R:PKnihStrom;
    Data:TKnihData
   end;
 TKnihovna=class
  private
   Procedure SmazKnihStrom;
    {Dealokuje pamìt, smaže své údaje.}
   Destructor Destroy;
  public
   Zmeneno:boolean;
   KnihStrom:PKnihStrom;
    {Tady si to všechno pamatuji.}
   function PocetPozic:LongInt;
   function HloubkaStromu:LongInt;
   Constructor Create;
   Procedure PridejData(var Data:TKnihData);
    {Pøidá pozici s údaji do knihovny. Je-li už pozice v knihovnì,
     pøepíše se.}
   Procedure PridejTah(T1:TTah1;var Pozice:TPozice;text:string30);
    {Pøidá tah z pozice do knihovny.
     Je-li už pozice v knihovnì:
      a) je-li už uveden tento tah jako jeden z možných,
          nestane se nic
      b) není-li uveden
          b1) Je-li volné místo, pøipíše se (jednou)
          b2) Není-li volné místo
              b2I) Je-li tam nejèetnìjší tah více než jednou,
                   pøepíše jeden jeho výskyt
             b2II) Je-li tam každý tah jednou, nestane se nic}
   Procedure DejData(var Pozice:TPozice;var Data:PKnihStrom);
    {Vrátí v Data pointer na záznam s tahy z Pozice nebo Nil.}
   function DejTah(var Pozice:TPozice;var T1:TTah1):boolean;
    {To hlavní... Vrací false, není-li pozice v knihovnì}
   procedure DejNTaData(n:longint;var Data:PKnihStrom);
    {Èíslováno od 1, je-li tam ménì záznamù, vrací nil}
   procedure mazej(var co:TPozice);
   procedure uloz;
   function otevri:boolean;
 end;
function CMPPozice(var P1,P2:TPozice):integer;
var Knihovna:TKnihovna;
implementation
 uses Forms,WinTypes,Form;
 type TPosPole=array[0..SizeOf(TPozice)-1]of byte;
 function CMPPozice(var P1,P2:TPozice):integer;
  var i:integer;{vrací 1: P1>P2; 0: P1=P2; -1: P1<P2}
  begin
   for i:=0 to SizeOf(TPozice)-1 do
    if TPosPole(P1)[i]>TPosPole(P2)[i] then begin result:=1;exit end else
     if TPosPole(P1)[i]<TPosPole(P2)[i] then begin result:=-1;exit end;
   result:=0
  end;
 Procedure TKnihovna.DejData(var Pozice:TPozice;var Data:PKnihStrom);
  var pom:PKnihStrom;i:integer;
  begin
   Data:=nil;
   if KnihStrom=nil then exit;
   Pom:=KnihStrom;
   repeat
    i:=CMPPozice(Pom^.Data.Pozice,Pozice);
    case i of
     0:Data:=Pom;
     1:Pom:=Pom^.L;
    -1:Pom:=Pom^.R;
    end
   until (Pom=nil)or (i=0)
  end;
 function TKnihovna.DejTah(var Pozice:TPozice;var T1:TTah1):boolean;
  var PodStrom:PKnihStrom;
      i,tahu:integer;
  begin
   DejData(Pozice,Podstrom);
   result:=false;
   if PodStrom<>nil then
    begin
     tahu:=0;
     for i:=1 to 5 do if PodStrom^.Data.Tahy[I].P1<>255 then
      begin
       inc(tahu);
       result:=true;
      end;
     if result then
      begin
       tahu:=random(tahu)+1;
       for i:=1 to 5 do if PodStrom^.Data.Tahy[I].P1<>255 then
        begin
         dec(tahu);
         if tahu=0 then begin T1:=PodStrom^.Data.Tahy[I];break end
        end
      end;
    end
  end;
 Procedure TKnihovna.PridejData(var Data:TKnihData);
  procedure pripoj(var kam:PKnihStrom);
   begin
    new(kam);
    kam^.l:=nil;
    kam^.r:=nil;
    kam^.data:=data
   end;
  var Pom:PKnihStrom;
      i:integer;
  begin
   zmeneno:=true;
   if KnihStrom=nil then
    begin
     new(KnihStrom);
     KnihStrom^.L:=Nil;
     KnihStrom^.R:=Nil;
     KnihStrom^.data:=Data
    end
     else
    begin
     Pom:=KnihStrom;
     repeat
      i:=CMPPozice(Pom^.Data.Pozice,Data.Pozice);
      case i of
       0:begin pom^.data:=data;break end;
                               {Tyhle brejky by asi céèkaø nepochopil...}
       1:if pom^.l<>nil then pom:=pom^.l else begin pripoj(pom^.l);break end;
      -1:if pom^.r<>nil then pom:=pom^.r else begin pripoj(pom^.r);break end;
      end
     until false;
    end
  end;
 Procedure TKnihovna.PridejTah(T1:TTah1;var Pozice:TPozice;text:string30);
  function rovno(ta,tb:ttah1):boolean;
   begin
    if (ta.p1=tb.p1)and(ta.p2=tb.p2)and(ta.promena=tb.promena) then
     result:=true else result:=false
   end;
  var Strom:PKnihStrom;
   Data:TKnihData;
   i,j:integer;
   volno:boolean;
  begin
   zmeneno:=true;
   DejData(Pozice,Strom);
   if Strom=nil then
    begin
     Data.Nazev:=Text;
     Data.pozice:=Pozice;
     Data.Tahy[1]:=T1;
     for i:=2 to 5 do Data.Tahy[i].p1:=255;
     PridejData(Data)
    end
   else
    begin {už tam ta pozice je}
     volno:=false;
     for i:=1 to 5 do if Strom^.Data.Tahy[i].p1=255 then volno:=true;
     if volno then {je tam ještì volno}
      begin
       for i:=1 to 5 do if Strom^.Data.Tahy[i].p1=255 then
        begin Strom^.Data.Tahy[i]:=T1; break end;
      end
     else
      begin {není tam místo}
       for i:=1 to 4 do
        for j:=i+1 to 5 do
         if rovno(Strom^.Data.Tahy[i],Strom^.Data.Tahy[j]) then
          begin
           Strom^.Data.Tahy[j]:=T1;exit
          end
      end
    end
  end;
 Procedure TKnihovna.SmazKnihStrom;
  procedure mazej(co:PKnihStrom);
   begin
    if Co<>Nil then
     begin
      mazej(co^.l);
      mazej(co^.r);
      dispose(co)
     end
   end;
  begin
   mazej(KnihStrom);
   KnihStrom:=nil;
  end;
 procedure TKnihovna.DejNTaData(n:longint;var Data:PKnihStrom);
  procedure jedem(kde:Pknihstrom);
   begin
    if kde=nil then exit;
    jedem(Kde^.l);
    if n>0 then
     begin
      n:=n-1;
      if n=0 then data:=kde else jedem(Kde^.r);
     end;
   end;
  begin
   data:=nil;
   jedem(KnihStrom);
  end;
 Type P_PknihStrom=^Pknihstrom;
 procedure TKnihovna.Mazej(var co:TPozice);
  Procedure Jednoduse(var co:Pknihstrom);
   var pom:PKnihStrom;
   begin {Je-li vpravo nebo vlevo nil. Musí být, už se nekontroluje.}
    pom:=co;
    if (co^.r=nil) then  co:=co^.l else co:=co^.r;
    dispose(pom)
   end;
  Function LevicovyPravicak(Odkud:PknihStrom):P_Pknihstrom;
   begin
    result:=@Odkud^.r;
    while result^^.l<>nil do result:=@result^^.l;
   end;
  var i:integer;
  pom,pom2:P_PknihStrom;
  begin
   pom:=@KnihStrom;
   while pom^<>nil do
    begin
     i:=CMPPozice(pom^^.Data.Pozice,Co);
     case i of
      -1:pom:=@pom^^.r;
       1:pom:=@pom^^.l;
       0:break;
     end
    end; {while}
    if pom^=nil then exit;
    zmeneno:=true;
    if (pom^^.r=nil) or (pom^^.l=nil) then jednoduse(pom^) else
     begin
      pom2:=LevicovyPravicak(pom^);
      Pom^^.Data:=Pom2^^.Data;
      jednoduse(Pom2^);pom2^:=nil
     end
  end;
 procedure TKnihovna.Uloz;
  var f:file of TKnihData;
  procedure ukladej(co:PknihStrom);
   begin
    if co<>nil then
     begin
      ukladej(co^.l);
      write(f,Co^.Data);
      ukladej(co^.r);
     end;
   end;
  begin
   assign(f,JmenoSouboruKnihovny);
   rewrite(f);
   ukladej(KnihStrom);
   close(f);
   zmeneno:=false;
  end;
 function TKnihovna.otevri:boolean;
  var f:file of TKnihData;
  procedure otvirej(a,b:longint);
   var s:longint;
   Data:TKnihData;
   begin
    if a>b then exit;
    s:=(a+b)div 2;
    seek(f,s);
    read(f,Data);
    PridejData(Data);
    otvirej(a,s-1);
    otvirej(s+1,b);
   end;
  begin
   assign(f,JmenoSouboruKnihovny);
   {$I-}
   reset(f);
   {$I+}
   if IOResult<>0 then result:=false else
    begin
     result:=true;
     SmazKnihStrom;
     Otvirej(0,Filesize(f)-1);
     close(f)
    end
  end;
 function TKnihovna.PocetPozic:LongInt;
  function PP(kde:PKnihStrom):LongInt;
   begin
    if kde=nil then result:=0 else
     result:=1+PP(Kde^.l)+PP(Kde^.r)
   end;
  begin
   result:=PP(KnihStrom)
  end;
 function TKnihovna.HloubkaStromu:LongInt;
  function HS(kde:PKnihStrom):LongInt;
   var i,j:LongInt;
   begin
    if kde=nil then result:=0 else
     begin
      i:=HS(kde^.l);
      j:=HS(kde^.r);
      if i<j then result:=j else result:=i;
      result:=result+1
     end
   end;
  begin
   result:=HS(KnihStrom)
  end;
 Destructor TKnihovna.Destroy;
  begin
   SmazKnihStrom
  end;
 Constructor TKnihovna.Create;
  begin
   if not Otevri then application.messagebox('Nemùžu otevøít soubor s knihovnou zahájení.'
   ,'Upozornìní',mb_ok);
   zmeneno:=false
  end;
end.

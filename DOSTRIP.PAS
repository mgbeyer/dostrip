
{$T+}

uses crt, dos, graph, mfii;

const histmax=100; jede=$FF; frq=200; hld=20; extreme=9999; bxo=50; byo=40;
      rn= 1; rno= 2; ro= 4; rso= 8; rs= 16; rsw= 32; rw= 64; rnw= 128;

type history = record
                 top, count: shortint;
                 hx, hy, madegoal: array[0..histmax] of byte;
               end;
     pshort  = ^shortint;
     ppiece  = ^piece;
     piece   = record
                 x, y, ax, ay, goalx, goaly, col: shortint;
                 machine: boolean;
                 reached, allowed, level: byte;
                 other: ppiece;
                 hist: ^history;
               end;
     menubut = record
                 sx, sy, ex, ey : word;
                 fa, hotkey : byte;
                 text : string;
                 hklabel : string[3];
               end;

const xoffs: array[0..7] of shortint = ( 0, 1,1,1,0,-1,-1,-1);
      yoffs: array[0..7] of shortint = (-1,-1,0,1,1, 1, 0,-1);
      xgoals: array[0..5] of byte = (4,6,6,1,1,3);
      ygoals: array[0..5] of byte = (7,6,1,1,6,7);
      combos: array[0..57] of byte =
      ($07,$0B,$0D,$0E,$13,$15,$16,$19,$1A,$1C,$23,$25,$26,$29,$2A,$2C,$31,
       $32,$34,$38,$43,$45,$46,$49,$4A,$4C,$51,$52,$54,$58,$61,$62,$64,$68,
       $70,$83,$85,$86,$89,$8A,$8C,$91,$92,$94,$98,$A1,$A2,$A4,$A8,$B0,$C1,
       $C2,$C4,$C8,$D0,$E0,jede,jede);
      shp_axis: array[1..6, 1..6] of byte =
      ( (0,0,8,8,0,0), (0,8,8,8,8,0), (8,8,8,8,8,8),
        (8,8,8,8,8,8), (0,8,8,8,8,0), (0,0,8,8,0,0) );
      shp_varrow: array[1..6, 1..10] of byte =
      ( (0,0,0,0,7,7,0,0,0,0), (0,0,7,7,7,7,7,0,0,0), (7,7,7,7,7,7,7,8,8,8),
        (7,7,7,7,7,7,7,8,8,8), (0,0,7,7,7,7,7,0,0,0), (0,0,0,0,7,7,0,0,0,0) );
      shp_harrow: array[1..10, 1..6] of byte =
      ( (0,0,8,8,0,0), (0,0,8,8,0,0), (0,0,8,8,0,0), (0,7,7,7,7,0),
        (7,7,7,7,7,7), (7,7,7,7,7,7), (0,7,7,7,7,0), (0,7,7,7,7,0),
        (0,0,7,7,0,0), (0,0,7,7,0,0) );
      shp_darrow: array[1..10, 1..9] of byte =
      ( (7,7,7,0,0,0,0,0,0), (7,7,7,7,7,0,0,0,0), (7,7,7,7,7,7,0,0,0),
        (0,7,7,7,7,7,0,0,0), (0,7,7,7,7,7,0,0,0), (0,0,7,7,7,8,0,0,0),
        (0,0,0,0,0,8,8,0,0), (0,0,0,0,0,0,8,8,0), (0,0,0,0,0,0,0,8,8),
        (0,0,0,0,0,0,0,8,0) );
      menu: array[0..8] of menubut =
      ( (sx:310+bxo; sy:60+byo; ex:446+bxo; ey:75+byo; fa:3; hotkey: 68; text: 'NEUES SPIEL'; hklabel: 'F10'),
        (sx:310+bxo; sy:80+byo; ex:446+bxo; ey:95+byo; fa:3; hotkey: 47; text: 'ZUGVORSCHLAG'; hklabel: '  v'),
        (sx:310+bxo; sy:100+byo; ex:446+bxo; ey:115+byo; fa:3; hotkey: 21; text: 'ZUG ZURöCK'; hklabel: '  z'),
        (sx:310+bxo; sy:135+byo; ex:446+bxo; ey:150+byo; fa:7; hotkey: 59; text: 'SPIELER GRöN     '+chr(16); hklabel: ' F1'),
        (sx:310+bxo; sy:150+byo; ex:446+bxo; ey:165+byo; fa:7; hotkey: 60; text: 'SPIELER ROT      '+chr(16); hklabel: ' F2'),
        (sx:310+bxo; sy:165+byo; ex:446+bxo; ey:180+byo; fa:7; hotkey: 61; text: 'LEVEL GRöN       '+chr(16); hklabel: ' F3'),
        (sx:310+bxo; sy:180+byo; ex:446+bxo; ey:195+byo; fa:7; hotkey: 62; text: 'LEVEL ROT        '+chr(16); hklabel: ' F4'),
        (sx:310+bxo; sy:205+byo; ex:446+bxo; ey:220+byo; fa:3; hotkey: 31; text: 'SCHLEIFEN        '+chr(16); hklabel: '  s'),
        (sx:310+bxo; sy:240+byo; ex:446+bxo; ey:255+byo; fa:6; hotkey: 1; text: 'ENDE'; hklabel: 'Esc') );
      levtext: array[1..10] of string =
      ('schwach', 'bescheiden', 'durchschnitt', 'passabel', 'gut',
       'sehr gut', 'super', 'spitzenklasse', 'ÅbernatÅrlich', 'gottgleich');

var board: array[0..7, 0..7] of byte;
    rr, gg: piece;
    turn: ppiece;
    rhist, ghist: history;
    ende, won, greenfirst, looprevent, notadrill, gblink: boolean;
    thinkx, thinky, suggx, suggy, agx, agy: shortint;
    r: registers;

procedure VGADriver; external;
{$L c:\p\tp70\bgi\default\EGAVGA.OBJ}
procedure GraphInit;
var drv, pal : integer;
begin
drv:=RegisterBGIdriver(@VGADriver);
if paramstr(1)='vga' then begin drv:=9; pal:=2; end
  else begin drv:=3; pal:=1; end;
InitGraph(drv,pal,'');
end;

function NX(x,i: integer): integer; begin NX:=x+xoffs[i]; end;
function NY(y,i: integer): integer; begin NY:=y+yoffs[i]; end;
function max(a,b: shortint): shortint; begin if a<b then max:=b else max:=a; end;
procedure SwapByte(var a, b: byte); var dummy : byte;
begin dummy:=a; a:=b; b:=dummy; end;

procedure DispValues(cod : byte);
var lev : string;
begin
setcolor(15);
case cod of
  59: begin
        bar(465+bxo,135+byo,575+bxo,150+byo);
        if gg.machine then outtextxy(465+bxo, 140+byo, 'COMPUTER')
          else outtextxy(465+bxo, 140+byo, 'MENSCH');
      end;
  60: begin
        bar(465+bxo,150+byo,575+byo,165+byo);
        if rr.machine then outtextxy(465+bxo, 155+byo, 'COMPUTER')
          else outtextxy(465+bxo, 155+byo, 'MENSCH');
      end;
  31: begin
        bar(465+bxo,205+byo,575+bxo,220+byo);
        if looprevent then outtextxy(465+bxo, 210+byo, 'verhindern')
          else outtextxy(465+bxo, 210+byo, 'zulassen');
      end;
  61: begin
        bar(465+bxo,165+byo,575+bxo,180+byo);
        outtextxy(465+bxo, 170+byo, levtext[gg.level]);
      end;
  62: begin
        bar(465+bxo,180+byo,575+bxo,195+byo);
        outtextxy(465+bxo, 185+byo, levtext[rr.level]);
      end;
end;
end;

procedure Maske;
var l : byte;
begin
setcolor(5); rectangle(306+bxo, byo-11, 450+bxo, 261+byo);
rectangle(bxo-10, 275+byo, 450+bxo, 290+byo);
setcolor(15); outtextxy(139+bxo, 280+byo, '(c) 1997 M.Beyer/DFSE');
setcolor(5); outtextxy(138+bxo, 279+byo, '(c) 1997 M.Beyer/DFSE');
rectangle(bxo-10, byo-35, 450+bxo, byo-20);
setcolor(15); outtextxy(131+bxo, byo-30, 'TRIPPPLES fÅr DOS v1.0');
setcolor(5); outtextxy(130+bxo, byo-31, 'TRIPPPLES fÅr DOS v1.0');
for l:=0 to 8 do
begin
  setcolor(menu[l].fa); rectangle(menu[l].sx, menu[l].sy, menu[l].ex, menu[l].ey);
  setcolor(15); outtextxy(menu[l].sx+5, menu[l].sy+5, menu[l].text);
  setcolor(14); outtextxy(420+bxo, menu[l].sy+5, menu[l].hklabel);
end;
DispValues(59); DispValues(60); DispValues(61); DispValues(62); DispValues(31);
end;

procedure DrawAxis(x, y : word);
var lx, ly : byte;
begin
for ly:=1 to 6 do for lx:=1 to 6 do
  if shp_axis[lx, ly]>0 then putpixel(x+lx, y+ly, shp_axis[lx, ly]);
end;

procedure DrawArrow(x, y, r : word);
var lx, ly : byte;
begin
case r of
rn: for ly:=1 to 10 do for lx:=1 to 6 do
  if shp_varrow[lx, ly]>0 then putpixel(x+lx, y-10+ly, shp_varrow[lx, ly]);
rs: for ly:=10 downto 1 do for lx:=1 to 6 do
  if shp_varrow[lx, ly]>0 then putpixel(x+lx, y+17-ly, shp_varrow[lx, ly]);
ro: for ly:=1 to 6 do for lx:=1 to 10 do
  if shp_harrow[lx, ly]>0 then putpixel(x+6+lx, y+ly, shp_harrow[lx, ly]);
rw: for ly:=1 to 6 do for lx:=10 downto 1 do
  if shp_harrow[lx, ly]>0 then putpixel(x+1-lx, y+ly, shp_harrow[lx, ly]);
rnw: for ly:=1 to 9 do for lx:=1 to 10 do
  if shp_darrow[lx, ly]>0 then putpixel(x-7+lx, y-7+ly, shp_darrow[lx, ly]);
rsw: for ly:=9 downto 1 do for lx:=1 to 10 do
  if shp_darrow[lx, ly]>0 then putpixel(x-7+lx, y+14-ly, shp_darrow[lx, ly]);
rno: for ly:=1 to 9 do for lx:=10 downto 1 do
  if shp_darrow[lx, ly]>0 then putpixel(x+14-lx, y-7+ly, shp_darrow[lx, ly]);
rso: for ly:=9 downto 1 do for lx:=10 downto 1 do
  if shp_darrow[lx, ly]>0 then putpixel(x+14-lx, y+14-ly, shp_darrow[lx, ly]);
end;
end;

procedure Cursor(t : ppiece; mov : boolean);
var dum, blink, x, y : word;
begin
gettime(dum,dum,dum,blink);
if mov then
begin
  setcolor(0); rectangle(((t^.ax+1)*35)-13+(bxo-35), ((t^.ay+1)*35)-13+(byo-35),
                        ((t^.ax+1)*35)+20+(bxo-35), ((t^.ay+1)*35)+20+(byo-35));
end else if blink<35 then setcolor(0) else setcolor(t^.col);
rectangle(((t^.x+1)*35)-13+(bxo-35), ((t^.y+1)*35)-13+(byo-35),
          ((t^.x+1)*35)+20+(bxo-35), ((t^.y+1)*35)+20+(byo-35));
setcolor(t^.other^.col);
rectangle(((t^.other^.x+1)*35)-13+(bxo-35), ((t^.other^.y+1)*35)-13+(byo-35),
          ((t^.other^.x+1)*35)+20+(bxo-35), ((t^.other^.y+1)*35)+20+(byo-35));
setcolor(t^.col); x:=bxo+(t^.goalx*35); y:=byo+(t^.goaly*35);
circle(x+3, y+3, 11); circle(x+4, y+4, 11);
circle(x+3, y+4, 11); circle(x+4, y+3, 11);
setcolor(t^.other^.col); x:=bxo+(t^.other^.goalx*35); y:=byo+(t^.other^.goaly*35);
circle(x+3, y+3, 11); circle(x+4, y+4, 11);
circle(x+3, y+4, 11); circle(x+4, y+3, 11);
gblink:=not gblink;
end;

procedure TellTurn;
var l : byte;
begin
setfillstyle(1,0); bar(363+bxo, 17+byo, 390+bxo, 44+byo);
setcolor(turn^.col); rectangle(363+bxo, 17+byo, 390+bxo, 44+byo);
DrawAxis(373+bxo, 27+byo);
for l:=0 to 7 do if boolean(turn^.allowed and (1 shl l)) then
  DrawArrow(373+bxo, 27+byo, turn^.allowed and (1 shl l));
bar(307+bxo,byo-7,449+bxo,byo+5);
if won then outtextxy(307+bxo, byo-3, '    GAME OVER!') else
  if not boolean(turn^.allowed) then outtextxy(311+bxo, byo-3, 'KEIN ZUG MôGLICH!') else
    if turn^.machine then outtextxy(307+bxo, byo-3, '  MAL öBERLEGEN!') else
      outtextxy(307+bxo, byo-3, 'MôGLICHE SPIELZöGE');
if not boolean(turn^.allowed) then won:=true;
if won then
begin
   setfillstyle(1,0); bar(363+bxo, byo+17, 390+bxo, 44+byo); setcolor(8);
   outtextxy(319+bxo, 22+byo, '   WIR HABEN');
   outtextxy(319+bxo, 32+byo, 'EINEN GEWINNER!');
   setcolor(turn^.other^.col);
   outtextxy(320+bxo, 23+byo, '   WIR HABEN');
   outtextxy(320+bxo, 33+byo, 'EINEN GEWINNER!');
end;
end;

procedure Shuffle;
var deck: array[0..57] of byte;
    x, y, i: shortint;
begin
randomize; move(combos, deck, sizeof(combos));
for i:=0 to 1 do for x:=0 to 57 do for y:=0 to 57 do
  if boolean(random(2)) then SwapByte(deck[x], deck[y]);
i:=0; for x:=0 to 7 do for y:=0 to 7 do
        if ((x=1) or (x=6)) and ((y=1) or (y=6)) then board[x, y]:=jede
          else if (y=7) and ((x=4) or (x=3)) then board[x, y]:=jede
            else begin board[x, y]:=deck[i]; inc(i); end;
end;

procedure SetGoal(p : ppiece);
var i : shortint;
    x, y : word;
begin
setcolor(0); x:=bxo+(p^.goalx*35); y:=byo+(p^.goaly*35);
circle(x+3, y+3, 11); circle(x+4, y+4, 11);
circle(x+3, y+4, 11); circle(x+4, y+3, 11);
if p=@rr then i:=p^.reached+1 else i:=4-p^.reached;
p^.goalx:=xgoals[i]; p^.goaly:=ygoals[i];
end;

procedure Allow(from, tu : ppiece);
var i, x, y : shortint;
    r : byte;
begin
r:=0; for i:=0 to 7 do
begin
  x:=NX(tu^.x, i); y:=NY(tu^.y, i);
  if not boolean(x and not 7) and not boolean(y and not 7) and
     not((x=from^.x) and (y=from^.y)) then r:=r or (1 shl i);
end;
tu^.allowed:=r and board[from^.x, from^.y];
end;

procedure Mooove(who : ppiece; x, y : shortint);
var gh : ^history;
begin
gh:=who^.hist;
if gh^.top<histmax-1 then inc(gh^.top) else gh^.top:=0;
if gh^.count<histmax then inc(gh^.count);
gh^.hx[gh^.top]:=who^.x; gh^.hy[gh^.top]:=who^.y;
gh^.madegoal[gh^.top]:=byte(x=who^.goalx) and byte(y=who^.goaly);
who^.x:=x; who^.y:=y; Allow(who, who^.other);
if boolean(gh^.madegoal[gh^.top]) then
begin
  inc(who^.reached); won:=boolean(who^.reached>4);
  if not won then SetGoal(who);
end;
end;

function TryMove(who : ppiece; x, y : shortint) : boolean;
var i, xd, yd : shortint;
begin
if won then begin TryMove:=false; exit; end;
r.ax:=2; Intr($33,r); xd:=x-who^.x; yd:=y-who^.y;

(* nur fÅr drag-token-movement *)
if (xd=0) and (yd=0) then
begin TryMove:=true; r.ax:=1; Intr($33,r); exit; end;
if (xd>1) or (xd<-1) or (yd>1) or (yd<-1) then
begin TryMove:=false; r.ax:=1; Intr($33,r); exit; end;

if xd=0 then
begin
  if yd>0 then i:=4 else i:=0;
end else if xd>0 then i:=2+yd
  else i:=6-yd;
if not boolean(who^.allowed and (1 shl i)) then
  begin TryMove:=false; r.ax:=1; Intr($33,r); exit; end;
turn^.ax:=turn^.x; turn^.ay:=turn^.y;
Mooove(who, x, y); Cursor(turn, true); turn:=turn^.other;
TellTurn; TryMove:=true; r.ax:=1; Intr($33,r);
end;

function WayToGo (p : ppiece) : shortint;
var d, dx, dy : shortint;
begin
dx:=abs(p^.x-p^.goalx); dy:=abs(p^.y-p^.goaly); d:=max(dx, dy);
if p^.reached<4 then inc(d, 5*(4-p^.reached)-2); WayToGo:=d;
end;

function Loopin(p : ppiece) : boolean;
var len, pt, ot, pi, oi, n : shortint;
    hp, ho : ^history;
begin
hp:=p^.hist; ho:=p^.other^.hist;
for len:=2 to (histmax shr 1) do
  if hp^.count>=(len shl 1) then
  begin
  pt:=(hp^.top+histmax+1-len) mod histmax; ot:=(ho^.top+histmax+1-len) mod histmax;
  if (p^.other^.x=ho^.hx[ot]) and (p^.other^.y=ho^.hy[ot]) and
     (p^.x=hp^.hx[pt]) and (p^.y=hp^.hy[pt]) then
  begin
    pi:=hp^.top; oi:=ho^.top;
    for n:=0 to len-1 do
    begin
      pt:=(pt+histmax-1) mod histmax; ot:=(ot+histmax-1) mod histmax;
      if (hp^.hx[pt]<>hp^.hx[pi]) or (hp^.hy[pt]<>hp^.hy[pi]) or
         (ho^.hx[ot]<>ho^.hx[oi]) or (ho^.hy[ot]<>ho^.hy[oi]) then exit;
      pi:=(pi+histmax-1) mod histmax; oi:=(oi+histmax-1) mod histmax;
    end;
  if n>=len then Loopin:=true;
  end;
end;
Loopin:=false;
end;

function PickBestMove(d:shortint; me, it:ppiece; rx, ry: pshort):integer;
var i, besti, best, t, go, bgo, otop, ntop, oxx, oyy, oco : integer;
    a : byte;
    p : piece;
    oooth : ppiece;
    h : ^history;
begin
best:=-extreme; bgo:=999; h:=me^.hist;
if not boolean(me^.allowed) then begin PickBestMove:=-extreme; exit; end;
dec(d);
if rx<>nil then
begin
  t:=0;
  for i:=0 to 7 do
    if boolean(me^.allowed and (1 shl i)) then
    begin
      inc(t); rx^:=NX(me^.x, i); ry^:=NY(me^.y, i);
    end;
  if t=1 then begin PickBestMove:=0; exit; end;
end;
otop:=h^.top; oco:=h^.count;
if h^.count<histmax then inc(h^.count);
if otop<histmax-1 then ntop:=otop+1 else ntop:=0;
h^.top:=ntop; oxx:=h^.hx[ntop]; oyy:=h^.hy[ntop];
h^.hx[ntop]:=me^.x; h^.hy[ntop]:=me^.y;
oooth:=it^.other; it^.other:=@p;
for i:=0 to 7 do
  if boolean(me^.allowed and (1 shl i)) then
  begin
    p:=me^; p.x:=NX(p.x, i); p.y:=NY(p.y, i);
    if (p.x=p.goalx) and (p.y=p.goaly) then
      begin
        inc(p.reached);
        if p.reached > 4 then
        begin
          if rx<>nil then rx^:=p.x; ry^:=p.y; best:=extreme; exit;
        end else SetGoal(@p);
      end;
    if d<=0 then t:=WayToGo(it) - WayToGo(@p)
      else begin
        a:=it^.allowed;
        Allow(@p, it); t:=-PickBestMove(d, it, @p, nil, nil);
        it^.allowed:=a;
      end;
    if (rx<>nil) and (looprevent) and (notadrill) and (Loopin(@p)) then
      dec(t, (extreme shl 1));
    go:=WayToGo(@p);
    if (t>best) or ((t=best) and (go<bgo)) then
    begin
      best:=t; besti:=i; bgo:=go;
      if rx<>nil then begin rx^:=p.x; ry^:=p.y; end;
    end;
  end;
it^.other:=oooth; h^.hx[ntop]:=oxx; h^.hy[ntop]:=oyy;
h^.count:=oco; h^.top:=otop; PickBestMove:=best;
end;

procedure MachineMove;
var who, whom : piece;
    wo, wm : history;
begin
notadrill:=turn^.machine;
if (notadrill) xor (turn^.other^.machine) then
  begin r.ax:=2; Intr($33,r);  end;
who:=turn^; whom:=who.other^; who.other:=@whom; whom.other:=@who;
wo:=who.hist^; wm:=whom.hist^; who.hist:=@wo; whom.hist:=@wm;
PickBestMove(turn^.level, @who, @whom, @thinkx, @thinky);
turn^.ax:=turn^.x; turn^.ay:=turn^.y; Mooove(turn, thinkx, thinky);
Cursor(turn, true); Cursor(turn^.other, true); turn:=turn^.other;
TellTurn;
if (notadrill) xor (turn^.machine) then
  begin r.ax:=1; Intr($33,r);  end;
end;

function SuggestMove : boolean;
var who, whom : piece;
    tx, ty : shortint;
    alb, lb : boolean;
    count : word;
begin
who:=turn^; whom:=who.other^; who.other:=@whom; whom.other:=@who; count:=0;
if (not won) and (boolean(who.allowed)) then
  PickBestMove(turn^.level, @who, @whom, @tx, @ty)
     else begin SuggestMove:=false; exit; end;
repeat
  Cursor(@who, false);
  r.ax:=3; Intr($33,r); alb:=lb; lb:=boolean(r.bx and 1);
  if count<20 then setcolor(15) else setcolor(0);
  rectangle(((tx+1)*35)-13+(bxo-35), ((ty+1)*35)-13+(byo-35),
           ((tx+1)*35)+20+(bxo-35), ((ty+1)*35)+20+(byo-35));
  inc(count); if count>25 then count:=0;
until (keypressed) or ((lb) and (not alb));
SuggestMove:=true; setcolor(0);
rectangle(((tx+1)*35)-13+(bxo-35), ((ty+1)*35)-13+(byo-35),
         ((tx+1)*35)+20+(bxo-35), ((ty+1)*35)+20+(byo-35));
end;

procedure GameInit;
begin
rr.hist:=@rhist; gg.hist:=@ghist; rr.other:=@gg; gg.other:=@rr;
rr.machine:=true; gg.machine:=false; rr.col:=4; gg.col:=2;
greenfirst:=true; rr.level:=5; gg.level:=5; looprevent:=true;
end;

procedure Restart;
begin
Shuffle; rr.x:=4; rr.y:=7; gg.x:=3; gg.y:=7; rr.ax:=0; rr.ay:=0; gg.ax:=0;
gg.ay:=0; Allow(@gg, @rr); Allow(@rr, @gg); ende:=false; won:=false;
rr.reached:=0; gg.reached:=0; SetGoal(@rr); SetGoal(@gg); rhist.top:=histmax;
ghist.top:=histmax; rhist.count:=0; ghist.count:=0;
if greenfirst then turn:=@gg else turn:=@rr; greenfirst:=not greenfirst;
setfillstyle (0,1); bar(307+bxo, 17+byo, 449+bxo, 44+byo);
end;

procedure Arrows(px, py : word; x, y : byte);
var l : byte;
begin
for l:=0 to 7 do if board[x,y]<>jede then
  DrawArrow(px,py,board[x,y] and (1 shl l));
end;

procedure ShowBoard;
var lx, ly : byte;
    x, y : word;
begin
x:=bxo;
for lx:=0 to 7 do
begin
  y:=byo;
  for ly:=0 to 7 do
  begin
    DrawAxis(x, y);
    setcolor(9); rectangle(x-10, y-10, x+17, y+17);
    setcolor(1); rectangle(x-11, y-11, x+18, y+18);
    if ((lx=1) or (lx=6)) and ((ly=1) or (ly=6)) then
    begin
      setcolor(14);
      circle(x+3, y+3, 6); circle(x+4, y+4, 6);
      circle(x+3, y+4, 6); circle(x+4, y+3, 6);
    end else if (ly=7) and ((lx=4) or (lx=3)) then
             begin
               if lx=4 then setfillstyle(1,rr.col) else setfillstyle(1,gg.col);
               bar(x-3, y-3, x+10, y+10);
             end else Arrows(x, y, lx, ly);
    inc(y,35);
  end;
  inc(x,35);
end;
TellTurn;
end;

function TakeBackMove : boolean;

procedure Suck(who : ppiece);
var h : ^history;
begin
h:=who^.hist;
if boolean(h^.count) then begin
  turn:=turn^.other;
  who^.x:=h^.hx[h^.top]; who^.y:=h^.hy[h^.top];
  if boolean(h^.madegoal[h^.top]) then
  begin
    dec(who^.reached); SetGoal(who);
  end;
  if not boolean(h^.top) then h^.top:=histmax-1
    else dec(h^.top);
  dec(h^.count);
end;
end;

var oldturn : ppiece;
begin {TakeBackMove}
r.ax:=2; Intr($33,r); oldturn:=turn;
turn^.ax:=turn^.x; turn^.ay:=turn^.y;
turn^.other^.ax:=turn^.other^.x; turn^.other^.ay:=turn^.other^.y;
if not boolean(turn^.other^.hist^.count) then
  begin TakeBackMove:=false; r.ax:=1; Intr($33,r); exit; end;
if won then bar(307+bxo, 17+byo, 449+bxo, 44+byo);
won:=false; Suck(turn^.other);
if oldturn^.other^.machine then Suck(oldturn);
Allow(turn^.other, turn); Cursor(turn, true); Cursor(turn^.other, true);
TellTurn; r.ax:=1; Intr($33,r);
end;

procedure Play;
var k, c : byte;
    mx, my : word;
    lbut, albut : boolean;
begin
r.ax:=0; Intr($33,r); r.ax:=1; Intr($33,r);
repeat
  GetKey(k, c); Cursor(turn, false);
  r.ax:=3; Intr($33,r); albut:=lbut; lbut:=boolean(r.bx and 1);
  if boolean(r.bx and 2) then c:=47;
  for k:=0 to 8 do
    if (r.cx>menu[k].sx) and (r.cx<menu[k].ex) and
       (r.dx>menu[k].sy) and (r.dx<menu[k].ey) and
       (lbut) and (not albut) then c:=menu[k].hotkey;
  mx:=(r.cx-(bxo-15)) div 35; my:=(r.dx-(byo-15)) div 35;
  if not turn^.machine then
  begin
    if (lbut) and (not albut) then
      if (mx>=0) and (mx<=7) and (my>=0) and (my<=7) then
        if not TryMove(turn, mx, my) then beep(frq,hld);
    case c of
      75: if not TryMove(turn, turn^.x-1, turn^.y) then beep(frq,hld);
      77: if not TryMove(turn, turn^.x+1, turn^.y) then beep(frq,hld);
      72: if not TryMove(turn, turn^.x, turn^.y-1) then beep(frq,hld);
      80: if not TryMove(turn, turn^.x, turn^.y+1) then beep(frq,hld);
      71: if not TryMove(turn, turn^.x-1, turn^.y-1) then beep(frq,hld);
      73: if not TryMove(turn, turn^.x+1, turn^.y-1) then beep(frq,hld);
      79: if not TryMove(turn, turn^.x-1, turn^.y+1) then beep(frq,hld);
      81: if not TryMove(turn, turn^.x+1, turn^.y+1) then beep(frq,hld);
    end;
  end else if not won then MachineMove;
  case c of
    01: ende:=true;
    68: begin
          Restart; r.ax:=2; Intr($33, r); setfillstyle(1,0);
          bar(bxo-15,byo-15,270+bxo,270+byo); setfillstyle(1,1);
          ShowBoard; Maske; r.ax:=1; Intr($33, r);
        end;
    47: if not SuggestMove then beep(frq,hld);
    21: if not TakeBackMove then beep(frq,hld*2);
    59: begin gg.machine:=not gg.machine; DispValues(c); end;
    60: begin rr.machine:=not rr.machine; DispValues(c); end;
    31: begin looprevent:=not looprevent; DispValues(c); end;
    61: begin inc(gg.level); if gg.level>10 then gg.level:=1; DispValues(c) end;
    62: begin inc(rr.level); if rr.level>10 then rr.level:=1; DispValues(c) end;
  end;
until ende;
r.ax:=2; Intr($33, r);
end;

begin
GraphInit; GameInit; Restart; ShowBoard; Maske; Play; CloseGraph;
end.



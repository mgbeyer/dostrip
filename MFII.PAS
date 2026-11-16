UNIT MFII;

INTERFACE

USES Dos, Crt;

VAR oldshape : word;

CONST Insrt      =$80;
      NumLock    =$20;
      CapsLock   =$40;
      ScrollLock =$10;
      LShift     =$2;
      RShift     =$1;
      Shift      =$3;
      Alt        =$8;
      Ctrl       =$4;
      RAlt       =$800;
      LAlt       =$200;
      RCtrl      =$400;
      LCtrl      =$100;
      SysReq     =$8000;

FUNCTION EnhKbd: boolean;
FUNCTION Key_Pressed: boolean;
FUNCTION KbdStat(KeyMask: word; Mode: boolean): boolean;
FUNCTION GetKey(var key, code: byte) : boolean;
PROCEDURE WaitKey(var key, code: byte);
PROCEDURE ClrKbdBufferDOS;
PROCEDURE ClrKbdBufferBIOS;
PROCEDURE Beep(Freq, Hold : word);
PROCEDURE CursorShape(shape : word);

IMPLEMENTATION

VAR crsrshape : word absolute $0040:$0060;
    r         : registers;

FUNCTION EnhKbd: boolean;
BEGIN
EnhKbd:=Mem[$40:$96] and $10<>0;
END;

FUNCTION Key_Pressed: boolean;
BEGIN
r.ah:=$1+$10*Ord(EnhKbd); Intr($16,r); Key_Pressed:=r.flags and fzero=0;
END;

FUNCTION KbdStat(KeyMask: word; Mode: boolean): boolean;
BEGIN
r.ah:=$2+$10*Ord(EnhKbd); Intr($16,r);
if Mode then KbdStat:=r.ax and KeyMask=KeyMask
   else KbdStat:=r.ax and KeyMask<>0;
END;

FUNCTION GetKey(var key, code: byte) : boolean;
BEGIN
if Key_Pressed then
begin
   r.ah:=$10*Ord(EnhKbd); Intr($16,r); code:=r.ah; key:=r.al; GetKey:=true;
end else begin GetKey:=false; key:=0; code:=0; end;
END;

PROCEDURE WaitKey(var key, code: byte);
BEGIN repeat until GetKey(key, code); END;

PROCEDURE ClrKbdBufferDOS;
BEGIN r.ax:=$0C00; MsDos(r); END;
PROCEDURE ClrKbdBufferBIOS;
BEGIN Inline($fa); MemW[$40:$1a]:=MemW[$40:$1c]; Inline($fb); END;

PROCEDURE Beep(Freq, Hold : word);
BEGIN Sound(Freq); Delay(Hold); NoSound; END;

{versch. BIOS-Versionen wie z.B. „ltere Phoenix haben Bugs in den
betr. API-Funktionen, daher der direkte Weg!}
PROCEDURE CursorShape(shape : word); ASSEMBLER;
ASM
mov dx, $3d4              { crt-controller index-port             }
mov al, $b                { register f. cursor-start              }
mov bx, &shape            { lowbyte des datenwortes ausmaskieren  }
and bx, $ff               { "                                     }
mov ah, bl                { datenregister gleich mitladen         }
out dx, ax                { und an den port damit                 }

mov al, $a                { register f. cursor-ende               }
mov bx, &shape            { hibyte des datenwortes ausmaskieren   }
and bx, $ff00             { "                                     }
mov ah, bh                { datenregister gleich mitladen         }
out dx, ax                { und an den port damit                 }

mov ax, &shape            { aktualisieren der bios-variablen      }
mov bx, $0040             { an offset 60h                         }
mov es, bx
mov es:$0060, ax
END;

BEGIN oldshape:=crsrshape; ClrKbdBufferDOS; END.

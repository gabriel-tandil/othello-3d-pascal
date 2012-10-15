{   +----------------------------------------------------------------------+
    |                                                                      |
    |   PasWiz  (C) Copyright 1996 Charon Software, All Rights Reserved    |
    |                                                                      |
    +----------------------------------------------------------------------+



Mouse:

   This unit provides mouse support by direct access to the Microsoft mouse
   driver.  It will also work with compatible drivers, such as those produced
   by Logitech and many other companies.  Trackballs and other devices that
   use compatible drivers are likewise fine.

   Note that PS/2 computers have rather unusual mouse support, due to an
   incomprehensible decision by IBM.  To the best of my knowledge, these
   routines will not work at all with PS/2 rodents.

}



UNIT Mouse;



INTERFACE



FUNCTION Init: Integer;
FUNCTION LeftButton: Boolean;
FUNCTION MidButton: Boolean;
FUNCTION RightButton: Boolean;
FUNCTION WhereX: Integer;
FUNCTION WhereY: Integer;

{PROCEDURE GotoXY (X, Y: Integer);}
PROCEDURE HideCursor;
PROCEDURE Info (VAR Version: Real; VAR Connector, IRQ: Byte);
PROCEDURE LeftClick (VAR Count, X, Y: Integer);
PROCEDURE LeftRelease (VAR Count, X, Y: Integer);
PROCEDURE MidClick (VAR Count, X, Y: Integer);
PROCEDURE MidRelease (VAR Count, X, Y: Integer);
PROCEDURE RightClick (VAR Count, X, Y: Integer);
PROCEDURE RightRelease (VAR Count, X, Y: Integer);
PROCEDURE ShowCursor;
PROCEDURE Window (X1, Y1, X2, Y2: Integer);



{ --------------------------------------------------------------------------- }



IMPLEMENTATION



USES
   Dos;



VAR
   Reg: Registers;



{ ---- procs to access the mouse driver ----------------------------------- }




{ range to which to restrict the mouse cursor }
PROCEDURE Window (X1, Y1, X2, Y2: Integer);
BEGIN
   Reg.AX := 7;
   Reg.CX := Y1;
   Reg.DX := Y2;
   Intr($33, Reg);
   Reg.AX := 8;
   Reg.CX := X1;
   Reg.DX := X2;
   Intr($33, Reg);
END;



{ basic mouse hardware/software info }
PROCEDURE Info (VAR Version: Real; VAR Connector, IRQ: Byte);
BEGIN
   Reg.AX := 36;
   Intr($33, Reg);
   Version := (Hi(Reg.BX) DIV 16) * 10 + (Hi(Reg.BX) MOD 16)
           + ((Lo(Reg.BX) DIV 16) * 10 + (Lo(Reg.BX) MOD 16)) / 100;
   Connector :=  Hi(Reg.CX);
   IRQ := Lo(Reg.CX);
   { attempt to safeguard against incompatible or outdated drivers }
   IF (Connector < 1) OR (Connector > 20) OR (IRQ = 1) OR (IRQ > 15) THEN BEGIN
      Version := 0.0;
      Connector := 0;
      IRQ := 0;
   END;
END;



{$F+}

{ the below routines are in assembly language }



FUNCTION Init; external;               { init mouse driver, return buttons }
PROCEDURE HideCursor; external;        { hide mouse cursor }
FUNCTION LeftButton; external;         { return left button status }
FUNCTION MidButton; external;          { return middle button status }
FUNCTION RightButton; external;        { return right button status }
PROCEDURE ShowCursor; external;        { show mouse cursor }
FUNCTION WhereX; external;             { return X coordinate of mouse }
FUNCTION WhereY; external;             { return Y coordinate of mouse }

PROCEDURE GotoXY (X, Y: Integer); external;      { set mouse cursor position }

{ get # of presses of a button & cursor location at last press }
PROCEDURE LeftClick (VAR Count, X, Y: Integer); external;
PROCEDURE MidClick (VAR Count, X, Y: Integer); external;
PROCEDURE RightClick (VAR Count, X, Y: Integer); external;

{ get # of releases of a button & cursor location at last release }
PROCEDURE LeftRelease (VAR Count, X, Y: Integer); external;
PROCEDURE MidRelease (VAR Count, X, Y: Integer); external;
PROCEDURE RightRelease (VAR Count, X, Y: Integer); external;


{$L MOUSES}



{ ----------------------- initialization code --------------------------- }
BEGIN
END.

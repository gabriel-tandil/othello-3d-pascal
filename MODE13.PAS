{ Unidad mode13, basada en tutoriales de FAC aka Alfonso Alba,
adaptada a las necesidades de velocidad de 64 cubos dando vuelta

  Contiene procedimientos y funciones para trabajar en el modo 13 }


unit Mode13;


interface

{ Tipos y constantes utilizadas }
const VGA = $A000;   { El segmento de la pantalla VGA }
      mText = 0;     { Constante para referenciar el modo de Texto }
      m13h = 1;       { Constante para el modo 13h }
      Long = $66;     { Opcode para instrucciones asm de 32 bits }

type TColor = array[0..2] of byte;       { Componentes de un color }
     TPalette = array[0..255] of TColor; { Tipo para almacenar una paleta }

var YOffset : array[0..199] of word; { Tabla precalculada de Y * 320 }
    CurrentMode : byte;  { Modo de video actual }

{ Cambiar de modo gr fico }
procedure SetMode13;      { Entrar al modo 13h }
procedure SetTextMode;    { Regresar al modo texto }

{ Procedimientos de dibujo }
procedure ClearScreen(color : byte; where : word);
procedure PutPixel(x, y : word; color : byte; where : word);
function  GetPixel(x, y : word; where : word) : byte;

procedure HLine(x1, x2, y : word; color : byte; where : word);
procedure Line(x1, y1, x2, y2 : word; color : byte; where : word);

{ Manejo de paleta }
procedure GetPal(color : byte; var red, green, blue : byte);
procedure SetPal(color, red, green, blue : byte);
procedure GetPalette(var pal : TPalette);
procedure SetPalette(pal : TPalette);

procedure RotatePalette(var pal : TPalette; first, last : byte);

procedure FadeOut(d : word);
procedure FadeTo(pal : TPalette; d : word);

{ Pantallas virtuales }

type TVirtual = array[1..64000] of byte;
     PTVirtual = ^TVirtual;

procedure SetupVirtual(var Vscr : PTVirtual; var Vseg : word);
procedure ShutDownVirtual(var Vscr : PTVirtual);
procedure CopyScreen(source, dest : word);


{ Procedimientos y funciones diversos }
procedure VRetrace;
procedure LoadPCX(fn : string; where, DimX, DimY, OffX, OffY : word;
                  var pal : TPalette);


implementation

uses Crt;

{ Cambio de modo grafico }

procedure SetMode13; { Cambia al modo 13 (320 * 200 * 256) }
begin
     asm
        mov ax, 0013h
        int 10h
     end;
     CurrentMode := m13h;
end;


procedure SetTextMode; { Cambia al modo de texto de 80 * 25 caracteres }
begin
     asm
        mov ax, 0003h
        int 10h
     end;
     CurrentMode := mText;
end;


{ Procedimientos de dibujo }

procedure ClearScreen(color : byte; where : word); assembler;
{ Borra la pantalla pint ndola con un determinado color }
     asm
        mov cx, 16000       { Vamos a almacenar 16000 DWORDS }
        mov es, where       { Segmento de la pantalla virtual o VGA }
        xor di, di          { DI := 0 }
        mov al, color       { AL := color }
        mov ah, al          { AH := color }
        mov dx, ax
        db long; shl ax, 16 { shl eax, 16 }
        mov ax, dx          { Ahora tenemos color en los 4 bytes de EAX }
        db 0F3h, 66h, 0ABh    { rep stosd }
                            { repite mov es:[di], eax    16000 veces }
     end;


procedure PutPixel(x, y : word; color : byte; where : word);assembler;
{ Dibuja un p¡xel }
     asm
        mov ax, -1
     @inicio:                 {veo si x esta entre 0 y 199}
        cmp ax,318
        je @fin
        inc ax
        cmp ax,x
        jne @inicio
        mov ax, -1
     @siguiente:             {veo si y esta entre o y 200}
        cmp ax,198
        je @fin
        inc ax
        cmp ax,y
        jne @siguiente        {si era asi dibujo el punto}

        mov es, where  { movemos el segmento de la pantalla a ES }
        mov bx, y      { BX := y }
        shl bx, 1      { BX := BX * 2 }
        mov di, word ptr [YOffset + bx] { Obtenemos DI := Y * 320 }
        add di, x      { DI := DI + X  --> DI = Y * 320 + X }
        mov al, color  { AL := color }
        mov es:[di], al

     @fin:

     end;

function GetPixel(x, y, where : word) : byte; assembler;
{ Devuelve el color del p¡xel en (x, y)}
     asm
        mov es, where  { ES := where }
        mov bx, y      { BX := Y }
        shl bx, 1      { BX := BX * 2 }
        mov di, word ptr[YOffset + bx] { DI := YOffset[Y] = 320 * Y }
        add di, x      { DI := Y * 320 + X }
        mov al, es:[di]
     end;


procedure HLine(x1, x2, y : word; color : byte; where : word); assembler;
{ Dibuja una l¡nea horizontal desde (x1, y) hasta (x2, y) con x1 < x2 }


      asm

        mov ax, -1
     @inicio:                 {veo si x esta entre 0 y 319}
        cmp ax,318
        je @corrigex1
        inc ax
        cmp ax,x1
        jne @inicio
        push x1

        mov ax, -1
     @otra:                 {veo si x esta entre 0 y 319}
        cmp ax,318
        je @corrigex2
        inc ax
        cmp ax,x2
        jne @otra
        push x2

        mov ax, -1
     @siguiente:             {veo si y esta entre 0 y 200}
        cmp ax,198
        je @fin
        inc ax
        cmp ax,y
        jne @siguiente        {si era asi dibujo la linea}


        mov bx, y
        shl bx, 1
        mov es, where
        pop cx {x2}
        pop dx {x1}
        sub cx,dx
        mov di, word ptr [YOffset + bx]
        add di,dx
        mov al,color
        mov ah,al
        shr cx,1
        jnc @start
        stosb
@start:
        rep   stosw
        jmp @fin

@corrigex1:
                            {veo si x es mayor que 319}
        mov ax, 1
     @ini1:
        cmp ax,-319
        je @fin
        dec ax
        cmp ax,x1
        jne @ini1

        push 0
        mov ax, -1
        jmp @otra


@corrigex2:

             {veo si x es menor que 0}
        mov ax, 319
     @ini2:
        cmp ax,2
        je @fin
        dec ax
        cmp ax,x1
        jne @ini2

        push 319
        mov ax, -1
        jmp @siguiente


@fin:

        end;

procedure Line(x1, y1, x2, y2 : word; color : byte; where : word);
{ Dibuja una l¡nea desde (x1, y1) hasta (x2, y2) }
  function sgn(n : integer) : integer;
  begin
       if n > 0 then sgn := 1
                else begin if n < 0 then sgn := -1
                                    else sgn := 0;
                     end;
  end;

var i,s,d1x,d1y,d2x,d2y,u,v,m,n:integer;
begin
     u := x2 - x1;
     v := y2 - y1;
     d1x := SGN(u);
     d1y := SGN(v);
     d2x := SGN(u);
     d2y := 0;
     m := ABS(u);
     n := ABS(v);
     IF not (M > N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := m shr 1;
     FOR i := 0 TO m DO
     BEGIN
          putpixel(x1, y1, color, where);
          s := s + n;
          IF not (s < m) THEN
          BEGIN
               s := s - m;
               x1 := x1 + d1x;
               y1 := y1 + d1y;
          END
          ELSE
          BEGIN
               x1 := x1 + d2x;
               y1 := y1 + d2y;
          END;
     end;
end;



{ Manejo de paleta }

procedure GetPal(color : byte; var red, green, blue : byte);
{ Lee los valores de rojo, verde y azul de un color en la paleta }
var r, g, b : byte;
begin
     asm
        mov dx, 3C7h
        mov al, color
        out dx, al
        add dx, 2
        in al, dx
        mov r, al
        in al, dx
        mov g, al
        in al, dx
        mov b, al
     end;
     red := r;
     green := g;
     blue := b;
end;


procedure SetPal(color, red, green, blue : byte); assembler;
{ Fija los valores de rojo, verde y azul de un color en la paleta }
asm
   mov dx, 3C8h
   mov al, color
   out dx, al
   inc dx
   mov al, red
   out dx, al
   mov al, green
   out dx, al
   mov al, blue
   out dx, al
end;


procedure GetPalette(var pal : TPalette); assembler;
asm
   les di, pal
   mov dx, 3C7h
   mov al, 0
   out dx, al
   add dx, 2
   mov cx, 768
   rep insb
end;

procedure SetPalette(pal : TPalette); assembler;
asm
   push ds
   lds si, pal
   mov dx, 3C8h
   mov al, 0
   out dx, al
   inc dx
   mov cx, 768
   rep outsb
   pop ds
end;

procedure RotatePalette(var pal : TPalette; first, last : byte);
{ Este procedimiento rota la paleta desde el color first hasta el
  color last.

  Si first < last, la rotaci¢n se hace hacia adelante
  Si first > last, la rotaci¢n se hace hacia atr s
}
var i : byte;
    c : TColor;

begin
     if first < last then
     begin
          c := pal[last];
          for i := last downto (first + 1) do pal[i] := pal[i - 1];
          pal[first] := c;
     end
     else
     begin
          c := pal[last];
          for i := last to (first - 1) do pal[i] := pal[i + 1];
          pal[first] := c;
     end;
end;

{ Fade Out (oscurece la pantalla) }
procedure FadeOut(d : word); { el par metro d es la velocidad del efecto }
{ Entre m s grande es el par metro d, m s lento es el efecto }
var p : TPalette;
    i, j : byte;
begin
     GetPalette(p);
     for i := 1 to 64 do { el efecto se hace en 64 pasos }
     begin
          for j := 0 to 255 do { para cada color de la paleta... }
          begin
               if p[j, 0] > 0 then dec(p[j, 0]); { Reducimos la intensidad }
               if p[j, 1] > 0 then dec(p[j, 1]); { de sus componentes RGB }
               if p[j, 2] > 0 then dec(p[j, 2]);
          end;
          VRetrace; { Evitamos los parpadeos }
          SetPalette(p); { Y fijamos la nueva paleta }
          delay(d); { un peque¤o retardo }
     end;
end;

{ FadeTo (hace el cambio progresivo de la paleta actual a la especificada) }
procedure FadeTo(pal : TPalette; d : word);
var p : TPalette;
    i, j : byte;
begin
     GetPalette(p);
     for i := 1 to 64 do { 64 pasos para hacer el efecto }
     begin
          for j := 0 to 255 do
          begin
               if p[j, 0] > pal[j, 0] then dec(p[j, 0]);
               if p[j, 0] < pal[j, 0] then inc(p[j, 0]);
               if p[j, 1] > pal[j, 1] then dec(p[j, 1]);
               if p[j, 1] < pal[j, 1] then inc(p[j, 1]);
               if p[j, 2] > pal[j, 2] then dec(p[j, 2]);
               if p[j, 2] < pal[j, 2] then inc(p[j, 2]);
          end;
          VRetrace;
          SetPalette(p);
          delay(d);
     end;
end;


{ Pantallas virtuales }

procedure SetupVirtual(var Vscr : PTVirtual; var Vseg : word);
begin
     Vscr := new(PTVirtual);
     Vseg := seg(Vscr^);
end;

procedure ShutDownVirtual(var Vscr : PTVirtual);
begin
     dispose(Vscr);
     Vscr := nil;
end;

procedure CopyScreen(source, dest : word); assembler;
     asm
        push ds
        mov es, dest
        mov ds, source
        xor si, si
        xor di, di
        mov cx, 16000
        db 0F3h, 66h, 0A5h { rep movsd }
        pop ds
     end;


{ Procedimientos diversos }

procedure VRetrace; assembler;
{ Espera hasta que ocurra un retrazado vertical }
asm
   mov dx, 3DAh         { El puerto $3DA nos dice si est  activo el
                          retrazado vertical }
@loop1:
      in al, dx         { examinamos el puerto }
      test al, 08h      { y vemos si en ese momento se est  efectuando
                          el retrace }
      jnz @loop1         { Si es as¡, esperamos hasta que termine }
@loop2:
      in al, dx         { Examinamos otra vez el puerto }
      test al, 08h      { y vemos si empieza alg£n retrace vertical }
      jz @loop2          { Y espera hasta que empiece el retrace }
end;

{ Procedimiento para cargar imagenes PCX }
procedure LoadPCX(fn : string; where, DimX, DimY, OffX, OffY : word;
                  var pal : TPalette);

var f : file of byte; { archivo que vamos a abrir }
    x, y : word;   { contadores y variables temporales }
    r, g, b : byte;   { para leer la paleta de colores }
    c, i, a : byte;      { m s contadores y variables temporales }
    flag : boolean;   { indicador de que hemos terminado }

    { Esta es una funci¢n auxiliar que incrementa la posici¢n en el
      array en el que se almacena la imagen e indica si se ha le¡do
      toda la imagen }
    function IncPos : boolean;
    begin
         inc(x); { incrementamos X }
         if x = DimX then { Si ya terminamos esa l¡nea, entonces... }
         begin
              x := 0; { Volvemos a empezar en la siguiente l¡nea }
              inc(y);
         end;
         if y = DimY then IncPos := true else IncPos := false;
         { Si ya terminamos todas las l¡neas de la imagen, entonces
           regresa true, de lo contrario regresa false }
    end;

begin
     assign(f, fn); { abrimos el archivo de la imagen }
     reset(f);

     seek(f, 128); { nos saltamos el encabezado de 128 bytes }
     flag := true; { Si flag = false, entonces hemos terminado }
     x := 0; { Empezamos en (0,0); }
     y := 0;
     while flag do
     begin
          read(f, c);   { leemos el siguiente byte }
          if ((c and $c0) = $c0) then
          { y comprobamos los 2 bits m s significativos }
          begin
               { si los bits est n activados, entonces el byte es un
                 contador }
               read(f, a); { leemos el siguiente byte }
               for i := 1 to (c and $3f) do { hacemos el ciclo }
               begin
                    PutPixel(OffX + x, OffY + y, a, where);
                    { almacenamos el byte de datos }
                    if IncPos then flag := false;
                    { Incrementamos la posici¢n y comprobamos si no
                      hemos terminado de leer la imagen }
               end;
          end
          else
          { Si los 2 bits no estan activados, entonces el byte es un
            byte de datos }
          begin
               PutPixel(OffX + x, OffY + y, c, where);
               { y simplemente lo almacenamos }
               if IncPos then flag := false;
               { y continuamos con la siguiente posici¢n }
          end;
     end;

     { Si ya termin¢ de leer la imagen, entonces sigue la paleta }
     seek(f, filesize(f) - 768); { Buscamos los £ltimos 768 bytes }

     for i := 0 to 255 do { y leemos la paleta }
     begin
          read(f, r, g, b);
          pal[i][0] := r div 4;   { Los valores del archivo PCX }
          pal[i][1] := g div 4; { van de 0 a 255, as¡ que hay }
          pal[i][2] := b div 4;  { que dividirlos entre 4 }
     end;

     close(f); { cerramos el archivo }
end;


var i : byte;
begin
     CurrentMode := mText;
     for i := 0 to 199 do YOffset[i] := i * 320;
end.

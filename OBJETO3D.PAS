
unit Objeto3D;

interface

uses Vertices;

const MaxVertices = 15;  { N£mero m ximo de v‚rtices }
      MaxCaras = 6;     { N£mero m ximo de caras }
      MaxVerticesCara = 4; { N£mero m ximo de v‚rtices en cada cara }


{ Variables globales usadas para el sombreado }
var rango, colorinicial : byte;
    FuenteLuz : TVertice;


{ Tipo cara (pol¡gono) }
type TCara = record
             NVertices : integer;  { N£mero de v‚rtices en el pol¡gono }
             Vertice : array[1..MaxVerticesCara] of integer;
                       { Indices correspondientes a cada v‚rtice }
             normal : TVertice;  { vector normal al plano de la cara }
             color : byte;       { color de la cara }
             coloro: byte;
             Z : double;
             end;

type PTCara = ^TCara;
     TCaraArray = array[1..MaxCaras] of PTCara;
     PTCaraArray = ^TCaraArray;


{ Tipo Objeto Tridimensional }
type PTObjeto3D = ^TObjeto3D;
     TObjeto3D = record
                 NVertices : integer;  { N£mero de v‚rtices }
                 NCaras : integer;     { N£mero de caras }
                 ox, oy, oz : double;  { Coordenadas del origen del objeto }
                 Vertice : array[1..MaxVertices] of TVertice; { V‚rtices }
                 Cara : array[1..MaxCaras] of TCara;          { Caras }
                 end;

type PTtablero3D = ^Ttablero3D;
     Ttablero3D = record
                 NVertices : integer;  { N£mero de v‚rtices }
                 NCaras : integer;     { N£mero de caras }
                 ox, oy, oz : double;  { Coordenadas del origen del objeto }
                 Vertice : array[1..81] of TVertice; { V‚rtices }
                 Cara : array[1..MaxCaras] of TCara;          { Caras }
                 end;

{ procedimientos para las caras }
procedure CaraReinicia(var cara : TCara);
procedure CaraAgregaVertice(var cara : TCara; vertice : integer);
{function CaraVisible(cara : TCara) : boolean; }
function CaraVisible(cara : TCara; objeto : PTObjeto3D) : boolean;
procedure CaraDibuja(obj : PTObjeto3D; cara : TCara; where : word);


{ procedimientos para los objetos }
procedure Objeto3DReinicia(obj : PTObjeto3D);
procedure tablero3DReinicia(obj : PTtablero3D);
procedure Objeto3DAgregaVertice(obj : PTObjeto3D; nx, ny, nz : double);
procedure tablero3DAgregaVertice(obj : PTtablero3D; nx, ny, nz : double);
procedure Objeto3DAgregaCara(obj : PTObjeto3D; cara : TCara);
procedure Objeto3DRota(obj : PTObjeto3D; ax, ay, az : integer);
procedure tablero3DRota(obj : PTtablero3D; ax, ay, az : integer);
procedure Objeto3DMueve(obj : PTObjeto3D; nx, ny, nz : double);
procedure tablero3DMueve(obj : PTtablero3D; nx, ny, nz : double);
procedure Objeto3DEscala(obj : PTObjeto3D; sx, sy, sz : double);
procedure tablero3DEscala(obj : PTtablero3D; sx, sy, sz : double);
procedure Objeto3DTraslada(obj : PTObjeto3D; tx, ty, tz : double);
procedure tablero3DTraslada(obj : PTtablero3D; tx, ty, tz : double);
procedure Objeto3DCentra(obj : PTObjeto3D);
procedure tablero3DCentra(obj : PTtablero3D);
procedure Objeto3DEncaja(obj : PTObjeto3D; distmax : double);
procedure tablero3DEncaja(obj : PTtablero3D; distmax : double);
procedure Objeto3DCalcula2D(obj : PTObjeto3D);
procedure tablero3DCalcula2D(obj : PTtablero3D);
procedure Objeto3DCalculaNormales(obj : PTObjeto3D);
procedure Tablero3DCalculaNormales(obj : PTtablero3D);
procedure tablero3DDibujaVertices(obj : PTtablero3D; color : byte; where : word);
procedure Objeto3DDibujaMalla(obj : PTObjeto3D; color : byte; where : word);
procedure Objeto3DDibujaSombreadoPlano(obj : PTObjeto3D; where : word);

implementation

uses Mode13;


{ Procedimiento QuickSort para ordenar un arreglo de caras }
procedure QuickSort(a : PTCaraArray; inicio, final : integer);
var izq, der, pos : integer;
    temp : PTCara;
    flag : boolean;
begin
     izq := inicio;
     der := final;
     pos := inicio;
     flag := true;
     while flag do
     begin
          flag := false;
          while (a^[pos]^.Z <= a^[der]^.Z) and (pos <> der) do dec(der);
          if pos <> der then
          begin
               temp := a^[pos]; a^[pos] := a^[der]; a^[der] := temp;
               pos := der;
               while (a^[pos]^.Z >= a^[izq]^.Z) and (pos <> izq) do inc(izq);
               if pos <> izq then
               begin
                    flag := true;
                    temp := a^[pos]; a^[pos] := a^[izq]; a^[izq] := temp;
                    pos := izq;
               end;
          end;
     end;
     if (pos - 1) > inicio then QuickSort(a, inicio, pos - 1);
     if final > (pos + 1) then QuickSort(a, pos + 1, final);
end;



{ Procedimientos de las caras }

{ Este procedimiento resetea las variables principales de una cara }
procedure CaraReinicia(var cara : TCara);
begin
     cara.NVertices := 0;
end;

{ Este procedimiento a¤ade un v‚rtice (su ¡ndice) a una cara }
{ Los v‚rtices se deben a¤adir en el sentido OPUESTO a las agujas del reloj.}
procedure CaraAgregaVertice(var cara : TCara; vertice : integer);
begin
     { Primero comprobamos si podemos a¤adir otro v‚rtice }
     if cara.NVertices = MaxVerticesCara then exit;
     { Si es as¡, lo a¤adimos }
     inc(cara.NVertices);
     cara.Vertice[cara.NVertices] := vertice;
end;


{ Funcion para detectar si una cara es visible o no:
  Comprobamos si el vector normal al plano de la cara est  dirigido
  hacia el observador (normal.z >= 0), despu‚s de hacer la proyecci¢n a 2D }

function CaraVisible(cara : TCara; objeto : PTObjeto3D) : boolean;
var ax, ay, bx, by : integer;
begin
     if cara.NVertices < 3 then exit;
     ax := objeto^.Vertice[cara.Vertice[1]].x2d -
           objeto^.Vertice[cara.Vertice[2]].x2d;
     ay := objeto^.Vertice[cara.Vertice[1]].y2d -
           objeto^.Vertice[cara.Vertice[2]].y2d;
     bx := objeto^.Vertice[cara.Vertice[3]].x2d -
           objeto^.Vertice[cara.Vertice[2]].x2d;
     by := objeto^.Vertice[cara.Vertice[3]].y2d -
           objeto^.Vertice[cara.Vertice[2]].y2d;
     CaraVisible := (bx * ay) > (by * ax);
end;


procedure CaraDibuja(obj : PTObjeto3D; cara : TCara; where : word);
var Xmin, Xmax : array[0..199] of integer;
    i, x1, y1, x2, y2 : integer;
    Ymin, Ymax, y : integer;

    procedure ScanSide(x1, y1, x2, y2 : integer);
    var y, ydiv, temp : integer;
        x, xinc : double;
    begin
         if y1 > y2 then
         begin
              { nos aseguramos de que (x1, y1) sea el punto SUPERIOR
                y (x2, y2) sea el punto INFERIOR }
              temp := y1; y1 := y2; y2 := temp;
              temp := x1; x1 := x2; x2 := temp;
         end;
         ydiv := y2 - y1;
         if ydiv = 0 then exit;
         xinc := (x2 - x1) / ydiv;
         x := x1;
         for y := y1 to y2 do
         begin
              if trunc(x) < Xmin[y] then Xmin[y] := trunc(x);
              if round(x) > Xmax[y] then Xmax[y] := round(x);
              x := x + xinc;
         end;
    end;

begin
     { Lo primero es obtener las coordenadas Y m xima y m¡nima del
       pol¡gono }
     Ymin := 32000;
     Ymax := -32000;
     for i := 1 to cara.NVertices do
     begin
          y := obj^.Vertice[cara.Vertice[i]].y2d;
          if y < Ymin then Ymin := y;
          if y > Ymax then Ymax := y;
     end;

     { Si el pol¡gono tiene altura igual a cero, entonces no lo dibujamos }
     if (Ymax - Ymin) = 0 then exit;

     for i := 0 to 199 do       { Inicializamos Xmin y Xmax }
     begin
          Xmin[i] := 32000;
          Xmax[i] := -32000;
     end;

     { Obtenemos las coordenadas del primer v‚rtice }
     x1 := obj^.Vertice[cara.Vertice[1]].x2d;
     y1 := obj^.Vertice[cara.Vertice[1]].y2d;

     { y hacemos un ciclo para dibujar todas las aristas }
     for i := 2 to cara.NVertices do
     begin
          { Obtenemos las coordenadas del siguiente v‚rtice }
          x2 := obj^.Vertice[cara.Vertice[i]].x2d;
          y2 := obj^.Vertice[cara.Vertice[i]].y2d;
          { "Escaneamos" el lado (x1, y1)-(x2, y2) }
          ScanSide(x1, y1, x2, y2);
          { y continuamos con el siguiente lado }
          x1 := x2;
          y1 := y2;
     end;

     { Obtenemos nuevamente las coordenadas del primer v‚rtice para
       escanear la l¡nea entre el primero y el £ltimo v‚rtices }
     x2 := obj^.Vertice[cara.Vertice[1]].x2d;
     y2 := obj^.Vertice[cara.Vertice[1]].y2d;
     ScanSide(x1, y1, x2, y2);

     { En este momento, ya tenemos la informaci¢n necesaria almacenada
       en Xmin y Xmax. Ahora procedemos a dibujar el pol¡gono }
     for i := Ymin to Ymax do
         HLine(Xmin[i], Xmax[i], i, cara.color, where);
end;


{ Procedimiento que calcula la profundidad (Z) de cara cara   }
{ simplemente sumando las coordenadas Z de todos sus v‚rtices }
procedure CaraCalculaZ(var cara : TCara; obj : PTObjeto3D);
var i : integer;
begin
     with cara do
     begin
          Z := 0;
          for i := 1 to NVertices do Z := Z + obj^.Vertice[Vertice[i]].z;
     end;
end;


{ Procedimientos de los objetos 3D }

{ Este procedimiento reinicia las variables importantes de un objeto 3D }
procedure Objeto3DReinicia(obj : PTObjeto3D);
begin
     obj^.NVertices := 0;
     obj^.NCaras := 0;
     obj^.ox := 0;
     obj^.oy := 0;
     obj^.oz := 0;
end;

procedure Tablero3DReinicia(obj : PTtablero3D);
begin
     obj^.NVertices := 0;
     obj^.NCaras := 0;
     obj^.ox := 0;
     obj^.oy := 0;
     obj^.oz := 0;
end;

{ Este procedimiento agrega un v‚rtice al objeto tridimensional }
{ (no importa el orden, pero hay que recordar el ¡ndice de cada v‚rtice
   a la hora de especificar los pol¡gonos) }
procedure Objeto3DAgregaVertice(obj : PTObjeto3D; nx, ny, nz : double);
begin
     { Comprobamos si se le puede a¤adir otro v‚rtice al objeto }
     if obj^.NVertices = MaxVertices then exit;
     { Si se puede, lo agregamos }
     inc(obj^.NVertices);
     obj^.Vertice[obj^.NVertices].x := nx;
     obj^.Vertice[obj^.NVertices].y := ny;
     obj^.Vertice[obj^.NVertices].z := nz;
end;


{ Este procedimiento a¤ade una cara (o pol¡gono) al objeto }
procedure Objeto3DAgregaCara(obj : PTObjeto3D; cara : TCara);
begin
     { Comprobamos que se pueda a¤adir otra cara }
     if obj^.NCaras = MaxCaras then exit;
     { Si es as¡, la a¤adimos }
     inc(obj^.NCaras);
     obj^.Cara[obj^.NCaras] := cara;
end;

procedure Tablero3DAgregaVertice(obj : PTtablero3D; nx, ny, nz : double);
begin
     if obj^.NVertices = 81 then exit;
     inc(obj^.NVertices);
     obj^.Vertice[obj^.NVertices].x := nx;
     obj^.Vertice[obj^.NVertices].y := ny;
     obj^.Vertice[obj^.NVertices].z := nz;
end;

{ Este procedimiento rota un objeto mediante la rotaci¢n de sus v‚rtices }
procedure Objeto3DRota(obj : PTObjeto3D; ax, ay, az : integer);
var i : integer;
begin
     { Simplemente rotamos todos los v‚rtices }
     for i := 1 to obj^.NVertices do
         VerticeRota(obj^.Vertice[i], ax, ay, az);

     { Y todas las normales }
     for i := 1 to obj^.NCaras do
         VerticeRota(obj^.Cara[i].normal, ax, ay, az);
end;

procedure Tablero3DRota(obj : PTtablero3D; ax, ay, az : integer);
var i : integer;
begin
     { Simplemente rotamos todos los v‚rtices }
     for i := 1 to obj^.NVertices do
         VerticeRota(obj^.Vertice[i], ax, ay, az);

     { Y todas las normales }
     for i := 1 to obj^.NCaras do
         VerticeRota(obj^.Cara[i].normal, ax, ay, az);
end;


{ Este procedimiento mueve el origen del objeto (y por lo tanto, el objeto)
  al punto (nx, ny, nz) con respecto al centro de la pantalla }
procedure Objeto3DMueve(obj : PTObjeto3D; nx, ny, nz : double);
begin
     obj^.ox := nx;
     obj^.oy := ny;
     obj^.oz := nz;
end;

procedure Tablero3DMueve(obj : PTTablero3D; nx, ny, nz : double);
begin
     obj^.ox := nx;
     obj^.oy := ny;
     obj^.oz := nz;
end;

{ Procedimiento que escala un objeto }
procedure Objeto3DEscala(obj : PTobjeto3D; sx, sy, sz : double);
var i : integer;
begin
     with obj^ do
          for i := 1 to NVertices do
          begin
               Vertice[i].x := Vertice[i].x * sx;
               Vertice[i].y := Vertice[i].y * sy;
               Vertice[i].z := Vertice[i].z * sz;
          end;
end;

procedure Tablero3DEscala(obj : PTTablero3D; sx, sy, sz : double);
var i : integer;
begin
     with obj^ do
          for i := 1 to NVertices do
          begin
               Vertice[i].x := Vertice[i].x * sx;
               Vertice[i].y := Vertice[i].y * sy;
               Vertice[i].z := Vertice[i].z * sz;
          end;
end;

{ Este procedimiento traslada el objeto }
procedure Objeto3DTraslada(obj : PTObjeto3D; tx, ty, tz : double);
var i : integer;
begin
     with obj^ do
          for i := 1 to NVertices do
          begin
               Vertice[i].x := Vertice[i].x + tx;
               Vertice[i].y := Vertice[i].y + ty;
               Vertice[i].z := Vertice[i].z + tz;
          end;
end;

procedure Tablero3DTraslada(obj : PTTablero3D; tx, ty, tz : double);
var i : integer;
begin
     with obj^ do
          for i := 1 to NVertices do
          begin
               Vertice[i].x := Vertice[i].x + tx;
               Vertice[i].y := Vertice[i].y + ty;
               Vertice[i].z := Vertice[i].z + tz;
          end;
end;

{ Este procedimiento centra el objeto con respecto al origen }
procedure Objeto3DCentra(obj : PTObjeto3D);
var i : integer;
    tx, ty, tz : double;
begin
     tx := 0;
     ty := 0;
     tz := 0;
     with obj^ do
     begin
          for i := 1 to NVertices do
          begin
               tx := tx + Vertice[i].x;
               ty := ty + Vertice[i].y;
               tz := tz + Vertice[i].z;
          end;
          tx := tx / NVertices;
          ty := ty / NVertices;
          tz := tz / NVertices;
     end;
     Objeto3DTraslada(obj, -tx, -ty, -tz);
end;
procedure Tablero3DCentra(obj : PTtablero3D);
var i : integer;
    tx, ty, tz : double;
begin
     tx := 0;
     ty := 0;
     tz := 0;
     with obj^ do
     begin
          for i := 1 to NVertices do
          begin
               tx := tx + Vertice[i].x;
               ty := ty + Vertice[i].y;
               tz := tz + Vertice[i].z;
          end;
          tx := tx / NVertices;
          ty := ty / NVertices;
          tz := tz / NVertices;
     end;
     tablero3DTraslada(obj, -tx, -ty, -tz);
end;


{ Hace que el objeto quepa en un cubo de lado espec¡fico }
procedure Objeto3DEncaja(obj : PTObjeto3D; distmax : double);
var i : integer;
    dist, max, escala : double;
begin
     max := 0;
     with obj^ do
          for i := 1 to NVertices do
          begin
               dist := sqrt( Vertice[i].x * Vertice[i].x +
                             Vertice[i].y * Vertice[i].y +
                             Vertice[i].z * Vertice[i].z);
               if dist > max then max := dist;
          end;
     escala := distmax / max;
     Objeto3DEscala(obj, escala, escala, escala);
end;
procedure Tablero3DEncaja(obj : PTtablero3D; distmax : double);
var i : integer;
    dist, max, escala : double;
begin
     max := 0;
     with obj^ do
          for i := 1 to NVertices do
          begin
               dist := sqrt( Vertice[i].x * Vertice[i].x +
                             Vertice[i].y * Vertice[i].y +
                             Vertice[i].z * Vertice[i].z);
               if dist > max then max := dist;
          end;
     escala := distmax / max;
     Tablero3DEscala(obj, escala, escala, escala);
end;

{ Este procedimiento calcula la proyecci¢n bidimensional de sus v‚rtices
  y los traslada respecto al origen del objeto }
procedure Objeto3DCalcula2D(obj : PTObjeto3D);
var i : integer;
begin
     { Calcula la proyecci¢n 2D de cada v‚rtice y lo desplaza con respecto
       al origen del objeto }
     with obj^ do
          for i := 1 to NVertices do
              VerticeCalcula2D(Vertice[i], ox, oy, oz);
end;

procedure tablero3DCalcula2D(obj : PTtablero3D);
var i : integer;
begin
     { Calcula la proyecci¢n 2D de cada v‚rtice y lo desplaza con respecto
       al origen del objeto }
     with obj^ do
          for i := 1 to NVertices do
              VerticeCalcula2D(Vertice[i], ox, oy, oz);
end;


{ Solo es necesario llamar una vez a este procedimiento }
procedure Objeto3DCalculaNormales(obj : PTObjeto3D);
var ax, ay, az, bx, by, bz, nx, ny, nz, mag : double;
    i : integer;
begin
     with obj^ do
     for i := 1 to NCaras do
     begin
       { Calculamos los dos vectores en el plano de la cara (A y B) }
       ax := Vertice[Cara[i].Vertice[1]].x - Vertice[Cara[i].Vertice[2]].x;
       ay := Vertice[Cara[i].Vertice[1]].y - Vertice[Cara[i].Vertice[2]].y;
       az := Vertice[Cara[i].Vertice[1]].z - Vertice[Cara[i].Vertice[2]].z;
       bx := Vertice[Cara[i].Vertice[3]].x - Vertice[Cara[i].Vertice[2]].x;
       by := Vertice[Cara[i].Vertice[3]].y - Vertice[Cara[i].Vertice[2]].y;
       bz := Vertice[Cara[i].Vertice[3]].z - Vertice[Cara[i].Vertice[2]].z;

       { Obtenemos el producto cruz de A x B }
       Cara[i].normal.x := by * az - ay * bz;
       Cara[i].normal.y := ax * bz - bx * az;
       Cara[i].normal.z := bx * ay - by * ax;

       { Normalizamos el vector perpendicular (A x B) }
       VerticeNormaliza(Cara[i].normal);
     end;
end;

procedure tablero3DCalculaNormales(obj : PTtablero3D);
var ax, ay, az, bx, by, bz, nx, ny, nz, mag : double;
    i : integer;
begin
     with obj^ do
     for i := 1 to NCaras do
     begin
       { Calculamos los dos vectores en el plano de la cara (A y B) }
       ax := Vertice[Cara[i].Vertice[1]].x - Vertice[Cara[i].Vertice[2]].x;
       ay := Vertice[Cara[i].Vertice[1]].y - Vertice[Cara[i].Vertice[2]].y;
       az := Vertice[Cara[i].Vertice[1]].z - Vertice[Cara[i].Vertice[2]].z;
       bx := Vertice[Cara[i].Vertice[3]].x - Vertice[Cara[i].Vertice[2]].x;
       by := Vertice[Cara[i].Vertice[3]].y - Vertice[Cara[i].Vertice[2]].y;
       bz := Vertice[Cara[i].Vertice[3]].z - Vertice[Cara[i].Vertice[2]].z;

       { Obtenemos el producto cruz de A x B }
       Cara[i].normal.x := by * az - ay * bz;
       Cara[i].normal.y := ax * bz - bx * az;
       Cara[i].normal.z := bx * ay - by * ax;

       { Normalizamos el vector perpendicular (A x B) }
       VerticeNormaliza(Cara[i].normal);
     end;
end;



{ Procedimientos para dibujar objetos 3D }

{ Este procedimiento simplemente dibuja un punto en cada v‚rtice del objeto }

procedure Tablero3DDibujaVertices(obj : PTtablero3D; color : byte; where : word);
var i : integer;
begin
     Tablero3DCalcula2D(obj); { Primero calculamos la proyecci¢n en 2D }
     for i := 1 to obj^.NVertices do
         PutPixel(obj^.Vertice[i].x2d, obj^.Vertice[i].y2d, color, where);
end;


{ Este procedimiento dibuja un "modelo de alambre" del objeto, es decir,
  dibuja £nicamente las aristas }
procedure Objeto3DDibujaMalla(obj : PTObjeto3D; color : byte; where : word);
var x1, y1, x2, y2 : integer;
    i, j : integer;
begin
     Objeto3DCalcula2D(obj);  { Calculamos la proyecci¢n en 2D }
     for j := 1 to obj^.NCaras do { Dibujamos todas las caras }
     begin
          if CaraVisible(obj^.cara[j], obj) then
          begin
               { Obtenemos las coordenadas del primer v‚rtice }
               x1 := obj^.Vertice[obj^.Cara[j].Vertice[1]].x2d;
               y1 := obj^.Vertice[obj^.Cara[j].Vertice[1]].y2d;

               { y hacemos un ciclo para dibujar todas las aristas }
               for i := 2 to obj^.cara[j].NVertices do
               begin
                    { Obtenemos las coordenadas del siguiente v‚rtice }
                    x2 := obj^.Vertice[obj^.Cara[j].Vertice[i]].x2d;
                    y2 := obj^.Vertice[obj^.Cara[j].Vertice[i]].y2d;
                    { Dibujamos una l¡nea entre los dos v‚rtices }
                    Line(x1, y1, x2, y2, color, where);
                    x1 := x2;
                    y1 := y2;
               end;

               { Obtenemos nuevamente las coordenadas del primer v‚rtice para
                  dibujar una l¡nea entre el primero y el £ltimo v‚rtices }
               x2 := obj^.Vertice[obj^.Cara[j].Vertice[1]].x2d;
               y2 := obj^.Vertice[obj^.Cara[j].Vertice[1]].y2d;
               Line(x1, y1, x2, y2, color, where);
          end;
     end;
end;


{ Procedimiento que dibuja un objeto usando sombreado plano }
procedure Objeto3DDibujaSombreadoPlano(obj : PTObjeto3D; where : word);
var i, j : integer;
    cosang : double;
    a : TCaraArray;
begin
     Objeto3DCalcula2D(obj);    { calcula la proyecci¢n a 2D del objeto }
     j := 1;
     { Generamos un arreglo de apuntadores a caras, incluyendo £nicamente }
     { aquellas caras que son visibles                                    }
     for i := 1 to obj^.NCaras do
         if CaraVisible(obj^.cara[i], obj) then
         begin
              CaraCalculaZ(obj^.cara[i], obj);
              a[j] := addr(obj^.cara[i]);
              inc(j);
         end;
     { Ordenamos el arreglo }
     QuickSort(addr(a), 1, j - 1);
     { Y dibujamos las caras }
     for i := 1 to (j - 1) do
     begin
          with a[i]^ do
          begin
               cosang := normal.x * FuenteLuz.x +
                         normal.y * FuenteLuz.y +
                         normal.z * FuenteLuz.z;
               color := trunc((cosang + 1.0) * rango / 2.0) + a[i]^.coloro;
          end;
          CaraDibuja(obj, a[i]^, where);
     end;
end;


end.

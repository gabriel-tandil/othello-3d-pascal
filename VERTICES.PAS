{ Unidad VERTICES.PAS }

unit Vertices;

interface

{ tablas trigonom‚tricas }
var Seno, Coseno : array[0..359] of double;  { Tablas trigonom‚tricas }

procedure GeneraTablas;


{ Tipo V‚rtice }
type TVertice = record
                x, y, z : double;  { Coordenadas del v‚rtice }
                x2d, y2d : integer; { Coordenadas de la proyecci¢n en 2D }
                end;


procedure VerticeCalcula2D(var v : TVertice; cx, cy, cz : double);
procedure VerticeRota(var v : TVertice; ax, ay, az : integer);
procedure VerticeNormaliza(var v : TVertice);
procedure VerticeEscala(var v : TVertice; sx, sy, sz : double);


implementation


{ El siguiente procedimiento genera las tablas trigonom‚tricas }
procedure GeneraTablas;
var a : integer;
begin
     for a := 0 to 359 do
     begin
          Seno[a] := sin(a * Pi / 180.0);
          Coseno[a] := cos(a * Pi / 180.0);
     end;
end;

{ Procedimientos de los v‚rtices }

{ Este procedimiento calcula la proyecci¢n a 2D de un v‚rtice }
procedure VerticeCalcula2D(var v : TVertice; cx, cy, cz : double);
var h,p : double;
begin
     { Zdist es la coordenada Z del origen del objeto tridimensional }
     h := 00.0;
     p:=1024.0;
     v.x2d := round((((v.x+cx)*p)/(p-cz-v.z))/2) + 160;
     v.y2d := round((((v.y+cy-h)*p)/((p-cz-v.z)+h))/2) + 100 ;

end;

{ Este procedimiento rota un v‚rtice sobre cualquier eje }
procedure VerticeRota(var v : TVertice; ax, ay, az : integer);
var nx, ny, nz : double;
begin
     { Aseguramos que los  ngulos sean positivos (entre 0 y 359) }
     if ax < 0 then inc(ax, 360);
     if ay < 0 then inc(ay, 360);
     if az < 0 then inc(az, 360);

     { Rotaci¢n sobre el eje X }
     if ax <> 0 then
     begin
          ny := v.y * Coseno[ax] - v.z * Seno[ax];
          nz := v.y * Seno[ax] + v.z * Coseno[ax];
          v.y := ny;
          v.z := nz;
     end;

     { Rotaci¢n sobre el eje Y }
     if ay <> 0 then
     begin
          nx := v.x * Coseno[ay] - v.z * Seno[ay];
          nz := v.x * Seno[ay] + v.z * Coseno[ay];
          v.x := nx;
          v.z := nz;
     end;

     { Rotaci¢n sobre el eje Z }
     if az <> 0 then
     begin
          nx := v.x * Coseno[az] - v.y * Seno[az];
          ny := v.x * Seno[az] + v.y * Coseno[az];
          v.x := nx;
          v.y := ny;
     end;
end;

{ Este procedimiento normaliza un vector }
procedure VerticeNormaliza(var v : TVertice);
var mag : double; { magnitud }
begin
     mag := sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
     if mag = 0.0 then exit;
     mag := 1.0 / mag;   { obtenemos el inverso de la magnitud }
     v.x := v.x * mag;   { porque es m s r pido multiplicar    }
     v.y := v.y * mag;   { que dividir                         }
     v.z := v.z * mag;
end;

{ Procedimiento que escala un vector }
procedure VerticeEscala(var v : TVertice; sx, sy, sz : double);
begin
     v.x := v.x * sx;
     v.y := v.y * sy;
     v.z := v.z * sz;
end;

begin
     GeneraTablas;  { Inicializaci¢n }

end.
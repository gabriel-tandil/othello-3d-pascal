{$M 65520, 0, 655360}  {hacemos una pila mas grande}

program otelo3D;

uses Vertices, Objeto3D, Mode13, Crt, mouse;

type
pficha=array [1..64] of PTObjeto3D;
posicion=record
           pieza:char; {la X o O}
           numero:byte;{la correspondencia con la ficha de 3d}
         end;
ttablero=array [1..8,1..8] of posicion;

{variables globales}
var  {nota: algunas variables se han definido globales a riesgo de perjudicar
 la estructuracion del programa por la escaza memoria que puede manejer este
 pascal}

 ficha:^pficha;   { Objeto tridimensional }
 flecha:ptobjeto3d; {flecha es el cursor del mouse}
 tablero:pttablero3d;  {este es el tablero de 3 dimensiones}

 azul,colorado,fichas:byte;  {cantidad de fichas}

 haymouse:boolean;

const
  colordex=128;
  colordeo=0;
  lado=10;

{-------------------------------------------------------------}

{este procedimiento dibuja la fuente de luz}
procedure DibujaLuz(where : word);
var i, cx, cy, radio : integer;
    p : double;
    luz : TVertice;
begin
     luz := FuenteLuz;  { obtiene la posicion de la fuente de luz }
     verticeEscala(Luz, 250, 250, 500); { la alejamos del centro }
     verticeCalcula2D(Luz, 0, 0, 0);
     p := 512.0 / (1024.0 - luz.z); { para darle cierta perspectiva... }
     for i := 0 to 7 do
     begin
          if odd(i) then radio := 5 else radio := 8;
          cx := round(Coseno[i * 45] * radio * p) + Luz.x2d;
          cy := round(Seno[i * 45] * radio * p) + Luz.y2d;
          Line(Luz.x2d, Luz.y2d, cx, cy, 255, where);
     end;
end;

{-------------------------------------------------------------------}

procedure creaflecha;     {los procedimientos que siguen son de creacion}
var                       {de objetos tridimensionales}
  cara:tcara;
begin
  new(flecha);
  Objeto3DReinicia(flecha);
  objeto3dagregavertice(flecha, 0, lado, 0);
  objeto3dagregavertice(flecha, -lado, -lado, lado);
  objeto3dagregavertice(flecha, lado, -lado, lado);
  objeto3dagregavertice(flecha, lado, -lado, -lado);
  objeto3dagregavertice(flecha, -lado, -lado, -lado);
  carareinicia(cara);
  caraagregavertice(cara, 1);
  caraagregavertice(cara, 2);
  caraagregavertice(cara, 3);
  Objeto3DAgregaCara(flecha, cara);
  carareinicia(cara);
  caraagregavertice(cara, 1);
  caraagregavertice(cara, 3);
  caraagregavertice(cara, 4);
  Objeto3DAgregaCara(flecha, cara);
  carareinicia(cara);
  caraagregavertice(cara, 1);
  caraagregavertice(cara, 4);
  caraagregavertice(cara, 5);
  Objeto3DAgregaCara(flecha, cara);
  carareinicia(cara);
  caraagregavertice(cara, 1);
  caraagregavertice(cara, 5);
  caraagregavertice(cara, 2);
  Objeto3DAgregaCara(flecha, cara);
  carareinicia(cara);
  caraagregavertice(cara, 5);
  caraagregavertice(cara, 4);
  caraagregavertice(cara, 3);
  caraagregavertice(cara, 2);
  Objeto3DAgregaCara(flecha, cara);

  Objeto3DCentra(flecha);
  Objeto3DEncaja(flecha, 19);
  Objeto3dcalculanormales(flecha);
end;


procedure creafichas(i:byte;colora:char);
var
  cara:tcara;
  color:byte;
begin
    if colora='X' then color:=colordex else color:=colordeo;

    ficha^[i] := new(PTObjeto3D);
    Objeto3DReinicia(ficha^[i]);
    objeto3dagregavertice(ficha^[i], -lado, lado, lado);
    objeto3dagregavertice(ficha^[i], lado, lado, lado);
    objeto3dagregavertice(ficha^[i], -lado, lado, -lado);
    objeto3dagregavertice(ficha^[i], lado, lado, -lado);
    objeto3dagregavertice(ficha^[i], -lado, -lado, -lado);
    objeto3dagregavertice(ficha^[i], lado, -lado, -lado);
    objeto3dagregavertice(ficha^[i], -lado, -lado, lado);
    objeto3dagregavertice(ficha^[i], lado, -lado, lado);
    {agregamos las 6 caras, construy‚ndolas una por una }
    carareinicia(cara);
    caraagregavertice(cara, 2);
    caraagregavertice(cara, 1);
    caraagregavertice(cara, 7);
    caraagregavertice(cara, 8);
    cara.coloro:=color;
    Objeto3DAgregaCara(ficha^[i], cara);
    carareinicia(cara);
    caraagregavertice(cara, 2);
    caraagregavertice(cara, 8);
    caraagregavertice(cara, 6);
    caraagregavertice(cara, 4);
    cara.coloro:=color;
    Objeto3DAgregaCara(ficha^[i], cara);
    carareinicia(cara);
    caraagregavertice(cara, 4);
    caraagregavertice(cara, 6);
    caraagregavertice(cara, 5);
    caraagregavertice(cara, 3);
    cara.coloro:=color;
    Objeto3DAgregaCara(ficha^[i], cara);
    carareinicia(cara);
    caraagregavertice(cara, 3);
    caraagregavertice(cara, 5);
    caraagregavertice(cara, 7);
    caraagregavertice(cara, 1);
    cara.coloro:=color;
    Objeto3DAgregaCara(ficha^[i], cara);
    carareinicia(cara);
    caraagregavertice(cara, 1);
    caraagregavertice(cara, 2);
    caraagregavertice(cara, 4);
    caraagregavertice(cara, 3);
    cara.coloro:=color;
    Objeto3DAgregaCara(ficha^[i], cara);
    carareinicia(cara);
    caraagregavertice(cara, 6);
    caraagregavertice(cara, 8);
    caraagregavertice(cara, 7);
    caraagregavertice(cara, 5);
    cara.coloro:=color;
    Objeto3DAgregaCara(ficha^[i], cara);
    Objeto3DCentra(ficha^[i]);
    objeto3dcalculanormales(ficha^[i]);

    Objeto3DEncaja(ficha^[i], (sqrt(sqr(flecha^.vertice[1].x-flecha^.vertice[2].x)
      +sqr(flecha^.vertice[1].y-flecha^.vertice[2].y)+
      sqr(flecha^.vertice[1].z-flecha^.vertice[2].z)))*0.75);
end;

procedure dibujatablero;
var
i,ii:byte;
begin
  Tablero3DReinicia(tablero);
  for i:= 0 to 8 do
    for ii:= 0 to 8 do
      tablero3DAgregaVertice(tablero,(ii*10),(i*10),0);

  tablero3DEncaja(tablero, 720);
  tablero3DRota(tablero, 60, 0, 0);
  tablero3DCentra(tablero);
end;


{-----------------------------------------------------------------------}

Procedure Cambios(x1,y1,x2,y2:integer;jugador:char;var mtablero:ttablero); {este procedimiento cambia las fichas}
Var                                     {en el tablero matriz}
  tmp,Posx,Posy:integer;
begin
    if (x1=x2) or (y1=y2) then
    begin
      if x2<x1 then
      begin
        tmp:=x1; x1:=x2; x2:=tmp;
      end;
      if y2<y1 then
      begin
        tmp:=y1; y1:=y2; y2:=tmp;
      end;
      posx:=x1; posy:=y1;

      if x1=x2 then
        for posy:=y1 to y2 do
          Mtablero[x1,posy].pieza:=jugador;

      if y1=y2 then
        for posx:=x1 to x2 do
          Mtablero[posx,y1].pieza:=jugador;
    end;


    if (x1<x2) and (y1<y2) then
      for posx:=x1 to x2 do
        Mtablero[posx,(y1+(posx-x1))].pieza:=jugador;
    if (x1<x2) and (y1>y2) then
      for posx:=x1 to x2 do
        Mtablero[posx,(y1-(posx-x1))].pieza:=jugador;
    if (x1>x2) and (y1<y2) then
      for posx:=x1 downto x2 do
        Mtablero[posx,(y1-(posx-x1))].pieza:=jugador;
    if (x1>x2) and (y1>y2) then
      for posx:=x1 downto x2 do
        Mtablero[posx,(y1+(posx-x1))].pieza:=jugador;

end;

Procedure Poscambios(x,y:integer;jugador:char;var mtablero:ttablero);  {aca se revisa si hay que cambiar fichas}

var
  InicX:integer;
  InicY:integer;
  Pos:integer;
  PosX:integer;
  PosY:integer;
begin
      inicy:=y;
      InicX:=x;

      while((MTablero [x+1,y].pieza <> jugador) and (x < 7) and (Mtablero[x+1,y].pieza<>' ')) do
           x:=x+1;


      if (MTablero [x+1,y].pieza=jugador) then
      cambios(inicx,inicy,x,inicy,jugador,mtablero);

      x:=inicx;

      while((MTablero [x-1,y].pieza <> jugador) and (x > 2) and (Mtablero[x-1,y].pieza<>' ')) do
           x:=x-1;


      if (MTablero [x-1,y].pieza=jugador) then
      cambios(inicx,inicy,x,inicy,jugador,mtablero);

      x:=inicx;

      while((MTablero [x,y+1].pieza <> jugador) and (Y < 7) and (MTablero[x,y+1].pieza<>' ')) do
           Y:=Y+1;


      if (MTablero [x,y+1].pieza=jugador) then
      cambios(inicx,inicy,Inicx,y,jugador,mtablero);

      y:=inicy;

      while((MTablero [x,y-1].pieza <> jugador) and (y > 2) and (MTablero[x,y-1].pieza<>' ')) do
           y:=y-1;


      If (MTablero [x,y-1].pieza=jugador) then
      cambios(inicx,inicy,Inicx,y,jugador,mtablero);

      y:=inicy;

      while((MTablero [x+1,y+1].pieza <> jugador) and (x < 7) and (y <7) and (MTablero[x+1,y+1].pieza<>' ')) do
           begin
                x:=x+1;
                y:=Y+1;
           end;

      if (MTablero [x+1,y+1].pieza=jugador) then
      cambios(inicx,inicy,x,y,jugador,mtablero);

      y:=inicy;
      x:=inicx;

      while((MTablero [x-1,y-1].pieza <> jugador) and (x > 2) and (y >2) and (MTablero[x-1,y-1].pieza<>' ')) do
           begin
                x:=x-1;
                y:=Y-1;
           end;

      if (MTablero [x-1,y-1].pieza=jugador) then
         cambios(inicx,inicy,x,y,jugador,mtablero);

      x:=inicx;
      y:=inicy;

      while((MTablero [x+1,y-1].pieza <> jugador) and (x < 7) and (y >2) and (MTablero[x+1,y-1].pieza<>' ')) do
           begin
                x:=x+1;
                y:=Y-1;
           end;

      if (MTablero [x+1,y-1].pieza=jugador) then
         cambios(inicx,inicy,x,y,jugador,mtablero);

      x:=inicx;
      y:=inicy;

      while((MTablero [x-1,y+1].pieza <> jugador) and (x > 2) and (y <7) and (MTablero[x-1,y+1].pieza<>' ')) do
           begin
                x:=x-1;
                y:=Y+1;
           end;

      if (MTablero [x-1,y+1].pieza=jugador )then
        cambios(inicx,inicy,x,y,jugador,mtablero);

      x:=inicx;
      y:=inicy;
end;


Function Posvalida (x,y:integer; var mtablero:ttablero):boolean;  {esta funcion devuelve verdadero}
                             {si la posicion del tablero matriz esta vacia}
begin
       if (mtablero[x,y].pieza = ' ') then
         Posvalida:=true
       else
        posvalida:=false;
end;


{-----------------------------------------------------------------}

function mejorposicion(jugador:char;mtablero:ttablero;flag:byte):integer;
var        {notar que la funcion debuelve un byte, la unidad es la Y y la
            decena es la X  }
  cantidadcontrario,aux,cantidaddepiezas,mejorlugar,i,ii,iii,iv:byte;
  tablero_de_pruevas:ttablero;
  contrario:char;

begin
  cantidadcontrario:=64;
  cantidaddepiezas:=0;
  if jugador='O' then contrario:='X' else contrario:='O';
  for i:=1 to 8 do
    for ii:=1 to 8 do
    begin

     { copia el tablero-----------------------}
      for iii:=1 to 8 do
        for iv:=1 to 8 do
          tablero_de_pruevas[iii,iv].pieza:=mtablero[iii,iv].pieza;
     {----------------------------------------}

      if posvalida(i,ii,tablero_de_pruevas) then
      begin
        poscambios(i,ii,jugador,tablero_de_pruevas);
        tablero_de_pruevas[i,ii].pieza:=jugador;

     { veo si es mejor esa posicion-----------}
        aux:=0;
        for iii:=1 to 8 do
          for iv:=1 to 8 do
          begin
            if (tablero_de_pruevas[iii,iv].pieza=jugador) and (mtablero[iii,iv].pieza<>jugador) then
              aux:=aux+1;
          end;


        if (aux>cantidaddepiezas) or ((aux=cantidaddepiezas) and
         (flag=1) and ((mejorposicion(contrario,tablero_de_pruevas,0) div 100<cantidadcontrario))) then
        begin
        if flag=1 then cantidadcontrario:=(mejorposicion(contrario,tablero_de_pruevas,0) div 100);
          cantidaddepiezas:=aux;
          if flag=1 then mejorlugar:=10*i+ii else mejorlugar:=100*cantidaddepiezas;
        end;
     {----------------------------------------}

      end;
    end;
    mejorposicion:=mejorlugar;
end;


procedure escalajuego(valor:double);{este procedimiento cambia el tamanio de}
var                                {todos los objetos del juego}
  contador:byte;
begin
  tablero3descala(tablero,valor,valor,valor);

  for contador:=1 to fichas do
    objeto3descala(ficha^[contador],valor,valor,valor);

  objeto3descala(flecha,valor,valor,valor);
end;


procedure mueveficha(num,x,y:byte);  {este procedimiento acomoda las fichas}
var                  {tridimensionales a las coordenadas que se le pasan}
  ax,az:integer;     {como parametro}
begin
  ax:=round((tablero^.vertice[2].x-tablero^.vertice[1].x) / 2);
  az:=round((tablero^.vertice[1].y-tablero^.vertice[10].y) / 2);
  objeto3dmueve(ficha^[num],tablero^.vertice[(y-1)*9+x].x+ax,tablero^.vertice[(y-1)*9+x].y-az,tablero^.vertice[(y-1)*9+x].z);
end;


procedure acomodafichas(mtablero:ttablero);{este procedimiento llama a mueveficha por cada ficha}
var           {del juego para acomodarlas cuando se movio o escalo el tablero}
  i,ii:byte;
begin
  for i:=1 to 8 do
    for ii:=1 to 8 do
      if mtablero[i,ii].numero<>0 then
        mueveficha(mtablero[i,ii].numero,i,ii);

end;


procedure actualizartablero3d(var mtablero:ttablero);  {este procedimiento hace concordar el juego en}
var                   {3 dimensiones con el tablero matriz}
i,ii,iii:byte;

begin
  for i:=1 to 8 do
    for ii:=1 to 8 do
    begin
      if (mtablero[i,ii].pieza<>' ') and (mtablero[i,ii].numero=0) then
      begin
        fichas:=fichas+1;
        mtablero[i,ii].numero:=fichas;
        creafichas(fichas,mtablero[i,ii].pieza);
        mueveficha(fichas,i,ii);
      end
      else
      begin
        if (mtablero[i,ii].pieza='X') and (ficha^[mtablero[i,ii].numero]^.cara[1].coloro<>colordex) then
        begin
          for iii:=1 to 6 do
            ficha^[mtablero[i,ii].numero]^.cara[iii].coloro:=colordex;
        end;
        if (mtablero[i,ii].pieza='O') and (ficha^[mtablero[i,ii].numero]^.cara[1].coloro<>colordeo) then
        begin
          for iii:=1 to 6 do
            ficha^[mtablero[i,ii].numero]^.cara[iii].coloro:=colordeo;
        end;
      end;
    end;
end;


{-------------------------------------------------------------------------}

procedure otelo(contrapc:boolean);
var h,v,i,ii,iii,ax, ay, az, a : integer;  { Angulos de rotaci¢n sobre cada eje }
    key, Fichaact:char; {en esta variable va un O o X depende del jugador actual}
    VirSeg : word;
    VirScr : PTVirtual;  { pantalla virtual }
    MTablero:ttablero; {este es el tablero matriz, aca van O y X y numeros
                                               para sincronizar los tableros}
    wherexant,whereyant:integer;
    indicador:boolean;
    pal:tpalette;
begin
  { Iniciamos las pantallas virtuales y cargamos la imagen de fondo }

  fillchar(pal, 768, 0);  { llena la paleta con ceros (negro)}
  for i := 0 to 63 do
  begin
    pal[i][0] := i;       { del 0 al 63:     rojo }
    pal[i + 64][1] := i;  { del 64 al 127:   verde }
    pal[i + 128][2] := i; { del 128 al 191:  azul }
    pal[i + 192][0] := i; { del 192 al 255:  amarillo }
    pal[i + 192][1] := i;
  end;
  colorinicial := 0;
  rango := 63;
  clearscreen(0,vga);
  setpalette(pal);

  SetupVirtual(VirScr, VirSeg);

  for i:=1 to 8 do
    for ii:=1 to 8 do
    begin
      MTablero[i,ii].pieza:=' ';
      MTablero[i,ii].numero:=0;
    end;

  MTablero[5,4].pieza:='X';
  MTablero[4,5].pieza:='X';
  MTablero[4,4].pieza:='O';
  MTablero[5,5].pieza:='O';

  Fichaact:='X';
  a := 0; { contador usado en la rotaci¢n }
  key := '?';
  h:=4; v:=4;

  actualizartablero3d(mtablero);
  indicador:=false;
  whereyant:=50; wherexant:=50;
  while (key <> #27) and (fichas<64) do  { mientras no se presione ESC... }
  begin                                    {y haya lugares vacios}

   {--------------------------------------------------------------------}

    if haymouse and ((wherex<>wherexant) or (wherey<>whereyant)) then
    begin
      wherexant:=wherex;
      whereyant:=wherey;
      h:=(wherex div 90)+1;   { Leo y convierto la posicion del mouse}
      v:=(wherey div 27)+1;
    end;

    ax:=round((tablero^.vertice[2].x-tablero^.vertice[1].x) / 2);
    az:=round((tablero^.vertice[1].y-tablero^.vertice[10].y) / 2)+20;
    Objeto3DMueve(flecha,tablero^.vertice[(v-1)*9+h].x+ax,tablero^.vertice[(v-1)*9+h].y-az,tablero^.vertice[(v-1
    )*9+h].z);

    objeto3DRota(flecha, 0, 5, 0); { y lo giro }

   {--------------------------------------------------------------------}
    if (haymouse and (leftbutton)) or (key=#13) or (indicador) then         {si apreto el boton del mouse}
    begin
      key:='?';
      if posvalida(h,v,mtablero) or (indicador) then     {vemos si es una posicion valida}
      begin
      if not indicador then
       begin
        sound(500);
        delay(300);
        nosound;
        Poscambios(h,v,fichaact,mtablero);    {y hacemos que se actualize el tablero matriz}
        MTablero[H,V].pieza:=Fichaact;
        actualizartablero3d(mtablero);{luego actualizamnos el tablero de 3d}
       end;
        if Fichaact='O' then
        begin
          Fichaact:='X';
          flecha^.cara[1].coloro:=colordex;
          flecha^.cara[3].coloro:=colordex;
        end
        else
        begin
          if not contrapc then
          begin
            Fichaact:='O';
            flecha^.cara[1].coloro:=colordeo;
            flecha^.cara[3].coloro:=colordeo;
          end
          else
            if indicador then
            begin
              delay(500);
              Fichaact:='O';
              i:=mejorposicion(fichaact,mtablero,1);
              ii:=i div 10;      {desarmo el Byte devuelto por mejorposicion
                                  en dos coordenadas  }
              iii:=i - ii*10;
              Poscambios(ii,iii,fichaact,mtablero);
              MTablero[ii,iii].pieza:=Fichaact;
              Fichaact:='X';
              indicador:=false;
            end
            else
              indicador:=true
        end;
        actualizartablero3d(mtablero);{luego actualizamnos el tablero de 3d}
      end;                                   {y cambiamos de jugador}
    end;
   {--------------------------------------------------------------------}

    clearscreen(0, VirSeg); { borro la pantalla virtual }
    tablero3ddibujavertices(tablero,127,virseg);
    if FuenteLuz.z < 0 then DibujaLuz(VirSeg);
    for i:=1 to 8 do
      for ii:=1 to 8 do     {metodo mejorado de dibujo de fichas en 3d}
                            {se dibujan primero las de atras asi no tapan a
                            {las de adelante}
        if mtablero[ii,i].numero<>0 then
          Objeto3DDibujaSombreadoPlano(ficha^[mtablero[ii,i].numero], VirSeg);

    if FuenteLuz.z >= 0 then DibujaLuz(VirSeg);
    objeto3DDibujaSombreadoPlano(flecha, VirSeg);


    VRetrace;       { espero al retrazado vertical }
    copyscreen(VirSeg, VGA);  { y muestro todo en VGA }

  { Rota las fichas y actualiza los  ngulos de rotacion }
    ax := round(seno[a]);
    ay := round(coseno[a]);
    az := round(-seno[a]);
    if (a < 360) then inc(a) else a := 0;
    for i:=1 to fichas do
    begin
      if ficha^[i]^.cara[1].coloro=colordeo then   {ve de que jugador es la ficha}
                            {para girarla diferente y hacer un lindo efecto}
        Objeto3DRota(ficha^[i], ax*2, -ay*3, az*2)
      else
        Objeto3DRota(ficha^[i], -az*3, ax*2, -ay*3);
    end;

    if keypressed then     { si se presiona una tecla...}
     begin
      key := readkey;   { la leemos }
      case key of       { y la comparamos }
      #0: begin
            key:=readkey;
            case key of
              #80: if v<8 then v:=v+1;
              #72: if v>1 then v:=v-1;
              #77: if h<8 then h:=h+1;
              #75: if h>1 then h:=h-1;
            end;
          end;
      #32: VerticeRota(FuenteLuz, 0, -2, 0);
      '4':
        tablero3drota(tablero,0,0,-1);
      '6':
        tablero3drota(tablero,0,0,1);
      '2':
        tablero3drota(tablero,-1,0,0);
      '8':
        tablero3drota(tablero,1,0,0);
      '3':
        tablero3drota(tablero,0,-1,0);
      '1':
        tablero3drota(tablero,0,1,0);
      '+':
        escalajuego(1.01);
      '-':
        escalajuego(0.99);
      end;
     acomodafichas(mtablero);
    end;

  end;

  delay(1000);

  for i:=1 to 8 do
    for ii:=1 to 8 do
    begin
      if Mtablero[i,ii].pieza='X' then azul:=azul+1;
      if Mtablero[i,ii].pieza='O' then colorado:=colorado+1;
    end;

  {libero la memoria de la pantalla virtual}
  shutdownvirtual(VirScr);
end;

procedure musica;
var
  soun:integer;
begin
 for soun:=(500) to (2000) do
 begin
   sound(soun);
   delay(1);
 end;
 Sound(2000);
 delay(100);
 nosound;
 delay(100);
 Sound(1500);
 delay(100);
 nosound;
 delay(200);
 Sound(1800);
 delay(200);
 nosound;
 delay(200);
 Sound(1600);
 delay(200);
 nosound;
 delay(200);
 Sound(1400);
 delay(200);
 Sound(1500);
 delay(300);
 nosound;
 delay(200);
 sound(3000);
 delay(300);
 nosound;
 delay(100);
 for soun:=(3000) downto (1000) do
 begin
   sound(soun);
   delay(1);
 end;
 nosound;
 delay(100);
 sound(500);
 delay(300);
 nosound;
end;


procedure inicializa(var emouse:boolean);  {procedimiento de inicializacion}
var
  i, ii, lado:byte;
  pal : TPalette;
  version:real;
begin
  clrscr;
  writeln('Grupo Nro: 104');
  writeln('Integrantes: ZEMMA, Gaston Alejandro; ALVAREZ, Gabriel Alberto');
  writeln('Ayudante: ROSSI, Fernando');
  writeln('Trabajo Practico Final de Introduccion a la Programacion I');
  writeln('Fecha de ultima modificacion: 25/8/2000');
  writeln('Version: 2.3');
  writeln;
  writeln;
  writeln('+ y -: escalan el juego en 3 dimensiones.');
  writeln('4 y 6: rota el tablero sobre un eje.');
  writeln('8 y 2: rota el tablero sobre otro eje.');
  writeln('1 y 3: rota el tablero sobre algun otro eje.');
  writeln('Espacio: gira la fuente de luz.');
  writeln('Escape: sale del juego.');
  writeln;
  writeln('El mouse y las flechas de direccion mueven una piramide amarilla que marca la');
  writeln('posicion donde (con Enter o el Boton Izquierdo) se colocara la ficha del');
  writeln('jugador actual. El jugador que juega en cada turno esta marcado por el color');
  writeln('de dos de las caras de la piramide del cursor.');
  writeln;
  writeln;
  writeln;
  writeln;
  writeln('Presione una tecla para iniciar.');
  while not keypressed do;

  fichas:=0;
  azul:=0; colorado:=0;

  new(tablero);
  new(ficha);

  dibujatablero;

  creaflecha;

  init; {inicializo el mouse}
  info(version,i,ii);
  if version>0 then emouse:=true else emouse:=false;

  FuenteLuz.x := 0;
  FuenteLuz.y := 0;
  FuenteLuz.z := 1;
  VerticeNormaliza(FuenteLuz);

  setmode13;

  fillchar(pal, 768, 0);  { llena la paleta con ceros (negro) }
  setpalette(pal);
  loadpcx('manculim.pcx',vga,320,200,0,0,pal);
  fadeto(pal,5);
  delay(1300);
  fadeout(5);

  loadpcx('othello.pcx',vga,320,200,0,0,pal);
  fadeto(pal,5);
  delay(1300);
  fadeout(5);

end;

procedure termina; {procedimiento que libera la memoria asignada
                    a los punteros, ve quien gano, etc.}
var
  i,ii:byte;
  pal : TPalette;
begin
  for i:=1 to fichas do
    dispose(ficha^[i]);
  dispose(ficha);
  dispose(tablero);
  dispose(flecha);

  clearscreen(0,vga);

  fillchar(pal, 768, 0);  { llena la paleta con ceros (negro) }
  setpalette(pal);

  if azul>colorado then
  begin
    loadpcx('azul.pcx',vga,320,200,0,0,pal);
    setpalette(pal);
  end
  else if colorado>azul then
    begin
      loadpcx('rojo.pcx',vga,320,200,0,0,pal);
      setpalette(pal);
    end
    else
      begin
        loadpcx('empate.pcx',vga,320,200,0,0,pal);
        setpalette(pal);
      end;

  musica;
  settextmode;
  clrscr;
  writeln('Azul: ',azul,', Colorado: ',colorado,'.');
  writeln;

end;

function menu:boolean;  {menu devuelve true si se va a jugar contra la pc}
var
  wherexant,whereyant,ax,az:integer;
  h,v:byte;
  pal : TPalette;
  VirSeg1 : word;
  VirScr1 : PTVirtual;  { pantalla virtual }
  VirSeg : word;
  VirScr : PTVirtual;  { pantalla virtual }
  key:char;
begin
  flecha^.cara[1].coloro:=192;
  flecha^.cara[2].coloro:=193;
  flecha^.cara[3].coloro:=194;
  flecha^.cara[4].coloro:=195;
  flecha^.cara[5].coloro:=196;
  setupvirtual(virscr1,virseg1);
  setupvirtual(virscr,virseg);
  fillchar(pal, 768, 0);  { llena la paleta con ceros (negro) }
  setpalette(pal);
  loadpcx('menu.pcx',vga,320,200,0,0,pal);
  fadeto(pal,5);
  copyscreen(vga, virseg);
  wherexant:=0; whereyant:=0;
  h:=4; v:=4;
  key:=' ';

  while haymouse and leftbutton do;
  while keypressed do readkey;{ vacio el buffer de teclado y veo que se haya
                              soltado el boton del mouse para evitar problemas}

  while ( ((haymouse and (not leftbutton)) or (not haymouse)) and (key<>#13) ) do
  begin
    ax:=round((tablero^.vertice[2].x-tablero^.vertice[1].x) / 2);
    az:=round((tablero^.vertice[1].y-tablero^.vertice[10].y) / 2)+20;
    Objeto3DMueve(flecha,tablero^.vertice[(v-1)*9+h].x+ax,tablero^.vertice[(v-1)*9+h].y-az,tablero^.vertice[(v-1
    )*9+h].z);
    objeto3DRota(flecha, 0, 5, 0);

    copyscreen(VirSeg, virseg1);
    objeto3DDibujaSombreadoPlano(flecha, virseg1);
    vretrace;
    copyscreen(VirSeg1, vga);
    if haymouse and ((wherex<>wherexant) or (wherey<>whereyant)) then
    begin
      wherexant:=wherex;
      whereyant:=wherey;
      h:=(wherex div 90)+1;
      v:=(wherey div 27)+1;
    end;

    if keypressed then     { si se presiona una tecla...}
    begin
      key := readkey;   { la leemos }

      if key=#0 then
                begin
                      key:=readkey;
                      case key of
                        #80: if v<8 then v:=v+1;
                        #72: if v>1 then v:=v-1;
                        #77: if h<8 then h:=h+1;
                        #75: if h>1 then h:=h-1;
                      end;
                end;
    end;
  end;

  shutdownvirtual(virscr);
  shutdownvirtual(virscr1);

  flecha^.cara[1].coloro:=colordex;
  flecha^.cara[2].coloro:=192;
  flecha^.cara[3].coloro:=colordex;
  flecha^.cara[4].coloro:=192;
  flecha^.cara[5].coloro:=192;

  while haymouse and leftbutton do;
  while keypressed do readkey;{ vacio el buffer de teclado y veo que se haya
                              soltado el boton del mouse para evitar problemas}

  if h>=5 then menu:=true else menu:=false;
end;

{-------------------------------------------------------------------------}
{ programa principal }
begin

  inicializa(haymouse);

  otelo(menu);

  termina;

end.
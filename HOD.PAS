{ type
  points = array [1..100] of record
    x, y :real
  end;

procedure parab(t1 : points; x1 : integer; x2 : integer; y1 : integer;
                y2 : integer; z : integer; xx : integer; c : integer;
                k : real; m : real; ym : integer; col : integer);
var a:real;
    j,i:real;
    txs:string;
begin
  if t1[x1].x-t1[x2].x=0 then
    i:=0.0001 else i:=t1[x1].x-t1[x2].x;
  a:=z * (t1[y1].y-t1[y2].y) / SQR(i);
  j:=(t1[c+1].x-t1[c].x)/400;
  i:=t1[c].x;
  while i<=t1[c+1].x do
    begin
      putpixel(xx+round(i*k),ym-round((z*a*(i-t1[x2].x)*(i-t1[x2].x)+t1[y2].y) * m),col);
      i:=i+j;
    end;
end;

procedure kriv(t1 : points; N1:integer;xx : integer; xm : integer; yy : integer;
               ym : integer; col : integer;max:real);
var j,c,tmp2 : integer;
    ty : integer;
    a:real;
    tmp,step,l:real;
    k :REAL;
    txs :string;
begin
  if max=0 then a:=0.000001 else a:=max;
  a:=(ym-yy)/a;
  k:=(xm-xx)/t1[N1].x;
  ty:=ym-1;

  for c:=1 to N1-1 do
    begin
      if c=N1-1 then
      begin
        if t1[c+1].y>t1[c].y then
        begin
          if t1[c-1].y<t1[c].y then begin
            parab(t1,c,c+1,c,c+1,-1,xx,c,k,a,ym,col);
                                    end
          else
          if t1[c-1].y>=t1[c].y then begin
            parab(t1,c+1,c,c+1,c,1,xx,c,k,a,ym,col);
                                     end
        end
        else
        if t1[c+1].y<t1[c].y then
        begin
          if (t1[c-1].y>t1[c].y) and (t1[c-2].y>t1[c-1].y) then begin
            parab(t1,c+1,c,c+1,c,1,xx,c,k,a,ym,col);
                                                                end
          else
          if (t1[c-1].y>t1[c].y) and (t1[c-2].y<=t1[c-1].y) then begin
            parab(t1,c,c+1,c,c+1,1,xx,c,k,a,ym,col);
                                                                 end
          else
          if t1[c-1].y<=t1[c].y then begin
            parab(t1,c,c+1,c,c+1,1,xx,c,k,a,ym,col);
                                     end
        end
        else
        if t1[c+1].y=t1[c].y then
        begin
          line(xx+round(t1[c].x*k),                   ym-round(t1[c].y * a),
               xx+round((t1[c+1].x)*k),ym-round(t1[c+1].y*a));
        end
      end
      else
      if t1[c+1].y>t1[c].y then
      begin
        if t1[c+2].y<=t1[c+1].y then
        begin
          parab(t1,c,c+1,c,c+1,-1,xx,c,k,a,ym,col);
        end
        else
        if t1[c+2].y>t1[c+1].y then begin
        begin
          line(xx+round(t1[c].x*k),                   ym-round(t1[c].y * a),
               xx+round((t1[c+1].x)*k),ym-round(t1[c+1].y*a));
        end
      end
      end
      else
      if t1[c+1].y<t1[c].y then
      begin
        if t1[c+2].y<t1[c+1].y then begin
        begin
          line(xx+round(t1[c].x*k),                   ym-round(t1[c].y * a),
               xx+round((t1[c+1].x)*k),ym-round(t1[c+1].y*a));
        end
       end
        else
        if t1[c+2].y>=t1[c+1].y then begin
          parab(t1,c,c+1,c,c+1,1,xx,c,k,a,ym,col);
                                     end
      end
      else
      if t1[c+1].y=t1[c].y then
      begin
        line(xx+round(t1[c].x*k),    ym-round(t1[c].y * a),
             xx+round((t1[c+1].x*k)),ym-round(t1[c+1].y*a));
      end;
    end;
  c:=xx;
  while c<=xm do
  begin
    tmp:=c/k;
    str(tmp:3:2,txs);
    outtextxy(c,ty+4,txs);
    c:=c+40;
  end;
  c:=getmaxy-60;
  while c>=50 do
  begin
    tmp:=(ym-c)*max/(ym-yy);
    str(tmp:3:2,txs);
    outtextxy(xx-30-5,c,txs);
    c:=c-15;
  end;
end;

procedure kriv_main (t1 : points; N1: integer);
var graphdriver:integer;
    graphmode  :integer;
    xm, ym, i     :integer;
    max,min:real;
    key : char;
begin
  graphdriver:=detect;
  initgraph(graphdriver,graphmode,'');
  cleardevice;
  setlinestyle(solidln,0,thickwidth);

  max:= abs(t1[1].y);
  for i:=2 to N1 do
    if abs(t1[i].y) > max then max:= abs(t1[i].y);

  min:= t1[1].y;
  for i:=2 to N1 do
    if t1[i].y < min then min:= t1[i].y;

  if min<0 then ym:=round((getmaxy * max)/(max-min))
  else ym:=getmaxy-15;

  if param<>2 then begin
    xm:=getmaxx-1;
    line(25+4+5,getmaxy,25+4+5,1+60);
    line(25+4+5,ym,xm,ym);           
    line(25+4+5,1+60,25+0+5,5+60);   
    line(25+4+5,1+60,25+8+5,5+60);
    line(xm,ym,xm-4,ym+4);        
    line(xm,ym,xm-4,ym-4);
    setlinestyle(solidln,0,normwidth);
    setcolor(2);
    kriv(t1,N1,25+5+5,xm,1+60,ym,2,max);
  end;

  repeat
    key:=readkey;
  until key<>'';

  closegraph;
end;
}
var
  S, al : real;

function fun (x : real; n: integer) : real;
var lamb, labd4, Ksi, Iam : real;
begin
  if n = 1 then
    fun := -abs (sin (al - x/2)/sin (al) * sin (x/2) + x/2 - S)
  else
    fun := 0;
end;

function extremum (a, b, eps : real; n : integer) : real;
var xs, fs, f1, x1, f2, x2 : real;
begin
  xs := (b-a)/2;
  fs := fun (xs, n);

  x1 := a + (b-a)/4;
  x2 := b - (b-a)/4;

  f1 := fun (x1, n);
  f2 := fun (x2, n);
  
  repeat
    if fs > f1 then
    begin
      a := xs;
      if fs > f2 then
        b := x2
      else
        a := xs
    end
    else
      b := xs;

    x1 := a + (b-a)/4;
    x2 := b - (b-a)/4;

    f1 := fun (x1, n);
    f2 := fun (x2, n);

    xs := a+(b-a)/2;
    fs := fun (xs, n);
  until x2-x1 < eps;
  extremum := xs;
end;

function integral (al, lam4 : real) : real;
const NUM = 100;
var
  th, s, a, b, st : real;
begin
  th := al;
  s := 0;
  st := lam4/NUM;

  a := sin (th - 1.4711) - sin (al - 1.4711) * exp (-(th-al)/10) -
               sin (al) * sqrt (101) * (1-exp (-(th-al)/10));

  while th <= al+lam4 do
  begin
    b := sin (th - 1.4711) - sin (al - 1.4711) * exp (-(th-al)/10) -
		sin (al) * sqrt (101) * (1-exp (-(th-al)/10));
    s := s + (a+b)/2*st;
    a := b;
    th := th + st;
  end;
  integral := s;
end;


const NUM = 300;

var
  lamb, step, lambda4, omega : real;
  Iam_, Sl_, I1ef_, Ksi_, E0_, Id_ : array[1..NUM] of real;
  i, Indexmax : integer;
  F, Fmax : real;

  Em, Idnom, Kpwh, Ud, Ib, I1ef, Iam, L, C, Sl, Rd, Xc, q, Kpwyh,
  dUc, Ub : real;

{  gra : points; }

begin
  al := 0.1;
  i := 1;
  Fmax := -1e100;

  while al <= 1.4 do
  begin
    S := cos (al)/sin (al) - (3.14259/2 - al);

    lamb := extremum (0, 1.4, 0.0001, 1);

    lambda4 := 3.14159 - 2*al + lamb;

    Iam_[i] := S * sin (al); { integral (al, lambda4); }
    Id_[i] := 2 * lambda4/3.14159/3.14159 * Iam_[i];
    Sl_[i] := 0.5/sin (al)*3.14159/4*Iam_[i];
    I1ef_[i] := 0.5*sqrt (lambda4/3.14159)*Iam_[i];
    Ksi_[i] := 4/3.14159 * sin (al) * sqrt (lambda4/3.14159);
    E0_[i] := sin (al);

    F := ((1-Ksi_[i]) + 0.8 * Sl_[i] + 3.14159*3.14159/2/lambda4);
    writeln ('alpha=', al, ' Ksi=', Ksi_[i], ' F=', F);
    if F > Fmax then
    begin
      Fmax := F;
      Indexmax := i;
    end;
{    gra[i].x := Id_[i];}
 
    al := al + 0.005;
    Inc (i);
  end;

   writeln ('Fmax=', Fmax, ' with i=', Indexmax);
{  for i := 1 to NUM do  
      gra[i].y := Iam_[i];
    kriv_main (gra, NUM);

    for i := 1 to NUM do
      gra[i].y := Sl_[i];
    kriv_main (gra, NUM);

    for i := 1 to NUM do
      gra[i].y := I1ef_[i];
    kriv_main (gra, NUM);

    for i := 1 to NUM do
      gra[i].y := Ksi_[i];
    kriv_main (gra, NUM);

    for i := 1 to NUM do
      gra[i].y := E0_[i];
    kriv_main (gra, NUM);

  { Продолжение }

  Em := 300;
  omega := 314;
  Idnom := 10;
  Kpwh := 0.67;

  writeln ('Id[Indexmax]=', Id_[Indexmax]);
  Ud := E0_[Indexmax]*Em;
  Ib := Idnom/Id_[Indexmax];
  I1ef := I1ef_[Indexmax] * Ib;
  Iam := Iam_[Indexmax] * Ib;
  L := Em/(omega * Ib);
  C := 0.0001/(3.14159*3.14159*L);
  Sl := 157 * L * I1ef * I1ef;
  Rd := Ud/Idnom;
  Xc := 1/(omega * C);
  if Xc <= Rd/10 then
    C := 10/(omega * Rd);
  q := 2 * omega * omega * L * C - 1;
  Kpwyh := Kpwh/q;
  dUc := Ud * Kpwyh;
  Ub := 10 * dUc;
  if Ub >= 1.1 * Ud then
    Ub := Ud;

  writeln ('Постоянное напряжение в звене постоянного тока Ud=', Ud, ' В');
  writeln ('Средний ток нагрузки Id=', Idnom, ' А');
  writeln ('Параметры дросселя:');
  writeln ('  индуктивность L=', L, ' мГн');
  writeln ('  габаритная мощность Sl=', Sl, ' ВА');
  writeln ('Параметры фильтрового конденсатора:');
  writeln ('  емкость C=', C, ' мкФ');
  writeln ('  амплитуда пульсаций напряжения Uв=', dUc, ' В');
  writeln ('Пульсация на выходе фильтра Kпвых=', Kpwyh);
end.

{ 1.75000E-01  5.25000E-01
 8.75000E-02  2.62500E-01
 1.96875E-01  2.40625E-01
 1.85937E-01  2.07812E-01
 1.99609E-01  2.05078E-01
 1.98242E-01  2.00977E-01
 1.99951E-01  2.00635E-01
Постоянное напряжение в звене постоянного тока Ud= 2.99500E+01 В
Средний ток нагрузки Id= 1.00000E+00 А
Параметры дросселя:
  индуктивность L= 5.57962E-02 мГн
  габаритная мощность Sl= 5.40310E+00 ВА
Параметры фильтрового кондкнсатора:
  емкость C= 1.81592E-04 мкФ
  напряжение Uв= 2.99500E+01 В
Пульсация на выходе фильтра Kпвых= 6.71359E-01
}

program interp;

uses crt;

const
  C_NUMPAR = 8;		{ max num parameters }
  C_NUMELEM = 6;	{ how many types of elements }
  C_MAXPARTS = 20;	{ max size of the scheme }
  C_NAMELEN = 10;
  C_MAXSTACK = 1000;    { max size of compile stack }

type
  nameT = string[C_NAMELEN];

  elementT = record
    name     : nameT;
    num_par  : integer;
    num_var  : integer;
    num_in   : integer;
    num_out  : integer;
    in_name  : array [1..C_NUMPAR] of nameT;
    out_name : array [1..C_NUMPAR] of nameT;
    par_name : array [1..C_NUMPAR] of nameT;
    var_name : array [1..C_NUMPAR] of nameT;
  end;
  pelementT = ^elementT;

  partT = record
    name    : nameT;
    in_wh   : array[1..C_NUMPAR] of integer;
    out_wh  : array[1..C_NUMPAR] of integer;
    par     : array[1..C_NUMPAR] of real;
    vars    : array[1..C_NUMPAR] of real;
    in_val  : array[1..C_NUMPAR] of real;
    out_val : array[1..C_NUMPAR] of real;
    whatIs  : pelementT;
  end;

var
  element : array[1..C_NUMELEM] of elementT;
  part : array[1..C_MAXPARTS] of ^partT;
  lastPart : integer;		{ how many parts there are }
  time : record
    start : real;
    stop : real;
    step : real
  end;
  screen : array[1..100] of ^string;	{ picture }
  scrY : integer;			{ picture vertical size }
  incid : array[1..C_MAXPARTS, 1..C_MAXPARTS] of boolean; { incidence matrix }
  indincid : array[1..C_MAXPARTS] of word;	{ index incid }
  st : array[1..C_MAXSTACK] of integer;		{ stack }
  sthead : integer;				{ last of stack }
  collectChain : integer;		{ # of chain that will be calculated }

procedure initScheme;
begin
  lastPart := 0;
  time.start := 0;
  time.stop := 0;
  time.step := 0;
  collectChain := -1;
end;
  
procedure initElem;
begin
  with element[1] do
  begin
    name := 'let1';
    num_in := 0;
    num_out := 1;
    num_par := 1;
    num_var := 0;
    out_name[1] := 'out1';
    par_name[1] := 'par1';
  end;
  with element[2] do
  begin
    name := 'let2';
    num_in := 1;
    num_out := 1;
    num_par := 1;
    num_var := 1;
    in_name[1] := 'in1';
    out_name[1] := 'out1';
    par_name[1] := 'par1';
    var_name[1] := 'var1';
  end;
  with element[3] do
  begin
    name := 'let3';
    num_in := 2;
    num_out := 2;
    num_par := 1;
    num_var := 2;
    in_name[1] := 'in1';
    in_name[2] := 'in2';
    out_name[1] := 'out1';
    out_name[2] := 'out2';
    par_name[1] := 'par1';
    var_name[1] := 'var1';
    var_name[2] := 'var2';
  end;
  with element[4] do
  begin
    name := 'let4';
    num_in := 2;
    num_out := 1;
    num_par := 1;
    num_var := 3;
    in_name[1] := 'in1';
    in_name[2] := 'in2';
    out_name[1] := 'out1';
    par_name[1] := 'par1';
    var_name[1] := 'var1';
    var_name[2] := 'var2';
    var_name[3] := 'var3';
  end;
  with element[5] do
  begin
    name := 'let5';
    num_in := 3;
    num_out := 2;
    num_par := 1;
    num_var := 4;
    in_name[1] := 'in1';
    in_name[2] := 'in2';
    in_name[3] := 'in3';
    out_name[1] := 'out1';
    out_name[2] := 'out2';
    par_name[1] := 'par1';
    var_name[1] := 'var1';
    var_name[2] := 'var2';
    var_name[3] := 'var3';
    var_name[4] := 'var4';
  end;
  with element[6] do
  begin
    name := 'let6';
    num_in := 1;
    num_out := 2;
    num_par := 1;
    num_var := 0;
    in_name[1] := 'in1';
    out_name[1] := 'out1';
    out_name[2] := 'out2';
    par_name[1] := 'par1';
  end;
end;

function max (i, j : integer) : integer;
begin
  if i > j then
    max := i
  else
    max := j
end;

procedure initPart (num : integer);
var i : integer;
begin
  with part[num]^ do
  for i := 1 to C_NUMPAR do
  begin
    in_wh[i] := -1;
    out_wh[i] := -1;
    par[i] := 0;
    vars[i] := 0;
    in_val[i] := 0;
    out_val[i] := 0;
  end;
end;

function upString (s : string) : string;
var
  i : integer;
  tmp : string;
begin
  tmp := s;
  for i := 1 to length (s) do
    tmp[i] := upcase (tmp[i]);
  upString := tmp;
end;

{ prints an error to the screen.
  s   - string
  num - position
  msg - message }
procedure printError (s : string; num : integer; msg : string);
var i : integer;
begin
  if num > 0 then
  begin
    writeln (s);
    if length (msg)+2 < num then
    begin
      write (msg);
      for i := length (msg) to num do
        write (' ');
      writeln ('^');
    end
    else
      begin
        for i := 1 to num-1 do
          write (' ');
        write ('^  ');
        
        if length (msg)+num+3 >= 78 then
          writeln;
        writeln (msg);
      end
  end
  else
    writeln ('^  ', msg)
end;

function posTok (s : string; num : integer) : integer;
var
  i, j : integer;
begin
  i := 1;
  j := 1;

  while (i <= length (s)) and (j < num) do
  begin
    while (i <= length (s)) and ((s[i] = ' ') or (s[i] = chr (9))) do
      inc (i);
    while (i <= length (s)) and (s[i] <> ' ') and (s[i] <> chr (9)) do
      inc (i);
    inc (j);
  end;

  posTok := -1;

  if i <= length (s) then
  begin
    while (i <= length (s)) and ((s[i] = ' ') or (s[i] = chr (9))) do
      inc (i);
    if i <= length (s) then
      posTok := i
  end
end;  { posTok }

function getTok (s : string; num : integer) : string;
var
  i, j : integer;
  tmp : string;
begin
  i := posTok (s, num);
  
  if i = -1 then
    getTok := ''
  else
  begin
    j := 0;
    while (i+j <= length (s)) and (s[i+j] <> ' ') and (s[i+j] <> chr (9)) do
      inc (j);

    if j > 0 then
      getTok := copy (s, i, j)
    else
      getTok := ''
  end
end;  { getTok }

function searchElement (s : string) : integer;	{ returns # el name }
var i : integer;
begin
  searchElement := 0;
  i := 1;

  while (i <= C_NUMELEM) and (element[i].name <> s) do
    inc (i);
  if i <= C_NUMELEM then
    searchElement := i;
end;	{ searchElement }

function searchPart (s : string) : integer;	{ returns # el name }
var i : integer;
begin
  searchPart := 0;
  i := 1;

  while (i <= lastPart) and (part[i]^.name <> s) do
    inc (i);
  if i <= lastPart then
    searchPart := i;
end;	{ searchPart }

function searchOUT (num : integer; s : string) : integer;{ returns #el's OUT }
var i : integer;
    x : integer;
    b : integer;
begin
  searchOUT := 0;
  i := 1;

  with part[num]^.whatIs^ do
    while (i <= num_out) and (out_name[i] <> s) do
      inc (i);
  if i <= part[num]^.whatIs^.num_out then
    searchOUT := i
  else
  begin
    val (s, b, x);
    if (x = 1) or (b > part[num]^.whatIs^.num_out) then
      searchOUT := 0
    else
      searchOUT := b;
  end
end;	{ searchOUT }

function searchIN (num : integer; s : string) : integer;{ returns #el's IN }
var i : integer;
    x : integer;
    b : integer;
begin
  searchIN := 0;
  i := 1;

  with part[num]^.whatIs^ do
    while (i <= num_in) and (in_name[i] <> s) do
      inc (i);
  if i <= part[num]^.whatIs^.num_in then
    searchIN := i
  else
  begin
    val (s, b, x);
    if (x = 1) or (b > part[num]^.whatIs^.num_in) then
      searchIN := 0
    else
      searchIN := b;
  end
end;	{ searchIN }

function searchParameter (num : integer; s : string) : integer;
var i : integer;
    x : integer;
    b : integer;
begin
  searchParameter := 0;
  i := 1;

  with part[num]^.whatIs^ do
    while (i <= num_par) and (par_name[i] <> s) do
      inc (i);
  if i <= part[num]^.whatIs^.num_par then
    searchParameter := i
  else
  begin
    val (s, b, x);
    if (x = 1) or (b > part[num]^.whatIs^.num_par) then
      searchParameter := 0
    else
      searchParameter := b;
  end
end;	{ searchParameter }

function searchVar (num : integer; s : string) : integer;
var i : integer;
    x : integer;
    b : integer;
begin
  searchVar := 0;
  i := 1;

  with part[num]^.whatIs^ do
    while (i <= num_var) and (var_name[i] <> s) do
      inc (i);
  if i <= part[num]^.whatIs^.num_var then
    searchVar := i
  else
  begin
    val (s, b, x);
    if (x = 1) or (b > part[num]^.whatIs^.num_var) then
      searchVar := 0
    else
      searchVar := b;
  end
end;	{ searchVar }

procedure tracePicture;

type
  pT = record
    x, y  : integer;
    in_y  : array[1..C_NUMPAR] of integer;
    out_x : integer;
    out_y : array[1..C_NUMPAR] of integer;
  end;

var
  i, j, k : integer;
  i1, j1 : integer;
  x, y : integer;
  p : array[1..C_MAXPARTS] of ^pT;
  curr : integer;
  chainNum : integer;

  procedure setValOfIn (x, y : integer);
  var
    i, j : integer;
  label loop1;
  begin
    i := 1;

  loop1:
    while p[i]^.x <> x do
      inc (i);

    j := 1;
    while (p[i]^.in_y[j] <> y) and (p[i]^.in_y[j] > -1) do
      inc (j);

    if p[i]^.in_y[j] = -1 then
    begin
      inc (i);
      goto loop1
    end;

    if part[i]^.in_wh[j] = -1 then
    begin
      part[i]^.in_wh[j] := chainNum;
{      gotoxy (x, y);
      write (chainNum:0); }
    end
    else
    begin
{      gotoxy (15, 2);
      write (part[i]^.in_wh[j], 'of ', i, j) }
    end
  end;

  procedure setValOfOut (x, y : integer);
  var
    i, j : integer;
  label loop1;
  begin
    i := 1;

  loop1:
    while p[i]^.out_x <> x do
      inc (i);

    j := 1;
    while (p[i]^.out_y[j] <> y) and (p[i]^.out_y[j] > -1) do
      inc (j);

    if p[i]^.out_y[j] = -1 then
    begin
      inc (i);
      goto loop1
    end;

    if part[i]^.out_wh[j] = -1 then
    begin
      part[i]^.out_wh[j] := chainNum;
{      gotoxy (x, y);
      write (chainNum:0); }
    end
    else
    begin
{      gotoxy (15, 2);
      write (part[i]^.out_wh[j], 'of ', i, j) }
    end
  end;

  	{ traces a wire }
  procedure setChainNum (x, y, dx, dy : integer);
  label loop1;
  const
    symb : string = '┌┐┼└┘│─';
    DXforDY : array[1..2, 1..7] of integer =
		((1, -1, 0, 0, 0,  0, 0), { up }
		 (0,  0, 0, 1, -1, 0, 0));{ down }
    DYforDY : array[1..2, 1..7] of integer =
		((0, 0, -1, 0, 0, -1, 0), { up }
		 (0, 0, 1, 0, 0, 1, 0));  { down }
    DXforDX : array[1..2, 1..7] of integer =
		((0, 0, -1, 0, 0, 0, -1), { left }
		 (0, 0, 1, 0, 0, 0, 1));  { right }
    DYforDX : array[1..2, 1..7] of integer =
		((1, 0, 0, -1, 0, 0, 0), { left }
		 (0, 1, 0, 0, -1, 0, 0));{ right }
  begin
loop1:
{  gotoxy (x+dx, y+dy); write ('.'); readln; }
    case screen[y+dy]^[x+dx] of
      '┌', '┐', '┼', '└', '┘', '│', '─':
        begin
          x := x+dx;
          y := y+dy;
          if dy = -1 then
          begin
            dx := DXforDY[1][pos (screen[y]^[x], symb)];
            dy := DYforDY[1][pos (screen[y]^[x], symb)];
            goto loop1
          end;
          if dy = 1 then
          begin
            dx := DXforDY[2][pos (screen[y]^[x], symb)];
            dy := DYforDY[2][pos (screen[y]^[x], symb)];
            goto loop1
          end;
          if dx = -1 then
          begin
            dx := DXforDX[1][pos (screen[y]^[x], symb)];
            dy := DYforDX[1][pos (screen[y]^[x], symb)];
            goto loop1
          end;
          if dx = 1 then
          begin
            dx := DXforDX[2][pos (screen[y]^[x], symb)];
            dy := DYforDX[2][pos (screen[y]^[x], symb)];
            goto loop1
          end;
        end;
      '┬':
        begin
          if dy = 0 then
          begin
            setChainNum (x+dx, y, dx, 0);
            x := x+dx;
            dx := 0;
            dy := 1;
            goto loop1
          end
          else
          begin
            setChainNum (x, y-1, -1, 0);
            y := y-1;
            dx := 1;
            dy := 0;
            goto loop1
          end
        end;
      '├':
        begin
          if dy = 0 then
          begin
            setChainNum (x-1, y, 0, -1);
            x := x-1;
            dx := 0;
            dy := 1;
            goto loop1
          end
          else
          begin
            setChainNum (x, y+dy, 0, dy);
            y := y+dy;
            dx := 1;
            dy := 0;
            goto loop1
          end
        end;
      '┤':
        begin
          if dy = 0 then
          begin
            setChainNum (x+1, y, 0, -1);
            x := x+1;
            dx := 0;
            dy := 1;
            goto loop1
          end
          else
          begin
            setChainNum (x, y+dy, 0, dy);
            y := y+dy;
            dx := -1;
            dy := 0;
            goto loop1
          end
        end;
      '┴':
        begin
          if dy = 0 then
          begin
            setChainNum (x+dx, y, dx, 0);
            x := x+dx;
            dx := 0;
            dy := -1;
            goto loop1
          end
          else
          begin
            setChainNum (x, y+1, -1, 0);
            y := y+1;
            dx := 1;
            dy := 0;
            goto loop1
          end
        end;
      ' ':
        ;
      '╢':
         setValOfIn (x+1, y);
      '╟':
         setValOfOut (x-1, y);
    end;
  end;

  
begin
  for i := 1 to lastPart do
  begin
    new (p[i]);

    p[i]^.out_x := -1;
    for j := 1 to C_NUMPAR do
      with p[i]^ do
      begin
        in_y[j]  := -1;
        out_y[j] := -1
      end;
  end;

  { search parts on the scheme }
  for i := 1 to scrY do
    for j := 1 to length (screen[i]^) do
    begin
      if screen[i]^[j] = '╔' then
      begin
        k := j+1;
        while (screen[i]^[k] >= '0') and (screen[i]^[k] <= '9') do
          inc (k);
        val (copy (screen[i]^, j+1, k-j-1), x, k);
        p[x]^.x := j;
        p[x]^.y := i;
      end;
    end;

  { search parts' outlets }
  for i := 1 to lastPart do
  begin
      { scan for in }
    x := p[i]^.x;
    y := p[i]^.y + 1;
    curr := 1;

    while screen[y]^[x] <> '╚' do
    begin
      if screen[y]^[x] = '╢' then
      begin
        if curr > part[i]^.whatIs^.num_in then
          writeln ('Too IN elements at part #', i);
        p[i]^.in_y[curr] := y;
        inc (curr)
      end;
      inc (y)
    end;

      { search out }
    y := p[i]^.y;
    while screen[y]^[x] <> '╗' do
      inc (x);
    p[i]^.out_x := x;

      { scan for out }
    curr := 1;

    while screen[y]^[x] <> '╝' do
    begin
      if screen[y]^[x] = '╟' then
      begin
        if curr > part[i]^.whatIs^.num_out then
          writeln ('Too OUT elements at part #', i);
        p[i]^.out_y[curr] := y;
        inc (curr)
      end;
      inc (y)
    end;
  end;	{ for to lastPart }

  chainNum := 1;

     { traces every outlet }
  for i := 1 to lastPart do
  begin
      { trace out }
    j := 1;

    while p[i]^.out_y[j] > -1 do	{ if defined outlet }
    begin
      if part[i]^.out_wh[j] = -1 then	{ if chain not set }
      begin
        x := p[i]^.out_x;		{ +1 to skip a box }
        y := p[i]^.out_y[j];
        setValOfOut (x, y);
        setChainNum (x, y, 1, 0);
        inc (chainNum);
      end;
      inc (j);
    end;

      { trace in }
    j := 1;

    while p[i]^.in_y[j] > -1 do		{ if defined outlet }
    begin
      if part[i]^.in_wh[j] = -1 then	{ if chain not set }
      begin
        x := p[i]^.x;		{ -1 to skip a box }
        y := p[i]^.in_y[j];
        setValOfIn (x, y);
        setChainNum (x, y, -1, 0);
        inc (chainNum);
      end;
      inc (j)
    end
  end;	{ outlets }

	{ free memory }
  for i := 1 to lastPart do
    dispose (p[i]);
end;

function readPicture (fileName : string) : integer;

  function scanNames (name : string) : pelementT;
  var
    i : integer;
    stop : byte;
  begin
    i := 1;
    stop := 0;

    while (i <= C_NUMELEM) and (stop = 0) do
      if element[i].name = name then
        stop := 1
      else
        inc (i);

     scanNames := @element[i];
  end;

var
  f : text;
  s : string;
  i : integer;
  stop : byte;
  tmp : string;
  x, y : integer;
label fail;

begin
  assign (f, fileName);
  {$I-}
  reset (f);
  {$I+}

  if IOResult <> 0 then
  begin
    writeln ('File not found');
    readPicture := 0;
    goto fail
  end;

  readPicture := 1;
  stop := 0;

  while (not eof (f)) and (stop = 0) do
  begin
    readln (f, s);

    if pos ('section scheme', s) <> 0 then
    begin
      for i := 1 to scrY do
        dispose (screen[i]);

      scrY := 0;
      readln (f, s);
      repeat
        inc (scrY);
        new (screen[scrY]);
        screen[scrY]^ := s;
        readln (f, s);
      until pos ('section end', s) <> 0;
    end;

    if pos ('section description', s) <> 0 then
    begin
      readln (f, s);
      val (getTok (s, 1), lastPart, x);
      if (upString (getTok (s, 2)) <> 'PARTS') or (x = 1) or
			(lastPart > C_MAXPARTS) then
      begin
        lastPart := 0;
        close (f);
        writeln ('Error at first line of section description');
        goto fail
      end;

      for i := 1 to lastPart do
        new (part[i]);

      while stop = 0 do
      begin
        readln (f, s);

        if pos ('section end', s) <> 0 then
          stop := 1
        else
        begin
          val (getTok (s, 1), y, x);
          if (x = 1) or (y < 1) or (y > lastPart) then
          begin
            writeln ('Error in part number (', getTok (s, 1), ')');
            close (f);
            goto fail
          end;
          initPart (y);

          i := searchElement (getTok (s, 2));
          if i = 0 then
          begin
            writeln ('Unknown part ', getTok (s, 2));
            close (f);
            goto fail
          end;

          if upString (getTok (s, 3)) <> 'IS' then
          begin
            writeln ('IS expected ', s);
            close (f);
            goto fail
          end;

          if searchPart (getTok (s, 4)) > 0 then
          begin
            printError (s, posTok (s, 4), 'Part multiply defined');
            close (f);
            goto fail
          end;
          
          part[y]^.whatIs := @element[i];
          part[y]^.name := getTok (s, 4);
        end;
      end;
      stop := 0;
    end;
    if pos ('eof', s) <> 0 then
      stop := 1;
  end;	{ while not eof }
  close (f);
  fail:
end;

var
  numCon : array[1..C_MAXPARTS] of word;      { number of connections }

procedure incident;

  procedure optimIncid;
  var
    i, j, num : integer;
    x : integer;
    max, nmax : integer;
  label loop1;
  begin
    for i := 1 to lastPart do
      indincid[i] := i;

    for num := 1 to lastPart do
    begin
      for i := num to lastPart do
        if numCon[indincid[i]] = 0 then
        begin
          x := indincid[i];
          indincid[i] := indincid[num];
          indincid[num] := x;
          goto loop1
        end;

      max := 1000;
      nmax := 0;
      for j := num to lastPart do
        for i := 1 to lastPart do
          if incid[indincid[i], indincid[j]] and (i < max) then
          begin
            max := i;
            nmax := j
          end;
      x := indincid[nmax];
      indincid[nmax] := indincid[num];
      indincid[num] := x;
      
  loop1:
    end
  end;   { optimIncid }
  
var
  i, j, k, l : integer;
begin
  for i := 1 to lastPart do
  begin
    numCon[i] := 0;
    for j := 1 to lastPart do
      incid[i, j] := false
  end;

  for i := 1 to lastPart do
  begin
    j := 1;
    while part[i]^.out_wh[j] <> -1 do
    begin
      for k := 1 to lastPart do
      begin
        l := 1;
        while part[k]^.in_wh[l] <> -1 do
        begin
          if part[i]^.out_wh[j] = part[k]^.in_wh[l] then
            if incid[i, k] then
              writeln ('Error ')
            else
            begin
              inc (numCon[k]);
              incid[i, k] := true
            end;
          inc (l)
        end
      end;
      inc (j)
    end
  end;
  optimIncid
end;      { incident }

procedure compile (what : integer);

  function tryTo (what : integer) : boolean;    { search if loop }
  var
    i, j, k : integer;
  begin
    tryTo := false;
    i := 1;

    while (i < sthead) and (st[i] <> what) do
      inc (i);

    if i < sthead then
    begin
      tryTo := true;
      k := sthead - i;
      for i := 1 to k do
      begin
        st[sthead] := st[sthead-k];
        inc (sthead);
      end;
    end
  end;

  procedure lookup (what : integer);		{ makes sequent }
  var
    i : integer;
  label loop1, loop2;
  begin
  loop1:
    st[sthead] := indincid[what];
    inc (sthead);

    if numCon[indincid[what]] > 0 then
    begin
      if ((numCon[indincid[what]] = 1) and
		(not incid[indincid[what], indincid[what]])) or
         ((numCon[indincid[what]] = 2) and
		(incid[indincid[what], indincid[what]])) then
      begin
        if incid[indincid[what], indincid[what]] then
        begin
          st[sthead] := indincid[what];
          inc (sthead);
        end;

        i := 1;
        while (not incid[indincid[i], indincid[what]]) or (i = what)  do
          inc (i);
        if tryTo (indincid[i]) then
          goto loop2;
        what := i;
        goto loop1
      end;
      if incid[indincid[what], indincid[what]] then
      begin
        st[sthead] := indincid[what];
        inc (sthead);
      end;

      for i := 1 to lastPart do
        if i <> what then
          if incid[indincid[i], indincid[what]] then
            if not tryTo (indincid[i]) then
              lookup (i)
    end;
loop2:
  end;   { lookup }

var
  i, j, x : integer;
begin   { compile }
  incident;

  sthead := 1;

  i := 1;
  while indincid[i] <> what do
    inc (i);
  lookup (i);

  for i := 1 to lastPart do
  begin
    x := -1;
    for j := sthead-1 downto 1 do
      if st[j] = i then
      begin
        st[j] := -i;
        x := j
      end;
    if x > -1 then
      st[x] := i
  end
end;

function dialog (fileName : string) : integer;

  procedure parseNEW (s : string);
  var
    num : integer;
    y_n : string[2];
    i : integer;
  label fail;
  begin
    if upString (getTok (s, 2)) = 'PART' then
    begin
      num := searchElement (getTok (s, 3));
      if num = 0 then
      begin
        printError (s, posTok (s, 3), 'Unknown element');
        goto fail
      end;
      if lastPart = C_MAXPARTS then
      begin
        printError (s, 0, 'Can not add a new part');
        goto fail
      end;

      if upString (getTok (s, 4)) <> 'NAME' then
      begin
        printError (s, posTok (s, 4), 'NAME expected');
        goto fail
      end;
      if posTok (s, 5) = -1 then
      begin
        printError (s, length (s), 'Part name expected');
        goto fail
      end;
      if searchPart (getTok (s, 5)) > 0 then
      begin
        printError (s, posTok (s, 5), 'Part already defined');
        goto fail
      end;

      inc (lastPart);
      new (part[lastPart]);
      initPart (lastPart);
      part[lastPart]^.whatIs := @element[num];
      part[lastPart]^.name := getTok (s, 5);
      goto fail;
    end;

    if upString (getTok (s, 2)) = 'SCHEME' then
    begin
      writeln ('Are you sure (Y/N)?');
      readln (y_n);
      if not ((y_n[1] = 'y') or (y_n[1] = 'Y')) then
        goto fail;

      for i := 1 to lastPart do
        dispose (part[i]);

      initScheme;
      writeln ('Scheme is empty');
      goto fail
    end;

    printError (s, posTok (s, 2), 'Unknown NEW directive');
  fail:
  end;

  procedure parseLIST (s : string);
  var
    i, j : integer;
    num, x : integer;
    tmp : string;
  const C1=(C_NAMELEN+1);
        C2=4;
        C3=12;
  label fail;
  begin
    if upString (getTok (s, 2)) = 'ELEMENTS' then
    begin
      writeln ('Available elements:');
      for i := 1 to C_NUMELEM do
        write (element[i].name:(C_NAMELEN+1));
      writeln;
      goto fail;
    end;

    if (upString (getTok (s, 2)) = 'ALL') and
                         (upString (getTok (s, 3)) = 'PARTS') then
    begin
      if lastPart = 0 then
        writeln ('Scheme is empty')
      else
        writeln ('Described parts:');
      for i := 1 to lastPart do
        writeln (part[i]^.name:(C_NAMELEN+1), ' IS ',
                                   part[i]^.whatIs^.name:(C_NAMELEN+1));
      goto fail;
    end;

    if upString (getTok (s, 2)) = 'PART' then
    begin
      i := searchPart (getTok (s, 3));
      if i = 0 then
      begin
        printError (s, posTok (s, 3), 'Part not defined');
        goto fail
      end;
      with part[i]^ do
      begin
        writeln ('Part: ', name, ' IS ', whatIs^.name);
        writeln ('INs:':C1, 'to':C2, 'OUTs':C1, 'to':C2,
			'PARs':C1, 'is');
        for j := 1 to max (whatIs^.num_in,
                 max (whatIs^.num_out, whatIs^.num_par)) do
        begin
          if whatIs^.num_in >= j then
            write (whatIs^.in_name[j]:C1, in_wh[j]:C2)
          else
            write (' ':C1, ' ':C2);
          if whatIs^.num_out >= j then
            write (whatIs^.out_name[j]:C1, out_wh[j]:C2)
          else
            write (' ':C1, ' ':C2);
          if whatIs^.num_par >= j then
            writeln (whatIs^.par_name[j]:C1, ' ', par[j])
          else
            writeln;
        end;
      end;
      goto fail
    end;

    if (upString (getTok (s, 2)) = 'STATE') and
		(upString (getTok (s, 3)) = 'OF')
			and (upString (getTok (s, 4)) = 'PART') then
    begin
      i := searchPart (getTok (s, 5));
      if i = 0 then
      begin
        printError (s, posTok (s, 5), 'Part not defined');
        goto fail
      end;
      with part[i]^ do
      begin
        writeln ('Part: ', name, ' IS ', whatIs^.name);
        if whatIs^.num_var > 0 then
          for j := 1 to whatIs^.num_var do
            writeln (whatIs^.var_name[j]:C1, vars[j])
        else
          writeln ('Has not variables')
      end;
      goto fail
    end;

    if upString (getTok (s, 2)) = 'TIME' then
    begin
      with time do
      begin
        writeln ('Time start: ', start:0:10);
        writeln ('Time  stop: ', stop:0:10);
        writeln ('Time  step: ', step:0:10)
      end;
      goto fail;
    end;

    if upString (getTok (s, 2)) = 'CHAIN' then
    begin
      val (getTok (s, 3), num, x);
      if x = 1 then
      begin
        printError (s, posTok (s, 3), 'number expected');
        goto fail
      end;
      for i := 1 to lastPart do
        for j := 1 to part[i]^.whatIs^.num_out do
          if part[i]^.out_wh[j] = num then
            write (i:3);
      write (' --> ');

      for i := 1 to lastPart do
        for j := 1 to part[i]^.whatIs^.num_in do
          if part[i]^.in_wh[j] = num then
            write (i:3);
      writeln;
      goto fail
    end;

    if upString (getTok (s, 2)) = 'COLLECT' then
    begin
      strwrite (tmp, 1, x, collectChain);
      parseLIST ('list chain '+tmp);
      goto fail
    end;

    printError (s, posTok (s, 2), 'Unknown LIST directive');
  fail:
  end;

  procedure parseSET (s : string);
  var
    i, num, b, x : integer;
    v : real;
    par_var : integer;
  label fail;
  begin
    if upString (getTok (s, 2)) = 'TIME' then
    begin
      if upString (getTok (s, 3)) = 'START' then
      begin
        val (getTok (s, 4), v, x);
        if x = 1 then
          printError (s, posTok (s, 4), 'number expected')
        else
          time.start := v;
        goto fail
      end;
      if upString (getTok (s, 3)) = 'STOP' then
      begin
        val (getTok (s, 4), v, x);
        if x = 1 then
          printError (s, posTok (s, 4), 'number expected')
        else
          time.stop := v;
        goto fail
      end;
      if upString (getTok (s, 3)) = 'STEP' then
      begin
        val (getTok (s, 4), v, x);
        if x = 1 then
          printError (s, posTok (s, 4), 'number expected')
        else
          time.step := v;
        goto fail
      end;
      printError (s, posTok (s, 3), 'Unknown SET TIME directive');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'PART' then
    begin
      i := searchPart (getTok (s, 3));
      if i = 0 then
      begin
        printError (s, posTok (s, 3), 'Part not defined');
        goto fail
      end;
      if (upString (getTok (s, 4)) = 'PARAMETER') or
		(upString (getTok (s, 4)) = 'VARIABLE') then
      begin
        if upString (getTok (s, 4)) = 'PARAMETER' then
          par_var := 1
        else
          par_var := 2;

        if par_var = 1 then
        begin
          num := searchParameter (i, getTok (s, 5));
          if num = 0 then
          begin
            printError (s, posTok (s, 5), 'Unknown parameter');
            goto fail
          end;
        end
        else
        begin
          num := searchVar (i, getTok (s, 5));
          if num = 0 then
          begin
            printError (s, posTok (s, 5), 'Unknown variable');
            goto fail
          end;
        end;

        if upString (getTok (s, 6)) <> 'TO' then
        begin
          printError (s, posTok (s, 6), 'TO expected');
          goto fail
        end;

        val (getTok (s, 7), v, x);
        if x = 1 then
        begin
          printError (s, posTok (s, 7), 'number expected');
          goto fail
        end;

        if par_var = 1 then
          part[i]^.par[num] := v
        else
          part[i]^.vars[num] := v;
        goto fail
      end;
      printError (s, posTok (s, 4), 'Unknown SET PART directive');
      goto fail
    end;

    if (upString (getTok (s, 2)) = 'COLLECT') and
			(upString (getTok (s, 3)) = 'PART') then
    begin
      i := searchPart (getTok (s, 4));
      if i = 0 then
      begin
        printError (s, posTok (s, 4), 'Part not defined');
        goto fail
      end;

      if upString (getTok (s, 5)) <> 'OUT' then
      begin
        printError (s, posTok (s, 5), 'OUT expected');
        goto fail
      end;

      num := searchOUT (i, getTok (s, 6));
      if num = 0 then
      begin
        printError (s, posTok (s, 6), 'unknown OUT');
        goto fail
      end;

      collectChain := part[i]^.out_wh[num];
      goto fail
    end;

    if (upString (getTok (s, 2)) = 'COLLECT') and
			(upString (getTok (s, 3)) = 'CHAIN') then
    begin
      val (getTok (s, 4), num, x);
      if x = 1 then
      begin
        printError (s, posTok (s, 4), 'number expected');
        goto fail
      end;

      collectChain := num;
      goto fail
    end;

    printError (s, posTok (s, 2), 'Unknown SET directive');
  fail:
  end;

  procedure parseCONNECT (s : string);
  var
    i, j, x : integer;
    num : integer;
    in_out : integer;
  label fail;
  begin
    i := searchPart (getTok (s, 2));
    if i = 0 then
    begin
      printError (s, posTok (s, 2), 'Part not defined');
      goto fail
    end;

    if upString (getTok (s, 3)) = 'IN' then
      in_out := 1
    else if upString (getTok (s, 3)) = 'OUT' then
      in_out := 2
    else
    begin
      printError (s, posTok (s, 3), 'IN or OUT expected');
      goto fail
    end;

    if upString (getTok (s, 5)) <> 'WITH' then
    begin
      printError (s, posTok (s, 5), 'WITH expected');
      goto fail
    end;

    if in_out = 1 then
    begin
      num := searchIN (i, getTok (s, 4));
      if num = 0 then
      begin
        printError (s, posTok (s, 4), 'unknown IN');
        goto fail
      end;
    end
    else
    begin
      num := searchOUT (i, getTok (s, 4));
      if num = 0 then
      begin
        printError (s, posTok (s, 4), 'unknown OUT');
        goto fail
      end;
    end;

    val (getTok (s, 6), j, x);
    if x = 1 then
    begin
      printError (s, posTok (s, 6), 'number expected');
      goto fail
    end;

    if in_out = 1 then
      part[i]^.in_wh[num] := j
    else
      part[i]^.out_wh[num] := j;

  fail:
  end;    { parseCONNECT }

  procedure parseSAVE (s : string);
  var i, j : integer;
    f : text;
    y_n : string[2];
  label fail;
  begin
    if (upString (getTok (s, 2)) = 'SCHEME') and
			(upString (getTok (s, 3)) = 'TO') then
    begin
      assign1 (f, getTok (s, 4));
      {$I-}
      reset (f);
      {$I+}

      if IOResult <> 0 then
      begin
        writeln ('File exist. Rewrite (Y/N)?');
        readln (y_n);
        if not ((y_n[1] = 'y') or (y_n[1] = 'Y')) then
          goto fail
      end;

      rewrite (f);

      for i := 1 to lastPart do
        writeln (f, 'new part ', part[i]^.whatIs^.name, ' name ', part[i]^.name);

      for i := 1 to lastPart do
      begin
        for j := 1 to part[i]^.whatIs^.num_in do
          writeln (f, 'connect ', part[i]^.name, ' in ',
                part[i]^.whatIs^.in_name[j], ' with ', part[i]^.in_wh[j]:0);
        for j := 1 to part[i]^.whatIs^.num_out do
          writeln (f, 'connect ', part[i]^.name, ' out ',
                part[i]^.whatIs^.out_name[j], ' with ', part[i]^.out_wh[j]:0);
        for j := 1 to part[i]^.whatIs^.num_par do
          writeln (f, 'set part ', part[i]^.name, ' parameter ',
                part[i]^.whatIs^.par_name[j], ' to ', part[i]^.par[j]:0:10);
      end;
      close (f);
      writeln ('Saved');
      goto fail
    end;

    if (upString (getTok (s, 2)) = 'STATE') and
			(upString (getTok (s, 3)) = 'TO') then
    begin
      assign1 (f, getTok (s, 4));
      {$I-}
      reset (f);
      {$I+}

      if IOResult <> 0 then
      begin
        writeln ('File exist. Rewrite (Y/N)?');
        readln (y_n);
        if not ((y_n[1] = 'y') or (y_n[1] = 'Y')) then
          goto fail
      end;

      rewrite (f);

      for i := 1 to lastPart do
      begin
        for j := 1 to part[i]^.whatIs^.num_var do
          writeln (f, 'set part ', part[i]^.name, ' variable ',
                part[i]^.whatIs^.var_name[j], ' to ', part[i]^.vars[j]:0:10);
      end;
      writeln (f, 'set time start ', time.start);
      writeln (f, 'set time stop ', time.stop);
      writeln (f, 'set time step ', time.step);
      writeln (f, 'set collect chain ', collectChain);
      close (f);
      writeln ('Saved');
      goto fail
    end;

    printError (s, posTok (s, 2), 'Unknown SAVE directive');
  fail:
  end;    { parseSAVE }

  procedure parseLOAD (s : string);
  var
    i : integer;
  label fail;
  begin
    if (upString (getTok (s, 2)) = 'SCHEME') and
			(upString (getTok (s, 3)) = 'FROM') then
    begin
      for i := 1 to lastPart do
        dispose (part[i]);

      initScheme;

      if dialog (getTok (s, 4)) = 1 then
        writeln ('Loaded from ', getTok (s, 4));
      goto fail
    end;

    if (upString (getTok (s, 2)) = 'PICTURE') and
			(upString (getTok (s, 3)) = 'FROM') then
    begin
      for i := 1 to lastPart do
        dispose (part[i]);

      initScheme;

      if readPicture (getTok (s, 4)) = 1 then
      begin
        writeln ('Loaded from ', getTok (s, 4));
        tracePicture;
        goto fail
      end;

      goto fail
    end;

    printError (s, posTok (s, 2), 'Unknown LOAD directive');
  fail:
  end;    { parseLOAD }

  procedure parseSHOW (s : string);
  var
    i, j : integer;
  label fail;
  begin
    if upString (getTok (s, 2)) = 'INCIDENT' then
    begin
      incident;

      write ('Normal     ');
      for i := 5 to lastPart do
        write ('  ');
      writeln ('Optimized');

      for i := 1 to lastPart do
      begin
        for j := 1 to lastPart do
          if incid[i, j] then
            write ('1 ')
          else
            write ('0 ');
        write ('   ');
        for j := 1 to lastPart do
          if incid[indincid[i], indincid[j]] then
            write ('1 ')
          else
            write ('0 ');
        writeln
      end;
      goto fail
    end;

    if upString (getTok (s, 2)) = 'SEQUENCE' then
    begin
      if collectChain = -1 then
      begin
        writeln ('Use SET COLLECT first');
        goto fail
      end;

      compile (collectChain);

      for i := sthead-1 downto 1 do
        write (st[i] : 0, ' ');
      writeln;
      writeln (sthead-1:0, ' elements');
      goto fail
    end;

    printError (s, posTok (s, 2), 'Unknown SHOW directive');
  fail:
  end;    { parse SHOW }  

  procedure parseHELP (s : string);
  label fail;
  begin
    if upString (getTok (s, 2)) = 'NEW' then
    begin
      writeln ('NEW PART element NAME name');
      writeln ('NEW SCHEME');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'LIST' then
    begin
      writeln ('LIST ELEMENTS');
      writeln ('LIST ALL PARTS');
      writeln ('LIST PART name');
      writeln ('LIST STATE OF PART name');
      writeln ('LIST TIME');
      writeln ('LIST CHAIN number');
      writeln ('LIST COLLECT');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'SET' then
    begin
      writeln ('SET TIME START');
      writeln ('SET TIME STOP');
      writeln ('SET TIME STEP');
      writeln ('SET PART name PARAMETER TO number');
      writeln ('SET PART name VARIABLE TO number');
      writeln ('SET COLLECT PART name OUT name');
      writeln ('SET COLLECT CHAIN number');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'CONNECT' then
    begin
      writeln ('CONNECT name IN name WITH number');
      writeln ('CONNECT name OUT name WITH number');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'SAVE' then
    begin
      writeln ('SAVE SCHEME TO fname');
      writeln ('SAVE STATE to fname');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'LOAD' then
    begin
      writeln ('LOAD SCHEME FROM fname');
      writeln ('LOAD PICTURE FROM fname');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'SHOW' then
    begin
      writeln ('SHOW INCIDENT');
      writeln ('SHOW SEQUENCE');
      goto fail
    end;

    if upString (getTok (s, 2)) = 'HELP' then
    begin
      writeln ('HELP');
      writeln ('?');
      goto fail
    end;

    if (upString (getTok (s, 2)) = 'BYE') or
			(upString (getTok (s, 2)) = 'QUIT') then
    begin
      writeln ('BYE');
      writeln ('QUIT');
      goto fail
    end;

    writeln ('BYE CONNECT HELP LIST LOAD NEW QUIT SAVE SET SHOW');
  fail:
  end;

  
var
  st : string;       { a readed string from file }
  f : text;
  tok : string;
  currLine : integer; { number of current string  for dignosis }
  stop : boolean;

label contread, exit;

begin
  assign (f, fileName);
  {$I-}
  reset (f);
  {$I+}

  currLine := 1;
  stop := false;
  dialog := 0;

  if IOResult = 0 then
  begin
    while (not Eof (f)) and (not stop) do
    begin
      readln (f, st);

      tok := upString (getTok (st, 1));

      if tok = 'NEW' then
      begin
        parseNEW (st);
        goto contread
      end;

      if (tok = 'BYE') or (tok = 'QUIT') then
      begin
        stop := true;
        goto exit
      end;

      if tok = 'LIST' then
      begin
        parseLIST (st);
        goto contread
      end;

      if tok = 'SET' then
      begin
        parseSET (st);
        goto contread
      end;

      if tok = 'CONNECT' then
      begin
        parseCONNECT (st);
        goto contread
      end;

      if tok = 'SAVE' then
      begin
        parseSAVE (st);
        goto contread
      end;

      if tok = 'LOAD' then
      begin
        parseLOAD (st);
        goto contread
      end;

      if tok = 'SHOW' then
      begin
        parseSHOW (st);
        goto contread
      end;

      if (tok = 'HELP') or (tok = '?') then
      begin
        parseHELP (st);
        goto contread
      end;

       { we didn't got any directive }
      if length (getTok (st, 1)) > 0 then
        printError (st, 0, 'Syntax error');
  contread:
      inc (currLine);
    end;     { while not eof }
  exit:
    close (f);
    dialog := 1;
  end
  else
    writeln ('Can not open file')
end;

var
  fileName : string;
begin
{  write ('Input file name: ');
  readln (fileName);
}
  clrscr;
  initElem;
  initScheme;
  dialog ('/dev/tty');
  writeln ('Bye!');
end.

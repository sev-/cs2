#include <stdio.h>
#include <stdlib.h>
#include <graphics.h>
#include <dos.h>
#include <conio.h>
#include <math.h>

#define Radix 10

void play(void);
void oct_freq(int);
void show_freq(int);
void hide_cursor(void);
void init_graph(void);
int init_mouse(void);
void set_cursor_position(void);
void set_mickey_pixel(void);
void set_cursor_shape(void);
void show_cursor(void);
void read_cursor(void);

unsigned int notes[12];

struct REGPACK ioregs;

/*******************************/
main()
{
  register int i;

  init_graph();
  init_mouse();
  set_cursor_shape();
  set_cursor_position();
  set_mickey_pixel();

  setfillstyle(SOLID_FILL, BLUE);
  bar(0, 0, 639, 349);

  setcolor(WHITE);
  rectangle(0, 0, 639, 649);

  setfillstyle(SOLID_FILL, YELLOW);
  bar(0, 100, 639, 200);

  setcolor(RED);
  for(i = 2; i < 50; i++)
    line(11+12*i, 100, 11+12*i, 200);

  setfillstyle(SOLID_FILL, BLACK);
  for(i = 0; i < 7; i++)
  {
    if(i)
      bar(7+84*i, 100, 15+84*i, 150);
    bar(31+84*i, 100, 39+84*i, 150);
    bar(43+84*i, 100, 51+84*i, 150);
    bar(67+84*i, 100, 75+84*i, 150);
    bar(79+84*i, 100, 87+84*i, 150);
    bar(91+84*i, 100, 99+84*i, 150);
  }

  setcolor(GREEN);
  for(i = 0; i < 8; i++)
    line(23+84*i, 100, 23+84*i, 200);

  play();
  closegraph();
}

void play(void)
{
  int oct = 0, oldoct = 0;
  unsigned note;
  char buffer[5];

  setfillstyle(SOLID_FILL, RED);
  bar(285, 40, 345, 70);

  setcolor(WHITE);
  settextstyle(TRIPLEX_FONT, HORIZ_DIR, 3);
  outtextxy(290, 42, "QUIT");

  show_cursor();

  while(1)
  {
    ioregs.r_bx = 0;

    while(ioregs.r_bx == 0)
    {
      read_cursor();

      printf("%d %d\r", ioregs.r_cx, ioregs.r_dx);

      if(ioregs.r_cx > 24 && ioregs.r_cx < 613)
	oct = (ioregs.r_cx - 24)/84+1;

      if(oldoct != oct)
      {
	oct_freq(oct);
	itoa(notes[0], buffer, Radix);

	setfillstyle(SOLID_FILL, RED);
	settextstyle(DEFAULT_FONT, HORIZ_DIR, 1);
	hide_cursor();
	bar(295, 80, 335, 95);
	bar(295, 6, 316, 20);

	setcolor(WHITE);
	outtextxy(300, 85, buffer);

	itoa(oct, buffer, Radix);
	outtextxy(302, 10, buffer);
	show_cursor();
	oldoct = oct;
      }
    }
    if(ioregs.r_bx == 1)
    {
      if(ioregs.r_dx > 100 && ioregs.r_dx < 200)
      {
	if(ioregs.r_cx > 24 && ioregs.r_cx < 613)
	{
	  ioregs.r_cx = ioregs.r_cx-24-(oct-1)*84;

	  if(ioregs.r_cx > 70 && ioregs.r_cx < 83)
	    note = notes[11];
	  else
	  {
	    if(ioregs.r_cx > 59 && ioregs.r_cx < 70)
	      note = notes[9];
	    else
	    {
	      if(ioregs.r_cx > 47 && ioregs.r_cx < 59)
		note = notes[7];
	      else
	      {
		if(ioregs.r_cx > 35 && ioregs.r_cx < 47)
		  note = notes[5];
		else
		{
		  if(ioregs.r_cx > 23 && ioregs.r_cx < 35)
		    note = notes[4];
		  else
		  {
		    if(ioregs.r_cx > 11 && ioregs.r_cx < 23)
		      note = notes[2];
		    else
		      if(ioregs.r_cx > 0 && ioregs.r_cx < 11)
			note = notes[0];
		  }
		}
	      }
	    }
	  }
	  if(ioregs.r_dx < 150)
	  {
	    if(ioregs.r_cx >= 67 && ioregs.r_cx <= 75)
	      note = notes[10];
	    else
	    {
	      if(ioregs.r_cx >= 55 && ioregs.r_cx <= 63)
		note = notes[8];
	      else
	      {
		if(ioregs.r_cx >= 43 && ioregs.r_cx <= 51)
		  note = notes[6];
		else
		{
		  if(ioregs.r_cx >= 19 && ioregs.r_cx <= 27)
		    note = notes[3];
		  else
		    if(ioregs.r_cx >= 8 && ioregs.r_cx <= 14)
		      note = notes[1];
		}
	      }
	    }
	  }
	  show_freq(note);
	  sound(note);
	  delay(100);
	  nosound();
	}
      }
    }
    if(ioregs.r_bx == 2)
    {
      if(ioregs.r_cx > 285 && ioregs.r_dx > 40 && ioregs.r_cx < 345
				&& ioregs.r_dx < 70)
	return;
    }
  }
}

void oct_freq(int oct)
{
  double f[12];
  register int i;

  f[0] = 32.75*pow(2.0, oct-1);
  notes[0] = (unsigned)f[0];

  for(i = 1; i <= 11; i++)
  {
    f[i] = f[0]*pow(2.0, i/12.0);
    notes[i] = (unsigned)f[i];
  }
}

void show_freq(int fr)
{
  char buffer[5];

  settextstyle(DEFAULT_FONT, HORIZ_DIR, 1);
  itoa(fr, buffer, Radix);
  setfillstyle(SOLID_FILL, RED);
  hide_cursor();
  bar(295, 205, 335, 220);
  setcolor(WHITE);
  outtextxy(300, 210, buffer);
  show_cursor();
}

void hide_cursor(void)
{
  ioregs.r_ax = 2;

  intr(0x33, &ioregs);
}

void init_graph(void)
{
  int gdriver=EGA, gmode=EGAHI, errorcode;

  initgraph(&gdriver, &gmode, "");
}

int init_mouse(void)
{
  ioregs.r_ax=0;

  intr(0x33, &ioregs);
  if(ioregs.r_ax == 0)
  {
    printf("MOUSE NOT INSTALLED! PRESS ANY KEY!\n");
    getch();
    closegraph();
    exit(1);
  }
}

void set_cursor_position(void)
{
  ioregs.r_ax = 4;
  ioregs.r_cx = 315;
  ioregs.r_dx = 160;

  intr(0x33, &ioregs);
}

void set_mickey_pixel(void)
{
  ioregs.r_ax = 15;
  ioregs.r_cx = 36;
  ioregs.r_dx = 36;

  intr(0x33, &ioregs);
}

void set_cursor_shape(void)
{
  unsigned int cursor[2][16];
  unsigned far *fpuns;
  unsigned far **pfpuns;

  cursor[1][0] = 0x0001;	/* 0000000000000001 */
  cursor[1][1] = 0x0002;	/* 0000000000000010 */
  cursor[1][2] = 0x000e;	/* 0000000000001110 */
  cursor[1][3] = 0x003c;	/* 0000000000111100 */
  cursor[1][4] = 0x00fc;	/* 0000000011111100 */
  cursor[1][5] = 0x03f8;	/* 0000001111111000 */
  cursor[1][6] = 0x0ff8;	/* 0000111111111000 */
  cursor[1][7] = 0x3ff0;	/* 0011111111110000 */
  cursor[1][8] = 0xfff0;	/* 1111111111110000 */
  cursor[1][9] = 0x3fe0;	/* 0011111111100000 */
  cursor[1][10] = 0x1fe0;	/* 0001111111100000 */
  cursor[1][11] = 0x3fc0;	/* 0011111111000000 */
  cursor[1][12] = 0x78c0;	/* 0111100011000000 */
  cursor[1][13] = 0xf000;	/* 1111000000000000 */
  cursor[1][14] = 0xe000;	/* 1110000000000000 */
  cursor[1][15] = 0xc000;	/* 1100000000000000 */

  cursor[0][0] = 0xfffc;	/* 1111111111111100 */
  cursor[0][1] = 0xfff8;	/* 1111111111111000 */
  cursor[0][2] = 0xffe0;	/* 1111111111100000 */
  cursor[0][3] = 0xff81;	/* 1111111110000001 */
  cursor[0][4] = 0xfe01;	/* 1111111000000001 */
  cursor[0][5] = 0xf803;	/* 1111100000000011 */
  cursor[0][6] = 0xe003;	/* 1110000000000011 */
  cursor[0][7] = 0x8007;	/* 1000000000000111 */
  cursor[0][8] = 0x0007;	/* 0000000000000111 */
  cursor[0][9] = 0x800f;	/* 1000000000001111 */
  cursor[0][10] = 0xc00f;	/* 1100000000001111 */
  cursor[0][11] = 0x801f;	/* 1000000000011111 */
  cursor[0][12] = 0x021f;	/* 0000001000011111 */
  cursor[0][13] = 0x07ff;	/* 0000011111111111 */
  cursor[0][14] = 0x0fff;	/* 0000111111111111 */
  cursor[0][15] = 0x1fff;	/* 0001111111111111 */

  ioregs.r_ax = 9;
  ioregs.r_bx = 16;
  ioregs.r_cx = 0;

  fpuns = (unsigned far *)cursor;
  pfpuns = &fpuns;

  ioregs.r_es = *((unsigned *)pfpuns +1);
  ioregs.r_dx = *(unsigned *)pfpuns;

  intr(0x33, &ioregs);
}

void show_cursor(void)
{
  ioregs.r_ax = 1;

  intr(0x33, &ioregs);
}

void read_cursor(void)
{
  ioregs.r_ax = 3;

  intr(0x33, &ioregs);
}
#define SPACE 0x1b
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <graphics.h>
#include <conio.h>

int max_X, max_Y;
int n555, n888;
int max_color, i54, j54;
int h, size, h2, w2, h3, w3, h3_1, w3_1, h_1, ncc, m62, d_h, b, b_1;
float p1;

main()
{
  float p;
  int i, ndn, j, nn;
  long int inf[3000], isa[3000], rc[3000], kst, n1, nbl, nt, ndsl1,
   ndsl2, kfp[12] =
  {2, 0, 4, 11, 24, 69, 157, 193, 276, 329, 484, 222}, msk, mpch, lll, nmsk3,
   ndsl3, n123 = 0, nmn[3000], n2, n88, n66, n55, mm1, ss, n44,
   n3, n5, n6, ktrh[11] =
  {8, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0}, mc4[11] =
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, ms4[11] =
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  printf("start random number? ");
  scanf("%ld", &kst);
  printf("your noise level? ");
  scanf("%f", &p);
  mpch = p * 1000;
  nmsk3 = 0x001fffffl;
  p1 = p;
  printf("block length? ");
  scanf("%ld", &nbl);
  printf("code distance? ");
  scanf("%ld", &ndn);
  if (nbl < kfp[ndn - 1] * 2 + 2)
    nbl = kfp[ndn - 1] * 2 + 2;
  size = nbl;
  kfp[0] = ndn - 1;
  ncc = ndn;
  m62 = kst;
  for (n1 = 0; n1 < nbl; n1++)
  {
    rc[n1] = 0;
    nmn[n1] = 0;
  }
  msk = 1023;
  mm1 = 1l;
  ndsl1 = kst;
  ndsl2 = 7799l;		       /* noise generation for inf branch */
  for (n1 = 0; n1 < nbl; n1++)
  {
    nt = ndsl1 & msk;
    mc4[0]++;
    if (nt <= mpch)
      inf[n1] = 1;
    else
      inf[n1] = 0;
    for (n5 = 0; n5 < 7; n5++)
    {
      lll = ndsl1 ^ ndsl2;
      ndsl1 = ndsl2 & nmsk3;
      ndsl3 = (ndsl2 >> 21) ^ (lll << 10);
      ndsl2 = ndsl3;
    }
  }				       /* noise generation for check barnch */
  for (n1 = 0; n1 < nbl; n1++)
  {
    nt = ndsl1 & msk;
    if (nt <= mpch)
      isa[n1] = 1;
    else
      isa[n1] = 0;
    for (n5 = 0; n5 < 7; n5++)
    {
      lll = ndsl1 ^ ndsl2;
      ndsl1 = ndsl2 & nmsk3;
      ndsl3 = (ndsl2 >> 21) ^ (lll << 10);
      ndsl2 = ndsl3;
    }
  }
  initialize();
  picture();
  for (nn = 0; nn < nbl; nn++)
  {
    change_color(nn, CYAN, 0);
    change_color(nn, LIGHTCYAN, 1);
    change_color(nn, YELLOW, 2);
  }
  for (nn = 0; nn < nbl; nn++)
  {
    if (inf[nn] == 1)
      change_color(nn, RED, 1);
    if (isa[nn] == 1)
    {
      change_color(nn, CYAN, 2);
      nmn[nn] = 1;
    }
  }
  for (nn = 0; nn < nbl; nn++)
  {
    if (inf[nn] == 1)
      mc4[1]++;
    if (isa[nn] == 1)
      mc4[2]++;
  } n1 = getch();		       /* syndrom calculations */
  for (n1 = 0; n1 < nbl; n1++)
  {
    if (inf[n1] == 1)
    {
      for (n2 = 1; n2 <= kfp[0]; n2++)
      {
	n66 = n1 + kfp[n2];
	if (n66 >= nbl)
	  n66 = n66 - nbl;
	isa[n66]++;
	if (nmn[n66] == 0)
	{
	  nn = n66;
	  change_color(nn, RED, 2);
	}
      }
    }
  }				       /* syndrom forming md2 f */
  for (n2 = 0; n2 < nbl; n2++)
  {
    n55 = isa[n2];
    isa[n2] = isa[n2] & mm1;
    if ((n55 != isa[n2]) && (isa[n2] == 0))
    {
      nn = n2;
      change_color(nn, YELLOW, 2);
    }
  }
  n88 = nbl / 3;
  for (n3 = 0; n3 < kfp[0]; n3++)
  {
    nn = n88 + kfp[n3 + 1];
    change_color(nn, BLACK, 2);
  }
  nn = n88;
  change_color(nn, BLACK, 1);
  change_color(nn, BLACK, 0);
  n88 = n88 - 1;
  for (n3 = 0; n3 < nbl; n3++)
    ms4[0] += isa[n3];
  n555 = ms4[0];
  n888 = mc4[1] + mc4[2];
  i = 13;
  j = max_Y * 0.7 + 55;
  j = j + 10;
  gprintf(&i, &j, "NOISE WEIGHT=%d, START DISTANCE=%d", n888, n555);
  n1 = getch();			       /* thresold work */
  for (n2 = 0; n2 < ktrh[0]; n2++)
  {
    for (n6 = 0; n6 < nbl; n6++)
    {
      n88++;
      if (n88 >= nbl)
	n88 = 0;		       /* calculation of sums */
      ss = rc[n88];
      for (n3 = 0; n3 < kfp[0]; n3++)
      {
	n44 = n88 + kfp[n3 + 1];
	if (n44 >= nbl)
	  n44 = n44 - nbl;
	ss += isa[n44];
      }
      if (ss > ktrh[n2 + 1] + kfp[0] / 2)
      {
	inf[n88] = 1 - inf[n88];
	rc[n88] = 1 - rc[n88];
	n555 = n555 + ndn - ss - ss;
	setcolor(BLACK);
	i54 = max_X / 2;
	j54 = max_Y * 0.7 + 65;
	settextstyle(0, 0, 2);
	g_printf(i54, j54, "                 %d", n123);
	setcolor(WHITE);
	n123 = n555;
	setfillstyle(SOLID_FILL, WHITE);
	g_printf(i54, j54, "CURRENT DISTANCE=%d", n555);
	for (n3 = 0; n3 < kfp[0]; n3++)
	{
	  n44 = n88 + kfp[n3 + 1];
	  if (n44 >= nbl)
	    n44 = n44 - nbl;
	  isa[n44] = 1 - isa[n44];
	}
      }
      nn = n88;
      if (rc[nn] == 0)
	change_color(nn, CYAN, 0);
      if ((rc[nn] == 1) && (inf[nn] != 1))
	change_color(nn, WHITE, 0);
      if ((rc[nn] == 1) && (inf[nn] == 1))
	change_color(nn, LIGHTGREEN, 0);
      change_color(nn, LIGHTCYAN, 1);
      if (inf[nn] == 1)
	change_color(nn, RED, 1);
      for (n3 = 0; n3 < kfp[0]; n3++)
      {
	nn = n88 + kfp[n3 + 1];
	if (nn >= nbl)
	  nn = nn - nbl;
	if (isa[nn] == 0)
	  change_color(nn, YELLOW, 2);
	if ((isa[nn] == 1) && (nmn[nn] == 1))
	  change_color(nn, CYAN, 2);
	if ((isa[nn] == 1) && (nmn[nn] != 1))
	  change_color(nn, RED, 2);
      }
      nn = n88 + 1;
      if (nn >= nbl)
	nn = nn - nbl;
      change_color(nn, BLACK, 1);
      change_color(nn, BLACK, 0);
      for (n3 = 0; n3 < kfp[0]; n3++)
      {
	nn = n88 + kfp[n3 + 1] + 1;
	if (nn >= nbl)
	  nn = nn - nbl;
	change_color(nn, BLACK, 2);
      }
      if (kbhit() != 0)
      {
	(void)getch();
	(void)getch();
      }
    }
    n1 = getch();
    for (n3 = 0; n3 < nbl; n3++)
      mc4[n2 + 3] += inf[n3];
    for (n3 = 0; n3 < nbl; n3++)
      ms4[n2 + 3] += isa[n3];
    if ((mc4[n2 + 3] == 0) || ((mc4[n2 + 3] == mc4[n2 + 2])) && (n2 > 1))
      break;
  }
  settextstyle(0, 0, 1);
  gprintf(&i, &j, "%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld", mc4[0],
	  mc4[1], mc4[2], mc4[3], mc4[4], mc4[5], mc4[6], mc4[7], mc4[8],
	  mc4[9], mc4[10]);
  gprintf(&i, &j, "%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld", ms4[0],
	  ms4[1], ms4[2], ms4[3], ms4[4], ms4[5], ms4[6], ms4[7], ms4[8],
	  ms4[9], ms4[10]);
  n1 = getch();
  closegraph();
}

picture()			       /* form data for movies */
{
  int i, i1, j;
  float coeff;

  cleardevice();
  setbkcolor(BLACK);
  setcolor(WHITE);
  settextstyle(0, 0, 2);
  cleardevice();
  settextstyle(0, 0, 1);
  i = 13;
  j = max_Y * 0.7 + 55;
  gprintf(&i, &j, "RAND=%d, P=%f, CODE R=1/2 K=%d, D=%d", m62, p1, size, ncc);
  coeff = 0.7 * max_X / (0.17 * max_Y);
  for (i = 0; i < 100; i++)
  {
    if ((coeff * i * i) >= size)
    {
      w3 = coeff * i;
      break;
    }
  }
  h3 = size / w3;
  if (w3 > size)
    w3 = size;
  d_h = 0.25 * max_Y;
  if ((size % w3) != 0)
    h2 = 0.17 * max_Y / (h3 + 1);
  w2 = max_X / w3 - 2;
  h2 = 0.8 * w2;
  b = (max_X - (w3 * (w2 + 2))) / 2;
  h = 45;
  h3_1 = 1;
  w3_1 = size - h3 * w3;
  h_1 = h + h3 * (h2 + 2);
  i = (w3 - w3_1) / 2;
  b_1 = b + (w2 + 2) * i;
  h3_1 = 1;
  settextstyle(0, 0, 2);
  i1 = textwidth("coder-decoder system");
  outtextxy((max_X - i1) / 2, 5, "CODER-DECODER SYSTEM");
  settextstyle(0, 0, 1);
  i1 = textwidth("difference");
  outtextxy((max_X - i1) / 2, h - 10, "DIFFERENCE");
  for (i = 0; i < size; i++)
    change_color(i, LIGHTBLUE, 0);
  i1 = textwidth("information");
  outtextxy((max_X - i1) / 2, h + d_h - 10, "INFORMATION");
  for (i = 0; i < size; i++)
    change_color(i, LIGHTGRAY, 1);
  i1 = textwidth("syndrom");
  outtextxy((max_X - i1) / 2, h + d_h * 2 - 10, "SYNDROM");
  for (i = 0; i < size; i++)
    change_color(i, LIGHTGREEN, 2);
}

change_color(i, color, s)	       /* dynamical draw */
int i, s, color;
{
  int j, basew, basew1, baseh;

  j = i % w3;
  i = i / w3;
  basew = b + j * (w2 + 2);
  basew1 = b_1 + j * (w2 + 2);
  baseh = h + i * (h2 + 2) + d_h * s;
  setfillstyle(SOLID_FILL, color);
  if ((i == h3))
  {
    bar(basew1, baseh, basew1 + w2, baseh + h2);
  }
  if (i < h3)
  {
    bar(basew, baseh, basew + w2, baseh + h2);
  }
  return;
}

initialize()			       /* start picture draw */
{
  int grdr, grmode;

  detectgraph(&grdr, &grmode);
  initgraph(&grdr, &grmode, "");
  max_X = getmaxx();
  max_Y = getmaxy();
  max_color = getmaxcolor() + 1;
  return;
}
int gprintf(int *xloc, int *yloc, char *format,...)	/* graphic string
							 * drawing */
{
  va_list argptr;
  char str[140];
  int cnt;

  va_start(argptr, format);
  cnt = vsprintf(str, format, argptr);
  outtextxy(*xloc, *yloc, str);
  *yloc += textheight("H") + 2;
  va_end(argptr);
  return (cnt);
}
int g_printf(int xloc, int yloc, char *format,...)	/* fixed place drawing */
{
  va_list argptr;
  char str[140];
  int cnt;

  va_start(argptr, format);
  cnt = vsprintf(str, format, argptr);
  outtextxy(xloc, yloc, str);
  va_end(argptr);
  return (cnt);
}

#include <stdio.h>
#include <graphics.h>
#include <conio.h>
#include <dos.h>

#define DATAFILE "elem.tr"
#define SQ 50
#define INSQUARE(x, y, x1, y1, x2, y2)	(x<=x2&&x>=x1&&y<=y2&&y>=y1)
#define MST 10	/* mouse step */
#define SIZEXSCHEME  3000
#define SIZEYSCHEME  3000

#define SELECTXL	(getmaxx()-96)		/* select window */
#define SELECTYL	0
#define SELECTXR	(getmaxx()-7)
#define SELECTYR	getmaxy()
#define DOWNLIFTXL 5
#define DOWNLIFTYL (getmaxy()-5)
#define DOWNLIFTXR (getmaxx()-111)
#define DOWNLIFTYR getmaxy()
#define LEFTLIFTXL (getmaxx()-102)
#define LEFTLIFTYL 5
#define LEFTLIFTXR (getmaxx()-97)
#define LEFTLIFTYR (getmaxy()-15)

typedef struct OBJ
{
  int x, y;
  struct OBJ *next;
  int number;
} OBJ;

OBJ *headobj;
OBJ *tailobj;
int numobjs;

long allocated;
long maxallocated;

typedef struct ELEMENT
{
  char name[32];
  char sizex;
  char sizey;
  struct ELEMENT *next;
  unsigned char data[1];
} ELEMENT;

typedef struct WPTR
{
  int x, y;
  int x1, y1;
  char *image;
  char **text;
} WPTR;

ELEMENT *headelem;
int numelem;
int elem_in_menu;
char **el;              /* array of elements images */
int *elsize;		/* array of elements size (x1, y1, x2, y2, ...) */
char *marker_point;
int exit_flag;
char *marker;		/* ptr to marker bitmap */
int currmarker;		/* element number (-1 if marker_point) */
int changed;		/* changing flag */
struct textsettingstype textsets;
char *symbols[4];	/* symbols '>', '<', '^' and 'v' for menus */

char *text_ask_saving[4] =
{
	"",	"Scheme was changed save?",	"", ""
};



void setgrmode(void);
void readelements(void);
void showelement(int, int, int, int);
void select(int *, int *);
void drawshape(void);
void makeimages(void);
void read_scheme(void);
void show_scheme(int, int);
char *rmalloc(int);
void add_obj(int, int, int);
void outmsg(int, int, char *);
void wopen(int, int, int, int, char **, WPTR *);
void wclose(WPTR *);
void ask_saving(void);
void save_scheme(void);
int shiftstate(void);
int ctrlstate(void);
int altstate(void);

main()
{
  int x, y;
  int key;
	int xcorner, ycorner;
	int step;

  setgrmode();

  readelements();
  setvisualpage(1);
  makeimages();
  drawshape();
  read_scheme();
  show_scheme(xcorner = 950, ycorner = 950);
  setvisualpage(0);

  exit_flag = changed = 0;
  marker = marker_point;
  putimage(0, 0, marker, COPY_PUT);

  x = y = 0;

  while((key = getch()) != 27)
	{
	if(!key)
	{
	  key = getch();
	  putimage(x, y, marker, XOR_PUT);
		if(ctrlstate())
			step = 1;
		else
			if(shiftstate())
				step = 3*MST;
			else
				step = MST;
		if(altstate())
	  {
		switch(key)
		{
		case 0x98:
			 if((ycorner-MST*3)>0)
			 {
			   ycorner -= MST*3;
			   show_scheme(xcorner, ycorner);
			 }
		   break;
		case 0xa0:
			 if((ycorner+MST*3+getmaxy()) < SIZEYSCHEME)
			 {
			   ycorner += MST*3;
			   show_scheme(xcorner, ycorner);
			 }
		   break;
		case 0x9d:
			 if((xcorner+MST*3+getmaxx()-101) < SIZEXSCHEME)
			 {
			   xcorner += MST*3;
			   show_scheme(xcorner, ycorner);
			 }
		   break;
		case 0x9b:
			 if((xcorner-MST*3) > 0)
			 {
			   xcorner -= MST*3;
			   show_scheme(xcorner, ycorner);
			 }
	    }
	  }
	  else switch(key)
	  {
	case 0x48:
	case 0x8d:
			 if(y >= step)
			 y-= step;
			 break;
	case 0x91:
	case 0x50:
			 if(y < getmaxy()-step)
			 y+=step;
			 break;
	case 0x74:
	case 0x4d:
			 if(x < getmaxx()-10-step)
			 x+=step;
			 break;
	case 0x73:
	case 0x4b:
			 if(x >= step)
			 x-=step;
		   break;
	  }
		if(INSQUARE(x, y, SELECTXL, SELECTYL, SELECTXR, SELECTYR))
			select(&x, &y);
		if(exit_flag)
		break;
			putimage(x, y, marker, XOR_PUT);
	}
	else
	  if(key == 13)
	  {
		if(INSQUARE(x, y, DOWNLIFTXL, DOWNLIFTYL, DOWNLIFTXR, DOWNLIFTYR))
		{
			 putimage(x, y, marker, XOR_PUT);
			 xcorner = (long)x*SIZEXSCHEME/(getmaxx()-111-5) - getmaxx()/2;
			 if(xcorner < 0)
				xcorner = 0;
			 if(xcorner > SIZEXSCHEME-getmaxx()+101)
				 xcorner = SIZEXSCHEME-getmaxx()+101;
			 show_scheme(xcorner, ycorner);
			 putimage(x, y, marker, XOR_PUT);
			 continue;
		}
		if(INSQUARE(x, y, LEFTLIFTXL, LEFTLIFTYL, LEFTLIFTXR, LEFTLIFTYR))
		{
			 putimage(x, y, marker, XOR_PUT);
			 ycorner = (long)y*SIZEYSCHEME/(getmaxy()-15-5) - getmaxy()/2;
			 if(ycorner < 0)
				ycorner = 0;
			 if(ycorner > SIZEYSCHEME - getmaxy())
				ycorner = SIZEYSCHEME-getmaxy();
			 show_scheme(xcorner, ycorner);
			 putimage(x, y, marker, XOR_PUT);
			 continue;
		}
		if(currmarker != -1)
		{
		  add_obj(x+xcorner, y+ycorner, currmarker);
		  marker = marker_point;
		  currmarker = -1;
		  x+=MST;
		  y+=MST;
		  putimage(x, y, marker, XOR_PUT);
		  changed = 1;
		}
	  }
  }

  if(changed)
	ask_saving();

	closegraph();
	printf("Maximum allocated %d bytes\n", maxallocated);
  return 0;
}

void select(x1, y1)
int *x1, *y1;
{
  int key;
  static int x = 0, j = 0;
  int i;

  putimage(*x1, *y1, marker, XOR_PUT);
  setfillstyle(SOLID_FILL, BLACK);

  while((*x1 >= 543) && (key = getch()) != 27)
  {
	if(!key)
	{
	  key = getch();
	  putimage(*x1, *y1, marker, XOR_PUT);
	  switch(key)
	  {
		case 0x50:
		   if(*y1 < getmaxy()-MST)
		   {
			 *y1 += MST;
			 break;
		   }
		   if(j < numelem-elem_in_menu || x != SQ-MST)
		   {
				if((x += MST) == SQ)
				{
					x = 0;
					j++;
				}
				for(i = 0; i < elem_in_menu; i++)
				{
				  if(i < elem_in_menu-2)
					bar(getmaxx()-71, i*SQ+5, getmaxx()-20, i*SQ+55);
				  else
					if(i < elem_in_menu-1)
					  bar(getmaxx()-71, i*SQ+5, getmaxx()-20, getmaxy()-3);
				  if(i*SQ+15-x < getmaxy() && i+j < numelem-1)
					putimage(getmaxx()-71, i*SQ+15-x, el[i+j], OR_PUT);
				}
				setfillstyle(SOLID_FILL, WHITE);
				bar(getmaxx()-4, ((j+elem_in_menu-1)*SQ/MST+1+x/MST)
					*getmaxy()/(SQ/MST*numelem), getmaxx(),
					getmaxy()*(j+elem_in_menu-1)/numelem);
				setfillstyle(SOLID_FILL, BLACK);
				bar(getmaxx()-4, (j*SQ/MST+x/MST-(x?0:1))*getmaxy()/(SQ/MST*numelem),
						getmaxx(), getmaxy()*j/numelem);
				line(getmaxx()-2, 0, getmaxx()-2, getmaxy());
		   }
		   break;
		case 0x48:
		   if(*y1 >= MST)
		   {
			 *y1 -= MST;
		     break;
		   }
		   if(j || x)
		   {
				if((x -= MST) < 0)
				{
				  x = SQ-MST;
				  j--;
				}
				for(i = 0; i < elem_in_menu; i++)
				{
				  if(i != -1 && i < elem_in_menu-2)
					bar(585-17, i*SQ+5, 636-17, i*SQ+55);
				  else
					if(i != -1 && i < elem_in_menu-1)
					  bar(585-17, i*SQ+5, 636-17, getmaxy()-3);
				  if(i*SQ+15-x < getmaxy() && i+j < numelem-1)
					putimage(getmaxx()-71, i*SQ+15-x, el[i+j], OR_PUT);
				}
				setfillstyle(SOLID_FILL, BLACK);
				bar(getmaxx()-4, ((j+elem_in_menu-1)*SQ/MST+x/MST+(x==SQ-MST?1:0))
					*getmaxy()/(SQ/MST*numelem)+SQ/MST, getmaxx(),
					getmaxy()*(j+elem_in_menu)/numelem);
				setfillstyle(SOLID_FILL, WHITE);
				bar(getmaxx()-4, (j*SQ/MST+x/MST)*getmaxy()/(SQ/MST*numelem),
						getmaxx(), getmaxy()*(j+1)/numelem);
				setfillstyle(SOLID_FILL, BLACK);
				line(getmaxx()-2, 0, getmaxx()-2, getmaxy());
		   }
		   break;
		case 0x4d:
		   if(*x1 < getmaxx()-10-MST)
		     *x1+=MST;
		   break;
		case 0x4b:
		   if(*x1 >= MST)
			 *x1-=MST;
		   break;

	  }
	  putimage(*x1, *y1, marker, XOR_PUT);
	}
	else
	  if(key == 13)
		{
			putimage(*x1, *y1, marker, XOR_PUT);
			if(currmarker != -1)
			{
				currmarker = -1;
				marker = marker_point;
			}
			else
			{
				currmarker = ((j+(*y1+x)/SQ) > numelem-2)?numelem-2:j+((*y1+x)/SQ);
				marker = el[currmarker];
			}
			putimage(*x1, *y1, marker, XOR_PUT);
	  }
  }
  putimage(*x1, *y1, marker, XOR_PUT);
  if(key == 27)
	exit_flag = 1;
}


void setgrmode(void)
{
	int driver = EGA;
	int mode = EGA64HI;

  initgraph(&driver, &mode, "");
  elem_in_menu = getmaxy()/SQ+2;
  gettextsettings(&textsets);
  textsets.charsize *= 8;
}

void readelements()
{
  FILE *in;
  char buf[256];
  char buf2[256];
  int sizex, sizey;
  int i, j;
  unsigned char *tmp, *tmp2;
  unsigned char k;
  ELEMENT *tmpelem, *currelem;

  numelem = 0;
  in = fopen(DATAFILE, "r");

  fgets(buf, 256, in);	/* skip string {De-Compiled Library} */

  while(!feof(in))
  {
	fgets(buf, 256, in); /* element name same as 'NPN' */
	fgets(buf2, 256, in); /* {X Size =}   2      {Y Size =}   1 */
	sscanf(buf2, "{X Size =} %d {Y Size =} %d", &sizex, &sizey);
    sizex *= 10;
	sizey *= 10;
    sizey++;
	sizex++;

	tmpelem = (ELEMENT *)rmalloc(sizeof(ELEMENT)+sizex*sizey/8+1);
	if(tmpelem == (ELEMENT *)NULL)
	  break;
    *(tmp = (char *)strrchr(buf, '\'')) = 0;   /* copying name */
	strncpy(tmpelem->name, &buf[1], 31);	/* skip { */
	tmpelem->sizex = sizex;
	tmpelem->sizey = sizey;
	if(numelem)
      currelem->next = tmpelem;
	else
	  headelem = tmpelem;
    currelem = tmpelem;
	tmpelem->next = (ELEMENT *)NULL;

	for(i = 0; i < 3; i++)
      fgets(buf, 256, in);	/* skip three comments */

	tmp = tmpelem->data;
	k = 0x80;
	*tmp = 0;
	for(i = 0; i < sizey; i++)
    {
	  fgets(buf, 256, in);
      tmp2 = buf+7;
	  for(j = 0; j < sizex; j++)
	  {
	if(*tmp2++ == '#')
	  *tmp |= k;
	k >>= 1;
	if(!k)
	{
	  tmp++;
	  k = 0x80;
	  *tmp = 0;
	}
      }
	}
	numelem++;
  }	/* while(!feof(in)) */

  fclose(in);
}

void showelement(x, y, num, color)
int x, y, num, color;
{
  unsigned char *tmp;
  int i, j;
  unsigned char k1, k;
  ELEMENT *tmpelem;

  tmpelem = headelem;

  for(i = 0; i < num && tmpelem->next != (ELEMENT *)NULL; i++)
	tmpelem = tmpelem->next;

  tmp = tmpelem->data;
  k1 = *tmp;
  k = 0x80;
  for(i = 0; i < tmpelem->sizey; i++)
	for(j = 0; j < tmpelem->sizex; j++)
	{
	  if(k1 & k)
		putpixel(x+j, y+i, color);
	  k >>= 1;
	  if(!k)
	  {
		k1 = *++tmp;
		k = 0x80;
	  }
	}
}

void drawshape(void)
{
  int i;

  setfillstyle(SOLID_FILL, BLACK);

  for(i = 0; i < 3; i++)
	rectangle(SELECTXL+i, i, getmaxx()-7-i, getmaxy()-i);

  for(i = 0; i < elem_in_menu-1; i++)
	putimage(getmaxx()-71, i*SQ+15, el[i], OR_PUT);
}

void makeimages(void)
{
  int i;
  ELEMENT *tmpelem;

  el = (char **)rmalloc(sizeof(char *)*numelem);
  elsize = (int *)rmalloc(sizeof(int)*2*numelem);
  tmpelem = headelem;
  setfillstyle(SOLID_FILL, BLACK);
  for(i = 0; i < numelem-1; i++)
  {
	bar(0, 0, 100, 100);
	showelement(0, 0, i, 15);
	el[i] = rmalloc(imagesize(0, 0, tmpelem->sizex, tmpelem->sizey));
	elsize[i*2] = tmpelem->sizex;
	elsize[i*2+1] = tmpelem->sizey;
	getimage(0, 0, tmpelem->sizex, tmpelem->sizey, el[i]);
	tmpelem = tmpelem->next;
  }

  bar(0, 0, 5, 5);
  line(1, 0, 1, 4);		/*   10000  */
  line(2, 1, 2, 3);     /*   11100  */
  line(3, 1, 3, 3);     /*   11111  */
  putpixel(4, 2, WHITE);/*   11100  */
  putpixel(5, 2, WHITE);/*   10000  */
	symbols[0] = (char *)rmalloc(imagesize(0, 0, 5, 4));
  getimage(0, 0, 5, 4, symbols[0]);

  bar(0, 0, 5, 5);
  line(4, 0, 4, 4);		/*   00001  */
  line(3, 1, 3, 3);     /*   00111  */
  line(2, 1, 2, 3);     /*   11111  */
  putpixel(1, 2, WHITE);/*   00111  */
  putpixel(0, 2, WHITE);/*   00001  */
	symbols[1] = (char *)rmalloc(imagesize(0, 0, 5, 4));
  getimage(0, 0, 5, 4, symbols[1]);

  bar(0, 0, 5, 5);
  line(0, 1, 4, 1);		/*   11111  */
  line(1, 2, 3, 2);     /*   01110  */
  line(1, 3, 3, 3);     /*   01110  */
  putpixel(2, 4, WHITE);/*   00100  */
  putpixel(2, 5, WHITE);/*   00100  */
	symbols[2] = (char *)rmalloc(imagesize(0, 0, 5, 4));
  getimage(0, 0, 5, 4, symbols[2]);

  bar(0, 0, 5, 5);
  line(0, 4, 4, 4);		/*   00100  */
  line(1, 3, 3, 3);     /*   00100  */
  line(1, 2, 3, 2);     /*   01110  */
  putpixel(2, 1, WHITE);/*   01110  */
  putpixel(2, 0, WHITE);/*   11111  */
	symbols[3] = (char *)rmalloc(imagesize(0, 0, 5, 4));
  getimage(0, 0, 5, 4, symbols[3]);

  bar(0, 0, 50, 50);
  line(0, 0, 15, 8);
  line(0, 0, 5, 12);
  line(15, 8, 5, 12);
  line(12, 10, 15, 13);
  line(15, 14, 14, 15);
  line(14, 15, 10, 11);
  setfillstyle(SOLID_FILL, WHITE);
  floodfill(4, 4, 15);
  floodfill(14, 13, 15);
  marker_point = rmalloc(imagesize(0, 0, 15, 15));
  currmarker = -1;
  getimage(0, 0, 15, 15, marker_point);
  setfillstyle(SOLID_FILL, WHITE);
  line(getmaxx()-2, 0, getmaxx()-2, getmaxy());
  bar(getmaxx()-4, 0, getmaxx(), getmaxy()*(elem_in_menu-1)/numelem+SQ/MST);
}


void show_scheme(x, y)
int x, y;
{
  OBJ *tmp;
  int a;

  setfillstyle(SOLID_FILL, BLACK);
  bar(0, 0, getmaxx()-103, getmaxy()-6);
  tmp = headobj;

  while(tmp)
  {
	if(INSQUARE(tmp->x-x, tmp->y-y, 0, 0, getmaxx()-103, getmaxy()))
	{
	  if(elsize[tmp->number*2]+tmp->x-x > getmaxx()-103)
	  {
		putimage(tmp->x-x, tmp->y-y, el[tmp->number], XOR_PUT);
		bar(tmp->x-x, tmp->y-y,
		(a = tmp->x-x+elsize[tmp->number*2])>getmaxx()-102?getmaxx()-102:a,
				tmp->y-y+elsize[tmp->number*2+1]);
	  }
	  putimage(tmp->x-x, tmp->y-y, el[tmp->number], XOR_PUT);
	}
	tmp = tmp->next;
  }
  setfillstyle(SOLID_FILL, BLACK);
  bar(getmaxx()-102, 0, SELECTXL, getmaxy());
  bar(0, getmaxy()-5, getmaxx()-101, getmaxy());
  line(getmaxx()-100, 0, getmaxx()-100, getmaxy()-6);
  line(0, getmaxy()-3, getmaxx()-101, getmaxy()-3);
  setfillstyle(SOLID_FILL, WHITE);
  bar(getmaxx()-102, ((long)getmaxy()-15)*y/SIZEYSCHEME+5, getmaxx()-97,
   ((long)getmaxy()-15)*(y+getmaxy()-15)/SIZEYSCHEME+5);
  bar(((long)getmaxx()-111)*x/SIZEXSCHEME+5, getmaxy()-5,
   ((long)getmaxx()-111)*(x+getmaxx()-111)/SIZEXSCHEME+5, getmaxy());
  putimage(0, getmaxy()-5, symbols[1], COPY_PUT);  /*  < */
  putimage(getmaxx()-106, getmaxy()-5, symbols[0], COPY_PUT);  /* > */
  putimage(getmaxx()-102,  0, symbols[3], COPY_PUT);  /* ^ */
  putimage(getmaxx()-102, getmaxy()-10, symbols[2], COPY_PUT);  /* v */
}

void read_scheme(void)
{
  FILE *in;
  char string[256];
  int x, y, number;

  numobjs = 0;

  in = fopen("data", "r");

  while(!feof(in))
  {
	fgets(string, 256, in);
	if(!strncmp(string, "end", 3))
	  break;

	sscanf(string, "%d, %d, %d", &x, &y, &number);
	add_obj(x, y, number);
  }
  fclose(in);
}

void add_obj(x, y, n)
int x, y, n;
{
  OBJ *tmpobj;

  tmpobj = (OBJ *)rmalloc(sizeof(OBJ));
  if(numobjs)
	tailobj->next = tmpobj;
  else
	headobj = tmpobj;

  tailobj = tmpobj;
  tmpobj->x = x;
  tmpobj->y = y;
  tmpobj->number = n;
  tmpobj->next = (OBJ *)NULL;
  numobjs++;
}

char *rmalloc(size)
int size;
{
  char *a;

  a = (char *)malloc(size);
  if(a == (void *)NULL)
  {
	closegraph();

	printf("error in allocating %d bytes. (%ld bytes already allocated)",
				size, allocated);
	printf("Maximum allocated %d bytes\n", maxallocated);
	exit(0);
  }
	allocated += size;
	if(allocated > maxallocated)
		maxallocated = allocated;
  return a;
}

void rfree(s)
char *s;
{
	maxallocated -= sizeof(s);
	allocated -= sizeof(s);
	free(s);
}

void wopen(x, y, x1, y1, text, w)
int x, y, x1, y1;
char **text;
WPTR *w;
{
  int i, j;
  char buf[256];

	w->image = (char *)rmalloc(imagesize(textsets.charsize*x, textsets.charsize*y,
			textsets.charsize*(x1+1), textsets.charsize*(y1+1)));
  getimage(textsets.charsize*x, textsets.charsize*y,
			textsets.charsize*(x1+1), textsets.charsize*(y1+1), w->image);
	w->text = (char **)rmalloc(sizeof(char *)*(y1-y-2));
  for(i = 0; i < y1-y-1; i++)
  {
	w->text[i] = (char *)rmalloc(x1-x-2);
	strcpy(w->text[i], text[i]);
  }
  w->x = x;
  w->y = y;
  w->x1 = x1;
  w->y1 = y1;

  setfillstyle(SOLID_FILL, BLACK);
  bar(textsets.charsize*x, textsets.charsize*y,
			textsets.charsize*(x1+1), textsets.charsize*(y1+1));
  buf[0] = '╔';
  for(i = 1; i < x1-x-1; i++)
	buf[i] = '═';
  buf[i++] = '╗';
  buf[i] = 0;
  outmsg(x, y, buf);


  for(j = y+1; j < y1; j++)
  {
	buf[0] = '║';
	buf[1] = ' ';
	buf[2] = 0;
	strcat(buf, text[j-y-1]);
	for(i = strlen(buf); i < x1-x-1; i++)
	  buf[i] = ' ';
	buf[i++] = '║';
	buf[i] = 0;
	outmsg(x, j, buf);
  }

  buf[0] = '╚';
  for(i = 1; i < x1-x-1; i++)
	buf[i] = '═';
  buf[i++] = '╝';
  outmsg(x, y1, buf);

}

void outmsg(x, y, s)
int x, y;
char *s;
{
  outtextxy(textsets.charsize*x, textsets.charsize*y, s);
}

void wclose(w)
WPTR *w;
{
  int i;

  putimage(w->x*textsets.charsize, w->y*textsets.charsize, w->image, COPY_PUT);

  rfree(w->image);
  w->image = (char *)NULL;
  for(i = 0; i < w->y1-w->y-1; i++)
	rfree(w->text[i]);
  rfree(w->text);
  w->text = (char **)NULL;
}

void ask_saving(void)
{
  WPTR w1;
  int key;
  int x, y;
  int ok = !0;

  y = getmaxy()/textsets.charsize/2+1;

  wopen(20, y-3, 48, y+2, text_ask_saving, &w1);
  setcolor(WHITE);
  outtextxy(37*textsets.charsize, y*textsets.charsize, "No");
  setfillstyle(SOLID_FILL, WHITE);
  bar(26*textsets.charsize ,y*textsets.charsize, 31*textsets.charsize,
										(y+1)*textsets.charsize);
  setcolor(BLACK);
  outtextxy(27*textsets.charsize, y*textsets.charsize, "Yes");

  while((key = getch()) != 13)
  {
	if(!key)
	{
	  key = getch();
	  setfillstyle(SOLID_FILL, BLACK);
	  bar(26*textsets.charsize ,y*textsets.charsize, 40*textsets.charsize,
				(y+1)*textsets.charsize);
	  switch(key)
	  {
		case 0x4d:
		case 0x4b:
		   if(ok)
		   {
			 setcolor(WHITE);
			 outtextxy(27*textsets.charsize, y*textsets.charsize, "Yes");
			 setfillstyle(SOLID_FILL, WHITE);
			 bar(36*textsets.charsize ,y*textsets.charsize,
					40*textsets.charsize, (y+1)*textsets.charsize);
			 setcolor(BLACK);
			 outtextxy(37*textsets.charsize, y*textsets.charsize, "No");
			 ok = !ok;
		   }
		   else
		   {
			 setcolor(WHITE);
			 outtextxy(37*textsets.charsize, y*textsets.charsize, "No");
			 setfillstyle(SOLID_FILL, WHITE);
			 bar(26*textsets.charsize ,y*textsets.charsize,
					31*textsets.charsize, (y+1)*textsets.charsize);
			 setcolor(BLACK);
			 outtextxy(27*textsets.charsize, y*textsets.charsize, "Yes");
			 ok = !ok;
		   }
	  }
	}
  }
  wclose(&w1);

  if(ok)
	save_scheme();
}

void save_scheme(void)
{
  FILE *out;
  OBJ *tmpobj;

  tmpobj = headobj;

  out = fopen("data", "w");

  while(tmpobj)
  {
	fprintf(out, "%d, %d, %d\n", tmpobj->x, tmpobj->y, tmpobj->number);
	tmpobj = tmpobj->next;
  }
  fprintf(out, "end\n");

  fclose(out);
}


int shiftstate(void)
{
  struct REGPACK reg;

  reg.r_ax = 0x0200;

  intr(0x16, &reg);

  return (reg.r_ax & 0x03);
}

int ctrlstate(void)
{
  struct REGPACK reg;

  reg.r_ax = 0x0200;

  intr(0x16, &reg);

	return (reg.r_ax & 0x04);
}

int altstate(void)
{
  struct REGPACK reg;

  reg.r_ax = 0x0200;

  intr(0x16, &reg);

	return (reg.r_ax & 0x08);
}

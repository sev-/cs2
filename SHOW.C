#include <stdio.h>

#define at(x, y)	printf("\033[%02d;%02dH", y, x)
#define getmaxy()	230
#define getmaxx()	780
#define SQ		10
#define INSQUARE(x, y, x1, y1, x2, y2) (x<=x2&&x>=x1&&y<=y2&&y>=y1)

typedef struct OBJ
{
  int x, y;
  struct OBJ *next;
  char name;
} OBJ;

OBJ *headobj;
int numobjs;

main()
{
  int i, j;
  OBJ ***screen;
  OBJ *tmpobj;
  int x, y;

  read_data();

  x = y = 0;
  tmpobj = headobj;

  screen = (OBJ ***)malloc(sizeof(OBJ *)*getmaxy()/SQ);
  for(i = 0; i < getmaxy()/SQ; i++)
    screen[i] = (OBJ **)malloc(sizeof(OBJ *)*getmaxx()/SQ);

  for(i = 0; i < getmaxy()/SQ; i++)
    for(j = 0; j < getmaxx()/SQ; j++)
      screen[i][j] = (OBJ *)NULL;

  for(i = 0; i < numobjs; i++)
  {
    if(INSQUARE(tmpobj->x+x, tmpobj->y+y, 0, 0, getmaxx(), getmaxy()))
    {
      screen[tmpobj->y/SQ][tmpobj->x/SQ] = tmpobj;
      printf("%c", tmpobj->name);
    }
    tmpobj = tmpobj->next;
  }

  for(i = 0; i < getmaxy()/SQ; i++)
    for(j = 0; j < getmaxx()/SQ; j++)
      if(screen[i][j] != (OBJ *)NULL)
      {
        at(j, i);
        printf("%c", screen[i][j]->name);
      }    
}

read_data()
{
  FILE *in;
  char string[256];
  OBJ *tmpobj;
  OBJ *prevobj;

  numobjs = 0;

  in = fopen("data", "r");

  while(!feof(in))
  {
    fgets(string, 256, in);
    if(!strncmp(string, "end", 3))
      break;
    tmpobj = (OBJ *)malloc(sizeof(OBJ));
    if(numobjs)
      prevobj->next = tmpobj;
    else
      headobj = tmpobj;

    sscanf(string, "%d, %d, %c", &tmpobj->x, &tmpobj->y, &tmpobj->name);
    numobjs++;
    prevobj = tmpobj;
  }
  fclose(in);
}

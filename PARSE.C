#include <stdio.h>

#define DATA "elem"

main()
{
  FILE *in;
  char string[256];
  FILE *out;

  if((in = fopen(DATA, "r")) == (FILE *)NULL)
  {
    printf("Can't open %s\n", DATA);
    exit(1);
  }

  out = fopen("elem.tr", "w");

  while(!feof(in))
  {
    fgets(string, 256, in);
    if(*string == '{' || *string == '\'' || string[6] == '{')
      fputs(string, out);
  }
  fclose(in);
  fclose(out);
}
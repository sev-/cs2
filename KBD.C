#include <stdio.h>
#include <dos.h>
#include <stdio.h>

main()
{
	struct REGPACK reg;
	int prev = 0, key;

	while((key = getch())!=27)
	{
		reg.r_ax = 0x0200;

		intr(0x16, &reg);

		if(reg.r_ax != prev)
		{
			prev = reg.r_ax;
			printf("%x: ", reg.r_ax);
		}
		printf("%x\n", key);
	}
}

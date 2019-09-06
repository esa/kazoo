/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "b.h"
#include <stdio.h>

void b_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
	printf ("[B] startup\n");
}

void b_PI_callee()
{
	printf ("[B] callee\n");
}

void b_PI_second_callee ()
{
	printf ("[B] second_callee\n");
}

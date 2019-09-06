/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "c.h"
#include <stdio.h>

void c_startup()
{
	printf ("[C] startup\n");
}

void c_PI_cyclic_activation()
{
	printf ("[C] cyclic activation. calling B (callee and second_callee)\n");
	c_RI_callee ();
	c_RI_second_callee ();
}

void c_PI_callee()
{
	printf ("[C] callee\n");
}


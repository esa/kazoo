/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "a.h"

#include <stdio.h>
void a_startup()
{
	printf ("[A] startup\n");
}

void a_PI_cyclic_activation()
{
	printf ("[A] cyclic activation. calling B and C\n");
	a_RI_caller ();
	a_RI_call_c ();
}


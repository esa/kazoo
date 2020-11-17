/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "b.h"
#include <stdio.h>

void b_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
        printf ("[B] startup\n");
}

void b_PI_Hello(const asn1SccT_POS *IN_in_param)
{
	/* Write your code here! */
        printf ("[B] Hello (value = %"PRId64")\n", IN_in_param->u.first_choice);
}


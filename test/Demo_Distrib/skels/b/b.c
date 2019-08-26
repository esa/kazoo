/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "b.h"
#include <stdio.h>

void b_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
    printf ("[B] Startup\n");
}

void b_PI_ping(const asn1SccMy_Integer *IN_p1)
{
	/* Write your code here! */
    printf ("[B] ping! (%lld)\n", *IN_p1);
    b_RI_pong();
}


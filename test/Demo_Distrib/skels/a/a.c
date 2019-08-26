/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "a.h"
#include <stdio.h>

void a_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
    printf ("[A] Startup\n");
}

void a_PI_ping()
{
	printf ("[A] ping!\n");

}

void a_PI_cyclic_activation()
{
	/* Write your code here! */
    static asn1SccMy_Integer value = 0;

    a_RI_pong (&value);
    value ++;
}


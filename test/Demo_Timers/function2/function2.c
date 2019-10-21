/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "function2.h"
#include <stdio.h>

void function2_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
    printf ("[function2] startup \n");
}

void function2_PI_PI1(const asn1SccT_Boolean *toto)
{
	/* Write your code here! */
    asn1SccT_UInt32 value = 5000;
    function2_RI_SET_my_timer(&value);
    printf("[function2] timer_should expire in 5 seconds\n");
}


void function2_PI_my_timer()
{
    printf ("[function2] timer expired!\n");
}

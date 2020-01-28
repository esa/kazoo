/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "function4.h"
#include <unistd.h>

void function4_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function4_PI_unp_ri(const asn1SccMyInteger *IN_inp, asn1SccMyInteger *OUT_outp)
{
    sleep(1);
    *OUT_outp = *IN_inp;
}


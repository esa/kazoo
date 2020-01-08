/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "function3.h"

void function3_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function3_PI_unp_pi(const asn1SccMyInteger *IN_inp, asn1SccMyInteger *OUT_outp)
{
   function3_RI_unp_ri(IN_inp, OUT_outp); 
   //*OUT_outp = *IN_inp;
}


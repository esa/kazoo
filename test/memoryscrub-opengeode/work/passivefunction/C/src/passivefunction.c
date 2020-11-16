/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "passivefunction.h"

void passivefunction_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
}

void passivefunction_PI_computeGNC(const asn1SccMyInteger *IN_inp, asn1SccMyInteger *OUT_outp)
{
	*OUT_outp = *IN_inp + 1;
}


/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "f1.h"
#include <stdio.h>

void f1_startup()
{
    printf ("[f1] startup\n");
}

static asn1SccMyInteger counterA = 0;
static asn1SccMyInteger counterB = 0;

void f1_PI_pulse()
{
   f1_RI_A(&counterA);
   counterA++;
   f1_RI_B(&counterB); 
   counterB++;
}


/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "caller_in_c.h"
#include <stdio.h>

void caller_in_c_startup()
{   
    printf("[C] startup\n");
}

void caller_in_c_PI_pulse()
{
 static asn1SccMyInteger i1=0, i2=1, o1, o2;

 printf("[C] Calling in C\n");
 caller_in_c_RI_RunDriver(&i1, &i2, &o1, &o2);

 printf ("[C] i1 = %lld, i2 = %lld, o1 = %lld, o2 = %lld", i1,i2,o1,o2);
 if (i1 != o2 || i2 != o1) {
     printf ("... ERROR!\n");
     exit(-1);
 }
 else printf("...OK\n");
 i1++;
 i2++;

}


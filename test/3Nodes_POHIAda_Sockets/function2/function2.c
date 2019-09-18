/* User code: This file will not be overwritten by TASTE. */

#include "function2.h"
#include <stdio.h>
void function2_startup()
{
    puts("[Function2] Startup");
}

void function2_PI_f2(const asn1SccTASTE_Boolean *IN_a)
{
    printf ("[Function2 Received %s\n", *IN_a ? "TRUE" : "FALSE");
}


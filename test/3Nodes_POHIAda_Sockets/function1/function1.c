/* User code: This file will not be overwritten by TASTE. */

#include "function1.h"
#include <stdio.h>
void function1_startup()
{
    puts("[Function1] Startup");
}

void function1_PI_f1(const asn1SccTASTE_Boolean *IN_a)
{
    printf ("[Function1] Received %s\n", *IN_a ? "TRUE" : "FALSE");
}


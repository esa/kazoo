/* User code: This file will not be overwritten by TASTE. */

#include "function2.h"

void function2_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function2_PI_t(const asn1SccTASTE_Boolean *IN_t)
{
    /* Write your code here! */
    printf("function1.c got %s ", *IN_t?"TRUE\n":"FALSE\n");
}


/* User code: This file will not be overwritten by TASTE. */

#include <stdio.h>

#include "function1.h"

void function1_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function1_PI_pulse()
{
    static asn1SccT_Int32 i=0, o;
    
    function1_RI_doSomethingInCPP(&i, &o);
    printf("Send %lld, got %lld\n", i, o);
}


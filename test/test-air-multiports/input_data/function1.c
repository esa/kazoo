/* User code: This file will not be overwritten by TASTE. */

#include "function1.h"

void function1_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function1_PI_cycl()
{
    static asn1SccT_Boolean someBool = true;
    /* Write your code here! */
    printf("function1_RI_t is sending %s\n", someBool?"TRUE":"FALSE");
    function1_RI_t(&someBool);
    someBool = someBool?false:true;
}




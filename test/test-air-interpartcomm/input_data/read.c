/* User code: This file will not be overwritten by TASTE. */

#include "read.h"

void read_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void read_PI_h()
{
    static asn1SccT_Boolean someBool = true;
    /* Write your code here! */
    printf("executing partition defined by TASTE\n");
    read_RI_s(&someBool);
    someBool = someBool?false:true;
}


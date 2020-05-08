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
    printf("[read] PI_h\n");
    printf("[read] Calling RI_s %s\n", someBool?"TRUE":"FALSE");

    read_RI_s(&someBool);

    someBool = someBool?false:true;
    asn1SccT_Int32 int1 = 100;
    printf("[read] Calling RI_z %u\n", int1);

    read_RI_z(&int1);
}

void read_PI_new(const asn1SccMyOctStr *IN_c)
{
        /* Write your code here! */
        printf("[read] PI_new: got %d \n", IN_c->arr[1]);
}




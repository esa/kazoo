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
    printf("[read] Calling RI_z %s\n", someBool?"TRUE":"FALSE");

    read_RI_z(&someBool);
}

void read_PI_new(const asn1SccTASTE_Boolean *IN_c)
{
        /* Write your code here! */
        printf("[read] PI_new: got %s ", *IN_c?"TRUE\n":"FALSE\n");
}




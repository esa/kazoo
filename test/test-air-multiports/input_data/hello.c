/* User code: This file will not be overwritten by TASTE. */

#include "hello.h"

void hello_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void hello_PI_s(const asn1SccTASTE_Boolean *IN_t)
{
    /* Write your code here! */
    printf("[hello] PI_s: got %s\n", *IN_t?"TRUE":"FALSE");
    asn1SccMyOctStr str1;
    str1.arr[0]=100;
    str1.arr[1]=101;
    printf("[hello] Calling RI_new\n");

    hello_RI_new(&str1);

}


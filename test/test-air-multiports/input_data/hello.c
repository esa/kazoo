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
    printf("[hello] Calling RI_new %s\n", *IN_t?"TRUE":"FALSE");

    hello_RI_new(IN_t);

}


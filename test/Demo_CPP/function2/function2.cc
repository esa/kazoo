/* User code: This file will not be overwritten by TASTE. */

#include <iostream>

#include "function2.h"

void function2_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function2_PI_doSomethingInCPP(const asn1SccT_Int32 *IN_in1,
                                   asn1SccT_Int32 *OUT_out1)
{
    /* Write your code here! */
    std::cout << *IN_in1 << std::endl;
    *OUT_out1 = *IN_in1 + 1;
}


/* User code: This file will not be overwritten by TASTE. */

#include "gr740.h"
#include <stdio.h>

void gr740_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
    //unsigned int *direction = (unsigned int *)0xFFA0B000;
    //*direction = 0xFFCFF;
    printf("[gr740_startup]\n");
}

void gr740_PI_print(const asn1SccT_Int8 *IN_inpPC)
{
    /* Write your code here! */
    printf("[gr740_PI_print] Received %d\n", *IN_inpPC);
    fflush(stdout);
}

void gr740_PI_cycle()
{
    asn1SccT_Int32 val = 0x0BADBEEF;
    /* Write your code here! */
    printf("[gr740_PI_cycle] Sending %x...\n", val);
    gr740_RI_fromGr740(&val);
    fflush(stdout);
}


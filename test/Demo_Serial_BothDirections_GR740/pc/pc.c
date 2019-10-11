/* User code: This file will not be overwritten by TASTE. */

#include "pc.h"
#include <stdio.h>

void pc_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
    printf("[pc_startup]\n");
    fflush(stdout);
}

void pc_PI_cyclePC()
{
    /* Write your code here! */
    static asn1SccT_Int8 toSend = 0;
    printf("[pc_PI_cyclePC] Sent %d\n", toSend);
    fflush(stdout);
    pc_RI_print(&toSend);
    
    if(toSend < 255){
        toSend++;
    }else{
        toSend = 0;
    }
}


void pc_PI_fromGr740(const asn1SccT_Int32 *arg)
{
    printf("[pc_PI_fromGr740] Received: %x\n", *arg);
    fflush(stdout);
}

/* User code: This file will not be overwritten by TASTE. */

#include "livesingr740.h"

void livesingr740_startup()
{
    puts("[livesingr740_startup]");
}

void livesingr740_PI_something(const asn1SccT_SEQ *IN_inputData)
{
    printf("[livesinxgr740_PI_something] anInt:  %lld\n", IN_inputData->anInt);
    printf("[livesinxgr740_PI_something] aFloat: %f\n", IN_inputData->aFloat);
    printf("[livesinxgr740_PI_something] arr[0]: %f\n", IN_inputData->anArray.arr[0]);
    printf("[livesinxgr740_PI_something] arr[1]: %f\n", IN_inputData->anArray.arr[1]);
    printf("[livesinxgr740_PI_something] arr[2]: %f\n", IN_inputData->anArray.arr[2]);
    livesingr740_RI_report(IN_inputData);
}


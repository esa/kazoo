/* User code: This file will not be overwritten by TASTE. */

#include "livesinx86.h"

void livesinx86_startup()
{
    puts("[livesinx86_startup]");
}


void livesinx86_PI_pulse()
{
    asn1SccT_SEQ inputData;
    
    inputData.anInt = 3;
    inputData.aFloat = 1.2718;
    inputData.anArray.arr[0] = 1;
    inputData.anArray.arr[1] = 2;
    inputData.anArray.arr[2] = 3;
    puts("[livesinx86_PI_pulse] Calling livesinx86_RI_something...");
    livesinx86_RI_something(&inputData);
}

void livesinx86_PI_report(const asn1SccT_SEQ *IN_inputData)
{
    printf("[livesinx86_PI_report] anInt:  %lld\n", IN_inputData->anInt);
    printf("[livesinx86_PI_report] aFloat: %f\n", IN_inputData->aFloat);
    printf("[livesinx86_PI_report] arr[0]: %f\n", IN_inputData->anArray.arr[0]);
    printf("[livesinx86_PI_report] arr[1]: %f\n", IN_inputData->anArray.arr[1]);
    printf("[livesinx86_PI_report] arr[2]: %f\n", IN_inputData->anArray.arr[2]);
}


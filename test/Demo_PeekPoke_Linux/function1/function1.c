/* User code: This file will not be overwritten by TASTE. */

#include "function1.h"
int maxime;
int thanassis = 42;
void function1_startup()
{
    maxime = 1;
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function1_PI_pulse()
{
    puts("pulse");
    maxime ++;
    thanassis ++;
    /* Write your code here! */
}


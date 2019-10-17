/* User code: This file will not be overwritten by TASTE. */

#include "driver.h"

void driver_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

static unsigned int storage = 0;

void driver_PI_setDataNative(const asn1SccT_Int32 *IN_gpio)
{
    storage = *IN_gpio;
}

void driver_PI_getDataNative(asn1SccT_Int32 *OUT_gpio)
{
    *OUT_gpio = storage + 1;
}


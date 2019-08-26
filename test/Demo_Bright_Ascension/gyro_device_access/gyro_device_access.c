/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "gyro_device_access.h"

static asn1SccT_Int32 memory[2] = {22, 55};

void gyro_device_access_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void gyro_device_access_PI_dasAcquireFromDevice(const asn1SccT_Int32 *IN_parameterid, asn1SccT_Int32 *OUT_parametervalue)
{
    *OUT_parametervalue = memory[*IN_parameterid];
}

void gyro_device_access_PI_dasCommandDevice(const asn1SccT_Int32 *IN_commandID, const asn1SccT_Int32 *IN_argument)
{
    /* Write your code here! */
}

void gyro_device_access_PI_GUIsetAngularRate(const asn1SccT_Int32 *IN_newRate)
{
    memory[0] = *IN_newRate;
}

void gyro_device_access_PI_GUIsetTemperature(const asn1SccT_Int32 *IN_newTemp)
{
    memory[1] = *IN_newTemp;
}
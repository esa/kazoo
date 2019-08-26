/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "virtual_gyro_device.h"

void virtual_gyro_device_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void virtual_gyro_device_PI_dvsAcquireFromDevice(const asn1SccT_Int32 *IN_paramerID, asn1SccT_Int32 *OUT_parameterValue)
{
   virtual_gyro_device_RI_dasAcquireFromDevice(IN_paramerID, OUT_parameterValue);
}

void virtual_gyro_device_PI_dvsCommandDevice(const asn1SccT_Int32 *IN_commandID,
                                             const asn1SccT_Int32 *IN_argument)
{  
    virtual_gyro_device_RI_dasCommandDevice(IN_commandID, IN_argument);
}




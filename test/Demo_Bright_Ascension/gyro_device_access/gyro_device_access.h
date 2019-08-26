/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_gyro_device_access__
#define __USER_CODE_H_gyro_device_access__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void gyro_device_access_startup();

void gyro_device_access_PI_dasAcquireFromDevice(const asn1SccT_Int32 *, asn1SccT_Int32 *);

void gyro_device_access_PI_dasCommandDevice(const asn1SccT_Int32 *, const asn1SccT_Int32 *);

void gyro_device_access_PI_GUIsetAngularRate(const asn1SccT_Int32 *);

void gyro_device_access_PI_GUIsetTemperature(const asn1SccT_Int32 *);

#ifdef __cplusplus
}
#endif


#endif

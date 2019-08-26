/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_virtual_gyro_device__
#define __USER_CODE_H_virtual_gyro_device__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void virtual_gyro_device_startup();

void virtual_gyro_device_PI_dvsAcquireFromDevice(const asn1SccT_Int32 *, asn1SccT_Int32 *);

void virtual_gyro_device_PI_dvsCommandDevice(const asn1SccT_Int32 *, const asn1SccT_Int32 *);

extern void virtual_gyro_device_RI_dasCommandDevice(const asn1SccT_Int32 *, const asn1SccT_Int32 *);

extern void virtual_gyro_device_RI_dasAcquireFromDevice(const asn1SccT_Int32 *, asn1SccT_Int32 *);

#ifdef __cplusplus
}
#endif


#endif

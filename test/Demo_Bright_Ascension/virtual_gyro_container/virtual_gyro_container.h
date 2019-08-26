/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_virtual_gyro_container__
#define __USER_CODE_H_virtual_gyro_container__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void virtual_gyro_container_startup();

void virtual_gyro_container_PI_getValue(const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

void virtual_gyro_container_PI_getAngularRate(asn1SccT_Int32 *);

void virtual_gyro_container_PI_getTemperature(asn1SccT_Int32 *);

extern void virtual_gyro_container_RI_dvsAcquireFromDevice(const asn1SccT_Int32 *, asn1SccT_Int32 *);

extern void virtual_gyro_container_RI_dvsCommandDevice(const asn1SccT_Int32 *, const asn1SccT_Int32 *);

#ifdef __cplusplus
}
#endif


#endif

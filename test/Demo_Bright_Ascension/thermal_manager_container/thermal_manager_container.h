/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_thermal_manager_container__
#define __USER_CODE_H_thermal_manager_container__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void thermal_manager_container_startup();

void thermal_manager_container_PI_setValue(const asn1SccT_Int32 *, const asn1SccT_Int32 *, asn1SccT_MO_ErrorCodes *);

void thermal_manager_container_PI_thermalManagerHeaterOn(const asn1SccT_Boolean *);

extern void thermal_manager_container_RI_heaterOn(const asn1SccT_Boolean *);

#ifdef __cplusplus
}
#endif


#endif

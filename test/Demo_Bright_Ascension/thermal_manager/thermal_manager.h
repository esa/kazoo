/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_thermal_manager__
#define __USER_CODE_H_thermal_manager__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void thermal_manager_startup();

void thermal_manager_PI_heaterOn(const asn1SccT_Boolean *);

extern void thermal_manager_RI_GUIupdateHeaterOverride(const asn1SccT_Boolean *);

#ifdef __cplusplus
}
#endif


#endif

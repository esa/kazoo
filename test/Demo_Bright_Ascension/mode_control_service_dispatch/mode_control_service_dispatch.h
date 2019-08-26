/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_mode_control_service_dispatch__
#define __USER_CODE_H_mode_control_service_dispatch__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void mode_control_service_dispatch_startup();

void mode_control_service_dispatch_PI_getMode(const asn1SccT_apid *, asn1SccT_SpacecraftMode *);

void mode_control_service_dispatch_PI_setMode(const asn1SccT_apid *, const asn1SccT_SpacecraftMode *);

void mode_control_service_dispatch_PI_reset(const asn1SccT_apid *);

extern void mode_control_service_dispatch_RI_getMode(asn1SccT_SpacecraftMode *);

extern void mode_control_service_dispatch_RI_setMode(const asn1SccT_SpacecraftMode *);

extern void mode_control_service_dispatch_RI_reset();

#ifdef __cplusplus
}
#endif


#endif

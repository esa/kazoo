/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_mode_control_service_adapter__
#define __USER_CODE_H_mode_control_service_adapter__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void mode_control_service_adapter_startup();

void mode_control_service_adapter_PI_modeControlServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mode_control_service_adapter_RI_getMode(const asn1SccT_apid *, asn1SccT_SpacecraftMode *);

extern void mode_control_service_adapter_RI_setMode(const asn1SccT_apid *, const asn1SccT_SpacecraftMode *);

extern void mode_control_service_adapter_RI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mode_control_service_adapter_RI_reset(const asn1SccT_apid *);

#ifdef __cplusplus
}
#endif


#endif

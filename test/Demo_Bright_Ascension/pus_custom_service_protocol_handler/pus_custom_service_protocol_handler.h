/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_pus_custom_service_protocol_handler__
#define __USER_CODE_H_pus_custom_service_protocol_handler__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void pus_custom_service_protocol_handler_startup();

void pus_custom_service_protocol_handler_PI_customServiceRequest(const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

extern void pus_custom_service_protocol_handler_RI_getMode(const asn1SccT_apid *, asn1SccT_SpacecraftMode *);

extern void pus_custom_service_protocol_handler_RI_setMode(const asn1SccT_apid *, const asn1SccT_SpacecraftMode *);

extern void pus_custom_service_protocol_handler_RI_serviceResponse(const asn1SccT_apid *, const asn1SccT_PUS_tm_userDataField *);

#ifdef __cplusplus
}
#endif


#endif

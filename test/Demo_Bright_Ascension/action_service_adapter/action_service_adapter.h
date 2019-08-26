/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_action_service_adapter__
#define __USER_CODE_H_action_service_adapter__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void action_service_adapter_startup();

void action_service_adapter_PI_actionServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void action_service_adapter_RI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void action_service_adapter_RI_submitAction(const asn1SccT_apid *, const asn1SccT_Int32 *);

#ifdef __cplusplus
}
#endif


#endif

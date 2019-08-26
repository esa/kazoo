/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_alert_service_adapter__
#define __USER_CODE_H_alert_service_adapter__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void alert_service_adapter_startup();

void alert_service_adapter_PI_alertServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

void alert_service_adapter_PI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_MO_AlertEventDetails *);

extern void alert_service_adapter_RI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void alert_service_adapter_RI_enableGeneration(const asn1SccT_apid *, const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

#ifdef __cplusplus
}
#endif


#endif

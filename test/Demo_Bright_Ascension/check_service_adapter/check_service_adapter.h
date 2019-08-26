/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_check_service_adapter__
#define __USER_CODE_H_check_service_adapter__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void check_service_adapter_startup();

void check_service_adapter_PI_checkServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void check_service_adapter_RI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void check_service_adapter_RI_triggerCheck(const asn1SccT_apid *, const asn1SccT_Int32List *, const asn1SccT_Int32List *);

extern void check_service_adapter_RI_enableCheck(const asn1SccT_apid *, const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

extern void check_service_adapter_RI_getSummaryReport(const asn1SccT_apid *, const asn1SccT_Int32List *, asn1SccT_MO_CheckSummaryList *);

#ifdef __cplusplus
}
#endif


#endif

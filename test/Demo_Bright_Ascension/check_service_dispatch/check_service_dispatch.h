/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_check_service_dispatch__
#define __USER_CODE_H_check_service_dispatch__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void check_service_dispatch_startup();

void check_service_dispatch_PI_triggerCheck(const asn1SccT_apid *, const asn1SccT_Int32List *, const asn1SccT_Int32List *);

void check_service_dispatch_PI_enableCheck(const asn1SccT_apid *, const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

void check_service_dispatch_PI_getSummaryReport(const asn1SccT_apid *, const asn1SccT_Int32List *, asn1SccT_MO_CheckSummaryList *);

void check_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_CheckResult *);

extern void check_service_dispatch_RI_triggerCheck(const asn1SccT_Int32List *, const asn1SccT_Int32List *);

extern void check_service_dispatch_RI_enableCheck(const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

extern void check_service_dispatch_RI_getSummaryReport(const asn1SccT_Int32List *, asn1SccT_MO_CheckSummaryList *);

extern void check_service_dispatch_RI_checkMonitorValueNotification(const asn1SccT_Int32 *, const asn1SccT_MO_CheckResult *);

#ifdef __cplusplus
}
#endif


#endif

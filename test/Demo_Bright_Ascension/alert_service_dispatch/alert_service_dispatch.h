/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_alert_service_dispatch__
#define __USER_CODE_H_alert_service_dispatch__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void alert_service_dispatch_startup();

void alert_service_dispatch_PI_enableGeneration(const asn1SccT_apid *, const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

void alert_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_MO_AlertEventDetails *);

extern void alert_service_dispatch_RI_alertEnableGeneration(const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

extern void alert_service_dispatch_RI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_MO_AlertEventDetails *);

#ifdef __cplusplus
}
#endif


#endif

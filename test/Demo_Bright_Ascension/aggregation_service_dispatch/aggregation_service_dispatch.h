/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_aggregation_service_dispatch__
#define __USER_CODE_H_aggregation_service_dispatch__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void aggregation_service_dispatch_startup();

void aggregation_service_dispatch_PI_enableGeneration(const asn1SccT_apid *, const asn1SccT_InstanceBooleanPairList *);

void aggregation_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_AggregationValue *);

void aggregation_service_dispatch_PI_getValue(const asn1SccT_apid *, const asn1SccT_Int32List *, asn1SccT_MO_AggregationValueList *);

void aggregation_service_dispatch_PI_monitorValueRegister(const asn1SccT_apid *, const asn1SccT_apid *, const asn1SccT_String *);

void aggregation_service_dispatch_PI_monitorValueDeregister(const asn1SccT_apid *, const asn1SccT_apid *, const asn1SccT_String *);

extern void aggregation_service_dispatch_RI_aggrServiceEnableGeneration(const asn1SccT_InstanceBooleanPairList *);

extern void aggregation_service_dispatch_RI_publishMO(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_AggregationValue *);

extern void aggregation_service_dispatch_RI_publishPUS(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_AggregationValue *);

extern void aggregation_service_dispatch_RI_aggrServiceGetValue(const asn1SccT_Int32List *, asn1SccT_MO_AggregationValueList *);

extern void aggregation_service_dispatch_RI_aggrServiceProvidermonitorValueRegister(const asn1SccT_apid *, const asn1SccT_String *);

extern void aggregation_service_dispatch_RI_aggrServiceProviderMonitorValueDeregister(const asn1SccT_apid *, const asn1SccT_String *);

#ifdef __cplusplus
}
#endif


#endif

/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_aggregation_service_provider__
#define __USER_CODE_H_aggregation_service_provider__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void aggregation_service_provider_startup();

void aggregation_service_provider_PI_enableGeneration(const asn1SccT_InstanceBooleanPairList *);

void aggregation_service_provider_PI_update();

void aggregation_service_provider_PI_getValue(const asn1SccT_Int32List *, asn1SccT_MO_AggregationValueList *);

void aggregation_service_provider_PI_monitorValueRegister(const asn1SccT_apid *, const asn1SccT_String *);

void aggregation_service_provider_PI_monitorValueDeregister(const asn1SccT_apid *, const asn1SccT_String *);

void aggregation_service_provider_PI_parameterReportingGroupEnable(const asn1SccT_Int32 *, const asn1SccT_Boolean *);

extern void aggregation_service_provider_RI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_AggregationValue *);

extern void aggregation_service_provider_RI_paramServiceGetValue(const asn1SccT_apid *, const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

#ifdef __cplusplus
}
#endif


#endif

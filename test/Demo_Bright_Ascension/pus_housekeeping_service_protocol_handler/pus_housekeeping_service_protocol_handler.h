/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_pus_housekeeping_service_protocol_handler__
#define __USER_CODE_H_pus_housekeeping_service_protocol_handler__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void pus_housekeeping_service_protocol_handler_startup();

void pus_housekeeping_service_protocol_handler_PI_hkServiceRequest(const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

void pus_housekeeping_service_protocol_handler_PI_publish(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_AggregationValue *);

extern void pus_housekeeping_service_protocol_handler_RI_enableGeneration(const asn1SccT_apid *, const asn1SccT_InstanceBooleanPairList *);

extern void pus_housekeeping_service_protocol_handler_RI_serviceResponse(const asn1SccT_apid *, const asn1SccT_PUS_tm_userDataField *);

#ifdef __cplusplus
}
#endif


#endif

/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_pus_service_dispatch__
#define __USER_CODE_H_pus_service_dispatch__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void pus_service_dispatch_startup();

void pus_service_dispatch_PI_pus_request(const asn1SccT_apid *, const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

void pus_service_dispatch_PI_serviceResponse(const asn1SccT_apid *, const asn1SccT_PUS_tm_userDataField *);

extern void pus_service_dispatch_RI_pus_response(const asn1SccT_apid *, const asn1SccT_PUS_tm_userDataField *);

extern void pus_service_dispatch_RI_customServiceRequest(const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

extern void pus_service_dispatch_RI_hkServiceRequest(const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

extern void pus_service_dispatch_RI_serviceRequest(const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

#ifdef __cplusplus
}
#endif


#endif

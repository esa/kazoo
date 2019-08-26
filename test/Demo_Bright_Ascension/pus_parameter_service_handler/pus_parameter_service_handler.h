/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_pus_parameter_service_handler__
#define __USER_CODE_H_pus_parameter_service_handler__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void pus_parameter_service_handler_startup();

void pus_parameter_service_handler_PI_serviceRequest(const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

extern void pus_parameter_service_handler_RI_getValue(const asn1SccT_apid *, const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

extern void pus_parameter_service_handler_RI_setValue(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_Int32 *, asn1SccT_MO_ErrorCodes *);

extern void pus_parameter_service_handler_RI_serviceResponse(const asn1SccT_apid *, const asn1SccT_PUS_tm_userDataField *);

#ifdef __cplusplus
}
#endif


#endif

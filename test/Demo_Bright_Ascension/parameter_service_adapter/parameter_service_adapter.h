/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_parameter_service_adapter__
#define __USER_CODE_H_parameter_service_adapter__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void parameter_service_adapter_startup();

void parameter_service_adapter_PI_paramServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

void parameter_service_adapter_PI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_ParameterValue *);

extern void parameter_service_adapter_RI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void parameter_service_adapter_RI_getValue(const asn1SccT_apid *, const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

extern void parameter_service_adapter_RI_setValue(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_Int32 *, asn1SccT_MO_ErrorCodes *);

extern void parameter_service_adapter_RI_monitorValueRegister(const asn1SccT_apid *, const asn1SccT_apid *, const asn1SccT_String *);

extern void parameter_service_adapter_RI_monitorValueDeregister(const asn1SccT_apid *, const asn1SccT_apid *, const asn1SccT_String *);

extern void parameter_service_adapter_RI_enableGeneration(const asn1SccT_apid *, const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

#ifdef __cplusplus
}
#endif


#endif

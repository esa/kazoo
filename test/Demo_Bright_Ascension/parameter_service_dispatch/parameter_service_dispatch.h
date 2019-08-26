/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_parameter_service_dispatch__
#define __USER_CODE_H_parameter_service_dispatch__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void parameter_service_dispatch_startup();

void parameter_service_dispatch_PI_setValue(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_Int32 *, asn1SccT_MO_ErrorCodes *);

void parameter_service_dispatch_PI_getValue(const asn1SccT_apid *, const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

void parameter_service_dispatch_PI_monitorValueRegister(const asn1SccT_apid *, const asn1SccT_apid *, const asn1SccT_String *);

void parameter_service_dispatch_PI_monitorValueDeregister(const asn1SccT_apid *, const asn1SccT_apid *, const asn1SccT_String *);

void parameter_service_dispatch_PI_enableGeneration(const asn1SccT_apid *, const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

void parameter_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_ParameterValue *);

extern void parameter_service_dispatch_RI_modeManagerGetValue(const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

extern void parameter_service_dispatch_RI_modeManagerSetValue(const asn1SccT_Int32 *, const asn1SccT_Int32 *, asn1SccT_MO_ErrorCodes *);

extern void parameter_service_dispatch_RI_thermalManagerSetValue(const asn1SccT_Int32 *, const asn1SccT_Int32 *, asn1SccT_MO_ErrorCodes *);

extern void parameter_service_dispatch_RI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_ParameterValue *);

extern void parameter_service_dispatch_RI_modeManagerEnableGeneration(const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

extern void parameter_service_dispatch_RI_modeManagerMonitorValueRegister(const asn1SccT_apid *, const asn1SccT_String *);

extern void parameter_service_dispatch_RI_modeManagerMonitorValueDeregister(const asn1SccT_apid *, const asn1SccT_String *);

extern void parameter_service_dispatch_RI_virtualGyroGetValue(const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

#ifdef __cplusplus
}
#endif


#endif

/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_mode_manager_container__
#define __USER_CODE_H_mode_manager_container__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void mode_manager_container_startup();

void mode_manager_container_PI_reset();

void mode_manager_container_PI_getMode(asn1SccT_SpacecraftMode *);

void mode_manager_container_PI_setMode(const asn1SccT_SpacecraftMode *);

void mode_manager_container_PI_getValue(const asn1SccT_Int32 *, asn1SccT_MO_ParameterValue *, asn1SccT_MO_ErrorCodes *);

void mode_manager_container_PI_setValue(const asn1SccT_Int32 *, const asn1SccT_Int32 *, asn1SccT_MO_ErrorCodes *);

void mode_manager_container_PI_monitorValueRegister(const asn1SccT_apid *, const asn1SccT_String *);

void mode_manager_container_PI_enableGeneration(const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

void mode_manager_container_PI_monitorValueDeregister(const asn1SccT_apid *, const asn1SccT_String *);

void mode_manager_container_PI_updateParameters();

void mode_manager_container_PI_submitAction(const asn1SccT_Int32 *);

void mode_manager_container_PI_alertEnableGeneration(const asn1SccT_Boolean *, const asn1SccT_InstanceBooleanPairList *);

void mode_manager_container_PI_checkMonitorValueNotification(const asn1SccT_Int32 *, const asn1SccT_MO_CheckResult *);

void mode_manager_container_PI_eventEmitter_modeChangedEvent(const asn1SccT_String *);

void mode_manager_container_PI_getAngularRate(asn1SccT_Int32 *);

void mode_manager_container_PI_getTemperature(asn1SccT_Int32 *);

void mode_manager_container_PI_monitoringGroupEnable(const asn1SccT_Int32 *, const asn1SccT_Boolean *);

void mode_manager_container_PI_reportingGroupEnable(const asn1SccT_Int32 *, const asn1SccT_Boolean *);

void mode_manager_container_PI_thermalManager_heaterOn(const asn1SccT_Boolean *);

extern void mode_manager_container_RI_setMode(const asn1SccT_SpacecraftMode *);

extern void mode_manager_container_RI_getMode(asn1SccT_SpacecraftMode *);

extern void mode_manager_container_RI_reset();

extern void mode_manager_container_RI_monitorValueNotify(const asn1SccT_apid *, const asn1SccT_Int32 *, const asn1SccT_MO_ParameterValue *);

extern void mode_manager_container_RI_getAngularRate(asn1SccT_Int32 *);

extern void mode_manager_container_RI_monitoringReportingGroupEnable(const asn1SccT_Int32 *, const asn1SccT_Boolean *);

extern void mode_manager_container_RI_parameterReportingGroupEnable(const asn1SccT_Int32 *, const asn1SccT_Boolean *);

extern void mode_manager_container_RI_alertMonitorValueNotify(const asn1SccT_apid *, const asn1SccT_MO_AlertEventDetails *);

extern void mode_manager_container_RI_eventReceiver_checkFailure();

extern void mode_manager_container_RI_thermalManagerHeaterOn(const asn1SccT_Boolean *);

extern void mode_manager_container_RI_getTemperature(asn1SccT_Int32 *);

#ifdef __cplusplus
}
#endif


#endif

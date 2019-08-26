/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_mode_manager__
#define __USER_CODE_H_mode_manager__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void mode_manager_startup();

void mode_manager_PI_getMode(asn1SccT_SpacecraftMode *);

void mode_manager_PI_setMode(const asn1SccT_SpacecraftMode *);

void mode_manager_PI_reset();

void mode_manager_PI_eventReceiver_checkFailure();

extern void mode_manager_RI_eventEmitter_modeChangedEvent(const asn1SccT_String *);

extern void mode_manager_RI_GUIupdateCurrentMode(const asn1SccT_SpacecraftMode *);

extern void mode_manager_RI_getAngularRate(asn1SccT_Int32 *);

extern void mode_manager_RI_getTemperature(asn1SccT_Int32 *);

extern void mode_manager_RI_monitoringGroupEnable(const asn1SccT_Int32 *, const asn1SccT_Boolean *);

extern void mode_manager_RI_reportingGroupEnable(const asn1SccT_Int32 *, const asn1SccT_Boolean *);

extern void mode_manager_RI_thermalManager_heaterOn(const asn1SccT_Boolean *);

#ifdef __cplusplus
}
#endif


#endif

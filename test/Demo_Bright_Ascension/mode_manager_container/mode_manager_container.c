/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "mode_manager_container.h"

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

#define NUM_PARAMS 1
#define NUM_ALERTS 1



static asn1SccT_Int32 instIdInc = 0x016500;

// Mode Manager Parameter Definitions:
// only one parameter, mode



// Parameter Definitions represented by ParameterDefinition COM object
    // Each Parameter represented by a ParameterIdentity COM objectInstID
static asn1SccT_MO_ParameterDefinitionDetails  modeManagerParams[NUM_PARAMS] = {
   { .objectInstID = 0x6500, .related = { .objectInstID = 0x6510, .objectName = { .arr = "mode"} }, .rawType = 11, .generationEnabled = 0 }
};


//Alert Definition

static asn1SccT_MO_AlertDefinitionDetails modeManagerAlerts[NUM_ALERTS] = {
      { .objectInstID = 06520,
        .related = { .objectInstID = 0x6521, .objectName = { .arr = "mode_change"} },
        .description = { .arr = "Fired on mode change" },  
        .severity = asn1Sccseverity_informational,
        .generationEnabled = 1 }  
};
                        
// In this demo we will only ever have a single subscriber (100), with a known subscription.
// A full implementation would store consumers and their subscription lists here.
static asn1SccT_apid consumerRegistered[1];  

void mode_manager_container_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */ 
    
}


// Parameter Service

void mode_manager_container_PI_getValue(const asn1SccT_Int32 * IN_paramID,
                                        asn1SccT_MO_ParameterValue *OUT_paramValue,
                                        asn1SccT_MO_ErrorCodes *OUT_exceptionCode)
{      
    asn1SccT_SpacecraftMode currentMode;
    
    // check param id falls within valid range
    if(*IN_paramID > NUM_PARAMS -1)
    {       
         *OUT_exceptionCode = asn1Sccunknown;
         return;
    }    
    *OUT_exceptionCode = asn1SccT_MO_ErrorCodes_none;
    
    printf("[Mode Manager Container] Parameter Service: Get Value. \n");
    mode_manager_container_RI_getMode(&currentMode);
    
    // Unique instance ID for this parameter value
    OUT_paramValue->objectInstID = instIdInc++;
    OUT_paramValue->related = modeManagerParams[*IN_paramID];
    OUT_paramValue->rawValue = (asn1SccT_Int32)currentMode;    
}

void mode_manager_container_PI_setValue(const asn1SccT_Int32 *IN_paramID,
                                        const asn1SccT_Int32 *IN_paramValue,
                                        asn1SccT_MO_ErrorCodes *OUT_exceptionCode)
{
    printf("[Mode Manager Container] Parameter Service: Set Value. \n");
    
    // check param id falls within valid range
    if(*IN_paramID > NUM_PARAMS -1)
    {       
         *OUT_exceptionCode = asn1Sccunknown;
         return;
    }    
    *OUT_exceptionCode = asn1SccT_MO_ErrorCodes_none;
    
    if(*IN_paramValue < 5 && *IN_paramValue > 0)
    {    
        mode_manager_container_RI_setMode((asn1SccT_SpacecraftMode*)IN_paramValue);
         *OUT_exceptionCode = asn1SccT_MO_ErrorCodes_none;
    }
    else
    {
        *OUT_exceptionCode = asn1SccT_MO_ErrorCodes_invalid;
    }
}

void mode_manager_container_PI_monitorValueRegister(const asn1SccT_apid *IN_consumerURI,
                                                      const asn1SccT_String *IN_subscriptionID)
{   
    printf("[Mode Manager Container] Registering subscriber: %u\n", *IN_consumerURI);
    consumerRegistered[0] = *IN_consumerURI;    
}

void mode_manager_container_PI_monitorValueDeregister(const asn1SccT_apid *IN_consumerURI,
                                                      const asn1SccT_String *IN_subscriptionID)
{
    printf("[Mode Manager Container] Deregistering subscriber: %u\n", *IN_consumerURI);
    consumerRegistered[0] = 0;
}

void mode_manager_container_PI_enableGeneration(const asn1SccT_Boolean *isGroupIDs,
                                                const asn1SccT_InstanceBooleanPairList *enableInstances)
{
     printf("[Mode Manager Container] Enable Generation\n");
     

     // We only have one parameter that can have generation enabled.
     modeManagerParams[0].generationEnabled = enableInstances->arr[0].value;
     
     
}

void mode_manager_container_PI_updateParameters()
{
    asn1SccT_Int32 parameterID;
    asn1SccT_MO_ParameterValue parameterValue;
    
    asn1SccT_SpacecraftMode currentMode;
    
        
    // For each subscribed consumers, get parameter updates and send notification.
    // We use a single static subscription for this demo.
    
    // Do nothing if consumer not registered
    if(!consumerRegistered[0])
    {
        return;
    }

    
    // We use a single known subscription for this demo. This contains a single parameter
    // For each parameter in the subscription, send a notification to the 
    if(modeManagerParams[0].generationEnabled)
    {
        // Fetch latest mode value
        printf("[Mode Manager Container] Notifying: %u\n", consumerRegistered[0]);
        
        mode_manager_container_RI_getMode(&currentMode);
        
        parameterID    = 0;
        parameterValue.objectInstID = instIdInc++;
        parameterValue.related = modeManagerParams[0];
        parameterValue.rawValue = (asn1SccT_Int32)currentMode;
        
        
        // send notification
        mode_manager_container_RI_monitorValueNotify(
                                        consumerRegistered,                                        
                                        &parameterID,
                                        &parameterValue);
    }
    
}

// Mode Control Service

void mode_manager_container_PI_getMode(asn1SccT_SpacecraftMode *OUT_mode)
{
    printf("[Mode Manager Container] Mode Service: Get Mode. \n");
    mode_manager_container_RI_getMode(OUT_mode);
}

void mode_manager_container_PI_setMode(const asn1SccT_SpacecraftMode *IN_mode)
{
    printf("[Mode Manager Container] Mode Service: Set Mode. \n");
    mode_manager_container_RI_setMode(IN_mode);
}

void mode_manager_container_PI_reset()
{
    printf("[Mode Manager Container] Mode Service: Reset. \n");
    mode_manager_container_RI_reset();
}

// Action Service
void mode_manager_container_PI_submitAction(const asn1SccT_Int32 *IN_actionID)
{
    printf("[Mode Manager Container] Mode Service: Reset Called via Action Service. \n");
    mode_manager_container_RI_reset();
}

//Alert Service
void mode_manager_container_PI_alertEnableGeneration(const asn1SccT_Boolean *IN_isGroupIDs,
                                                     const asn1SccT_InstanceBooleanPairList *IN_enableInstances)
{
    printf("[Mode Manager Container] Enable Alert Generation \n");
}

// Called by mode manager when mode has changed. send an alert.
void mode_manager_container_PI_eventEmitter_modeChangedEvent(const asn1SccT_String *IN_newModeString)
{
    
    printf("[Mode Manager Container] Mode Changed Event \n");
    
    asn1SccT_apid consumerID = 110;
    
    asn1SccT_MO_AlertEventDetails alertDetails = {.related = modeManagerAlerts[0], .values = { .nCount = 1, .arr[0].value = *IN_newModeString}};
    
    mode_manager_container_RI_alertMonitorValueNotify(&consumerID, &alertDetails);
}

// Called by check service when a check has failed
void mode_manager_container_PI_checkMonitorValueNotification(const asn1SccT_Int32 *IN_checkID,
                                                             const asn1SccT_MO_CheckResult *IN_checkTransition)
{
    printf("[Mode Manager Container] Check Failed Event \n");
    mode_manager_container_RI_eventReceiver_checkFailure();
}

void mode_manager_container_PI_getAngularRate(asn1SccT_Int32 *OUT_angularRate)
{
    mode_manager_container_RI_getAngularRate(OUT_angularRate);
}

void mode_manager_container_PI_getTemperature(asn1SccT_Int32 *OUT_temp)
{
    mode_manager_container_RI_getTemperature(OUT_temp);
}

void mode_manager_container_PI_thermalManager_heaterOn(const asn1SccT_Boolean *IN_overrideState)
{
    mode_manager_container_RI_thermalManagerHeaterOn(IN_overrideState);
}

void mode_manager_container_PI_monitoringGroupEnable(const asn1SccT_Int32 *IN_groupID, const asn1SccT_Boolean *IN_enable)
{
    mode_manager_container_RI_monitoringReportingGroupEnable(IN_groupID, IN_enable);
}

void mode_manager_container_PI_reportingGroupEnable(const asn1SccT_Int32 *IN_groupID, const asn1SccT_Boolean *IN_enable)
{
    mode_manager_container_RI_parameterReportingGroupEnable(IN_groupID, IN_enable);
}







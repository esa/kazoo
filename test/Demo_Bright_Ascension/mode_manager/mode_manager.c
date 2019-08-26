/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "mode_manager.h"

#include <stdio.h>
#include <assert.h>



static asn1SccT_SpacecraftMode SpacecraftMode = asn1Sccsafe;

static char* prettyPrintMode(asn1SccT_SpacecraftMode mode)
{
    switch(mode) {
        
    case asn1Sccsafe:
      return "Safe";  
      
    case asn1SccsunAcquisition:
      return "Sun Acquisition";
    
    case asn1Sccstandby:
      return "Standby";
    
    case asn1Sccmeasurement:
      return "Measurement";
    
    default:
      assert(0 && "Invalid mode");
      return "ERROR Invalid Mode value";
    }
}

static void enterSafeState()
{
    asn1SccT_Int32 reportingGroupId, monitoringGroupId;
    asn1SccT_Boolean enable, overrideState;
    asn1SccT_String eventStr = {.arr = "Mode changed: Safe"};
    
    SpacecraftMode = asn1Sccsafe;
   
    reportingGroupId = 0;
    enable = 1;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    reportingGroupId = 1;
    enable = 0;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    monitoringGroupId = 0;
    enable = 0; 
    mode_manager_RI_monitoringGroupEnable(&monitoringGroupId, &enable); 
    
    overrideState = 0;
    mode_manager_RI_thermalManager_heaterOn(&overrideState);
    
    mode_manager_RI_eventEmitter_modeChangedEvent(&eventStr);
    
}

static void enterSunAcqState()
{
    asn1SccT_Int32 reportingGroupId, monitoringGroupId;
    asn1SccT_Boolean enable, overrideState;
    asn1SccT_String eventStr = {.arr = "Mode changed: Sun Acquisition"};
    
    SpacecraftMode = asn1SccsunAcquisition;
   
    reportingGroupId = 0;
    enable = 1;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    reportingGroupId = 1;
    enable = 1;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    monitoringGroupId = 0;
    enable = 0; 
    mode_manager_RI_monitoringGroupEnable(&monitoringGroupId, &enable); 
    
    overrideState = 0;
    mode_manager_RI_thermalManager_heaterOn(&overrideState);

    mode_manager_RI_eventEmitter_modeChangedEvent(&eventStr);
}

static void enterStandbyState()
{
    asn1SccT_Int32 reportingGroupId, monitoringGroupId;
    asn1SccT_Boolean enable, overrideState;
    asn1SccT_String eventStr = {.arr = "Mode changed: Standby"};
    
    SpacecraftMode = asn1Sccstandby;
   
    reportingGroupId = 0;
    enable = 1;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    reportingGroupId = 1;
    enable = 1;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    monitoringGroupId = 0;
    enable = 1; 
    mode_manager_RI_monitoringGroupEnable(&monitoringGroupId, &enable); 
    
    overrideState = 1;
    mode_manager_RI_thermalManager_heaterOn(&overrideState);

    mode_manager_RI_eventEmitter_modeChangedEvent(&eventStr);
}

static void enterMeasurementState()
{
    asn1SccT_Int32 reportingGroupId, monitoringGroupId;
    asn1SccT_Boolean enable, overrideState;
    asn1SccT_String eventStr = {.arr = "Mode changed: Measurement"};
    
    SpacecraftMode = asn1Sccmeasurement;
   
    reportingGroupId = 0;
    enable = 0;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    reportingGroupId = 1;
    enable = 1;    
    mode_manager_RI_reportingGroupEnable(&reportingGroupId, &enable);  
    
    monitoringGroupId = 0;
    enable = 1; 
    mode_manager_RI_monitoringGroupEnable(&monitoringGroupId, &enable); 
    
    overrideState = 1;
    mode_manager_RI_thermalManager_heaterOn(&overrideState);
    
    mode_manager_RI_eventEmitter_modeChangedEvent(&eventStr);

}

void mode_manager_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
    
    printf("[ModeManager] Mode Manager startup\n");    
    printf("[ModeManager] Initial mode:  %s\n", prettyPrintMode(SpacecraftMode));
}

void mode_manager_PI_getMode(asn1SccT_SpacecraftMode *OUT_spacecraftMode)
{
    printf("[ModeManager] Get mode. Current mode: %s\n", prettyPrintMode(SpacecraftMode));
    * OUT_spacecraftMode = SpacecraftMode;
}

void mode_manager_PI_setMode(const asn1SccT_SpacecraftMode *IN_spacecraftMode)
{
    printf("[ModeManager] Set mode. New mode: %s\n", prettyPrintMode(*IN_spacecraftMode));
    
    
    switch(*IN_spacecraftMode) {
        
    case asn1Sccsafe:
        enterSafeState();
        break;
        
    case asn1SccsunAcquisition:
        enterSunAcqState();
        break;
    
    case asn1Sccstandby:
        enterStandbyState();
        break;
    
    case asn1Sccmeasurement:
        enterMeasurementState();
        break;
    
    default:
      assert(0 && "ERROR: Attempt to set Invalid Mode");
      break;
    }
    
    mode_manager_RI_GUIupdateCurrentMode(IN_spacecraftMode);
    
    //TODO make calls to osra paltform reporting interface on mode change
    // to enable/disabel reporting groups in certain modes
}

void mode_manager_PI_reset()
{
     printf("[ModeManager] Reset");
     
     enterSafeState();
}


// Called when a check has failed
void mode_manager_PI_eventReceiver_checkFailure()
{
    printf("[ModeManager] Check Failed");
    enterSafeState();
}



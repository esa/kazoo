/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "thermal_manager_container.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#define NUM_PARAMS 1

static asn1SccT_MO_ParameterDefinitionDetails  modeManagerParams[NUM_PARAMS] = {
   { .objectInstID = 0x8500, .related = { .objectInstID = 0x8510, .objectName = { .arr = "heater-override"} }, .rawType = 11, .generationEnabled = 0 }
};

void thermal_manager_container_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void thermal_manager_container_PI_setValue(const asn1SccT_Int32 *IN_paramID,
                                        const asn1SccT_Int32 *IN_paramValue,
                                        asn1SccT_MO_ErrorCodes *OUT_exceptionCode)
{
    printf("[Thermal Manager Container] Parameter Service: Set Value. \n");
    
    asn1SccT_Boolean heaterOverride;
    
    // check param id falls within valid range
    if(*IN_paramID != NUM_PARAMS -1)
    {       
         *OUT_exceptionCode = asn1Sccunknown;
         return;
    }    
    *OUT_exceptionCode = asn1SccT_MO_ErrorCodes_none;
    
    switch(*IN_paramID)
    {
        case 0:            
            heaterOverride = *IN_paramValue != 0;
            
            thermal_manager_container_RI_heaterOn(&heaterOverride);
            break;
            
        default:
            *OUT_exceptionCode = asn1Sccunknown;
    }
}

void thermal_manager_container_PI_thermalManagerHeaterOn(const asn1SccT_Boolean *IN_overrideState)
{
    thermal_manager_container_RI_heaterOn(IN_overrideState);    
}
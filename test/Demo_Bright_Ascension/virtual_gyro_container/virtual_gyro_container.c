/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "virtual_gyro_container.h"

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

static asn1SccT_Int32 instIdInc = 0x017800;

// Parameter Definitions:
static asn1SccT_MO_ParameterDefinitionDetails  gyroParams[] = {
    { .objectInstID = 0x7800, .related = { .objectInstID = 0x7810, .objectName = {.arr = "angularRate"} }, .rawType = 11, .generationEnabled = 0 },
    { .objectInstID = 0x7801, .related = { .objectInstID = 0x7811, .objectName = {.arr = "temperature"} }, .rawType = 11, .generationEnabled = 0 }

};

void virtual_gyro_container_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void virtual_gyro_container_PI_getValue(const asn1SccT_Int32 * IN_paramID,
                                        asn1SccT_MO_ParameterValue *OUT_paramValue,
                                        asn1SccT_MO_ErrorCodes *OUT_exceptionCode)

{
    asn1SccT_Int32 currentVal;
    
    // check param id falls within valid range
    if(*IN_paramID > sizeof(gyroParams))
    {       
         *OUT_exceptionCode = asn1Sccunknown;
         return;
    }    
    *OUT_exceptionCode = asn1SccT_MO_ErrorCodes_none;
    
    printf("[Virtual Gyro Container] Parameter Service: Get Value. \n");
    

    virtual_gyro_container_RI_dvsAcquireFromDevice(IN_paramID, &currentVal);

    
    // Unique instance ID for this parameter value
    OUT_paramValue->objectInstID = instIdInc++;
    OUT_paramValue->related = gyroParams[*IN_paramID];
    OUT_paramValue->rawValue = (asn1SccT_Int32)currentVal;    
}


void virtual_gyro_container_PI_getAngularRate(asn1SccT_Int32 *OUT_angularRate)
{
    asn1SccT_Int32 paramID = 0;
    virtual_gyro_container_RI_dvsAcquireFromDevice(&paramID, OUT_angularRate);
}

void virtual_gyro_container_PI_getTemperature(asn1SccT_Int32 *OUT_temperature)
{
    asn1SccT_Int32 paramID = 1;
    virtual_gyro_container_RI_dvsAcquireFromDevice(&paramID, OUT_temperature);
}
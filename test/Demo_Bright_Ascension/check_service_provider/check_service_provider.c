/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "check_service_provider.h"

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

#define NUM_CHECK_LINKS 1

static const asn1SccT_apid modeManagerApid = 144;

static asn1SccT_MO_CheckDefinition checks[] = {
    { .objectInstID = 0x6700,
      .source = { .objectInstID = 0x6701,
                  .related = { .objectInstID = 0x6710, .objectName = {.arr = "temperatureLimit"}},
                  .violateInRange = 1,
                  .lowerLimit = 0,
                  .upperLimit = 55 },
      .related = { .objectInstID = 0x6710, .objectName = {.arr = "temperatureLimit"}}  
    }
    
};

static asn1SccT_MO_CheckLinkDetails checkLinks[] = { 
    {
        .objectInstID = 0x6720,
        .source = { .objectInstID = 0x7801, .related = { .objectInstID = 0x7811, .objectName = {.arr = "temperature"} }, .rawType = 11, .generationEnabled = 0 }, 
        .related = 
                     { .objectInstID = 0x6700,
                        .source = { .objectInstID = 0x6701,
                                    .related = { .objectInstID = 0x6710, .objectName = {.arr = "temperatureLimit"}},
                                    .violateInRange = 1,
                                    .lowerLimit = 0,
                                    .upperLimit = 55 },
                        .related = { .objectInstID = 0x6710, .objectName = {.arr = "temperatureLimit"}}  
                     },
        .checkEnabled = 1
    }
};
        
    

void check_service_provider_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void check_service_provider_PI_performChecks()
{
    int i;
    
    asn1SccT_apid  providerID;
    asn1SccT_Int32 parameterID;
    asn1SccT_MO_ParameterValue parameterValue;
    asn1SccT_MO_ErrorCodes errorCode;
    asn1SccT_MO_CheckResult checkResult;
    
    
//     perform periodic limits checks.
    
    for (i = 0; i < NUM_CHECK_LINKS; i++)
    {
        providerID  = checkLinks[i].source.objectInstID >> 8;
        parameterID = checkLinks[i].source.objectInstID & 0xFF;
        
        check_service_provider_RI_getValue(&providerID, &parameterID, &parameterValue, &errorCode);
        
        if(parameterValue.rawValue <  checkLinks[i].related.source.lowerLimit ||
           parameterValue.rawValue > checkLinks[i].related.source.upperLimit)
        {
            
            checkResult.source = parameterValue;
            checkResult.related = checkLinks[i];
            checkResult.currentCheckState = asn1SccnotOk;
            
            
            // Mode manager is statically registered for check transitions
            check_service_provider_RI_monitorValueNotify(&modeManagerApid,
                                                         &checkLinks[i].source.objectInstID,
                                                         &checkResult);
        }
    }
    
}

void check_service_provider_PI_triggerCheck(const asn1SccT_Int32List *IN_checkIDs,
                                            const asn1SccT_Int32List *IN_linkIDs)
{
    /* Write your code here! */
}

void check_service_provider_PI_enableCheck(const asn1SccT_Boolean *IN_isgroupids,
                                           const asn1SccT_InstanceBooleanPairList *IN_enableinstances)
{

}

void check_service_provider_PI_getSummaryReport(const asn1SccT_Int32List *IN_checkIdentityIDs,
                                                asn1SccT_MO_CheckSummaryList *OUT_checkSummaries)
{
    
}

void check_service_provider_PI_monitoringReportingGroupEnable(const asn1SccT_Int32 *groupID, const asn1SccT_Boolean *enabled)
{
         printf("[Check Service] %s check\n",
                *enabled ? "Enable":"Disable");
         
         checkLinks[*groupID].checkEnabled = *enabled;
}

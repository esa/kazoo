/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "parameter_service_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

void parameter_service_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void parameter_service_dispatch_PI_getValue(const asn1SccT_apid *IN_providerID,
                                            const asn1SccT_Int32 *IN_parameterID, 
                                            asn1SccT_MO_ParameterValue *OUT_parameterValue,
                                            asn1SccT_MO_ErrorCodes *OUT_exceptionCode)
{
    switch(*IN_providerID)
    {
        case 101:
            printf("[Parameter Service Dispatch] Call mode manager container getValue\n");
            parameter_service_dispatch_RI_modeManagerGetValue(IN_parameterID,
                                                              OUT_parameterValue,
                                                              OUT_exceptionCode);
            break;
            
        case 120:
            printf("[Parameter Service Dispatch] Call virtual gyro container getValue\n");
            parameter_service_dispatch_RI_virtualGyroGetValue(IN_parameterID,
                                                              OUT_parameterValue,
                                                              OUT_exceptionCode);
            
            break;
    }
}

void parameter_service_dispatch_PI_setValue(const asn1SccT_apid *IN_providerID, 
                                            const asn1SccT_Int32 *IN_parameterID, 
                                            const asn1SccT_Int32 *IN_parameterValue,
                                            asn1SccT_MO_ErrorCodes *OUT_exceptionCode)
{
    switch(*IN_providerID)
    {
        case 101:
            printf("[Parameter Service Dispatch] Call mode manager container setValue\n");
            parameter_service_dispatch_RI_modeManagerSetValue(IN_parameterID,
                                                              IN_parameterValue,
                                                              OUT_exceptionCode);
            break;
            
        case 133:
            printf("[Parameter Service Dispatch] Call thermal manager container setValue\n");
            parameter_service_dispatch_RI_thermalManagerSetValue(IN_parameterID,
                                                              IN_parameterValue,
                                                              OUT_exceptionCode);
            break;
    }
}

void parameter_service_dispatch_PI_monitorValueRegister(const asn1SccT_apid *IN_providerID,
                                                        const asn1SccT_apid *IN_consumerURI,
                                                        const asn1SccT_String *IN_subscriptionID)
{
    switch(*IN_providerID)
    {
        case 101:
            printf("[Parameter Service Dispatch] Call mode manager container Register\n");
            parameter_service_dispatch_RI_modeManagerMonitorValueRegister(
                                                              IN_consumerURI,
                                                              IN_subscriptionID);
            
            break;
    }
}

void parameter_service_dispatch_PI_monitorValueDeregister(const asn1SccT_apid *IN_providerID,
                                                          const asn1SccT_apid *IN_consumerURI,
                                                          const asn1SccT_String *IN_subscriptionID)
{
    switch(*IN_providerID)
    {
        case 101:
            printf("[Parameter Service Dispatch] Call mode manager container Deregister\n");
            parameter_service_dispatch_RI_modeManagerMonitorValueDeregister(
                                                              IN_consumerURI,
                                                              IN_subscriptionID);
            
            break;
    }
}

void parameter_service_dispatch_PI_enableGeneration(const asn1SccT_apid *IN_providerID,
                                                    const asn1SccT_Boolean *IN_isGroupIDs,                                                    
                                                    const asn1SccT_InstanceBooleanPairList *IN_enableInstances)
{
    switch(*IN_providerID)
    {
        case 101:
            printf("[Parameter Service Dispatch] Call mode manager enableGeneration\n");
            parameter_service_dispatch_RI_modeManagerEnableGeneration(
                                                              IN_isGroupIDs,
                                                              IN_enableInstances);
            
            break;
    }
}

void parameter_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *IN_providerID,
                                                     const asn1SccT_Int32 *IN_paramID,
                                                     const asn1SccT_MO_ParameterValue *IN_paramVal)
{
    // Switch to MO  or PUS stack depending on provider ID
    // In this case, we only ever dispatch to MO side.
    
    parameter_service_dispatch_RI_monitorValueNotify(IN_providerID, IN_paramID, IN_paramVal);
}



/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "aggregation_service_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>


void aggregation_service_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}


void aggregation_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *IN_consumerID,
                                                        const asn1SccT_Int32 *IN_aggregationID,
                                                        const asn1SccT_MO_AggregationValue *IN_aggregationValue)
{
    printf("[Aggregation Service Dispatch] Notification received\n");
    //switch on consumer id whether we are going MO  or PUS  stack
    switch(*IN_consumerID)
    {
        case 106:
            printf("[Aggregation Service Dispatch] Dispatch to MO\n");
            aggregation_service_dispatch_RI_publishMO(IN_consumerID, IN_aggregationID, IN_aggregationValue);
            break;
    
        case 2042:  
            printf("[Aggregation Service Dispatch] Dispatch to PUS\n");
            aggregation_service_dispatch_RI_publishPUS(IN_consumerID, IN_aggregationID, IN_aggregationValue);
            break;
    }
}

void aggregation_service_dispatch_PI_enableGeneration(const asn1SccT_apid *IN_providerId,
                                                      const asn1SccT_InstanceBooleanPairList *IN_enableInstances)
{
    printf("[Aggregation Service Dispatch] Call EnableGeneration\n");
    aggregation_service_dispatch_RI_aggrServiceEnableGeneration(IN_enableInstances);
}




void aggregation_service_dispatch_PI_getValue(const asn1SccT_apid *IN_providerId,
                                              const asn1SccT_Int32List *IN_aggInstIDs,
                                              asn1SccT_MO_AggregationValueList *OUT_aggrValues)
{
    printf("[Aggregation Service Dispatch] Call GetAggregationValue\n");
    aggregation_service_dispatch_RI_aggrServiceGetValue(IN_aggInstIDs, OUT_aggrValues);
}

void aggregation_service_dispatch_PI_monitorValueRegister(const asn1SccT_apid *IN_providerId,
                                                          const asn1SccT_apid *IN_consumerID,
                                                          const asn1SccT_String *IN_subscriptionID)
{
    printf("[Aggregation Service Dispatch] Call Register\n");
    aggregation_service_dispatch_RI_aggrServiceProvidermonitorValueRegister(IN_consumerID, IN_subscriptionID);
}

void aggregation_service_dispatch_PI_monitorValueDeregister(const asn1SccT_apid *IN_providerId,
                                                            const asn1SccT_apid *IN_consumerID,
                                                            const asn1SccT_String *IN_subscriptionID)
{
    printf("[Aggregation Service Dispatch] Call Deregister\n");
    aggregation_service_dispatch_RI_aggrServiceProviderMonitorValueDeregister(IN_consumerID, IN_subscriptionID);
}


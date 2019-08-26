/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "alert_service_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

void alert_service_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void alert_service_dispatch_PI_enableGeneration(const asn1SccT_apid *IN_providerID,
                                                const asn1SccT_Boolean *IN_isGroupIDs,
                                                const asn1SccT_InstanceBooleanPairList *IN_enableInstances)
{
    switch(*IN_providerID)
    {
        case 111:
            printf("[Alert Service Dispatch] Call Mode Manager alert service enable alert submit action\n");
            alert_service_dispatch_RI_alertEnableGeneration(IN_isGroupIDs, IN_enableInstances);
            
            break;
    }
}

void alert_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *IN_consumerID,
                                                  const asn1SccT_MO_AlertEventDetails *IN_alertValue)
{

    printf("[Alert Service Dispatch] Notification received\n");
    
    // Always direct to MAL stack

    alert_service_dispatch_RI_monitorValueNotify(IN_consumerID, IN_alertValue);
    
    
}

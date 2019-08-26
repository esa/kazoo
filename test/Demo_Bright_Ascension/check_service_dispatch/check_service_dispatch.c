/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "check_service_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

void check_service_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void check_service_dispatch_PI_triggerCheck(const asn1SccT_apid *IN_providerID, 
                                            const asn1SccT_Int32List *IN_checkIDs,
                                            const asn1SccT_Int32List *IN_linkIDs)
{
    /* Write your code here! */
}

void check_service_dispatch_PI_enableCheck(const asn1SccT_apid *IN_providerID,
                                           const asn1SccT_Boolean *IN_isGroupIDs,
                                           const asn1SccT_InstanceBooleanPairList *IN_enableInstances)
{
}


void check_service_dispatch_PI_getSummaryReport(const asn1SccT_apid *IN_providerID,
                                                const asn1SccT_Int32List * IN_checkIdentityIDs,
                                                asn1SccT_MO_CheckSummaryList *IN_checkSummaries)
{
}


void check_service_dispatch_PI_monitorValueNotify(const asn1SccT_apid *IN_consumerID,
                                                  const asn1SccT_Int32 *IN_checkID,
                                                  const asn1SccT_MO_CheckResult *IN_checkTransition)
{
    printf("[Check Service Dispatch] Notification received\n");
    
    switch(*IN_consumerID)
    {
        case 144:
            printf("[Check Service Dispatch] Dispatch to MO\n");
            check_service_dispatch_RI_checkMonitorValueNotification(IN_checkID, IN_checkTransition);
            break;

    }
}

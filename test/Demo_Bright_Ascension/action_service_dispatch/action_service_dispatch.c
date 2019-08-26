/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "action_service_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

void action_service_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void action_service_dispatch_PI_submitAction(const asn1SccT_apid *IN_providerid,
                                             const asn1SccT_Int32 *IN_actionid)
{
    switch(*IN_providerid)
    {
        case 109:
            printf("[Action Service Dispatch] Call mode manager container submit action\n");
            action_service_dispatch_RI_submitAction(IN_actionid);
            
            break;
    }
}


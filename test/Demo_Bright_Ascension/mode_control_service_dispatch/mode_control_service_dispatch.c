/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "mode_control_service_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

void mode_control_service_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void mode_control_service_dispatch_PI_getMode(const asn1SccT_apid *IN_providerId,
                                              asn1SccT_SpacecraftMode *OUT_spacecraftMode)
{
    switch(*IN_providerId)
    {
        case(99):
            mode_control_service_dispatch_RI_getMode(OUT_spacecraftMode);
            break;            
            
        default:
            printf("[Mode Control Service Dispatch] Error Invalid Provider ID: %u:\n", *IN_providerId);                 
    }
}

void mode_control_service_dispatch_PI_setMode(const asn1SccT_apid *IN_providerId,
                                              const asn1SccT_SpacecraftMode *IN_spacecraftMode)
{
    switch(*IN_providerId)
    {
        case(99):
            mode_control_service_dispatch_RI_setMode(IN_spacecraftMode);
            break;            
            
        default:
            printf("[Mode Control Service Dispatch] Error Invalid Provider ID: %u:\n", *IN_providerId);                 
    }
}

void mode_control_service_dispatch_PI_reset(const asn1SccT_apid *IN_providerId)
{
}


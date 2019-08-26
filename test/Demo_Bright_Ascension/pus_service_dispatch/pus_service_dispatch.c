/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "pus_service_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

void pus_service_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}


void pus_service_dispatch_PI_pus_request(const asn1SccT_apid * IN_applicationID,
                                         const asn1SccT_PUS_tc_userDataField *IN_userData,
                                         asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    switch(*IN_applicationID)
    {
        
        case 2042:
            printf("[PUS Dispatch] Dispatch service 3\n"); 
            pus_service_dispatch_RI_hkServiceRequest(IN_userData, OUT_errCode);
            break;
            
        case 2043:
            printf("[PUS Dispatch] Dispatch service 128\n");
            pus_service_dispatch_RI_customServiceRequest(IN_userData, OUT_errCode);
            break;            
        
        case 2044:
            printf("[PUS Dispatch] Dispatch service 20\n");
            pus_service_dispatch_RI_serviceRequest(IN_userData, OUT_errCode);
            break;
            
        default:
            *OUT_errCode = asn1SccillegalApid;            
            printf("[PUS Dispatch] Unexpected APID: %u:\n", *IN_applicationID);
            break; 
    }
    
        
}

void pus_service_dispatch_PI_serviceResponse(const asn1SccT_apid * IN_applicationID,
                                             const asn1SccT_PUS_tm_userDataField *IN_userData)
{
    pus_service_dispatch_RI_pus_response(IN_applicationID, IN_userData);
}

/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "mal_dispatch.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>


enum MO_Services {
    modeControl = 1, 
    parameter   = 2,
    check       = 3,
    aggregation = 6,
    action      = 7,
    alert       = 8
}; 

void mal_dispatch_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

/* 
 * Convert from raw service number in mal message header to enumerated type.
 * TODO: take account of service area. For this demonstrator only one area is
 * in use (99).
 */
static enum MO_Services numberToService(uint16_t serviceNum)
{
    enum MO_Services service = (enum MO_Services)serviceNum;
    
    switch(service) 
    {
        case modeControl:
        case parameter:
        case check:
        case aggregation:
        case alert:
        case action:
            break;
        
        default:
            printf("[MAL Dispatch] Error Invalid Service Number recieved: %u:\n", serviceNum);
            assert(0);
    }
    
    return service;
}

void mal_dispatch_PI_receiveIndication(const asn1SccT_MAL_msg_header *IN_hdr, const asn1SccT_MO_userDataField *IN_msgBody)
{ 
    enum MO_Services service = numberToService(IN_hdr->moService);
  
    switch(service)
    {
        case(modeControl):
            printf("[MAL Dispatch] Dispatching to Mode Control service Adapter\n");
            mal_dispatch_RI_modeControlServiceReceiveIndication(IN_hdr, IN_msgBody);
            break;
            
        case(parameter):
            printf("[MAL Dispatch] Dispatching to Parameter service Adapter\n");
            mal_dispatch_RI_paramServiceReceiveIndication(IN_hdr, IN_msgBody);
            break;            
        
        case(aggregation):
            printf("[MAL Dispatch] Dispatching to Aggregation service Adapter\n");
            mal_dispatch_RI_aggrServiceReceiveIndication(IN_hdr, IN_msgBody);
            break;
            
        case(check):
            printf("[MAL Dispatch] Dispatching to Check service Adapter\n");
            mal_dispatch_RI_checkServiceReceiveIndication(IN_hdr, IN_msgBody);
            break;
            
        case(alert):
            printf("[MAL Dispatch] Dispatching to Alert service Adapter\n");
            mal_dispatch_RI_alertServiceReceiveIndication(IN_hdr, IN_msgBody);
            break;
        
        case(action):
            printf("[MAL Dispatch] Dispatching to Action service Adapter\n");
            mal_dispatch_RI_actionServiceReceiveIndication(IN_hdr, IN_msgBody);
            break;
        
        default:
            printf("[MAL Dispatch] Service Dispatch not implemented: %u:\n", service);
            assert(0);
            break;        
    }
}

void mal_dispatch_PI_transmitRequest(const asn1SccT_MAL_msg_header *IN_hdr, const asn1SccT_MO_userDataField *IN_msgBody)
{
    mal_dispatch_RI_transmitRequest(IN_hdr, IN_msgBody);
}
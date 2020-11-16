/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "pus_custom_service_protocol_handler.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

// APID for mode control service instance provided by mode manager component
#define MODE_MANAGER_PROVIDER_ID 99

static const asn1SccT_apid applicationID = 2043;

void pus_custom_service_protocol_handler_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}



//Get Mode
static void handle_128_1(const asn1SccT_PUS_tc_userDataField *IN_userData)
{
    asn1SccT_apid providerID = MODE_MANAGER_PROVIDER_ID;
    
    asn1SccT_SpacecraftMode mode;
        
    pus_custom_service_protocol_handler_RI_getMode(&providerID,
                                                   &mode);
    
    //TODO: test for errror, return failed start of execution
    
    //Send telemetry
    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    
    tmData.kind = tm_128_2_mode_report_PRESENT; 
    tmData.u.tm_128_2_mode_report.mode = mode;
    
    pus_custom_service_protocol_handler_RI_serviceResponse(&applicationID,
                                                           &tmData);
}

//Set Mode
static void handle_128_3(const asn1SccT_PUS_tc_userDataField *IN_userData)
{
    asn1SccT_apid providerID = MODE_MANAGER_PROVIDER_ID;
    asn1SccT_SpacecraftMode newMode = IN_userData->u.tc_128_3_set_mode.mode;  
    
    
    pus_custom_service_protocol_handler_RI_setMode(&providerID,
                                                   &newMode);
    
    //Send telemetry
    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    
    tmData.kind = tm_128_4_mode_set_ack_PRESENT; 
    tmData.u.tm_128_4_mode_set_ack.value = 1;
    
    pus_custom_service_protocol_handler_RI_serviceResponse(&applicationID,
                                                           &tmData);
}

void pus_custom_service_protocol_handler_PI_customServiceRequest(
                            const asn1SccT_PUS_tc_userDataField *IN_userData,
                            asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    /* Determine operation to call from PUS packet */
    
    
    switch(IN_userData->kind)
    {
        case tc_128_1_get_mode_PRESENT:
            printf("[PUS Service 128 Handler] Get Mode\n");
            handle_128_1(IN_userData);
            break;            
        
        case tc_128_3_set_mode_PRESENT:
            printf("[PUS Service 128 Handler] Set Mode\n");
            handle_128_3(IN_userData);
            break;
            
        default:
            printf("[PUS Service 128 Handler] Invalid TC type received: %u:\n", IN_userData->kind);
            assert(0);
            break;
    }
}


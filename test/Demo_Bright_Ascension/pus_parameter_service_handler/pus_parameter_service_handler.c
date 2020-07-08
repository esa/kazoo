/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "pus_parameter_service_handler.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

// APID for parameter service instance provided by mode manager component
#define MODE_MANAGER_PROVIDER_ID 101

static const asn1SccT_apid applicationID = 2044;

void pus_parameter_service_handler_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

// Request some parameter values
static void handle_20_1(const asn1SccT_PUS_tc_userDataField *IN_userData,
                        asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    asn1SccT_MO_ParameterValue paramVal;
    asn1SccT_MO_ErrorCodes     exception;
    
    asn1SccT_UInt32 parameterID = 
            IN_userData->u.tc_20_1_request_parameter.parameterID & 0xFF;
    
    // Here we know the desired parameter service provider in advance, so specify this statically.
    // An alternative method of deciding on the provider would be to split the provided parameter
    // ID in to Provider and Parameter for Provider parts.
    asn1SccT_apid providerID =
            MODE_MANAGER_PROVIDER_ID +
            (IN_userData->u.tc_20_1_request_parameter.parameterID >> 8) & 0xFF;
    pus_parameter_service_handler_RI_getValue(&providerID,
                                              &parameterID,
                                              &paramVal,
                                              &exception);
    
    printf("[PUS Service 20 Handler] Got parameter: %lld value: %lld\n", parameterID, paramVal.rawValue);
     

    if(exception)
    {
        *OUT_errCode = asn1SccexecutionFail;
        return;
    }
    
    //Send telemetry
    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    
    tmData.kind = tm_20_2_parameter_report_PRESENT;
    
    tmData.u.tm_20_2_parameter_report.count       = 1;
    tmData.u.tm_20_2_parameter_report.parameterID = parameterID;
    tmData.u.tm_20_2_parameter_report.value       = paramVal.rawValue;
    
    
    pus_parameter_service_handler_RI_serviceResponse(&applicationID,
                                                     &tmData);
}

static void handle_20_3(const asn1SccT_PUS_tc_userDataField *IN_userData,
                        asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    asn1SccT_apid providerID = MODE_MANAGER_PROVIDER_ID;
    
    asn1SccT_MO_ErrorCodes     exception;
    
    asn1SccT_Int32 parameterID = 
            IN_userData->u.tc_20_3_set_parameter.parameterID;
            
    asn1SccT_Int32 parameterValue = 
            IN_userData->u.tc_20_3_set_parameter.value;
            
    pus_parameter_service_handler_RI_setValue(&providerID,
                                              &parameterID,
                                              &parameterValue,
                                              &exception);
    
    if(exception)
    {
        *OUT_errCode = asn1SccexecutionFail;
        return;
    }
    
    //Send telemetry
    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize(&tmData);
    
    tmData.kind = tm_20_4_parameter_set_ack_PRESENT;
    tmData.u.tm_20_4_parameter_set_ack.value = 1;
    
    
    pus_parameter_service_handler_RI_serviceResponse(&applicationID,
                                                     &tmData);
    
}

void pus_parameter_service_handler_PI_serviceRequest(const asn1SccT_PUS_tc_userDataField *IN_userData,
                                                     asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    switch(IN_userData->kind)
    {
        
        case tc_20_1_request_parameter_PRESENT:
            printf("[PUS Service 20 Handler] Request Parameter\n");
            handle_20_1(IN_userData, OUT_errCode);
            break;            
        
        case tc_20_3_set_parameter_PRESENT:
            printf("[PUS Service 20 Handler] Set Parameter\n");
            handle_20_3(IN_userData, OUT_errCode);
            break;
            
        default:
            printf("[PUS Service 20 Handler] Invalid TC type received: %u:\n", IN_userData->kind);
            assert(0);
            break; 
    }
      
}



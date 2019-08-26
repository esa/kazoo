/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "pus_housekeeping_service_protocol_handler.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

// APID for aggregation service instance
#define AGGR_SERVICE_PROVIDER_ID 107

const asn1SccT_apid applicationID = 2042;

void pus_housekeeping_service_protocol_handler_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

// EnableGeneration of PUS aggregation
static void handle_3_5(const asn1SccT_PUS_tc_userDataField *IN_userData,
                       asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    asn1SccT_InstanceBooleanPairList enableList;
    enableList.nCount = 1;
    enableList.arr[0].id = 0;
    enableList.arr[0].value = 1;
    
    pus_housekeeping_service_protocol_handler_RI_enableGeneration(&applicationID, &enableList);
    
    OUT_errCode = asn1SccT_PUS_tc_failure_code_none;
}

// DisableGeneration of PUS aggregation
static void handle_3_6(const asn1SccT_PUS_tc_userDataField *IN_userData,
                       asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    asn1SccT_InstanceBooleanPairList enableList;
    enableList.nCount = 1;
    enableList.arr[0].id = 0;
    enableList.arr[0].value = 0;
    
    pus_housekeeping_service_protocol_handler_RI_enableGeneration(&applicationID, &enableList);   
    
    OUT_errCode = asn1SccT_PUS_tc_failure_code_none;
    
}


void pus_housekeeping_service_protocol_handler_PI_hkServiceRequest(const asn1SccT_PUS_tc_userDataField *IN_userData,
                                                                   asn1SccT_PUS_tc_failure_code *OUT_errCode)
{
    switch(IN_userData->kind)
    {
        
        case tc_3_5_enable_hk_PRESENT:
            printf("[PUS Service 3 Handler] Enable Housekeeping\n");
            handle_3_5(IN_userData, OUT_errCode);
            break;            
        
        case tc_3_6_disable_hk_PRESENT:
            printf("[PUS Service 3 Handler] Disable Housekeeping\n");
            handle_3_6(IN_userData, OUT_errCode);
            break;
            
        default:
            printf("[PUS Service 3 Handler] Invalid TC type received: %u:\n", IN_userData->kind);
            assert(0);
            break; 
    }
}

void pus_housekeeping_service_protocol_handler_PI_publish(
                            const asn1SccT_apid *IN_consumerID,
                            const asn1SccT_Int32 *IN_aggregationID,
                            const asn1SccT_MO_AggregationValue *IN_aggregationValue)
{
    //Send telemetry
    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    
    // At this  point we could look up the related field of the parameter value to get the
    // parameter definition details, in order to handle the types appropriately.
    // For this demo we know in advance the only format the Ground Software can accept.
    
    tmData.kind = tm_3_25_hk_report_PRESENT; 
    tmData.u.tm_3_25_hk_report.reportDefinitionID = IN_aggregationValue->objectInstID;
    tmData.u.tm_3_25_hk_report.valueA = IN_aggregationValue->values.arr[0].values.arr[0].rawValue;
    tmData.u.tm_3_25_hk_report.valueB = IN_aggregationValue->values.arr[0].values.arr[1].rawValue;
    
    pus_housekeeping_service_protocol_handler_RI_serviceResponse(&applicationID, &tmData);
}


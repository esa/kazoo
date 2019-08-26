/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "action_service_adapter.h"

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#define MAX_USER_DATA_FIELD_LEN 222


void action_service_adapter_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

static void handleSubmitActionSubmit(const asn1SccT_MAL_msg_header *IN_hdr,
             const asn1SccT_MO_userDataField *IN_msgBody)
{
     asn1SccT_MAL_msg_header                     responseMsg = { .uriTo = 0};    
     asn1SccT_MO_userDataField                   responseBody = { .nCount = 0 };
    
     // Skip decoding body, ground only ever sends the one action ID
     asn1SccT_Int32 requestedActionID = 0;
      
     // Call Dispatcher Interface
     action_service_adapter_RI_submitAction(
                                    &IN_hdr->uriTo,
                                    &requestedActionID);
                                                   
     //Send Submit Ack           
    responseMsg.uriFrom           = IN_hdr->uriTo;
    responseMsg.timestamp         = IN_hdr->timestamp; //TODO: time service
    responseMsg.uriTo             = IN_hdr->uriFrom;
    responseMsg.interactionType   = asn1Sccsubmit;
    responseMsg.interactionStage  = 2;
    responseMsg.transactionId     = IN_hdr->transactionId;
    responseMsg.serviceArea       = IN_hdr->serviceArea;
    responseMsg.moService         = IN_hdr->moService;
    responseMsg.operation         = IN_hdr->operation;
    responseMsg.areaVersion       = IN_hdr->areaVersion;
    responseMsg.isErrorMsg        = IN_hdr->isErrorMsg;
    
    action_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
}


void action_service_adapter_PI_actionServiceReceiveIndication(
                                const asn1SccT_MAL_msg_header *IN_hdr,                                                              
                                const asn1SccT_MO_userDataField *IN_msgBody)
{
    /* Dispatch according to operation type and interaction stage */
    printf("[Action Service Adapter] Receive Indication\n");
    
    // Operation numbers as specified in XML Service Specification
    switch(IN_hdr->operation)
    {
        case 1:
            //Submit Action
            handleSubmitActionSubmit(IN_hdr, IN_msgBody);
            break;
            
        default:
            printf("[Action Service Adapter] Unknown Operation\n");
    }
}


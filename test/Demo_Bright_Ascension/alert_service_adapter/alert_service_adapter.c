/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "alert_service_adapter.h"


#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#define MAX_USER_DATA_FIELD_LEN 222

void alert_service_adapter_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

static void decodeEnableGenerationSubmitBody(const asn1SccT_MO_userDataField *IN_msgBody,
                                             asn1SccT_InstanceBooleanPairList *OUT_enableInstances)
{
    BitStream bitStrm;
    asn1SccT_MO_alert_enableGenerationSubmitBody decodedPDU = { .enableInstances = {.nCount = 0} };
    int errorCode, i;
    
    // Explicit cast to avoid cast discarding const qualifier warning. We will not be writing to this buffer.
    BitStream_AttachBuffer(&bitStrm, (unsigned char *)(IN_msgBody->arr), IN_msgBody->nCount);
    
    if(!asn1SccT_MO_alert_enableGenerationSubmitBody_ACN_Decode(&decodedPDU,
                                                                &bitStrm,
                                                                &errorCode))
    {
        printf("[Alert Service Adapter] Decode failed. Error code: %d\n", errorCode);
    }
    
    //convert from mal encoded instance boolean pair
    for(i=0; i < decodedPDU.enableInstances.nCount; i++)
    {
        OUT_enableInstances->arr[i].id    = decodedPDU.enableInstances.arr[i].id.intVal;
        OUT_enableInstances->arr[i].value = decodedPDU.enableInstances.arr[i].value;
    }
    OUT_enableInstances->nCount = decodedPDU.enableInstances.nCount;
    
}


static void handleEnableGenerationSubmit(const asn1SccT_MAL_msg_header *IN_hdr,
                                 const asn1SccT_MO_userDataField *IN_msgBody)
{
     asn1SccT_MAL_msg_header                     responseMsg = { .uriTo = 0};    
     asn1SccT_MO_userDataField                   responseBody = { .nCount = 0 };
    
     //Decode body to get instance boolean pairs
    
     asn1SccT_Boolean isgroup = 0;
     asn1SccT_InstanceBooleanPairList enableInstances = { .nCount = 1 };
     
     decodeEnableGenerationSubmitBody(IN_msgBody, &enableInstances);
     
      
     // Call Dispatcher Interface
     alert_service_adapter_RI_enableGeneration(
                                    &IN_hdr->uriTo,
                                    &isgroup,
                                    &enableInstances);
                                                   
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
    
    alert_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
                                                   
}

void alert_service_adapter_PI_alertServiceReceiveIndication(const asn1SccT_MAL_msg_header *IN_hdr,
                                                const asn1SccT_MO_userDataField *IN_msgBody)
{
     /* Dispatch according to operation type and interaction stage */
    printf("[Alert Service Adapter] Receive Indication\n");
    
    switch(IN_hdr->operation)
    {
        case 1:
             //enable generation
            handleEnableGenerationSubmit(IN_hdr, IN_msgBody);
            break;
                        
        default:
            printf("[Aggregation Service Adapter] Unknown Operation\n");
    }
}

void alert_service_adapter_PI_monitorValueNotify(const asn1SccT_apid *IN_consumerID,
                                                 const asn1SccT_MO_AlertEventDetails *IN_alertEvent)
{
    // Ground is not capable of receiving alerts. We Just print that it occurred here.
    printf("[Alert Service Adapter] Received Alert: %s\n", IN_alertEvent->related.related.objectName.arr);
}

/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "mode_control_service_adapter.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#define MAX_USER_DATA_FIELD_LEN 222

void mode_control_service_adapter_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

static asn1SccT_SpacecraftMode decodeBody(const asn1SccT_MO_userDataField *IN_msgBody)
{
    BitStream bitStrm;
    asn1SccT_MAL_encoded_ModeManager decodedModePDU;
    int errorCode;
       
    // Explicit cast to avoid cast discarding const qualifier warning. We will not be writing to this buffer.
    BitStream_AttachBuffer(&bitStrm, (unsigned char *)(IN_msgBody->arr), IN_msgBody->nCount);
    
    if(!asn1SccT_MAL_encoded_ModeManager_ACN_Decode(&decodedModePDU, &bitStrm, &errorCode))
    {
        printf("[Mode Control Service Adapter] Decode failed. Error code: %d\n", errorCode);
    }
    
    return decodedModePDU.mode;
}

static void encodeBody(const asn1SccT_SpacecraftMode *IN_mode,
                       asn1SccT_MO_userDataField *OUT_msgBody)
{    
    BitStream bitStrm;
    int errorCode;
    asn1SccT_MAL_encoded_ModeManager encodedMode = {.isPresent = 1, .mode = *IN_mode};
    
    BitStream_Init(&bitStrm, OUT_msgBody->arr, MAX_USER_DATA_FIELD_LEN);
    
    if(!asn1SccT_MAL_encoded_ModeManager_ACN_Encode(&encodedMode,
                                                    &bitStrm,
                                                    &errorCode,
                                                    1))
    {
        printf("[Mode Control Service Adapter] Encode failed. Error code: %d\n", errorCode);
    }
    
    OUT_msgBody->nCount = BitStream_GetLength(&bitStrm);
}

void mode_control_service_adapter_PI_modeControlServiceReceiveIndication(const asn1SccT_MAL_msg_header *IN_hdr, const asn1SccT_MO_userDataField *IN_msgBody)
{
    /* Write your code here! */
    printf("[Mode Control Service Adapter] Recieve Indication\n");
    
    asn1SccT_SpacecraftMode currentMode, newMode;
    asn1SccT_MAL_msg_header responseMsg = { .uriTo = 0};
    
    asn1SccT_MO_userDataField responseBody = { .nCount = 0 };
    
    // We do not need to inspect interaction type and stage to adapt for this service
    switch(IN_hdr->operation)
    {
        case 100:
            //Set Mode
            
            newMode= decodeBody(IN_msgBody);
            
            printf("[Mode Control Service Adapter] Operation: Set Mode, Provider ID: %u, Value: %u\n", IN_hdr->uriTo, newMode);
            mode_control_service_adapter_RI_setMode(&IN_hdr->uriTo,
                                                    &newMode);
            
            //Send SUBMIT-ACK            
            responseMsg.uriFrom           = IN_hdr->uriTo;
            responseMsg.timestamp          = IN_hdr->timestamp; //TODO: time service
            responseMsg.uriTo             = IN_hdr->uriFrom;
            responseMsg.interactionType   = asn1Sccsubmit;
            responseMsg.interactionStage  = 2;
            responseMsg.transactionId     = IN_hdr->transactionId;
            responseMsg.serviceArea       = IN_hdr->serviceArea;
            responseMsg.moService         = IN_hdr->moService;
            responseMsg.operation         = IN_hdr->operation;
            responseMsg.areaVersion       = IN_hdr->areaVersion;
            responseMsg.isErrorMsg        = IN_hdr->isErrorMsg;
            
            
            mode_control_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);            
            
            break;
            
        case 101:
            //Get Mode
            
            mode_control_service_adapter_RI_getMode(&IN_hdr->uriTo,
                                                    &currentMode);
            //Send Response            
            encodeBody(&currentMode, &responseBody);            
            
            //Send REQUEST-RESPONSE            
            responseMsg.uriFrom           = IN_hdr->uriTo;
            responseMsg.timestamp          = IN_hdr->timestamp; //TODO: time service
            responseMsg.uriTo             = IN_hdr->uriFrom;
            responseMsg.interactionType   = asn1Sccrequest;
            responseMsg.interactionStage  = 2;
            responseMsg.transactionId     = IN_hdr->transactionId;
            responseMsg.serviceArea       = IN_hdr->serviceArea;
            responseMsg.moService         = IN_hdr->moService;
            responseMsg.operation         = IN_hdr->operation;
            responseMsg.areaVersion       = IN_hdr->areaVersion;
            responseMsg.isErrorMsg        = IN_hdr->isErrorMsg;
            
            
            mode_control_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
            
            break;
            
        default:
            printf("[Mode Control Service Adapter] Unknown Operation\n");
    }
    
}


/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "parameter_service_adapter.h"

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#define MAX_USER_DATA_FIELD_LEN 222

//Lookup table for mal header information for ongoing PUB SUB operations
static asn1SccT_MAL_msg_header monitorValueSubscriptions[4];


static void lookupMalHeaderForNotification(asn1SccT_apid consumerApid,
                                           asn1SccT_MAL_msg_header *OUT_hdr)
{
//     In this demonstrator there is only ever a single subscription per consumerApid
//        We know the consumer APIDs that may be used in advance
    
    switch(consumerApid)
    {
        case 100:
            *OUT_hdr = monitorValueSubscriptions[0];
            break;
            
        case 106:
            *OUT_hdr = monitorValueSubscriptions[1];
            break;
            
        case 2042:            
             *OUT_hdr = monitorValueSubscriptions[2];
            break;
            
        case 2044:            
             *OUT_hdr = monitorValueSubscriptions[3];
            break;
            
        default:
            assert(0 && "Unexpected parameter service monitor value consumer");
    }
    
}

static void storeMalHeaderForNotification(asn1SccT_apid consumerApid,
                                          const asn1SccT_MAL_msg_header *IN_hdr)
{
//     In this demonstrator there is only ever a single subscription per consumerApid
//        We know the consumer APIDs that may be used in advance
    
    switch(consumerApid)
    {
        case 100:
            monitorValueSubscriptions[0] = *IN_hdr;
            break;
            
        case 106:
            monitorValueSubscriptions[1] = *IN_hdr;
            break;
            
        case 2042:            
            monitorValueSubscriptions[2] = *IN_hdr;
            break;
            
        case 2044:            
            monitorValueSubscriptions[3] = *IN_hdr;
            break;
            
        default:
            assert(0 && "Unexpected parameter service monitor value consumer");
    }
    
}

void parameter_service_adapter_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

static void
decodeGetValueRequestBody(const asn1SccT_MO_userDataField *IN_msgBody,
                          asn1SccT_MO_parameter_getValueRequestBody *OUT_requestBody) 
{
    BitStream bitStrm;
    asn1SccT_MAL_encoded_parameter_getValueRequestBody decodedPDU = { .paramID.isPresent = 1, .paramID.intVal = 3 };
    int errorCode;
    
    // Explicit cast to avoid cast discarding const qualifier warning. We will not be writing to this buffer.
    BitStream_AttachBuffer(&bitStrm, (unsigned char *)(IN_msgBody->arr), IN_msgBody->nCount);
    
    if(!asn1SccT_MAL_encoded_parameter_getValueRequestBody_ACN_Decode(&decodedPDU,
                                                                      &bitStrm,
                                                                      &errorCode))
    {
        printf("[Parameter Service Adapter] Decode failed. Error code: %d\n", errorCode);
    }
    
    printf("[Parameter Service Adapter] Message body len: %u \n", IN_msgBody->nCount);
      
    printf("[Parameter Service Adapter] decodedPDU.isPresent: %u, decodedPDU.intVal: %#llx \n",
                decodedPDU.paramID.isPresent,
                decodedPDU.paramID.intVal);
       
    OUT_requestBody->paramID = decodedPDU.paramID.intVal;
}

static void encodeGetValueResponseBody(const asn1SccT_Int32 *IN_paramID,
                                       const asn1SccT_Int32 *IN_paramVal,
                                       asn1SccT_MO_userDataField *OUT_msgBody)
{
    BitStream bitStrm;
    int errorCode;
    asn1SccT_MAL_encoded_parameter_getValueResponseBody encoded = 
                {.paramID.isPresent  = 1,
                 .paramID.intVal     = *IN_paramID,  
                 .paramVal.isPresent = 1, 
                 .paramVal.intVal    = *IN_paramVal};
    
    BitStream_Init(&bitStrm, OUT_msgBody->arr, MAX_USER_DATA_FIELD_LEN);
    
    if(!asn1SccT_MAL_encoded_parameter_getValueResponseBody_ACN_Encode(&encoded,
                                                    &bitStrm,
                                                    &errorCode,
                                                    1))
    {
        printf("[Parameter Service Adapter] Encode failed. Error code: %d\n", errorCode);
    }
    
    OUT_msgBody->nCount = BitStream_GetLength(&bitStrm);
    
    
}

static void handleGetValueRequest(const asn1SccT_MAL_msg_header *IN_hdr,
                                  const asn1SccT_MO_userDataField *IN_msgBody)
{ 
    asn1SccT_MO_parameter_getValueRequestBody   requestBody = { .paramID = 0}; 
    asn1SccT_MAL_msg_header                     responseMsg = { .uriTo = 0};    
    asn1SccT_MO_userDataField                   responseBody = { .nCount = 0 };
    asn1SccT_Int32 parameterID = 0;
    asn1SccT_MO_ParameterValue paramValue;
    asn1SccT_MO_ErrorCodes     exception;
    
    //Decode body to get param ID                
    decodeGetValueRequestBody(IN_msgBody, &requestBody);
    
    //Get Current parameter Value requested
    printf("[Parameter Service Adapter] Operation: Get Parameter, Provider ID: %lld, Parameter ID: %#llx\n", IN_hdr->uriTo, requestBody.paramID);
        
    parameter_service_adapter_RI_getValue(&IN_hdr->uriTo,
                                          &parameterID,
                                          &paramValue,
                                          &exception);
    
    //Send Response  
    
    if(exception == asn1SccT_MO_ErrorCodes_none)
    {
        responseMsg.isErrorMsg        = 0;          
        encodeGetValueResponseBody(&parameterID, &paramValue.rawValue, &responseBody);
    }
    else
    {
        responseMsg.isErrorMsg        = 1;
        //TODO: Encode list of unkown ids
    }
    
    
    //Send REQUEST-RESPONSE            
    responseMsg.uriFrom           = IN_hdr->uriTo;
    responseMsg.timestamp         = IN_hdr->timestamp; //TODO: time service
    responseMsg.uriTo             = IN_hdr->uriFrom;
    responseMsg.interactionType   = asn1Sccrequest;
    responseMsg.interactionStage  = 2;
    responseMsg.transactionId     = IN_hdr->transactionId;
    responseMsg.serviceArea       = IN_hdr->serviceArea;
    responseMsg.moService         = IN_hdr->moService;
    responseMsg.operation         = IN_hdr->operation;
    responseMsg.areaVersion       = IN_hdr->areaVersion;
    
    
    
    parameter_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
    
}

static void
decodeSetValueSubmitBody(const asn1SccT_MO_userDataField *IN_msgBody,
                         asn1SccT_MO_parameter_setValueSubmitBody *OUT_submitBody) 
{
    BitStream bitStrm;
    asn1SccT_MAL_encoded_parameter_setValueSubmitBody decodedPDU;
    int errorCode;
    
    // Explicit cast to avoid cast discarding const qualifier warning. We will not be writing to this buffer.
    BitStream_AttachBuffer(&bitStrm, (unsigned char *)(IN_msgBody->arr), IN_msgBody->nCount);
    
    if(!asn1SccT_MAL_encoded_parameter_setValueSubmitBody_ACN_Decode(&decodedPDU,
                                                                      &bitStrm,
                                                                      &errorCode))
    {
        printf("[Parameter Service Adapter] Decode failed. Error code: %d\n", errorCode);
    }
       
    OUT_submitBody->paramID  = decodedPDU.paramID.intVal;
    OUT_submitBody->paramVal = decodedPDU.paramVal.intVal;
}

static void handleSetValueSubmit(const asn1SccT_MAL_msg_header *IN_hdr,
                                 const asn1SccT_MO_userDataField *IN_msgBody)
{ 
    asn1SccT_MO_parameter_setValueSubmitBody    submitBody = { .paramID = 0}; 
    asn1SccT_MAL_msg_header                     responseMsg = { .uriTo = 0};    
    asn1SccT_MO_userDataField                   responseBody = { .nCount = 0 };
    asn1SccT_MO_ErrorCodes     exception;
    
    //Decode body to get param ID and value        
    decodeSetValueSubmitBody(IN_msgBody, &submitBody);
    
    //Set new parameter Value requested
    printf("[Parameter Service Adapter] Operation: Set Parameter, Provider ID: %lld, Parameter ID: %#llx, Parameter Value: %#llx\n",
                        IN_hdr->uriTo,
                        submitBody.paramID,
                        submitBody.paramVal);
        
    parameter_service_adapter_RI_setValue(&IN_hdr->uriTo,
                                          &submitBody.paramID,
                                          &submitBody.paramVal,
                                          &exception);
    
    if(exception == asn1SccT_MO_ErrorCodes_none)
    {
        responseMsg.isErrorMsg        = 0;
    }
    else
    {
        responseMsg.isErrorMsg        = 1;
        //TODO: Encode list of affected ids
    }
    
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

    
    parameter_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
    
}

static void handleEnableGenerationSubmit(const asn1SccT_MAL_msg_header *IN_hdr,
                                 const asn1SccT_MO_userDataField *IN_msgBody)
{
     asn1SccT_MAL_msg_header                     responseMsg = { .uriTo = 0};    
     asn1SccT_MO_userDataField                   responseBody = { .nCount = 0 };
    
     //Decode body to get instance boolean pairs
    
     asn1SccT_Boolean isgroup = 0;
     asn1SccT_InstanceBooleanPairList pairs = { .nCount = 1 };
     
     asn1SccT_InstanceBooleanPair pair;
     pair.id = 1;
     pair.value = 1;
     pairs.arr[0] = pair;
      
     // Call Dispatcher Interface
     parameter_service_adapter_RI_enableGeneration(
                                    &IN_hdr->uriTo,
                                    &isgroup,
                                    &pairs);
                                                   
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
    
    parameter_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
                                                   
}

static void handleMonitorValueOperation(const asn1SccT_MAL_msg_header *IN_hdr,
                                        const asn1SccT_MO_userDataField *IN_msgBody)
{
    
    asn1SccT_MAL_msg_header responseMsg    = { .uriTo = 0}; 
    asn1SccT_MO_userDataField responseBody = { .nCount = 0 };
    asn1SccT_apid temp;
    
       
//     Register and Deregister are only ever given wildcards by demo ground, so we 
//     skip decoding the body.
    
    // Body always contains subscriptionID "SUB"
     asn1SccT_String subscriptionID;
     subscriptionID.arr[0] = 'S';
     subscriptionID.arr[1] = 'U';
     subscriptionID.arr[2] = 'B';
     subscriptionID.arr[3] = '\0';
    
    //Switch on PUB-SUB interaction stage provided
    switch(IN_hdr->interactionStage)
    {        
        // Register
        // save transactionid and mal header parts for future notifications
        case 1:
            storeMalHeaderForNotification(IN_hdr->uriFrom ,IN_hdr);
            
            // Call provider register function
            parameter_service_adapter_RI_monitorValueRegister(&IN_hdr->uriTo, 
                                                              &IN_hdr->uriFrom,
                                                              &subscriptionID);
            
            //Send Register ACK
            responseMsg.uriFrom           = IN_hdr->uriTo;
            responseMsg.timestamp         = IN_hdr->timestamp; //TODO: time service
            responseMsg.uriTo             = IN_hdr->uriFrom;
            responseMsg.interactionType   = asn1Sccpubsub;
            responseMsg.interactionStage  = 2;
            responseMsg.transactionId     = IN_hdr->transactionId;
            responseMsg.serviceArea       = IN_hdr->serviceArea;
            responseMsg.moService         = IN_hdr->moService;
            responseMsg.operation         = IN_hdr->operation;
            responseMsg.areaVersion       = IN_hdr->areaVersion;
            responseMsg.isErrorMsg        = IN_hdr->isErrorMsg;
            
                        
            parameter_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
            break;        
        
        // Deregister
        case 7:
            
            parameter_service_dispatch_PI_monitorValueDeregister(&IN_hdr->uriTo, 
                                                                 &IN_hdr->uriFrom,
                                                                 &subscriptionID);            
  
            //Fetch initial message header
            lookupMalHeaderForNotification(IN_hdr->uriFrom, &responseMsg);
            
            //Send Deregister ACK
            temp = responseMsg.uriTo;
            responseMsg.uriTo = responseMsg.uriFrom;
            responseMsg.uriFrom = temp;            
            responseMsg.interactionStage = 8;
            
            parameter_service_adapter_RI_transmitRequest(&responseMsg, &responseBody); 
            break;
            
        default:
            printf("[Parameter Service Adapter] Unexpected Interaction stage. MonitorValue Stage: %u\n", IN_hdr->interactionStage);
       
    }
}

void parameter_service_adapter_PI_paramServiceReceiveIndication(const asn1SccT_MAL_msg_header *IN_hdr,
                                                                const asn1SccT_MO_userDataField *IN_msgBody)
{
    /* Dispatch according to operation type and interaction stage */
    printf("[Parameter Service Adapter] Receive Indication\n");
    
    // Operation numbers as specified in XML Service Specification
    switch(IN_hdr->operation)
    {
        case 1:
            handleMonitorValueOperation(IN_hdr, IN_msgBody);
            break;
            
        case 2:
            handleGetValueRequest(IN_hdr, IN_msgBody);            
            break;
            
        case 3:
            //Set Value
            handleSetValueSubmit(IN_hdr, IN_msgBody);
            break;
            
        case 4:
            //enable generation
            handleEnableGenerationSubmit(IN_hdr, IN_msgBody);
            break;
            
        default:
            printf("[Parameter Service Adapter] Unknown Operation\n");
    }
}


static void encodeMonitorValueNotifyBody(const asn1SccT_MO_parameter_MonitorValueNotifyBody_updateHeaders *IN_updateHeaderList,
                                         const asn1SccT_MO_parameter_MonitorValueNotifyBody_sourceIDs *IN_sourceIds,
                                         const asn1SccT_MO_parameter_MonitorValueNotifyBody_paramVals *IN_paramVals,
                                         asn1SccT_MO_userDataField *OUT_msgBody)
{
    BitStream bitStrm;
    int errorCode;
    
    // Ground only ever uses this subscription ID.             
    asn1SccT_MO_parameter_MonitorValueNotifyBody_subscriptionID subID = {.nCount =3};
    subID.arr[0] = 'S';
    subID.arr[1] = 'U';
    subID.arr[2] = 'B';
    
    asn1SccT_MO_parameter_MonitorValueNotifyBody encoded = 
                {
                    .subscriptionID = subID,
                    .updateHeaders  = *IN_updateHeaderList,
                    .sourceIDs      = *IN_sourceIds,
                    .paramVals      = *IN_paramVals
                };
                 

    BitStream_Init(&bitStrm, OUT_msgBody->arr, MAX_USER_DATA_FIELD_LEN);
    
    if(!asn1SccT_MO_parameter_MonitorValueNotifyBody_ACN_Encode(&encoded,
                                                    &bitStrm,
                                                    &errorCode,
                                                    1))
    {
        printf("[Parameter Service Adapter] Encode failed. Error code: %d\n", errorCode);
    }
    
    OUT_msgBody->nCount = BitStream_GetLength(&bitStrm);
    
    
}

void parameter_service_adapter_PI_monitorValueNotify(const asn1SccT_apid *IN_consumerApid, 
                                                     const asn1SccT_Int32 *IN_paramID, 
                                                     const asn1SccT_MO_ParameterValue *IN_paramVal)
{
    const char uriStr[] = "SomeURI"; //Ignored by ground
    
    asn1SccT_MAL_msg_header responseMsg = { .uriTo = 0};
    asn1SccT_MO_userDataField responseBody = { .nCount = 0 };
    
    lookupMalHeaderForNotification(*IN_consumerApid, &responseMsg);
    
    //Send Notification    
    asn1SccT_apid temp = responseMsg.uriTo;
    responseMsg.uriTo = responseMsg.uriFrom;
    responseMsg.uriFrom = temp;
    
    responseMsg.interactionStage  = 6;
    
    
    asn1SccT_MO_parameter_MonitorValueNotifyBody_updateHeaders updateHeaders = {.nCount = 1};
    
    updateHeaders.arr[0].sourceURI.nCount = sizeof(uriStr) -1;
    memcpy(updateHeaders.arr[0].sourceURI.arr, uriStr, 12);
    updateHeaders.arr[0].updateType = asn1Sccupdate;
    
    updateHeaders.arr[0].key.firstSubKey.nCount = strlen(IN_paramVal->related.related.objectName.arr);
    memcpy(updateHeaders.arr[0].key.firstSubKey.arr,
           IN_paramVal->related.related.objectName.arr,
           updateHeaders.arr[0].key.firstSubKey.nCount);
    
    
    // Source type for periodic update is NULL
    asn1SccT_MO_parameter_MonitorValueNotifyBody_sourceIDs sourceIds =   {
                                            .nCount = 1,
                                            .arr = { {.isPresent=1, .intVal = 0} } };
                                            
                                            
    asn1SccT_MO_parameter_MonitorValueNotifyBody_paramVals paramVals = {
                                            .nCount = 1,
                                            .arr = { { .validity = asn1Sccvalid, 
                                                       .rawValue = {.isPresent=1, .intVal = IN_paramVal->rawValue},
                                                       .convertedValue = {.isPresent=1, .intVal = IN_paramVal->rawValue}  } } };

     
    
    encodeMonitorValueNotifyBody(&updateHeaders,
                                 &sourceIds,
                                 &paramVals,
                                 &responseBody);
    
    parameter_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
    
    
}



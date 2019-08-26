/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "aggregation_service_adapter.h"

#include <stdio.h>
#include <string.h>
#include <stdint.h>
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
            assert(0 && "Unexpected aggregation service monitor value consumer");
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
            assert(0 && "Unexpected aggregation service monitor value consumer");
    }
    
}

void aggregation_service_adapter_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}


static void decodeEnableGenerationSubmitBody(const asn1SccT_MO_userDataField *IN_msgBody,
                                             asn1SccT_InstanceBooleanPairList *OUT_enableInstances)
{
    BitStream bitStrm;
    asn1SccT_MO_aggregation_enableGenerationSubmitBody decodedPDU = { .enableInstances = {.nCount = 0} };
    int errorCode, i;
    
    // Explicit cast to avoid cast discarding const qualifier warning. We will not be writing to this buffer.
    BitStream_AttachBuffer(&bitStrm, (unsigned char *)(IN_msgBody->arr), IN_msgBody->nCount);
    
    if(!asn1SccT_MO_aggregation_enableGenerationSubmitBody_ACN_Decode(&decodedPDU,
                                                                      &bitStrm,
                                                                      &errorCode))
    {
        printf("[Aggregation Service Adapter] Decode failed. Error code: %d\n", errorCode);
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
     aggregation_service_adapter_RI_enableGeneration(
                                    &IN_hdr->uriTo,
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
    
    aggregation_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
                                                   
}

static void
decodeGetValueRequestBody(const asn1SccT_MO_userDataField *IN_msgBody,
                          asn1SccT_MO_aggregation_getValueRequestBody *OUT_requestBody) 
{
    BitStream bitStrm;
    asn1SccT_MO_aggregation_getValueRequestBody decodedPDU = { 0 };
    int errorCode;
    
    // Explicit cast to avoid cast discarding const qualifier warning. We will not be writing to this buffer.
    BitStream_AttachBuffer(&bitStrm, (unsigned char *)(IN_msgBody->arr), IN_msgBody->nCount);
    
    if(!asn1SccT_MO_aggregation_getValueRequestBody_ACN_Decode(OUT_requestBody,
                                                               &bitStrm,
                                                               &errorCode))
    {
        printf("[Aggregation Service Adapter] Decode failed. Error code: %d\n", errorCode);
        return;
    }
}

static void encodeGetValueResponseBody(const asn1SccT_Int32List *IN_aggInstIDs,
                                       const asn1SccT_MO_AggregationValueList *IN_aggVals,
                                       asn1SccT_MO_userDataField *OUT_msgBody)
{
    int i, j;
    BitStream bitStrm;
    int errorCode;
    asn1SccT_MAL_encoded_AggregationValue *pAggregationValue;
    
    asn1SccT_MAL_encoded_ParameterValue *pEncodedParameterSet;
    asn1SccT_MO_ParameterValue  const   *pParameterSet;
    
    
    asn1SccT_MO_aggregation_getValueResponseBody encoded = {0};
    
    //Encode Inst IDs list
    encoded.aggInstIds.nCount = IN_aggInstIDs->nCount;    
    for(i = 0; i < encoded.aggInstIds.nCount; i++)
    {
       encoded.aggInstIds.arr[i].isPresent= 1;
       encoded.aggInstIds.arr[i].intVal   = IN_aggInstIDs->arr[i]; 
    }
    
    //Encode Agg Values list    
    encoded.aggValues.nCount = IN_aggVals->nCount;
    for(i = 0; i < encoded.aggValues.nCount; i++)
    {
        encoded.aggValues.arr[i].aggSets.nCount = 1;
        encoded.aggValues.arr[i].aggSets.arr[0].deltaTime.isPresent = 1;
        encoded.aggValues.arr[i].aggSets.arr[0].deltaTime.intVal    = 0; //TODO time acess
        encoded.aggValues.arr[i].aggSets.arr[0].parameterSet.nCount = IN_aggVals->arr[i].values.arr[0].values.nCount;
        
        pParameterSet = IN_aggVals->arr[i].values.arr[0].values.arr;
        pEncodedParameterSet = encoded.aggValues.arr[i].aggSets.arr[0].parameterSet.arr;
        
        // For each parameter in aggregation:
        for(j = 0; j < IN_aggVals->arr[i].values.arr[0].values.nCount; j++)
        {
            pEncodedParameterSet[j].validity                 = asn1Sccvalid;
            pEncodedParameterSet[j].rawValue.isPresent       = 1;
            pEncodedParameterSet[j].rawValue.intVal          = pParameterSet[j].rawValue;
            pEncodedParameterSet[j].convertedValue.isPresent = 1;
            pEncodedParameterSet[j].convertedValue.intVal    = pParameterSet[j].rawValue;
        }            
    } 
    
    BitStream_Init(&bitStrm, OUT_msgBody->arr, MAX_USER_DATA_FIELD_LEN);
    
    if(!asn1SccT_MO_aggregation_getValueResponseBody_ACN_Encode(&encoded,
                                                    &bitStrm,
                                                    &errorCode,
                                                    1))
    {
        printf("[Aggregation Service Adapter] Encode failed. Error code: %d\n", errorCode);
    }
    
    OUT_msgBody->nCount = BitStream_GetLength(&bitStrm);
    
    
}

static void handleGetValueRequest(const asn1SccT_MAL_msg_header *IN_hdr,
                                  const asn1SccT_MO_userDataField *IN_msgBody)
{ 
    asn1SccT_MO_aggregation_getValueRequestBody requestBody  = { 0 }; 
    asn1SccT_MAL_msg_header                     responseMsg  = { 0 };    
    asn1SccT_MO_userDataField                   responseBody = { 0 };
    asn1SccT_Int32List                          aggInstIDs   = { 0 };
    asn1SccT_MO_AggregationValueList            aggValues    = { 0 };
    asn1SccT_MO_ErrorCodes                      exception = asn1SccT_MO_ErrorCodes_none;
    int i;
    
    
    //Decode body to get aggInstIDs               
    decodeGetValueRequestBody(IN_msgBody, &requestBody);
    
    aggInstIDs.nCount = requestBody.aggInstIds.nCount;
    
    // COnvert from MAL encoded type to onboard type
    printf("[Aggregation Service Adapter] Decode Get Value Request. Get Agg IDs: [ ");  
    for(i = 0; i < aggInstIDs.nCount; i++)
    {
        aggInstIDs.arr[i] = requestBody.aggInstIds.arr[i].intVal;
        printf("%lld ", aggInstIDs.arr[i]);
        fflush(stdout);
    }
    printf("]\n");
    
    
    //Get Aggregation Values requested
    printf("[Aggregation Service Adapter] Operation: Get Aggregations, Provider ID: %lld\n", IN_hdr->uriTo);
     
    aggregation_service_adapter_RI_getValue(&IN_hdr->uriTo,
                                            &aggInstIDs,
                                            &aggValues);
    
    //Send Response  
    
    if(exception == asn1SccT_MO_ErrorCodes_none)
    {
        responseMsg.isErrorMsg        = 0;          
        encodeGetValueResponseBody(&aggInstIDs, &aggValues, &responseBody);
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
    
    
    
    aggregation_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
    
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
            aggregation_service_adapter_RI_monitorValueRegister(&IN_hdr->uriTo, 
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
            
                        
            aggregation_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);
            break;        
        
        // Deregister
        case 7:
            
            aggregation_service_adapter_RI_monitorValueDeregister(&IN_hdr->uriTo, 
                                                                 &IN_hdr->uriFrom,
                                                                 &subscriptionID);            
  
            //Fetch initial message header
            lookupMalHeaderForNotification(IN_hdr->uriFrom, &responseMsg);
            
            //Send Deregister ACK
            temp = responseMsg.uriTo;
            responseMsg.uriTo = responseMsg.uriFrom;
            responseMsg.uriFrom = temp;            
            responseMsg.interactionStage = 8;
            
            aggregation_service_adapter_RI_transmitRequest(&responseMsg, &responseBody); 
            break;
            
        default:
            printf("[Aggregation Service Adapter] Unexpected Interaction stage. MonitorValue Stage: %u\n", IN_hdr->interactionStage);
       
    }
}

void aggregation_service_adapter_PI_aggrServiceReceiveIndication(
                                        const asn1SccT_MAL_msg_header *IN_hdr,
                                        const asn1SccT_MO_userDataField *IN_msgBody)
{    
     /* Dispatch according to operation type and interaction stage */
    printf("[Aggregation Service Adapter] Receive Indication\n");
    
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
            //enable generation
            handleEnableGenerationSubmit(IN_hdr, IN_msgBody);
            break;
            
        default:
            printf("[Aggregation Service Adapter] Unknown Operation\n");
    }
}

static void encodeMonitorValueNotifyBody(const asn1SccT_MO_aggregation_MonitorValueNotifyBody_updateHeaders *IN_updateHeaderList,
                                       const asn1SccT_MO_aggregation_MonitorValueNotifyBody_sourceIDs *IN_sourceIDs,
                                       const asn1SccT_MO_aggregation_MonitorValueNotifyBody_aggrVals *IN_aggVals,
                                       asn1SccT_MO_userDataField *OUT_msgBody)
{
    int i, j;
    BitStream bitStrm;
    int errorCode;
    asn1SccT_MAL_encoded_AggregationValue *pAggregationValue;
    
    asn1SccT_MAL_encoded_ParameterValue *pEncodedParameterSet;
    asn1SccT_MO_ParameterValue  const   *pParameterSet;
    
        // Ground only ever uses this subscription ID.             
    asn1SccT_MO_aggregation_MonitorValueNotifyBody_subscriptionID subID = {.nCount =3};
    subID.arr[0] = 'S';
    subID.arr[1] = 'U';
    subID.arr[2] = 'B';
    
    asn1SccT_MO_aggregation_MonitorValueNotifyBody encoded = {0};
    
    encoded.subscriptionID = subID;
    encoded.updateHeaders = *IN_updateHeaderList;
    encoded.sourceIDs    = *IN_sourceIDs;
    encoded.aggrVals     = *IN_aggVals;
        
    
    BitStream_Init(&bitStrm, OUT_msgBody->arr, MAX_USER_DATA_FIELD_LEN);
    
    if(!asn1SccT_MO_aggregation_MonitorValueNotifyBody_ACN_Encode(&encoded,
                                                    &bitStrm,
                                                    &errorCode,
                                                    1))
    {
        printf("[Aggregation Service Adapter] Encode failed. Error code: %d\n", errorCode);
    }
    
    OUT_msgBody->nCount = BitStream_GetLength(&bitStrm);
    
    
}

static void mal_encode_aggregation(const asn1SccT_MO_AggregationValue *IN_aggregationValue,
                                   asn1SccT_MAL_encoded_AggregationValue *OUT_encoded)
{
     //Encode Agg Values list    
    int i;
    
    OUT_encoded->aggSets.nCount = 1;
    OUT_encoded->aggSets.arr[0].deltaTime.isPresent = 1;
    OUT_encoded->aggSets.arr[0].deltaTime.intVal    = 0; //TODO time acess
    OUT_encoded->aggSets.arr[0].parameterSet.nCount = IN_aggregationValue->values.arr[0].values.nCount;
    
    asn1SccT_MO_ParameterValue const *pParameterSet = IN_aggregationValue->values.arr[0].values.arr;
    asn1SccT_MAL_encoded_ParameterValue *pEncodedParameterSet = OUT_encoded->aggSets.arr[0].parameterSet.arr;
    
    // For each parameter in aggregation:
    for(i = 0; i < IN_aggregationValue->values.arr[0].values.nCount; i++)
    {
        pEncodedParameterSet[i].validity                 = asn1Sccvalid;
        pEncodedParameterSet[i].rawValue.isPresent       = 1;
        pEncodedParameterSet[i].rawValue.intVal          = pParameterSet[i].rawValue;
        pEncodedParameterSet[i].convertedValue.isPresent = 1;
        pEncodedParameterSet[i].convertedValue.intVal    = pParameterSet[i].rawValue;
    }            
    
}

void aggregation_service_adapter_PI_monitorValueNotify(
                            const asn1SccT_apid *IN_consumerID,
                            const asn1SccT_Int32 *IN_aggregationID,
                            const asn1SccT_MO_AggregationValue *IN_aggregationValue)

{
    const char uriStr[] = "SomeURI"; //Ignored by ground
    
    asn1SccT_MAL_msg_header responseMsg = { .uriTo = 0};
    asn1SccT_MO_userDataField responseBody = { .nCount = 0 };
    
    lookupMalHeaderForNotification(*IN_consumerID, &responseMsg);
    
    //Send Notification    
    asn1SccT_apid temp = responseMsg.uriTo;
    responseMsg.uriTo = responseMsg.uriFrom;
    responseMsg.uriFrom = temp;
    
    responseMsg.interactionStage  = 6;
    
    
    asn1SccT_MO_aggregation_MonitorValueNotifyBody_updateHeaders updateHeaders = {.nCount = 1};
    
    updateHeaders.arr[0].sourceURI.nCount = sizeof(uriStr) -1;
    memcpy(updateHeaders.arr[0].sourceURI.arr, uriStr, 12);
    updateHeaders.arr[0].updateType = asn1Sccupdate;
    
    updateHeaders.arr[0].key.firstSubKey.nCount = strlen(IN_aggregationValue->related.related.objectName.arr);
    memcpy(updateHeaders.arr[0].key.firstSubKey.arr,
           IN_aggregationValue->related.related.objectName.arr,
           updateHeaders.arr[0].key.firstSubKey.nCount);
    
    
    // Source type for periodic update is NULL
    asn1SccT_MO_aggregation_MonitorValueNotifyBody_sourceIDs sourceIds =   {
                                            .nCount = 1,
                                            .arr = { {.isPresent=1, .intVal = *IN_aggregationID} } };
                                            
                                          
    asn1SccT_MO_aggregation_MonitorValueNotifyBody_aggrVals aggrVals = { .nCount = 1 };    
    mal_encode_aggregation(IN_aggregationValue, aggrVals.arr);  
    
    encodeMonitorValueNotifyBody(&updateHeaders,
                                 &sourceIds,
                                 &aggrVals,
                                 &responseBody);
    
    aggregation_service_adapter_RI_transmitRequest(&responseMsg, &responseBody);    
}



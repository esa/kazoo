/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "aggregation_service_provider.h"

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

#define NUM_AGGRS 2LL
#define NUM_SUBSCRIBERS 2LL

typedef struct {    
    asn1SccT_apid consumerID;
    asn1SccT_Boolean registeredAggregations[NUM_AGGRS];
}subscriptionList;

// Fills the  role of both container and provider for aggregation service. Part of the execution platfrom

static subscriptionList subscriptions[NUM_SUBSCRIBERS] = {
                                                {.consumerID = 106, .registeredAggregations =  {0, 0} },
                                                {.consumerID = 2042, .registeredAggregations = {1, 0} }
                                           };

static asn1SccT_Int32 instIdInc = 0x016B00;

// Static aggregation definitions
static asn1SccT_MO_AggregationDefinitionDetails  aggregations[NUM_AGGRS] = {
    
    // mode and Gyro temp
    { .objectInstID = 0x6B00, .related = { .objectInstID = 0x6B10, .objectName = {.arr = "housekeeping"} }, .generationEnabled = 0,
        .parameterSets = { .nCount = 1, .arr = { {.parameters = {.nCount = 2, .arr = {0x6500, 0x7801} } } } } },
    
    { .objectInstID = 0x6B01, .related = { .objectInstID = 0x6B10, .objectName = {.arr = "diagnostic"} }, .generationEnabled = 0,
        .parameterSets = { .nCount = 1, .arr = { {.parameters = {.nCount = 3, .arr = {0x6500, 0x7800, 0x7801} } } } } },   
};

void aggregation_service_provider_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void aggregation_service_provider_PI_enableGeneration(const asn1SccT_InstanceBooleanPairList *IN_enableInstances)
{        
     int i;
     
     for(i = 0; i < IN_enableInstances->nCount; i++)
     {
         printf("[Aggregation Service] %s generation of aggregation: %lld\n",
                IN_enableInstances->arr[i].value ? "Enable":"Disable",
                IN_enableInstances->arr[i].id);
         
         aggregations[IN_enableInstances->arr[i].id].generationEnabled = IN_enableInstances->arr[i].value;
     }
    
}

static void populateAggrVal(int aggrDefNum,
                            asn1SccT_MO_AggregationValue *OUT_aggrValue)
{
    int i;
    asn1SccT_apid  providerID;
    asn1SccT_Int32 parameterID;
    asn1SccT_MO_ParameterValue parameterValue;
    asn1SccT_MO_ErrorCodes exceptionCode;
            
    OUT_aggrValue->objectInstID = instIdInc++;
    OUT_aggrValue->related = aggregations[aggrDefNum];
    
    // aggregation value contains a list of aggregation sets: a duration/list of parametervalues pair
    // We only ever have a single aggregation set per parameter value in this demo
    asn1SccT_MO_AggregationSetValue *pAggregationSet = OUT_aggrValue->values.arr;
    OUT_aggrValue->values.nCount = 1;
    
    pAggregationSet->deltaTime= (asn1SccT_UnsegmentedTime) {1,2,3,4}; // Place holder. No Time  service available
    pAggregationSet->values.nCount = aggregations[aggrDefNum].parameterSets.arr[0].parameters.nCount;
    
    asn1SccT_MO_ParameterValue     *pParameterSet = pAggregationSet->values.arr;
    
    
    
    // call parameter service gets for aggregation service parameters
    
    for(i = 0; i < pAggregationSet->values.nCount; i++)
    {
        providerID  = aggregations[aggrDefNum].parameterSets.arr[0].parameters.arr[i] >> 8;
        parameterID = aggregations[aggrDefNum].parameterSets.arr[0].parameters.arr[i] & 0xFF;
        
        printf("[Aggregation Service] Get Parameter: ProviderID: %lld ParameterID: %lld \n", providerID, parameterID);
                
        aggregation_service_provider_RI_paramServiceGetValue(&providerID,
                                                            &parameterID,
                                                            pParameterSet + i,
                                                            &exceptionCode);
        
        printf("[Aggregation Service] Got Value:  %lld \n", pParameterSet[i].rawValue);
        
    }
        
    
}

void aggregation_service_provider_PI_update()
{
    // Send notification for enabled aggregations:
    
    asn1SccT_MO_AggregationValue aggrValue = {0};
    int i, j;
    asn1SccT_Int32 aggrID;
    
    for(i = 0; i < NUM_AGGRS; i++)
    {
        if(aggregations[i].generationEnabled)
        {       
            
            // fill out aggregation value struct
            populateAggrVal(i, &aggrValue);
            
            // for each registered subscriber, send a notification to dispatcher
            // subscribers are static. one to PUS, one to MO.
            // PUS side only receives housekeeping aggregation 
            
            for(j = 0; j < NUM_SUBSCRIBERS; j++)
            {
                if(subscriptions[j].registeredAggregations[i])
                {   
                    aggrID = i;
                    printf("[Aggregation Service] Notify Subscriber: %lld Aggregation: %d\n", subscriptions[j].consumerID, i);
                    aggregation_service_provider_RI_monitorValueNotify(&subscriptions[j].consumerID,
                                                                       &aggrID,
                                                                       &aggrValue);
                }
            }
        }
    }
}


void aggregation_service_provider_PI_getValue(const asn1SccT_Int32List *IN_aggrIDs,
                                              asn1SccT_MO_AggregationValueList *OUT_aggrValues)
{
    int i = 0;
    asn1SccT_MO_AggregationValue *pAggrValue = OUT_aggrValues->arr;
    
    // Switch on provided aggregation ID, call parameter service gets for required parameters
    printf("[Aggregation Service] Get Aggregation Values. Count: %d\n", IN_aggrIDs->nCount);
    

    for(i = 0; i < IN_aggrIDs->nCount; i++)
    {
        
        if((IN_aggrIDs->arr[i]) < NUM_AGGRS)
        {
            //Valid aggregation id
            printf("[Aggregation Service] Get Aggregation Value: %lld\n", IN_aggrIDs->arr[i]);
            
            populateAggrVal(IN_aggrIDs->arr[i], pAggrValue + i);
        }
    }
    
    OUT_aggrValues->nCount = IN_aggrIDs->nCount;
    
}

void aggregation_service_provider_PI_monitorValueRegister(const asn1SccT_apid *IN_consumerID,
                                                          const asn1SccT_String * IN_subscriptionID)

{
     printf("[Aggregation Service] Register Subscription for Consumer: %lld\n", *IN_consumerID);
     //Only one MO subscriber, always registers wildcard
     subscriptions[0].registeredAggregations[0] = 1;
     subscriptions[0].registeredAggregations[1] = 1;
}

void aggregation_service_provider_PI_monitorValueDeregister(const asn1SccT_apid *IN_consumerID,
                                                            const asn1SccT_String *IN_subscriptionID)
{
    printf("[Aggregation Service] Deregister Subscription for Consumer: %lld\n", *IN_consumerID);
    
    //Ground never calls deregister.
     subscriptions[0].registeredAggregations[0] = 0;
     subscriptions[0].registeredAggregations[1] = 0;
    
}

void aggregation_service_provider_PI_parameterReportingGroupEnable(const asn1SccT_Int32 *groupID,
                                                                   const asn1SccT_Boolean *enable)
{
    aggregations[*groupID].generationEnabled = enable != 0 ? 1 : 0;
}

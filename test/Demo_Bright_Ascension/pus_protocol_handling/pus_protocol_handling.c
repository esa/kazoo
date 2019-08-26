/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "pus_protocol_handling.h"

#include <stdint.h>
#include <stdio.h>

#define DUMMY_TM

void pus_protocol_handling_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

static void dummyResponseTM(const asn1SccT_PUS_tc_sp *tc)
{
    
    static unsigned int dummyModeVal = 1;
    static unsigned int seq20_1 = 0;
    static unsigned int seq20_3 = 0;
    static unsigned int seq128_1 = 0;
    static unsigned int seq128_3 = 0;
    
    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    asn1SccT_PUS_tm_sp tmPacket;
    asn1SccT_PUS_tm_sp_Initialize(&tmPacket);
    
    
    switch(tc->userDataField.kind){   
        
        case tc_20_1_request_parameter_PRESENT:
            printf("[PUS Protocol Handling] TC [20,1] received\n");
            
            
            tmData.kind = tm_20_2_parameter_report_PRESENT;            
            tmData.u.tm_20_2_parameter_report.value= dummyModeVal;            
                        
            tmPacket.primaryHeader.packetID.apid = 2044;
            tmPacket.primaryHeader.packetSequenceControl.sequenceControlFlags = asn1SccstandAlonePacket;
            tmPacket.primaryHeader.packetSequenceControl.sequenceCount = seq20_1++;
            tmPacket.primaryHeader.packetLength = 0; //overwritten in pus spp handler
            tmPacket.userDataField = tmData;               
            
            pus_protocol_handling_RI_pus_packetRequest(&tmPacket);
            
            break;
            
             
            
        case tc_20_3_set_parameter_PRESENT:
            printf("[PUS Protocol Handling] TC [20,3] received\n");
            
            dummyModeVal = tc->userDataField.u.tc_20_3_set_parameter.value;
           
            tmData.kind = tm_1_1_acc_success_PRESENT;            
            tmData.u.tm_1_1_acc_success.packetID = tc->primaryHeader.packetID;
            tmData.u.tm_1_1_acc_success.packetSequenceControl = tc->primaryHeader.packetSequenceControl;
            
                      
            tmPacket.primaryHeader.packetID.apid = 2044u;
            tmPacket.primaryHeader.packetSequenceControl.sequenceControlFlags = asn1SccstandAlonePacket;
            tmPacket.primaryHeader.packetSequenceControl.sequenceCount = seq20_3++;
            tmPacket.primaryHeader.packetLength = 0; //overwritten in pus spp handler
            tmPacket.userDataField = tmData;               
            
            pus_protocol_handling_RI_pus_packetRequest(&tmPacket);
            
            break;
            
        case tc_128_1_get_mode_PRESENT:
            printf("[PUS Protocol Handling] TC [128,1] received\n");
            
           
            tmData.kind = tm_128_2_mode_report_PRESENT;            
            tmData.u.tm_128_2_mode_report.mode = dummyModeVal;
            
                    
            tmPacket.primaryHeader.packetID.apid = 2043u;
            tmPacket.primaryHeader.packetSequenceControl.sequenceControlFlags = asn1SccstandAlonePacket;
            tmPacket.primaryHeader.packetSequenceControl.sequenceCount = seq128_1++;
            tmPacket.primaryHeader.packetLength = 0; //overwritten in pus spp handler
            tmPacket.userDataField = tmData;               
            
            pus_protocol_handling_RI_pus_packetRequest(&tmPacket);
            
            break;
            
        case tc_128_3_set_mode_PRESENT:
            printf("[PUS Protocol Handling] TC [128,3] received\n");
            
            dummyModeVal = tc->userDataField.u.tc_128_3_set_mode.mode; 
           
            tmData.kind = tm_1_1_acc_success_PRESENT;            
            tmData.u.tm_1_1_acc_success.packetID = tc->primaryHeader.packetID;
            tmData.u.tm_1_1_acc_success.packetSequenceControl = tc->primaryHeader.packetSequenceControl;
                    
            tmPacket.primaryHeader.packetID.apid = 2043u;
            tmPacket.primaryHeader.packetSequenceControl.sequenceControlFlags = asn1SccstandAlonePacket;
            tmPacket.primaryHeader.packetSequenceControl.sequenceCount = seq128_3++;
            tmPacket.primaryHeader.packetLength = 0; //overwritten in pus spp handler
            tmPacket.userDataField = tmData;                 
            
            pus_protocol_handling_RI_pus_packetRequest(&tmPacket);
            
            break;
            
        default:
            printf("[PUS Protocol Handling] Invalid PUS telecommand received\n");
            //FIXME: Crash gracefully?
            break;
    }
}


static void handleIllegalApid(const asn1SccT_PUS_tc_sp *tc)
{
    //Send telemetry
    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    
    tmData.kind = tm_1_2_acc_failure_PRESENT;
    tmData.u.tm_1_2_acc_failure.packetID              = tc->primaryHeader.packetID;
    tmData.u.tm_1_2_acc_failure.packetSequenceControl = tc->primaryHeader.packetSequenceControl;
    tmData.u.tm_1_2_acc_failure.failure               = asn1SccillegalApid;
    
    pus_protocol_handling_PI_pus_response(&tc->primaryHeader.packetID.apid,
                                          &tmData);
}

static void handlePusError(const asn1SccT_PUS_tc_sp *tc,
                                asn1SccT_PUS_tc_failure_code errorCode)
{

    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    
    if(!tc->secondaryHeader.ackExecutionCompletion)
    {
        return;
    }
    
    if(asn1SccT_PUS_tc_failure_code_none == errorCode)
    {
        //Send telemetry 1,7 Success exectuion
        printf("[PUS Protocol Handling] Send TM [1,7] Execution Success\n");
        tmData.kind = tm_1_7_exec_success_PRESENT;
        tmData.u.tm_1_7_exec_success.packetID              = tc->primaryHeader.packetID;
        tmData.u.tm_1_7_exec_success.packetSequenceControl = tc->primaryHeader.packetSequenceControl;       
    }
    else
    {
        //Send telemetry 1,8 Failed execution
        printf("[PUS Protocol Handling] Send TM [1,8] Execution Failure\n");
        tmData.kind = tm_1_8_exec_failure_PRESENT;
        tmData.u.tm_1_8_exec_failure.packetID              = tc->primaryHeader.packetID;
        tmData.u.tm_1_8_exec_failure.packetSequenceControl = tc->primaryHeader.packetSequenceControl;
        tmData.u.tm_1_8_exec_failure.failure               = errorCode;
    }
        
    pus_protocol_handling_PI_pus_response(&tc->primaryHeader.packetID.apid,
                                          &tmData);
}

static void handlePusAcceptance(const asn1SccT_PUS_tc_sp *tc,
                                asn1SccT_PUS_tc_failure_code errorCode)
{

    asn1SccT_PUS_tm_userDataField tmData;
    asn1SccT_PUS_tm_userDataField_Initialize( &tmData);
    
    if(!tc->secondaryHeader.ackAcceptance)
    {
        return;
    }
    
    if(asn1SccT_PUS_tc_failure_code_none == errorCode)
    {
        //Send telemetry 1,1 Success acceptance
        printf("[PUS Protocol Handling] Send TM [1,1] Acceptance Success\n");
        tmData.kind = tm_1_1_acc_success_PRESENT;
        tmData.u.tm_1_1_acc_success.packetID              = tc->primaryHeader.packetID;
        tmData.u.tm_1_1_acc_success.packetSequenceControl = tc->primaryHeader.packetSequenceControl;       
    }
    else
    {
        //Send telemetry 1,2 Failed acceptance
        printf("[PUS Protocol Handling] Send TM [1,2] Acceptance Failure\n");
        tmData.kind = tm_1_2_acc_failure_PRESENT;
        tmData.u.tm_1_2_acc_failure.packetID              = tc->primaryHeader.packetID;
        tmData.u.tm_1_2_acc_failure.packetSequenceControl = tc->primaryHeader.packetSequenceControl;
        tmData.u.tm_1_2_acc_failure.failure               = errorCode;
    }
        
    pus_protocol_handling_PI_pus_response(&tc->primaryHeader.packetID.apid,
                                          &tmData);
}

void pus_protocol_handling_PI_pus_packetIndication(const asn1SccT_PUS_tc_sp *tc)
{

    // Extract PUS command from space packet 
    // Handle PUS service 1 at this point    
    
    asn1SccT_PUS_tc_failure_code errorCode = asn1SccT_PUS_tc_failure_code_none;
    
    switch(tc->userDataField.kind){   
        
        case tc_3_5_enable_hk_PRESENT:
            printf("[PUS Protocol Handling] TC [3,5] received\n");
            break;            
        
        case tc_3_6_disable_hk_PRESENT:
            printf("[PUS Protocol Handling] TC [3,6] received\n");
            break;
        
        case tc_20_1_request_parameter_PRESENT:
            printf("[PUS Protocol Handling] TC [20,1] received\n");            
            break;
            
        case tc_20_3_set_parameter_PRESENT:
            printf("[PUS Protocol Handling] TC [20,3] received\n");
            break;
         
        case tc_128_1_get_mode_PRESENT:
            printf("[PUS Protocol Handling] TC [128,1] received\n");
            break;
            
         case tc_128_3_set_mode_PRESENT:
            printf("[PUS Protocol Handling] TC [128,3] received\n");
            break;
            
        default:
            printf("[PUS Protocol Handling] Invalid PUS telecommand received\n");
            errorCode = asn1SccillegalType;
            break;
    }
    
    handlePusAcceptance(tc, errorCode);
    
    if(asn1SccT_PUS_tc_failure_code_none == errorCode)
    {
        //Forward user data field to dispatcher
        pus_protocol_handling_RI_pus_request(&tc->primaryHeader.packetID.apid,
                                             &tc->userDataField,
                                             &errorCode);
    }
    else
    {
        return;
    }
    
    handlePusError(tc, errorCode);
}

void pus_protocol_handling_PI_pus_response(const asn1SccT_apid *IN_apid,
                                           const asn1SccT_PUS_tm_userDataField *IN_tmData)
{
    // Telemetery message type counters
    //TODO: Add Service 3 tm counters
    static asn1SccT_UInt16 seq1_2  = 0;
    static asn1SccT_UInt16 seq20_2 = 0;
    static asn1SccT_UInt16 seq20_4 = 0;
    static asn1SccT_UInt16 seq128_2 = 0;
    static asn1SccT_UInt16 seq128_4 = 0;
    
    asn1SccT_UInt16 subTypeCounter = 0;
    
    //build telemetry space packet.
    asn1SccT_PUS_tm_sp tmPacket;
    asn1SccT_PUS_tm_sp_Initialize(&tmPacket);    
        
    tmPacket.primaryHeader.packetID.apid = *IN_apid;
    tmPacket.userDataField = *IN_tmData;  
    
    // fill in telemetry message type counter    
    switch (IN_tmData->kind)
    {
        case tm_1_2_acc_failure_PRESENT:
            subTypeCounter = seq1_2++;            
            break;
            
        case tm_20_2_parameter_report_PRESENT:
            subTypeCounter = seq20_2++;            
            break;
            
        case tm_20_4_parameter_set_ack_PRESENT:
            subTypeCounter = seq20_4++;            
            break;
            
        case tm_128_2_mode_report_PRESENT:
            subTypeCounter = seq128_2++;            
            break;
            
        case tm_128_4_mode_set_ack_PRESENT:
            subTypeCounter = seq128_4++;            
            break;
    }    
    tmPacket.secondaryHeader.messageTypeCounter = subTypeCounter;
    
    pus_protocol_handling_RI_pus_packetRequest(&tmPacket);
    
}


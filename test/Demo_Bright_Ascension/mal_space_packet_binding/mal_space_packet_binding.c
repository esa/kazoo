/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "mal_space_packet_binding.h"

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

#define STAGE_SUBMIT            1
#define STAGE_ACK_or_ERROR      2
#define STAGE_REQUEST           1
#define STAGE_RESPONSE_or_ERROR 4
#define STAGE_REGISTER          1
#define STAGE_DEREGISTER        7
#define STAGE_REGISTER_ACK_or_ERROR 13

void mal_space_packet_binding_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

static void decodeSDU(const asn1SccT_MO_header_sduType sdu,
           asn1SccT_MAL_interactionType *OUT_type,
           asn1SccT_UInt8 *OUT_stage)
{
    switch(sdu)
    {
        case(1):
            *OUT_type  = asn1Sccsubmit;
            *OUT_stage = STAGE_SUBMIT;
            break;

        case(2):
            *OUT_type  = asn1Sccsubmit;
            *OUT_stage = STAGE_ACK_or_ERROR;
            break;

        case(3):
            *OUT_type  = asn1Sccrequest;
            *OUT_stage = STAGE_REQUEST;
            break;

        case(4):
            *OUT_type  = asn1Sccrequest;
            *OUT_stage = STAGE_RESPONSE_or_ERROR;
            break;
        
        case(12):
            *OUT_type  = asn1Sccpubsub;
            *OUT_stage = STAGE_REGISTER;
            break;
            
            //Should be 18 according to blue book
        case(13):
            *OUT_type  = asn1Sccpubsub;
            *OUT_stage = STAGE_DEREGISTER;
            break;

        default:
            printf("[MAL_SP] ERROR: Unsupported interaction type/stage: %u \n", sdu);
            assert(0);
    }
}


static asn1SccT_MO_header_sduType encodeSDU(asn1SccT_MAL_interactionType type, asn1SccT_UInt8 stage)
{
    switch(type)
    {
        case asn1Sccsubmit:
            switch(stage)
            {                
                case 2: // ACK or error
                    return 2;
                    
                default:
                    printf("[MAL_SP] ERROR: Unexpected SUBMIT stage: %u \n", stage);
                    assert(0);
            }            
            break;
        
        case asn1Sccrequest:
            switch(stage)
            {                
                case 2: // Response or error
                    return 4;
                    
                default:
                    printf("[MAL_SP] ERROR: Unexpected REQUEST stage: %u \n", stage);
                    assert(0);
            }
            break;
        
        case asn1Sccpubsub:
            switch(stage)
            {                
                case 2: //Register Ack or error
                    return 16; //Should be 13 according to blue book
                    
                case 6://Notify or notify error
                    return 21; //Should be 17 according to blue book
                
                case 8: //Deregister ack
                    return 17; //Should be 19 according to blue book
                    
                default:
                    printf("[MAL_SP] ERROR: Unexpected PUBLISH-SUBSCRIBE stage: %u \n", stage);
                    assert(0);
            }            
            break;
            
        default:
            printf("[MAL_SP] ERROR: Unexpected interaction type: %u \n", type);
            assert(0);
    }
}


static void prettyPrintMoPacket(const asn1SccT_MO_tc_sp *IN_sp,
                         const asn1SccT_MO_userDataField *IN_body)
{
    asn1SccT_MO_header const * const pMoHdr = &(IN_sp->secondaryHeader);
    int i;
    
    printf("[MAL_SP] APID: %u \n", IN_sp->primaryHeader.packetID.apid);
    printf("[MAL_SP] Seq Flags: 0x%u  Seq Len: %u \n", IN_sp->primaryHeader.packetSequenceControl.sequenceControlFlags, IN_sp->primaryHeader.packetSequenceControl.sequenceCount);
    printf("[MAL_SP] Packet Len: %u \n", IN_sp->primaryHeader.packetLength);
    printf("[MAL_SP] Secondary Hdr Version: %u \n", pMoHdr->versionNumber);
    printf("[MAL_SP] SDU Type: %u \n", pMoHdr->sduType);
    printf("[MAL_SP] Service Area: %u \n", pMoHdr->serviceArea);
    printf("[MAL_SP] Service: %u \n", pMoHdr->moService);
    printf("[MAL_SP] Operation: %u \n", pMoHdr->operation);
    printf("[MAL_SP] Area Version: %u \n", pMoHdr->areaVersion);    
    printf("[MAL_SP] Is error: %u \n", pMoHdr->isErrorMsg);
    printf("[MAL_SP] QoS Level: %u \n", pMoHdr->qosLevel);
    printf("[MAL_SP] Session: %u \n", pMoHdr->session);
    printf("[MAL_SP] Secondary APID: %u \n", pMoHdr->scdryAPID);
    printf("[MAL_SP] Secondary APID Qualifier: %u \n", pMoHdr->scdryAPIDQual);
    printf("[MAL_SP] Transaction ID: %u \n", pMoHdr->transactionId);
    printf("[MAL_SP] Timestamp: %x %x %x %x %x %x %x\n", pMoHdr->timestamp.arr[0],
                            pMoHdr->timestamp.arr[1],
                            pMoHdr->timestamp.arr[2],
                            pMoHdr->timestamp.arr[3],
                            pMoHdr->timestamp.arr[4],
                            pMoHdr->timestamp.arr[5],
                            pMoHdr->timestamp.arr[6]);
    
    
    printf("[MAL_SP] MAL Body of length %u:\n", IN_body->nCount);
    for(i=0; i < IN_body->nCount; i++)
    {
        printf("%02X ", IN_body->arr[i]);
    }
    puts("");   
    
}

static void extractMoHeaderFromSpacePacket(asn1SccT_MAL_msg_header * const hdr,
                                        asn1SccT_MO_tc_sp const * const IN_sp)
{
    asn1SccT_MO_header const * const pMoHdr = &(IN_sp->secondaryHeader);
     
    hdr->uriTo           = IN_sp->primaryHeader.packetID.apid;
    
    hdr->uriFrom         = pMoHdr->scdryAPID;    
    hdr->transactionId   = pMoHdr->transactionId;
    hdr->timestamp       = pMoHdr->timestamp;
    hdr->serviceArea     = pMoHdr->serviceArea;
    hdr->moService       = pMoHdr->moService;
    hdr->operation       = pMoHdr->operation;
    hdr->areaVersion     = pMoHdr->areaVersion;
    hdr->isErrorMsg      = pMoHdr->isErrorMsg;
        
    decodeSDU(pMoHdr->sduType,
          &hdr->interactionType,
          &hdr->interactionStage);
}     


/*
 * 
 * @param IN_sp   Pointer to decoded MO Space Packet primary and secondary headers
 * @param IN_body Pointer to buffer containing MAL Space packet binding encoded message body.
 */
void mal_space_packet_binding_PI_mo_packetIndication(const asn1SccT_MO_tc_sp *IN_sp,
                                                     const asn1SccT_MO_userDataField *IN_body)
{
    asn1SccT_MAL_msg_header hdr;
    asn1SccT_MO_header const * const pMoHdr = &(IN_sp->secondaryHeader);
    int i;
  
    /* Display contents of Space Packet for Debug/Demo */
    printf("[MAL_SP] Received MAL Space packet \n");
    prettyPrintMoPacket(IN_sp, IN_body);
    
    /* Copy space packet fields to new mo message structure */    
    asn1SccT_MAL_msg_header_Initialize(&hdr);     
    extractMoHeaderFromSpacePacket(&hdr, IN_sp);

    
    // Pass decoded message up to MAL dispatch    
    mal_space_packet_binding_RI_receiveIndication(&hdr, IN_body);
}

void mal_space_packet_binding_PI_transmitRequest(const asn1SccT_MAL_msg_header *IN_hdr,
                                                 const asn1SccT_MO_userDataField *IN_body)
{
    asn1SccT_MO_tm_sp moHeaders;    
    memset(&moHeaders, 0, sizeof(moHeaders));
    
    printf("[MAL_SP] Received MAL Message \n");
    
    moHeaders.primaryHeader.packetID.apid = IN_hdr->uriTo;
    moHeaders.primaryHeader.packetSequenceControl.sequenceControlFlags = asn1SccstandAlonePacket;
    
    // Overwritten by SPP handling
    //moHeaders.primaryHeader.packetSequenceControl.sequenceCount = 0;
    //moHeaders.primaryHeader.packetLength = 0    
    
    moHeaders.secondaryHeader.versionNumber = 0;
    moHeaders.secondaryHeader.sduType       = encodeSDU(IN_hdr->interactionType,IN_hdr->interactionStage);
    moHeaders.secondaryHeader.serviceArea   = IN_hdr->serviceArea;
    moHeaders.secondaryHeader.moService     = IN_hdr->moService;
    moHeaders.secondaryHeader.operation     = IN_hdr->operation;
    moHeaders.secondaryHeader.areaVersion   = IN_hdr->areaVersion;
    moHeaders.secondaryHeader.isErrorMsg    = IN_hdr->isErrorMsg;
    moHeaders.secondaryHeader.scdryAPID     = IN_hdr->uriFrom;    
    moHeaders.secondaryHeader.timestampFlg  = 1;
    moHeaders.secondaryHeader.timestamp     = IN_hdr->timestamp;   
    moHeaders.secondaryHeader.transactionId = IN_hdr->transactionId;
    
    /*  Ignored    
    moHeaders.secondaryHeader.qosLevel       = 0;
    moHeaders.secondaryHeader.scdryAPIDQual  = 0;
    moHeaders.secondaryHeader.sourceIdFlg    = 0;
    moHeaders.secondaryHeader.destIdFlg      = 0;
    moHeaders.secondaryHeader.priorityFlg    = 0;
    moHeaders.secondaryHeader.netZoneFlg     = 0;
    moHeaders.secondaryHeader.sessionNameFlg = 0;
    moHeaders.secondaryHeader.domainFlg      = 0;
    moHeaders.secondaryHeader.authFlg        = 0;
    moHeaders.secondaryHeader.session        = 0;
    */
    
    mal_space_packet_binding_RI_mo_packetRequest(&moHeaders, IN_body);
}


/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "space_packet_routing.h"
#include "C_ASN1_Types.h"

#include <stdio.h>
#include <assert.h>
#include <stdint.h>
#include <string.h>

#define MO_HEADERS_LEN asn1SccT_MO_tc_sp_REQUIRED_BYTES_FOR_ACN_ENCODING

void space_packet_routing_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
}


void space_packet_routing_packetIndication(const char *IN_apid, size_t IN_apid_size, const char *IN_rawpacket, size_t IN_rawpacket_size)
{
     uint16_t apid = *(uint16_t*)IN_apid;
     int i;
     
     printf("[Packet Routing] Forwarding Packet size %u with APID %u ", IN_rawpacket_size, apid);     
     printf("to %s stack\n", apid < 2000 ? "MO" : "PUS");
    
     
     if (apid >= 2000)
     {   
         // Destined for PUS stack
         vm_space_packet_routing_pus_spacepacketindication(IN_rawpacket, IN_rawpacket_size);
     }
     else
     {
         // Destined for MO stack
         
        /* 
         * Split off any message body parts for decoding further up chain. Message body decoding
         * relies on work done in MAL space packet binding.
         */
              
        asn1SccT_MO_userDataField msgBody;
        asn1SccT_MO_userDataField_Initialize(&msgBody);
        
        // Skip over Space Packet primary and secondary headers - these will be automatically decoded
        uint8_t* pMalBodyStart = (uint8_t*)IN_rawpacket + MO_HEADERS_LEN;
        
        msgBody.nCount = IN_rawpacket_size - MO_HEADERS_LEN;
        memcpy(msgBody.arr, pMalBodyStart, msgBody.nCount);
        
        vm_space_packet_routing_mo_packetindication(IN_rawpacket, 
                                                    MO_HEADERS_LEN,
                                                    &msgBody,
                                                    sizeof(msgBody));
     }
}

void space_packet_routing_mo_packetRequest(const char *IN_headers,
                                           size_t IN_headers_size,
                                           const char *IN_bodies,
                                           size_t IN_bodies_size)
{
    // Buffer large enough for concatenated packet parts
    uint8_t acnBuffer [asn1SccT_packet_REQUIRED_BYTES_FOR_ACN_ENCODING];
    
    
    assert(IN_headers);
    assert(IN_headers_size == MO_HEADERS_LEN);
    assert(IN_bodies);
    
    asn1SccT_MO_userDataField *bodies = IN_bodies;
    
    //append bodies to end of headers
    //headers and bodies are ACN encoded at this point. Bodies may be len 0.
    
    memcpy(acnBuffer, IN_headers, IN_headers_size);
    memcpy(acnBuffer + IN_headers_size, bodies->arr, bodies->nCount);
    
    vm_space_packet_routing_packetrequest(&acnBuffer, IN_headers_size + bodies->nCount);
}



void space_packet_routing_pus_spacePacketRequest(const char *IN_telemetry, size_t IN_telemetry_size)
{
    vm_space_packet_routing_packetrequest(IN_telemetry, IN_telemetry_size);
}



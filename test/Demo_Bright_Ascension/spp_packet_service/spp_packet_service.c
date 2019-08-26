/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "spp_packet_service.h"
#include <stdio.h>
#include <stdint.h>

#define MIN_SPACE_PACKET_LEN 7
#define SPP_HEADER_LEN 6

void init_spp_packet_service()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
}

static uint16_t getApidFromPacketBuf(uint8_t *pPacketBuf)
{
    uint16_t apid = 0;
    apid |= pPacketBuf[0];
    apid <<=8;
    apid |= pPacketBuf[1];
    apid &= 0x7FF;
    
    return apid;
}

void spp_packet_service_packetReceiveIndication(void *IN_rawpacket, size_t IN_rawpacket_size)
{

    //TODO Extract APID, maintain counters
    
    uint16_t apid;
    uint8_t *pBuf = (uint8_t *)IN_rawpacket;     
    
    printf("[Packet Service] Receive Indication \n");
    
    if(IN_rawpacket_size >= MIN_SPACE_PACKET_LEN)
    {
        apid = getApidFromPacketBuf(pBuf);
        
        printf("[Packet Service] Extracted APID: %u\n", apid);

        printf("[Packet Service] Forwarding %u bytes...\n", IN_rawpacket_size);    
        vm_spp_packet_service_packetIndication(&apid, 2, IN_rawpacket, IN_rawpacket_size);
    }
    else
    {
        printf("[Packet Service] Error: Packet too small. Dropping. \n");
    }
        
    //TODO return error bad packet

}

static unsigned int seqNext(unsigned int counter)
{
    return (counter == (1<<14) -1) ? 0 : counter+1;
}

void spp_packet_service_packetRequest(void *IN_rawpacket, size_t IN_rawpacket_size)
{  
    //Wastes memory, but enables future APIDs to be added without modifications here.
    static unsigned int sequenceCounters[2048];
    
    uint8_t * pBuf = (uint8_t*) IN_rawpacket;
    uint16_t apid;
    
    // Inspect APID    
    apid = getApidFromPacketBuf(pBuf);    
        
    sequenceCounters[apid] = seqNext(sequenceCounters[apid]);    
    
    //overwrite sequence counter field MSB first 
    pBuf[2] |= (0x00007F00 & sequenceCounters[apid]) >> 8;
    pBuf[3] =  0x000000FF & sequenceCounters[apid];    
    
    //overwrite size fields
    unsigned payload_size = (IN_rawpacket_size - SPP_HEADER_LEN) -1;
    /* Add size of the TM manually MSB first */
    pBuf[4] = (0xFF00 & payload_size) >> 8;
    pBuf[5] =  0x00FF & payload_size;
    

    vm_spp_packet_service_packetSendRequest(IN_rawpacket, IN_rawpacket_size);
}





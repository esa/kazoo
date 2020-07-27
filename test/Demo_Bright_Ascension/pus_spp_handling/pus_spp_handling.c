/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "pus_spp_handling.h"

#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#define HEADER_LEN 7

void pus_spp_handling_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
    
    //TODO CRC table
}

void pus_spp_handling_pus_spacePacketIndication(const char *IN_telemetry, size_t size_IN_telemetry)
{
	/*
	 * Write your code here! 
	 * Note: the parameters are encoded following the rules you specified
	 * in the interface view (Native, uPER, or ACN).
	 */
    
    //TODO Check CRC
    
    vm_pus_spp_handling_pus_packetindication(IN_telemetry, size_IN_telemetry);
}

void pus_spp_handling_pus_packetRequest(const char *IN_telemetry, size_t size_IN_telemetry)
{
	/*
	 * Write your code here! 
	 * Note: the parameters are encoded following the rules you specified
	 * in the interface view (Native, uPER, or ACN).
	 */
    
    uint8_t * tm = (uint8_t*) IN_telemetry;
    
    
    //overwrite size fields- we do this here rather than in spp handling further down stack so 
    //we can correctly generate a checksum.
    unsigned payload_size = size_IN_telemetry - HEADER_LEN;
    /* Add size of the TM manually MSB first */
    tm[4] = (0xFF00 & payload_size) >> 8;
    tm[5] =  0x00FF & payload_size;
    
    
    /* Add Checksum of the TM manually to the last 2 bytes of the stream MSB first */
    
    //uint16_t crc = computeCRC( tm, size_IN_telemetry-2 );
    //tm[size_IN_telemetry-2] = (0xFF00 & crc) >> 8;
   // tm[size_IN_telemetry-1] =  0x00FF & crc;
    
    vm_pus_spp_handling_pus_spacepacketrequest(IN_telemetry, size_IN_telemetry);
}


/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __DRIVER_CODE_H_spp_packet_service__
#define __DRIVER_CODE_H_spp_packet_service__

#include <stdlib.h>

void init_spp_packet_service();

void spp_packet_service_packetReceiveIndication(void *, size_t);

void spp_packet_service_packetRequest(void *, size_t);


/* Required interface "packetSendRequest" */
extern void vm_spp_packet_service_packetSendRequest(void *IN_rawpacket, size_t IN_rawpacket_size);


/* Required interface "packetIndication" */
extern void vm_spp_packet_service_packetIndication(void *IN_apid, size_t IN_apid_size, void *IN_rawpacket, size_t IN_rawpacket_size);


#endif

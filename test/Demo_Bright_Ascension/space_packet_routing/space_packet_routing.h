/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __DRIVER_CODE_H_space_packet_routing__
#define __DRIVER_CODE_H_space_packet_routing__

#include <stdlib.h>

void init_space_packet_routing();

void space_packet_routing_packetIndication(void *, size_t, void *, size_t);

void space_packet_routing_pus_spacePacketRequest(void *, size_t);

void space_packet_routing_mo_packetRequest(void *, size_t, void *, size_t);


/* Required interface "packetRequest" */
extern void vm_space_packet_routing_packetRequest(void *IN_rawpacket, size_t IN_rawpacket_size);


/* Required interface "pus_spacePacketIndication" */
extern void vm_space_packet_routing_pus_spacePacketIndication(void *IN_telemetry, size_t IN_telemetry_size);


/* Required interface "mo_packetIndication" */
extern void vm_space_packet_routing_mo_packetIndication(void *IN_headers, size_t IN_headers_size, void *IN_body, size_t IN_body_size);


#endif

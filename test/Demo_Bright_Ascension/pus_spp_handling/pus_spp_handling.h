/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __DRIVER_CODE_H_pus_spp_handling__
#define __DRIVER_CODE_H_pus_spp_handling__

#include <stdlib.h>

void init_pus_spp_handling();

void pus_spp_handling_pus_spacePacketIndication(void *, size_t);

void pus_spp_handling_pus_packetRequest(void *, size_t);


/* Required interface "pus_spacePacketRequest" */
extern void vm_pus_spp_handling_pus_spacePacketRequest(void *IN_telemetry, size_t IN_telemetry_size);


/* Required interface "pus_packetIndication" */
extern void vm_pus_spp_handling_pus_packetIndication(void *IN_telemetry, size_t IN_telemetry_size);


#endif

/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __DRIVER_CODE_H_space_link_rx__
#define __DRIVER_CODE_H_space_link_rx__

#include <stdlib.h>

void init_space_link_rx();

void space_link_rx_pollSocket();


/* Required interface "packetReceiveIndication" */
extern void vm_space_link_rx_packetReceiveIndication(void *IN_rawpacket, size_t IN_rawpacket_size);


#endif

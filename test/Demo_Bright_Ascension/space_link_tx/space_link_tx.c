/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "space_link_tx.h"
#include "Context-space-link-tx.h"

#include <zmq.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

static void *context;
static void* sock;

void space_link_tx_startup()
{        
    /* Write your initialization code here,
       but do not make any call to a required interface!! */
    
    //buffer long enough for max port passed by user. Port can be 1-5 chars in length.
    char endpointStr[] = "tcp://*:xxxxx";    
    sprintf(endpointStr, "tcp://*:%u", space_link_tx_ctxt.zmqtxport);  
    
    printf("[SpaceLinkTx] Startup \n");
    
    /* Workaround for same blackbox function init multiple times.*/
    if(!context)
    {
        context = zmq_ctx_new();
        //Bind to socket to talk to clients
        sock = zmq_socket(context, ZMQ_DEALER);
        int rc = zmq_bind (sock, endpointStr);   
        if(-1 == rc)
        {
        printf("[SpaceLinkTx] zmq error %d: %s\n", errno, strerror(errno));
        }   
        assert (rc == 0);
        printf("[SpaceLinkTx] Bound to port %u \n", space_link_tx_ctxt.zmqtxport);
    }
    
}

void space_link_tx_packetSendRequest(const char *IN_rawpacket, size_t IN_rawpacket_size)
{
   
    //Lazy init spacelink tx as taste inits only one blackbox func.
    if(!context)
    {
        init_space_link_tx();
    }
    
    
    printf("[SpaceLinkTx] Sending Packet: \n");
    
    int i, nBytes = IN_rawpacket_size;
    uint8_t * packet = (uint8_t*) IN_rawpacket;
    for(i=0; i < nBytes; i++)
    {
        printf("%02X ", packet[i]);
    }
    puts("");
    
    errno=0;
    if(-1 == zmq_send(sock, IN_rawpacket, IN_rawpacket_size, 0))
    {
        printf("[SpaceLinkTx] zmq error %s\n", strerror(errno));
    }
    
}


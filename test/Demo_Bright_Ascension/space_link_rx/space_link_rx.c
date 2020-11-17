/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "space_link_rx.h"
#include "Context-space-link-rx.h"

#include <zmq.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

static void *context;
static void* sock;

/* #define MAX_SP_LEN 65542 */
#define MAX_SP_LEN 256

void space_link_rx_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */

	int major, minor, patch;
	zmq_version(&major, &minor,  &patch);
	
	printf("[SpaceLinkRx] Startup \n");
	printf("[SpaceLinkRx] ZMQ Version: %d.%d.%d\n", major, minor,  patch);
    
    //buffer long enough for max port passed by user. Port can be 1-5 chars in length.
    char endpointStr[] = "tcp://*:xxxxx";    
    sprintf(endpointStr, "tcp://*:%u", space_link_rx_ctxt.zmqrxport);  
    
    
    /* Workaround for blackbox functions are init multiple times.*/
    if(!context)
    {
        context = zmq_ctx_new();
        //Bind to socket to talk to clients
        sock = zmq_socket(context, ZMQ_DEALER);
        int rc = zmq_bind (sock, endpointStr);   
        if(-1 == rc)
        {
        printf("[SpaceLinkRx] zmq error %d: %s\n", errno, strerror(errno));
        }   
        assert (rc == 0);
        printf("[SpaceLinkRx] Bound to port %u \n", space_link_rx_ctxt.zmqrxport);
    }
}

void space_link_rx_pollSocket()
{
    int i, nBytes = 0;
    
    unsigned char rxBuf[MAX_SP_LEN];
    
    static printFlag = 1;
    
    if(printFlag)
    {
        printf("[SpaceLinkRx] Waiting for message...\n");
    }

    /* Check if zmq message available */
    errno = 0;
    nBytes = zmq_recv(sock, rxBuf, MAX_SP_LEN, ZMQ_DONTWAIT);
    if(-1 == nBytes)
    {
        if(errno == EAGAIN)
        {
        /*No message available*/
        printFlag=0;
        }
        else
        {
        printf("[SpaceLinkRx] zmq error %s\n", strerror(errno));
        }
    }
    else
    {
        printf("[SpaceLinkRx] Received space packet from ground: \n");
        for(i=0; i < nBytes; i++)
        {
        printf("%02X ", rxBuf[i]);
        }
        puts("");
        
        printFlag=1;
                
        vm_space_link_rx_packetreceiveindication(rxBuf, nBytes);
    }
}


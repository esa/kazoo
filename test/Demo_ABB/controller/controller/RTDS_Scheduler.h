#ifndef _RTDS_SCHEDULER_H_
#define _RTDS_SCHEDULER_H_

/* If no RTDS scheduler, make sure the type is defined as a dummy type */
#ifdef RTDS_NO_SCHEDULER

#define RTDS_Scheduler void

/* Normal case */
#else

struct _RTDS_Scheduler;
typedef struct _RTDS_Scheduler RTDS_Scheduler;

#include "RTDS_Common.h"
#include "RTDS_Proc.h"

#include "RTDS_ADDL_MACRO.h"

/*
** TYPE RTDS_Scheduler:
** ====================
** A variable of this type represents a scheduler running a set of process instances
*/
struct _RTDS_Scheduler
  {
  unsigned int              nextInstanceNumber; /* Numerical identifier for next created instance */
  RTDS_Proc               * scheduledInstances; /* Chained list of contexts for all process instances running in scheduler */
  RTDS_RtosQueueId          externalQueue;      /* Queue for messages coming from the outside of the scheduler */
  RTDS_MessageHeader      * internalQueue;      /* Chained list for all messages in scheduler's internal queue */
  RTDS_GlobalProcessInfo  * currentContext;     /* Context for the currently running process */
  };
  
/*
** FUNCTION RTDS_Scheduler_init:
** -----------------------------
** Initializes a scheduler.
** Parameters:
**  - scheduler: The scheduler to initialize. The variable must already be allocated.
**  - schedulerExternalQueue: External message queue for scheduler if it has already been created. If
**                            NULL, a new queue will be created.
** Returns: The initialized scheduler, which is always the same as the 'scheduler' parameter. This allows
** to use this function in expressions.
*/
RTDS_Scheduler * RTDS_Scheduler_init(RTDS_Scheduler * scheduler, RTDS_RtosQueueId * schedulerExternalQueue);

/*
** FUNCTION RTDS_Scheduler_registerInstance:
** -----------------------------------------
** Registers a process instance as running in this scheduler.
** Parameters:
**  - scheduler: Scheduler to register the instance in.
**  - instanceDescriptor: Descriptor for instance to register.
**  - registerContext: If true, the context needs to be registered in the global list for contexts.
** NB: This doesn't send the start message to the instance.
*/
void RTDS_Scheduler_registerInstance(RTDS_Scheduler * scheduler, RTDS_Proc * instanceDescriptor, short registerContext);

/*
** FUNCTION RTDS_Scheduler_run:
** ----------------------------
** Scheduler run loop. Gets all incoming messages, either from inside or outside the scheduler and triggers
** the associated transitions.
** Parameter: The scheduler to run.
*/
void RTDS_Scheduler_run(RTDS_Scheduler * scheduler);

/*
** FUNCTION RTDS_Scheduler_sendMessage:
** ------------------------------------
** Sends a message to an instance identified by its PID. If the receiver instance runs inside the current scheduler,
** the message is handled internally. If it doesn't, a "normal" message send is performed via the services of the
** underlying RTOS.
** Parameters:
**  - scheduler: Scheduler handling the message send.
**  - senderContext: Context for the message sender.
**  - receiver: PID for the receiver instance.
**  - messageNumber: Numerical identifier for the message type to send.
**  - dataLength: Length of data associated to the message.
**  - pData: Pointer on the buffer containing the actual message data.
*/
void RTDS_Scheduler_sendMessage(RTDS_Scheduler * scheduler, RTDS_GlobalProcessInfo * senderContext, RTDS_SdlInstanceId * receiver,
                                int messageNumber, long dataLength, void * pData);

/*
** FUNCTION RTDS_Scheduler_sendMessageToName:
** ------------------------------------------
** Sends a message to an instance identified by its name. If the receiver instance runs inside the current scheduler,
** the message is handled internally. If it doesn't, a "normal" message send is performed via the services of the
** underlying RTOS.
** Parameters:
**  - scheduler: Scheduler handling the message send.
**  - senderContext: Context for the message sender.
**  - receiverNameNumber: Numerical identifier for the receiver process. One of the instances of this process
**                        is chosen randomly to be the actual message receiver.
**  - messageNumber: Numerical identifier for the message type to send.
**  - dataLength: Length of data associated to the message.
**  - pData: Pointer on the buffer containing the actual message data.
*/
void RTDS_Scheduler_sendMessageToName(RTDS_Scheduler * scheduler, RTDS_GlobalProcessInfo * senderContext, int receiverNameNumber,
                                      int messageNumber, long dataLength, void * pData);

/*
** MACRO RTDS_SCHEDULER_NEW:
** -------------------------
** Creates a new scheduler; May be redefined for special behaviors, e.g wholly scheduled systems.
*/
#ifndef RTDS_SCHEDULER_NEW
#define RTDS_SCHEDULER_NEW RTDS_Scheduler_init((RTDS_Scheduler*)(RTDS_MALLOC(sizeof(RTDS_Scheduler))), NULL)
#endif

#endif

#endif


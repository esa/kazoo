#ifndef _CONTROLLER_P_DECL_H_
#define _CONTROLLER_P_DECL_H_

#include "controller_p_locals.h"
#include "RTDS_Proc.h"

#include "RTDS_Scheduler.h"


/* Message sending macro redefinitions to use the methods instead of the functions */
#undef RTDS_MSG_QUEUE_SEND_TO_ID
#define RTDS_MSG_QUEUE_SEND_TO_ID(MESSAGE_NUMBER, LENGTH_DATA, P_DATA, RECEIVER) \
  RTDS_Proc_msgQueueSendToId(RTDS_instanceDescriptor, MESSAGE_NUMBER, LENGTH_DATA, (unsigned char *)(P_DATA), RECEIVER)
#undef RTDS_MSG_QUEUE_SEND_TO_ENV
#define RTDS_MSG_QUEUE_SEND_TO_ENV(MESSAGE_NUMBER, LENGTH_DATA, P_DATA) \
  RTDS_Proc_msgQueueSendToEnv(RTDS_instanceDescriptor, MESSAGE_NUMBER, LENGTH_DATA, (unsigned char *)(P_DATA))
#undef RTDS_MSG_QUEUE_SEND_TO_NAME
#define RTDS_MSG_QUEUE_SEND_TO_NAME(MESSAGE_NUMBER, LENGTH_DATA, P_DATA, RECEIVER_STRING, RECEIVER_NUMBER) \
  RTDS_Proc_msgQueueSendToName(RTDS_instanceDescriptor, MESSAGE_NUMBER, LENGTH_DATA, (unsigned char *)(P_DATA), RECEIVER_STRING, RECEIVER_NUMBER)

/* Entry point for all transitions */
short RTDS_controller_p_executeTransition(RTDS_Proc * RTDS_instanceDescriptor, RTDS_MessageHeader * currentMessage);

/* Entry point for transitions for continuous signals */
short RTDS_controller_p_continuousSignals(RTDS_Proc * RTDS_instanceDescriptor, int * lowestPriority);

/* Instance creation/initialization */
void RTDS_Proc_controller_p_createInstance(RTDS_Proc * RTDS_instanceDescriptor, RTDS_Scheduler * parentScheduler, RTDS_GlobalProcessInfo * instanceContext, RTDS_GlobalProcessInfo * creatorContext);

#endif

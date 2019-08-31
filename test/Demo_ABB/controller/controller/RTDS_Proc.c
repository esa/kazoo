#include <stdlib.h>

#include "RTDS_Common.h"
#include "RTDS_MACRO.h"
#include "RTDS_ADDL_MACRO.h"

#include "RTDS_Scheduler.h"
#include "RTDS_Proc.h"


/*
** FUNCTION RTDS_Proc_createInstance:
** ----------------------------------
** Initializes a descriptor for an instance.
** NB: This function is never called directly, as it handles only the initializations of the fields in RTDS_Proc. To create an instance
** of process p, the function RTDS_p_createInstance should be used, which will in turn call this one.
*/
void RTDS_Proc_createInstance(
  RTDS_Proc               * instanceDescriptor, /* Preallocated descriptor for instance */
  RTDS_Scheduler          * parentScheduler,    /* Scheduler inside which the instance will run if any. If NULL, the instance is created outside of any scheduler */
  RTDS_GlobalProcessInfo  * instanceContext,    /* Context for new instance if it has been allocated previously. If NULL, a new context is created */
  RTDS_GlobalProcessInfo  * creatorContext      /* Context for the instance creating the new one if any. If NULL, it means the new instance is created at system startup */
)
  {
  /* If instance context already exists, just record it */
  if ( instanceContext != NULL )
    {
    instanceDescriptor->RTDS_currentContext = instanceContext;
    }
  /* If instance context does not yet exist */
  else
    {
    /* Get or create a new context */
#ifdef RTDS_MALLOC
    instanceDescriptor->RTDS_currentContext = (RTDS_GlobalProcessInfo*)RTDS_MALLOC(sizeof(RTDS_GlobalProcessInfo));
#else
    /* Don't really know what to do here: context *must* be passed if dynamic memory allocation is forbidden */
    instanceDescriptor->RTDS_currentContext = NULL;
    return;
#endif
    instanceDescriptor->RTDS_currentContext->next = NULL;
    }
  /* Set all fields in context */
  /* NB: myRtosTaskId cannot be set, as the type RTDS_RtosTaskId depends on the actual profile */
  instanceDescriptor->RTDS_currentContext->sdlProcessNumber = -1;   /* Default; set 'for real' in the creation functions for individual processes */
  instanceDescriptor->RTDS_currentContext->mySdlInstanceId = NULL;  /* Default; set 'for real' when/if instance is registered in a scheduler */
  if ( creatorContext == NULL )
    instanceDescriptor->RTDS_currentContext->parentSdlInstanceId = NULL;
  else
    instanceDescriptor->RTDS_currentContext->parentSdlInstanceId = creatorContext->mySdlInstanceId;
  instanceDescriptor->RTDS_currentContext->offspringSdlInstanceId = NULL;
  instanceDescriptor->RTDS_currentContext->sdlState = 0;
  instanceDescriptor->RTDS_currentContext->currentMessage = NULL;
  instanceDescriptor->RTDS_currentContext->timerList = NULL;
  instanceDescriptor->RTDS_currentContext->readSaveQueue = NULL;
  instanceDescriptor->RTDS_currentContext->writeSaveQueue = NULL;
  /* Set all fields in descriptor, except 'is procedure' indicator, which is set before the call */
  instanceDescriptor->RTDS_initialMessage = NULL;
  instanceDescriptor->RTDS_senderId = NULL;
  instanceDescriptor->RTDS_calledProcedure = NULL;
  instanceDescriptor->RTDS_nextLabelId = 0;
  instanceDescriptor->RTDS_sdlStatePrev = 0;
  instanceDescriptor->nextScheduledInstance = NULL;
  
  /* Record new instance in parent scheduler if needed */
  if ( parentScheduler == NULL )
    {
    instanceDescriptor->RTDS_parentScheduler = NULL;
    instanceDescriptor->RTDS_currentContext->mySdlInstanceId = NULL;
    }
  else
    {
    instanceDescriptor->RTDS_parentScheduler = parentScheduler;
#ifndef RTDS_NO_SCHEDULER
    if ( ! instanceDescriptor->RTDS_isProcedure )
      RTDS_Scheduler_registerInstance(parentScheduler, instanceDescriptor, instanceContext == NULL);
#endif
    }
  }


/*
** FUNCTION RTDS_Proc_deleteInstance:
** ----------------------------------
** Deletes and forgets everything about a given process instance
*/
void RTDS_Proc_deleteInstance(RTDS_Proc * instanceDescriptor)
  {
  /* Delete called procedure if any */
  if ( instanceDescriptor->RTDS_calledProcedure != NULL )
    RTDS_Proc_deleteInstance(instanceDescriptor->RTDS_calledProcedure);
  /* If needed and available, delete message that triggered last executed transition if needed */
#ifdef RTDS_FREE
  if ( ( instanceDescriptor->RTDS_initialMessage != NULL ) && ( instanceDescriptor->RTDS_initialMessage != instanceDescriptor->RTDS_currentContext->currentMessage ) )
    {
    RTDS_FREE(instanceDescriptor->RTDS_initialMessage);
    }
#endif
  /* If instance is a process, delete its information in global process information chained list */
  if ( ! instanceDescriptor->RTDS_isProcedure )
    {
    RTDS_GlobalProcessInfo * RTDS_currentContext = instanceDescriptor->RTDS_currentContext;
    RTDS_FORGET_INSTANCE_INFO;
    }
  }


/*
** FUNCTION RTDS_Proc_msgQueueSendToId:
** ------------------------------------
** Sends a message to an instance identified by its PID.
** NB: This call is actually forwarded to the scheduler where the sender instance runs (see RTDS_Scheduler_sendMessage in RTDS_Scheduler.h).
*/
void RTDS_Proc_msgQueueSendToId(
  RTDS_Proc           * instanceDescriptor, /* Descriptor for sender instance */
  long                  messageNumber,      /* Numerical identifier for message type to send */
  long                  dataLength,         /* Length of data associated to message */
  unsigned char       * pData,              /* Pointer on message actual data */
  RTDS_SdlInstanceId  * receiver            /* PID for receiver instance */
)
  {
#ifdef RTDS_NO_SCHEDULER
#ifdef RTDS_CUSTOM_MSG_QUEUE_SEND_TO_ID
  RTDS_CUSTOM_MSG_QUEUE_SEND_TO_ID(instanceDescriptor, messageNumber, dataLength, pData, receiver);
#endif
#else
  // Forwarded to scheduler
  RTDS_Scheduler_sendMessage(instanceDescriptor->RTDS_parentScheduler, instanceDescriptor->RTDS_currentContext, receiver, messageNumber, dataLength, pData);
#endif
  }


/*
** FUNCTION RTDS_Proc_msgQueueSendToName:
** --------------------------------------
** Sends a message to any instance of a process identified by its name.
** NB: This call is actually forwarded to the scheduler where the sender instance runs (see RTDS_Scheduler_sendMessageToName in RTDS_Scheduler.h).
*/
void RTDS_Proc_msgQueueSendToName(
  RTDS_Proc     * instanceDescriptor, /* Descriptor for sender instance */
  long            messageNumber,      /* Numerical identifier for message type to send */
  long            dataLength,         /* Length of data associated to message */
  unsigned char * pData,              /* Pointer on message actual data */
  char          * receiverName,       /* Name of the receiver process - not used */
  int             receiverNumber      /* Numerical identifier for the receiver process. An instance of this process will be chosen randomly to be the message receiver */
)
  {
#ifdef RTDS_NO_SCHEDULER
#ifdef RTDS_CUSTOM_MSG_QUEUE_SEND_TO_NAME
  RTDS_CUSTOM_MSG_QUEUE_SEND_TO_NAME(instanceDescriptor, messageNumber, dataLength, pData, receiverNumber);
#endif
#else
  // Forwarded to scheduler
  RTDS_Scheduler_sendMessageToName(instanceDescriptor->RTDS_parentScheduler, instanceDescriptor->RTDS_currentContext, receiverNumber, messageNumber, dataLength, pData);
#endif
  }


/*
** FUNCTION RTDS_Proc_msgSave:
** ---------------------------
** Saves a message. The actual "re-sending" of the message will be handled by the scheduler after the next instance's state change.
*/
void RTDS_Proc_msgSave(
  RTDS_Proc           * instanceDescriptor, /* Descriptor for the instance saving the message */
  RTDS_MessageHeader  * message             /* Actual message to save */
)
  {
#ifdef RTDS_MSG_SAVE
  RTDS_GlobalProcessInfo * RTDS_currentContext = instanceDescriptor->RTDS_currentContext;
  RTDS_MSG_SAVE(message);
#endif
  }


/*
** FUNCTION RTDS_Proc_setTimer:
** ----------------------------
** Starts a timer.
*/
void RTDS_Proc_setTimer(
  RTDS_Proc * instanceDescriptor, /* Instance starting the timer */
  long        timerNumber,        /* Numerical identifier for the timer to start */
  int         delay               /* Delay for the timer, in system ticks */
)
  {
#ifdef RTDS_SET_TIMER
  RTDS_GlobalProcessInfo * RTDS_currentContext = instanceDescriptor->RTDS_currentContext;
  RTDS_SET_TIMER(timerNumber, delay);
#endif
  }


/*
** FUNCTION RTDS_Proc_resetTimer:
** ------------------------------
** Cancels a timer.
*/
void RTDS_Proc_resetTimer(
  RTDS_Proc * instanceDescriptor, /* Instance cancelling the timer, which must be the one that started it */
  long        timerNumber         /* Numerical identifier for the timer to cancel */
)
  {
#ifdef RTDS_RESET_TIMER
  RTDS_GlobalProcessInfo * RTDS_currentContext = instanceDescriptor->RTDS_currentContext;
  RTDS_RESET_TIMER(timerNumber);
#endif
  }


/*
** FUNCTION RTDS_Proc_setSdlState:
** -------------------------------
** Changes the SDL state of an instance.
*/
void RTDS_Proc_setSdlState(
  RTDS_Proc * instanceDescriptor, /* Instance for which the state must be changed */
  int         newState            /* Numerical value for the the new SDL state */
)
  {
  instanceDescriptor->RTDS_currentContext->sdlState = newState;
  }



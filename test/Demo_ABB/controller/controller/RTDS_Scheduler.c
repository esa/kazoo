/* If no RTDS scheduler, all definitions in this file are not needed */
#ifndef RTDS_NO_SCHEDULER

#include <stdlib.h>

#include "RTDS_MACRO.h"
#include "RTDS_ADDL_MACRO.h"

#include "RTDS_Scheduler.h"
#include "RTDS_Proc.h"

#include "RTDS_all_processes.h"


/*
** FUNCTION RTDS_Scheduler_init:
** -----------------------------
** Scheduler initialization
*/

RTDS_Scheduler * RTDS_Scheduler_init(RTDS_Scheduler * scheduler, RTDS_RtosQueueId * schedulerExternalQueue)
  {
  /* Initialize all attributes */
  scheduler->nextInstanceNumber = 0;
  scheduler->scheduledInstances = NULL;
  if ( schedulerExternalQueue == NULL )
    scheduler->externalQueue = RTDS_NEW_MESSAGE_QUEUE;
  else
    scheduler->externalQueue = *schedulerExternalQueue;
  scheduler->internalQueue = NULL;
  scheduler->currentContext = NULL;
  
  return scheduler;
  }
  

/*
** FUNCTION RTDS_Scheduler_registerInstance:
** -----------------------------------------
** Registers an already allocated instance in a scheduler
*/
void RTDS_Scheduler_registerInstance(RTDS_Scheduler * scheduler, RTDS_Proc * instanceDescriptor, short registerContext)
  {
  RTDS_SdlInstanceId      * newInstanceId = NULL;
  
  /* Create identification descriptor for new instance */
#ifdef RTDS_MALLOC
  newInstanceId = (RTDS_SdlInstanceId*)RTDS_MALLOC(sizeof(RTDS_SdlInstanceId));
#else
  #error Not supported yet
#endif
  instanceDescriptor->RTDS_currentContext->mySdlInstanceId = newInstanceId;
  /* Set missing information in instance */
  newInstanceId->queueId = scheduler->externalQueue;
  newInstanceId->instanceNumber = scheduler->nextInstanceNumber;
  scheduler->nextInstanceNumber += 1;
  /* Record process descriptor in running instances */
  instanceDescriptor->nextScheduledInstance = scheduler->scheduledInstances;
  scheduler->scheduledInstances = instanceDescriptor;
  /* Add the process information to the end of the RTDS_globalProcessInfo global list if needed */
  if ( registerContext )
    {
    RTDS_CRITICAL_SECTION_START;
    if ( RTDS_globalProcessInfo == NULL )
      {
      RTDS_globalProcessInfo = instanceDescriptor->RTDS_currentContext;
      }
    else
      {
      /* Let's get to the end of the list */
      RTDS_GlobalProcessInfo * processInfo = RTDS_globalProcessInfo;
      while( processInfo->next != NULL ) processInfo = processInfo->next;
      processInfo->next = instanceDescriptor->RTDS_currentContext;
      }
    RTDS_CRITICAL_SECTION_STOP;
    }
  }
  

/*
** FUNCTION RTDS_Scheduler_run:
** ----------------------------
** Scheduler run loop
*/

void RTDS_Scheduler_run(RTDS_Scheduler * scheduler)
  {
  RTDS_MessageHeader      * currentMessage = NULL;
  int                       cr;
  int                       receiverInstanceNumber;
  RTDS_Proc               * receiverInstance = NULL;
  short                     instanceKilled;
  int                       initialState;
  RTDS_Proc               * scheduledInstance;
  RTDS_Proc               * prevScheduledInstance;
  
  /* Message loop */
  for ( ; ; )
    {
    /* If a message is present in the internal message queue, it has priority */
    if ( scheduler->internalQueue != NULL )
      {
      currentMessage = scheduler->internalQueue;
      scheduler->internalQueue = scheduler->internalQueue->next;
      }
    /* If no message in internal message queue, read the next one from the external message queue */
    else
      {
      currentMessage = (RTDS_MessageHeader *)RTDS_MALLOC(sizeof(RTDS_MessageHeader));
      cr = RTDS_READ_MESSAGE_QUEUE(scheduler->externalQueue, currentMessage);
      if ( cr == RTDS_ERROR )
        {
        RTDS_SYSTEM_ERROR( RTDS_ERROR_MSG_RECEIVE )
        }
      }
    /* Get actual instance for receiver */
    receiverInstanceNumber = currentMessage->receiver->instanceNumber;
    receiverInstance = NULL;
    for ( receiverInstance = scheduler->scheduledInstances; receiverInstance != NULL; receiverInstance = receiverInstance->nextScheduledInstance )
      {
      if ( receiverInstance->RTDS_currentContext->mySdlInstanceId->instanceNumber == receiverInstanceNumber ) break;
      }
    /* If message is a timer time-out and a receiver was found */
    if ( (currentMessage->timerUniqueId != 0) && (receiverInstance != NULL) )
      {
      /* Figure out if the timer was cancelled */
      RTDS_TimerState * current_timer = NULL;
      RTDS_TimerState * prev_timer = NULL;
      for ( current_timer = receiverInstance->RTDS_currentContext->timerList; current_timer != NULL; current_timer = current_timer->next )
        {
        /* If timer found and cancelled */
        if ( current_timer->timerUniqueId == currentMessage->timerUniqueId )
            {
            if ( current_timer->state == RTDS_TIMER_CANCELLED )
                {
                /* Discard current message */
                RTDS_FREE(currentMessage);
                /* Remove it from list of timers */
                if ( prev_timer == NULL )
                    receiverInstance->RTDS_currentContext->timerList = receiverInstance->RTDS_currentContext->timerList->next;
                else
                    prev_timer->next = current_timer->next;
                RTDS_FREE(current_timer);
                /* Forget receiver instance to prevent transition execution */
                receiverInstance = NULL;
                }
            break;
            }
        prev_timer = current_timer;
        }
      }
    /* If a receiver was found */
    if ( receiverInstance != NULL )
      {
      /*
      ** Call the appropriate transition for this message in its receiver instance, considering
      ** the case of a start pseudo-message
      */
      scheduler->currentContext = receiverInstance->RTDS_currentContext;
      initialState = receiverInstance->RTDS_currentContext->sdlState;
      if ( currentMessage->messageNumber == -1 )
        instanceKilled = RTDS_executeTransition(receiverInstance, NULL);
      else
        {
        RTDS_SIMULATOR_TRACE(
          RTDS_messageReceived,
          currentMessage,
          receiverInstance->RTDS_currentContext->mySdlInstanceId,
          receiverInstance->RTDS_currentContext
        );
        RTDS_RELEASE_MESSAGE_UNIQUE_ID(currentMessage->messageUniqueId);
        instanceKilled = RTDS_executeTransition(receiverInstance, currentMessage);
        }
      /* If instance was not killed, execute transitions for continuous signals in current state */
      if ( ! instanceKilled )
        {
        /* If a transition changes the process state, continue execution with continuous signals for new state */
        int lowestPriority;
        int previousState = -1;
        while ( ( ! instanceKilled ) && ( receiverInstance->RTDS_currentContext->sdlState != previousState ) )
          {
          previousState = receiverInstance->RTDS_currentContext->sdlState;
          /*
          ** Execute all transition for continuous signals, starting with the one with the highest priority
          ** and until there are no more transitions to execute or instance is killed
          */
          lowestPriority = 0;
          for ( ; ; )
            {
            int previousLowestPriority = lowestPriority;
            /*
            ** If we're in SDL semantics, if there is any message for current instance in the scheduler's queue,
            ** stop considering continuous signals
            */
#ifdef RTDS_SDL_SEMANTICS
            for ( currentMessage = scheduler->internalQueue; currentMessage != NULL; currentMessage = currentMessage->next )
              {
              if ( currentMessage->receiver->instanceNumber == receiverInstanceNumber )
                break;
              }
            if ( currentMessage != NULL )
              break;
#endif
            instanceKilled = RTDS_continuousSignals(receiverInstance, &lowestPriority);
            /* If instance changed its state, was killed, or if no more continuous signal can be executed, over */
            if ( ( receiverInstance->RTDS_currentContext->sdlState != previousState ) || instanceKilled ||
                 ( lowestPriority == previousLowestPriority ) )
              break;
            }
          }
        }
      /* If any executed transition killed the instance */
      if ( instanceKilled )
        {
        /* Remove entry from scheduled instances */
        /* NB: browse list again! processes may have been created in the transition so the list may have changed... */
        prevScheduledInstance = NULL;
        for ( scheduledInstance = scheduler->scheduledInstances; scheduledInstance != NULL; scheduledInstance = scheduledInstance->nextScheduledInstance )
          {
          if ( scheduledInstance->RTDS_currentContext->mySdlInstanceId->instanceNumber == receiverInstanceNumber )
            {
            if ( prevScheduledInstance == NULL )
              scheduler->scheduledInstances = scheduler->scheduledInstances->nextScheduledInstance;
            else
              prevScheduledInstance->nextScheduledInstance = scheduledInstance->nextScheduledInstance;
            break;
            }
          prevScheduledInstance = scheduledInstance;
          }
        /* Actually delete the instance */
        RTDS_Proc_deleteInstance(receiverInstance);
        receiverInstance->RTDS_currentContext = NULL;
        }
      /* If instance wasn't killed */
      else
        {
        /* If instance state has changed, transfer its write save queue to its read save queue */
        if ( ( receiverInstance->RTDS_currentContext->sdlState != initialState ) &&
             ( receiverInstance->RTDS_currentContext->writeSaveQueue != NULL ) )
          {
          /* Let's get to the end of the save queue */
          currentMessage = receiverInstance->RTDS_currentContext->writeSaveQueue;
          while( currentMessage->next != NULL ) currentMessage = currentMessage->next;
          currentMessage->next = receiverInstance->RTDS_currentContext->readSaveQueue;
          receiverInstance->RTDS_currentContext->readSaveQueue = receiverInstance->RTDS_currentContext->writeSaveQueue;
          receiverInstance->RTDS_currentContext->writeSaveQueue = NULL;
          }
        /* If instance has saved messages */
        if ( receiverInstance->RTDS_currentContext->readSaveQueue != NULL )
          {
          /* Put them at the beginning of the scheduler's internal queue */
          currentMessage = receiverInstance->RTDS_currentContext->readSaveQueue;
          while ( currentMessage->next != NULL ) currentMessage = currentMessage->next;
          currentMessage->next = scheduler->internalQueue;
          scheduler->internalQueue = receiverInstance->RTDS_currentContext->readSaveQueue;
          /* Reset instance's saved messages */
          receiverInstance->RTDS_currentContext->readSaveQueue = NULL;
          }
        }
      }
    }
  }


/*
** FUNCTION RTDS_Scheduler_sendMessage:
** ------------------------------------
** Sends a message to a process instance identified by its PID
*/

void RTDS_Scheduler_sendMessage(
  RTDS_Scheduler          * scheduler,
  RTDS_GlobalProcessInfo  * senderContext,
  RTDS_SdlInstanceId      * receiver,
  int                       messageNumber,
  long                      dataLength,
  void                    * pData
)
  {
  RTDS_MessageHeader  * newMessage = NULL;
  
  /* If receiver is not managed by this scheduler */
  if ( receiver->queueId != scheduler->externalQueue )
    {
    /* Get context for sender with the correct variable name */
    RTDS_GlobalProcessInfo * RTDS_currentContext = senderContext;
    /* Use standard macro to send the message */
    RTDS_MSG_QUEUE_SEND_TO_ID(messageNumber, dataLength, pData, receiver);
    /* Over */
    return;
    }
  /* If receiver is managed by this scheduler, allocate message descriptor for new message in internal queue */
  if ( scheduler->internalQueue == NULL )
    {
    scheduler->internalQueue = (RTDS_MessageHeader *)RTDS_MALLOC(sizeof(RTDS_MessageHeader));
    newMessage = scheduler->internalQueue;
    }
  else
    {
    newMessage = scheduler->internalQueue;
    while ( newMessage->next != NULL )
      newMessage = newMessage->next;
    newMessage->next = (RTDS_MessageHeader *)RTDS_MALLOC(sizeof(RTDS_MessageHeader));
    newMessage = newMessage->next;
    }
  /* Record all needed information in descriptor */
  newMessage->messageNumber = messageNumber;
  newMessage->timerUniqueId = 0;
  #ifdef RTDS_SIMULATOR
    if (messageNumber != -1)
      newMessage->messageUniqueId = RTDS_GET_MESSAGE_UNIQUE_ID;
    else
      newMessage->messageUniqueId = 0; /* No unique id when start message */
  #endif
  if ( senderContext == NULL )
    newMessage->sender = NULL;
  else
    newMessage->sender = senderContext->mySdlInstanceId;
  newMessage->receiver = receiver;
  newMessage->dataLength = dataLength;
  newMessage->pData = (unsigned char *)pData;
  newMessage->next = NULL;
  /* Trace */
  if (messageNumber != -1)
    {
    RTDS_SIMULATOR_TRACE(RTDS_messageSent, newMessage, receiver, senderContext);
    }
  }


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
                                      int messageNumber, long dataLength, void * pData)
  {
  RTDS_Proc               * instanceInfo = NULL;
  RTDS_GlobalProcessInfo  * RTDS_currentContext = NULL;
  
  /* Look for a process instance having the given name */
  for ( instanceInfo = scheduler->scheduledInstances; instanceInfo != NULL; instanceInfo = instanceInfo->nextScheduledInstance )
    {
    if ( instanceInfo->RTDS_currentContext->sdlProcessNumber == receiverNameNumber )
      {
      /* If found, send the message to it */
      RTDS_Scheduler_sendMessage(scheduler, senderContext, instanceInfo->RTDS_currentContext->mySdlInstanceId, messageNumber, dataLength, pData);
      return;
      }
    }
  /* If not found, process is not managed by this scheduler => use standard macro */
  RTDS_currentContext = senderContext;
  RTDS_MSG_QUEUE_SEND_TO_NAME(messageNumber, dataLength, pData, "", receiverNameNumber);
  }

#endif /* defined(RTDS_NO_SCHEDULER) */

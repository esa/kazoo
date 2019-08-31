#ifndef _RTDS_PROC_H_
#define _RTDS_PROC_H_

struct _RTDS_Proc;
typedef struct _RTDS_Proc RTDS_Proc;

#include "RTDS_Common.h"
#include "RTDS_Scheduler.h"

#include "RTDS_all_processes.h"

/*
** TYPE RTDS_Proc:
** ---------------
** Descriptor for a process in the scheduler
*/
struct _RTDS_Proc
  {
  RTDS_GlobalProcessInfo  * RTDS_currentContext;    /* Context for the instance */
  RTDS_ProcessLocals        myLocals;               /* Local variables for the instance */
  RTDS_Scheduler          * RTDS_parentScheduler;   /* Scheduler into which the instance is running if any */
  short                     RTDS_isProcedure;       /* If true, instance is for a procedure */
  RTDS_MessageHeader      * RTDS_initialMessage;    /* Message that triggered the actual transition in this instance */
  RTDS_SdlInstanceId      * RTDS_senderId;          /* Identifier for the process sending the current message */
  struct _RTDS_Proc       * RTDS_calledProcedure;   /* Descriptor for the currently called procedure instance if any */
  unsigned int              RTDS_nextLabelId;       /* Numerical identifier for the label branching to the code after the current procedure call if any */
  int                       RTDS_sdlStatePrev;      /* Previous SDL state for instance */
  struct _RTDS_Proc       * nextScheduledInstance;  /* Alternate list chaining when in scheduled instances in a scheduler */
  };


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
);

/*
** FUNCTION RTDS_Proc_deleteInstance:
** ----------------------------------
** Deletes and forgets everything about a given process instance
*/
void RTDS_Proc_deleteInstance(RTDS_Proc * instanceDescriptor);

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
);

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
);

/*
** FUNCTION RTDS_Proc_msgQueueSendToEnv:
** -------------------------------------
** Sends a message to the environnement.
*/
void RTDS_Proc_msgQueueSendToEnv(
  RTDS_Proc     * instanceDescriptor, /* Descriptor for sender instance */
  long            messageNumber,      /* Numerical identifier for message type to send */
  long            dataLength,         /* Length of data associated to message */
  unsigned char * pData               /* Pointer on message actual data */
);

/*
** FUNCTION RTDS_Proc_msgSave:
** ---------------------------
** Saves a message. The actual "re-sending" of the message will be handled by the scheduler after the next instance's state change.
*/
void RTDS_Proc_msgSave(
  RTDS_Proc           * instanceDescriptor, /* Descriptor for the instance saving the message */
  RTDS_MessageHeader  * message             /* Actual message to save */
);

/*
** FUNCTION RTDS_Proc_setTimer:
** ----------------------------
** Starts a timer.
*/
void RTDS_Proc_setTimer(
  RTDS_Proc * instanceDescriptor, /* Instance starting the timer */
  long        timerNumber,        /* Numerical identifier for the timer to start */
  int         delay               /* Delay for the timer, in system ticks */
);

/*
** FUNCTION RTDS_Proc_resetTimer:
** ------------------------------
** Cancels a timer.
*/
void RTDS_Proc_resetTimer(
  RTDS_Proc * instanceDescriptor, /* Instance cancelling the timer, which must be the one that started it */
  long        timerNumber         /* Numerical identifier for the timer to cancel */
);

/*
** FUNCTION RTDS_Proc_setSdlState:
** -------------------------------
** Changes the SDL state of an instance.
*/
void RTDS_Proc_setSdlState(
  RTDS_Proc * instanceDescriptor, /* Instance for which the state must be changed */
  int         newState            /* Numerical value for the the new SDL state */
);

#endif


#ifndef _RTDS_COMMON_H_
#define _RTDS_COMMON_H_


#include "RTDS_BasicTypes.h"


/*
 * TYPE RTDS_SdlInstanceId:
 * ---------------------
 * Identifier for a process instance in the running system.
 */
typedef struct RTDS_SdlInstanceId
  {
  RTDS_RtosQueueId  queueId;        /* Queue id for the process or its scheduler if scheduled */
  int               instanceNumber; /* Numerical identifier for instance if in a scheduler */
  } RTDS_SdlInstanceId;


/*
 * TYPE RTDS_PID:
 * --------------
 * New type for process identifiers. This type should now be used instead of RTDS_QueueId
 */
typedef RTDS_SdlInstanceId * RTDS_PID;


/*
 * TYPE RTDS_QueueId:
 * ------------------
 * Only for compatibility: old RTDS_QueueId type is defined as a RTDS_PID
 * NB: THIS TYPE SHOULD NO MORE BE USED!
 */
#define RTDS_QueueId RTDS_PID


/*
 * STRUCT RTDS_MESSAGE.HEADER:
 * ---------------------------
 * Type for a message descriptor
 * Don't invert fields !!! This would mess up the gopher scripts used in:
 *   - getMessageInformation in wtxmodule.c
 */
typedef struct RTDS_MessageHeader
  {
  RTDS_MESSAGE_HEADER_ADDITIONNAL_FIELDS        /* OSE requires the first field to be sigNo */
  long                        messageNumber;    /* The integer value for the message or the timer */
  long                        timerUniqueId;    /* If 0, normal message; otherwise unique id. for timer if message is a timer */
#ifdef RTDS_SIMULATOR
  unsigned long               messageUniqueId;  /* Used by simulator to trace messages */
#endif
  RTDS_SdlInstanceId        * sender;           /* The SDL instance id of the sender */
  RTDS_SdlInstanceId        * receiver;         /* The SDL instance id of the receiver */
  long                        dataLength;       /* Length of data */
  unsigned char             * pData;            /* Pointer to message data */

  struct RTDS_MessageHeader * next;             /* Next message if used as a message queue */
  } RTDS_MessageHeader;


/*
 * STRUCT RTDS_GLOBAL.PROCESS.INFO:
 * -------------------------------
 * Type for the list of processes in the system with their information
 * Offset displayed for Tornado gopher script
 */
typedef struct RTDS_GlobalProcessInfo
  {
  RTDS_RtosTaskId                  myRtosTaskId;            /* 0x00 The PID of the RTOS task */
  int                              sdlProcessNumber;        /* 0x04 Name of the process as a number defined in RTDS_gen.h */
  RTDS_SdlInstanceId             * mySdlInstanceId;         /* 0x08 The SDL instance id for the current process */
  RTDS_SdlInstanceId             * parentSdlInstanceId;     /* 0x0C The SDL instance id for the parent process */
  RTDS_SdlInstanceId             * offspringSdlInstanceId;  /* 0x10 The SDL instance id for the child process */
  int                              sdlState;                /* 0x14 Current SDL state of the process */
  RTDS_MessageHeader             * currentMessage;          /* 0x18 Last message read */
  RTDS_TimerState                * timerList;               /* 0x1C Pointer to the list of current active timers */
  RTDS_MessageHeader             * readSaveQueue;           /* 0x20 Save queue chained list entry point when reading saved messages */
  RTDS_MessageHeader             * writeSaveQueue;          /* 0x24 Save queue chained list entry point when saving messages */
  struct RTDS_GlobalProcessInfo  * next;                    /* 0x28 Next processInfo */
  RTDS_GLOBAL_PROCESS_INFO_ADDITIONNAL_FIELDS               /* 0x30 OS dependant */
  } RTDS_GlobalProcessInfo;


/*
 * ENUM RTDS_EVENT.TYPE:
 * -------------------------------
 * Enum of event types the simulator can be warned about
 */

enum RTDS_EventType
  {
  RTDS_messageSent      = 0,
  RTDS_messageReceived  = 1,
  RTDS_timerStarted     = 2,
  RTDS_timerCancelled   = 3,
  RTDS_processCreated   = 4,
  RTDS_processDied      = 5,
  RTDS_semTakeAttempt   = 6,
  RTDS_semTakeSucceded  = 7,
  RTDS_semGive          = 8,
  RTDS_sdlStateSet      = 9,
  RTDS_initDone         = 10,
  RTDS_semTakeTimedOut  = 11,
  RTDS_systemError      = 12,
  RTDS_semaphoreCreated = 13,
  RTDS_semaphoreDeleted = 14,
  RTDS_messageSaved     = 15,
  RTDS_information      = 16
  } ;


/*
 * STRUCT RTDS_GLOBAL.TRACE.INFO:
 * -------------------------------
 * Structure containing the event information red by the simulator
 */
#if defined( RTDS_SIMULATOR ) || defined( RTDS_MSC_TRACER ) || defined( RTDS_FORMAT_TRACE )
typedef struct RTDS_GlobalTraceInfo
  {
  enum RTDS_EventType       event;
  void                    * eventParameter1;
  long                      eventParameter2;
  RTDS_GlobalProcessInfo  * currentContext;
  } RTDS_GlobalTraceInfo;
#endif


#endif

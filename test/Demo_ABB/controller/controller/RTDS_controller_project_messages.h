#ifndef _RTDS_CONTROLLER_PROJECT_MESSAGES_H_
#define _RTDS_CONTROLLER_PROJECT_MESSAGES_H_

#include "RTDS_CommonTypes.h"
#include "controller.h"

#ifdef __cplusplus
extern "C" {
#endif


/* DATA TYPES FOR MESSAGES */
#ifndef RTDS_floor_detected_DATA_DEFINED
typedef struct RTDS_floor_detected_data
{
	Floors	param1;
} RTDS_floor_detected_data;
#define RTDS_floor_detected_DATA_DEFINED
#endif

#ifndef RTDS_Manual_Control_DATA_DEFINED
typedef struct RTDS_Manual_Control_data
{
	Lift_control	param1;
} RTDS_Manual_Control_data;
#define RTDS_Manual_Control_DATA_DEFINED
#endif

#ifndef RTDS_Pulse_DATA_DEFINED
typedef char RTDS_Pulse_data;
#define RTDS_Pulse_DATA_DEFINED
#endif

#ifndef RTDS_Start_DATA_DEFINED
typedef struct RTDS_Start_data
{
	Start_condition	param1;
} RTDS_Start_data;
#define RTDS_Start_DATA_DEFINED
#endif

#ifndef RTDS_Cabin_Command_DATA_DEFINED
typedef struct RTDS_Cabin_Command_data
{
	Cabin_button	param1;
} RTDS_Cabin_Command_data;
#define RTDS_Cabin_Command_DATA_DEFINED
#endif

#ifndef RTDS_Floor_Command_DATA_DEFINED
typedef struct RTDS_Floor_Command_data
{
	Floor_button	param1;
} RTDS_Floor_Command_data;
#define RTDS_Floor_Command_DATA_DEFINED
#endif

#ifndef RTDS_door_status_DATA_DEFINED
typedef struct RTDS_door_status_data
{
	OpenClose	param1;
} RTDS_door_status_data;
#define RTDS_door_status_DATA_DEFINED
#endif

#ifndef RTDS_position_DATA_DEFINED
typedef struct RTDS_position_data
{
	Position	param1;
} RTDS_position_data;
#define RTDS_position_DATA_DEFINED
#endif


/* MACRO FOR DECLARATIONS FOR MESSAGE SEND/RECEIVE */

#ifndef RTDS_MSG_DATA_DECL
#define RTDS_MSG_DATA_DECL RTDS_MessageData RTDS_msgData;
#endif  /* RTDS_MSG_DATA_DECL defined */


/* MACRO FOR RECEPTION OF MESSAGE floor_detected */

#ifndef RTDS_MSG_RECEIVE_floor_detected
#define RTDS_MSG_RECEIVE_floor_detected(RTDS_PARAM1) \
	{ \
	if ( RTDS_currentContext->currentMessage->pData != NULL ) \
		{ \
		RTDS_PARAM1 = ((RTDS_floor_detected_data*)(RTDS_currentContext->currentMessage->pData))->param1; \
		} \
	else \
		{ \
		RTDS_MSG_INPUT_ERROR; \
		} \
	}
#endif /* RTDS_MSG_RECEIVE_floor_detected defined */


/* MACRO FOR SENDING MESSAGE floor_detected TO A PROCESS NAME */

#ifndef RTDS_MSG_SEND_floor_detected_TO_NAME
#define RTDS_MSG_SEND_floor_detected_TO_NAME(RECEIVER, RECEIVER_NUMBER, RTDS_PARAM1) \
	{ \
	RTDS_msgData.floor_detected_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_NAME(RTDS_message_floor_detected, sizeof(RTDS_floor_detected_data), &(RTDS_msgData.floor_detected_data), RECEIVER, RECEIVER_NUMBER); \
	}
#endif /* RTDS_MSG_SEND_floor_detected_TO_NAME defined */


/* MACRO FOR SENDING MESSAGE floor_detected TO A PROCESS ID */

#ifndef RTDS_MSG_SEND_floor_detected_TO_ID
#define RTDS_MSG_SEND_floor_detected_TO_ID(RECEIVER, RTDS_PARAM1) \
	{ \
	RTDS_msgData.floor_detected_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_ID(RTDS_message_floor_detected, sizeof(RTDS_floor_detected_data), &(RTDS_msgData.floor_detected_data), RECEIVER); \
	}
#endif /* RTDS_MSG_SEND_floor_detected_TO_ID defined */


/* MACROS FOR SENDING MESSAGE floor_detected TO ENVIRONMENT */

#ifndef RTDS_MSG_SEND_floor_detected_TO_ENV
#define RTDS_MSG_SEND_floor_detected_TO_ENV(RTDS_PARAM1) \
	{ \
	RTDS_msgData.floor_detected_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_ENV(RTDS_message_floor_detected, sizeof(RTDS_floor_detected_data), &(RTDS_msgData.floor_detected_data)); \
	}
#endif /* RTDS_MSG_SEND_floor_detected_TO_ENV defined */


#ifndef RTDS_MSG_SEND_floor_detected_TO_ENV_W_MACRO
#define RTDS_MSG_SEND_floor_detected_TO_ENV_W_MACRO(MACRO_NAME, RTDS_PARAM1) \
	{ \
	RTDS_msgData.floor_detected_data.param1 = RTDS_PARAM1; \
	MACRO_NAME(RTDS_message_floor_detected, sizeof(RTDS_floor_detected_data), &(RTDS_msgData.floor_detected_data)); \
	}
#endif /* RTDS_MSG_SEND_floor_detected_TO_ENV defined */


/* MACRO FOR MESSAGE floor_detected HEADER INITIALIZATION */

#ifndef RTDS_floor_detected_SET_MESSAGE
#define RTDS_floor_detected_SET_MESSAGE(MESSAGE_HEADER, RTDS_PARAM1) \
	{ \
	(MESSAGE_HEADER)->dataLength = sizeof(RTDS_floor_detected_data); \
	(MESSAGE_HEADER)->pData = (unsigned char *)&(RTDS_msgData.floor_detected_data); \
	RTDS_msgData.floor_detected_data.param1 = RTDS_PARAM1; \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_floor_detected; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_floor_detected_SET_MESSAGE defined */


/* MACRO FOR RECEPTION OF MESSAGE Manual_Control */

#ifndef RTDS_MSG_RECEIVE_Manual_Control
#define RTDS_MSG_RECEIVE_Manual_Control(RTDS_PARAM1) \
	{ \
	if ( RTDS_currentContext->currentMessage->pData != NULL ) \
		{ \
		memcpy(&(RTDS_PARAM1), &(((RTDS_Manual_Control_data*)(RTDS_currentContext->currentMessage->pData))->param1), sizeof(Lift_control)); \
		} \
	else \
		{ \
		RTDS_MSG_INPUT_ERROR; \
		} \
	}
#endif /* RTDS_MSG_RECEIVE_Manual_Control defined */


/* MACRO FOR SENDING MESSAGE Manual_Control TO A PROCESS NAME */

#ifndef RTDS_MSG_SEND_Manual_Control_TO_NAME
#define RTDS_MSG_SEND_Manual_Control_TO_NAME(RECEIVER, RECEIVER_NUMBER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Manual_Control_data.param1), &(RTDS_PARAM1), sizeof(Lift_control)); \
	RTDS_MSG_QUEUE_SEND_TO_NAME(RTDS_message_Manual_Control, sizeof(RTDS_Manual_Control_data), &(RTDS_msgData.Manual_Control_data), RECEIVER, RECEIVER_NUMBER); \
	}
#endif /* RTDS_MSG_SEND_Manual_Control_TO_NAME defined */


/* MACRO FOR SENDING MESSAGE Manual_Control TO A PROCESS ID */

#ifndef RTDS_MSG_SEND_Manual_Control_TO_ID
#define RTDS_MSG_SEND_Manual_Control_TO_ID(RECEIVER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Manual_Control_data.param1), &(RTDS_PARAM1), sizeof(Lift_control)); \
	RTDS_MSG_QUEUE_SEND_TO_ID(RTDS_message_Manual_Control, sizeof(RTDS_Manual_Control_data), &(RTDS_msgData.Manual_Control_data), RECEIVER); \
	}
#endif /* RTDS_MSG_SEND_Manual_Control_TO_ID defined */


/* MACROS FOR SENDING MESSAGE Manual_Control TO ENVIRONMENT */

#ifndef RTDS_MSG_SEND_Manual_Control_TO_ENV
#define RTDS_MSG_SEND_Manual_Control_TO_ENV(RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Manual_Control_data.param1), &(RTDS_PARAM1), sizeof(Lift_control)); \
	RTDS_MSG_QUEUE_SEND_TO_ENV(RTDS_message_Manual_Control, sizeof(RTDS_Manual_Control_data), &(RTDS_msgData.Manual_Control_data)); \
	}
#endif /* RTDS_MSG_SEND_Manual_Control_TO_ENV defined */


#ifndef RTDS_MSG_SEND_Manual_Control_TO_ENV_W_MACRO
#define RTDS_MSG_SEND_Manual_Control_TO_ENV_W_MACRO(MACRO_NAME, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Manual_Control_data.param1), &(RTDS_PARAM1), sizeof(Lift_control)); \
	MACRO_NAME(RTDS_message_Manual_Control, sizeof(RTDS_Manual_Control_data), &(RTDS_msgData.Manual_Control_data)); \
	}
#endif /* RTDS_MSG_SEND_Manual_Control_TO_ENV defined */


/* MACRO FOR MESSAGE Manual_Control HEADER INITIALIZATION */

#ifndef RTDS_Manual_Control_SET_MESSAGE
#define RTDS_Manual_Control_SET_MESSAGE(MESSAGE_HEADER, RTDS_PARAM1) \
	{ \
	(MESSAGE_HEADER)->dataLength = sizeof(RTDS_Manual_Control_data); \
	(MESSAGE_HEADER)->pData = (unsigned char *)&(RTDS_msgData.Manual_Control_data); \
	memcpy(&(RTDS_msgData.Manual_Control_data.param1), &(RTDS_PARAM1), sizeof(Lift_control)); \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_Manual_Control; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_Manual_Control_SET_MESSAGE defined */


/* MACRO FOR MESSAGE Pulse HEADER INITIALIZATION */

#ifndef RTDS_Pulse_SET_MESSAGE
#define RTDS_Pulse_SET_MESSAGE(MESSAGE_HEADER) \
	{ \
	(MESSAGE_HEADER)->dataLength = 0; \
	(MESSAGE_HEADER)->pData = NULL; \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_Pulse; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_Pulse_SET_MESSAGE defined */


/* MACRO FOR RECEPTION OF MESSAGE Start */

#ifndef RTDS_MSG_RECEIVE_Start
#define RTDS_MSG_RECEIVE_Start(RTDS_PARAM1) \
	{ \
	if ( RTDS_currentContext->currentMessage->pData != NULL ) \
		{ \
		memcpy(&(RTDS_PARAM1), &(((RTDS_Start_data*)(RTDS_currentContext->currentMessage->pData))->param1), sizeof(Start_condition)); \
		} \
	else \
		{ \
		RTDS_MSG_INPUT_ERROR; \
		} \
	}
#endif /* RTDS_MSG_RECEIVE_Start defined */


/* MACRO FOR SENDING MESSAGE Start TO A PROCESS NAME */

#ifndef RTDS_MSG_SEND_Start_TO_NAME
#define RTDS_MSG_SEND_Start_TO_NAME(RECEIVER, RECEIVER_NUMBER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Start_data.param1), &(RTDS_PARAM1), sizeof(Start_condition)); \
	RTDS_MSG_QUEUE_SEND_TO_NAME(RTDS_message_Start, sizeof(RTDS_Start_data), &(RTDS_msgData.Start_data), RECEIVER, RECEIVER_NUMBER); \
	}
#endif /* RTDS_MSG_SEND_Start_TO_NAME defined */


/* MACRO FOR SENDING MESSAGE Start TO A PROCESS ID */

#ifndef RTDS_MSG_SEND_Start_TO_ID
#define RTDS_MSG_SEND_Start_TO_ID(RECEIVER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Start_data.param1), &(RTDS_PARAM1), sizeof(Start_condition)); \
	RTDS_MSG_QUEUE_SEND_TO_ID(RTDS_message_Start, sizeof(RTDS_Start_data), &(RTDS_msgData.Start_data), RECEIVER); \
	}
#endif /* RTDS_MSG_SEND_Start_TO_ID defined */


/* MACROS FOR SENDING MESSAGE Start TO ENVIRONMENT */

#ifndef RTDS_MSG_SEND_Start_TO_ENV
#define RTDS_MSG_SEND_Start_TO_ENV(RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Start_data.param1), &(RTDS_PARAM1), sizeof(Start_condition)); \
	RTDS_MSG_QUEUE_SEND_TO_ENV(RTDS_message_Start, sizeof(RTDS_Start_data), &(RTDS_msgData.Start_data)); \
	}
#endif /* RTDS_MSG_SEND_Start_TO_ENV defined */


#ifndef RTDS_MSG_SEND_Start_TO_ENV_W_MACRO
#define RTDS_MSG_SEND_Start_TO_ENV_W_MACRO(MACRO_NAME, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Start_data.param1), &(RTDS_PARAM1), sizeof(Start_condition)); \
	MACRO_NAME(RTDS_message_Start, sizeof(RTDS_Start_data), &(RTDS_msgData.Start_data)); \
	}
#endif /* RTDS_MSG_SEND_Start_TO_ENV defined */


/* MACRO FOR MESSAGE Start HEADER INITIALIZATION */

#ifndef RTDS_Start_SET_MESSAGE
#define RTDS_Start_SET_MESSAGE(MESSAGE_HEADER, RTDS_PARAM1) \
	{ \
	(MESSAGE_HEADER)->dataLength = sizeof(RTDS_Start_data); \
	(MESSAGE_HEADER)->pData = (unsigned char *)&(RTDS_msgData.Start_data); \
	memcpy(&(RTDS_msgData.Start_data.param1), &(RTDS_PARAM1), sizeof(Start_condition)); \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_Start; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_Start_SET_MESSAGE defined */


/* MACRO FOR RECEPTION OF MESSAGE Cabin_Command */

#ifndef RTDS_MSG_RECEIVE_Cabin_Command
#define RTDS_MSG_RECEIVE_Cabin_Command(RTDS_PARAM1) \
	{ \
	if ( RTDS_currentContext->currentMessage->pData != NULL ) \
		{ \
		memcpy(&(RTDS_PARAM1), &(((RTDS_Cabin_Command_data*)(RTDS_currentContext->currentMessage->pData))->param1), sizeof(Cabin_button)); \
		} \
	else \
		{ \
		RTDS_MSG_INPUT_ERROR; \
		} \
	}
#endif /* RTDS_MSG_RECEIVE_Cabin_Command defined */


/* MACRO FOR SENDING MESSAGE Cabin_Command TO A PROCESS NAME */

#ifndef RTDS_MSG_SEND_Cabin_Command_TO_NAME
#define RTDS_MSG_SEND_Cabin_Command_TO_NAME(RECEIVER, RECEIVER_NUMBER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Cabin_Command_data.param1), &(RTDS_PARAM1), sizeof(Cabin_button)); \
	RTDS_MSG_QUEUE_SEND_TO_NAME(RTDS_message_Cabin_Command, sizeof(RTDS_Cabin_Command_data), &(RTDS_msgData.Cabin_Command_data), RECEIVER, RECEIVER_NUMBER); \
	}
#endif /* RTDS_MSG_SEND_Cabin_Command_TO_NAME defined */


/* MACRO FOR SENDING MESSAGE Cabin_Command TO A PROCESS ID */

#ifndef RTDS_MSG_SEND_Cabin_Command_TO_ID
#define RTDS_MSG_SEND_Cabin_Command_TO_ID(RECEIVER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Cabin_Command_data.param1), &(RTDS_PARAM1), sizeof(Cabin_button)); \
	RTDS_MSG_QUEUE_SEND_TO_ID(RTDS_message_Cabin_Command, sizeof(RTDS_Cabin_Command_data), &(RTDS_msgData.Cabin_Command_data), RECEIVER); \
	}
#endif /* RTDS_MSG_SEND_Cabin_Command_TO_ID defined */


/* MACROS FOR SENDING MESSAGE Cabin_Command TO ENVIRONMENT */

#ifndef RTDS_MSG_SEND_Cabin_Command_TO_ENV
#define RTDS_MSG_SEND_Cabin_Command_TO_ENV(RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Cabin_Command_data.param1), &(RTDS_PARAM1), sizeof(Cabin_button)); \
	RTDS_MSG_QUEUE_SEND_TO_ENV(RTDS_message_Cabin_Command, sizeof(RTDS_Cabin_Command_data), &(RTDS_msgData.Cabin_Command_data)); \
	}
#endif /* RTDS_MSG_SEND_Cabin_Command_TO_ENV defined */


#ifndef RTDS_MSG_SEND_Cabin_Command_TO_ENV_W_MACRO
#define RTDS_MSG_SEND_Cabin_Command_TO_ENV_W_MACRO(MACRO_NAME, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Cabin_Command_data.param1), &(RTDS_PARAM1), sizeof(Cabin_button)); \
	MACRO_NAME(RTDS_message_Cabin_Command, sizeof(RTDS_Cabin_Command_data), &(RTDS_msgData.Cabin_Command_data)); \
	}
#endif /* RTDS_MSG_SEND_Cabin_Command_TO_ENV defined */


/* MACRO FOR MESSAGE Cabin_Command HEADER INITIALIZATION */

#ifndef RTDS_Cabin_Command_SET_MESSAGE
#define RTDS_Cabin_Command_SET_MESSAGE(MESSAGE_HEADER, RTDS_PARAM1) \
	{ \
	(MESSAGE_HEADER)->dataLength = sizeof(RTDS_Cabin_Command_data); \
	(MESSAGE_HEADER)->pData = (unsigned char *)&(RTDS_msgData.Cabin_Command_data); \
	memcpy(&(RTDS_msgData.Cabin_Command_data.param1), &(RTDS_PARAM1), sizeof(Cabin_button)); \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_Cabin_Command; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_Cabin_Command_SET_MESSAGE defined */


/* MACRO FOR RECEPTION OF MESSAGE Floor_Command */

#ifndef RTDS_MSG_RECEIVE_Floor_Command
#define RTDS_MSG_RECEIVE_Floor_Command(RTDS_PARAM1) \
	{ \
	if ( RTDS_currentContext->currentMessage->pData != NULL ) \
		{ \
		memcpy(&(RTDS_PARAM1), &(((RTDS_Floor_Command_data*)(RTDS_currentContext->currentMessage->pData))->param1), sizeof(Floor_button)); \
		} \
	else \
		{ \
		RTDS_MSG_INPUT_ERROR; \
		} \
	}
#endif /* RTDS_MSG_RECEIVE_Floor_Command defined */


/* MACRO FOR SENDING MESSAGE Floor_Command TO A PROCESS NAME */

#ifndef RTDS_MSG_SEND_Floor_Command_TO_NAME
#define RTDS_MSG_SEND_Floor_Command_TO_NAME(RECEIVER, RECEIVER_NUMBER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Floor_Command_data.param1), &(RTDS_PARAM1), sizeof(Floor_button)); \
	RTDS_MSG_QUEUE_SEND_TO_NAME(RTDS_message_Floor_Command, sizeof(RTDS_Floor_Command_data), &(RTDS_msgData.Floor_Command_data), RECEIVER, RECEIVER_NUMBER); \
	}
#endif /* RTDS_MSG_SEND_Floor_Command_TO_NAME defined */


/* MACRO FOR SENDING MESSAGE Floor_Command TO A PROCESS ID */

#ifndef RTDS_MSG_SEND_Floor_Command_TO_ID
#define RTDS_MSG_SEND_Floor_Command_TO_ID(RECEIVER, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Floor_Command_data.param1), &(RTDS_PARAM1), sizeof(Floor_button)); \
	RTDS_MSG_QUEUE_SEND_TO_ID(RTDS_message_Floor_Command, sizeof(RTDS_Floor_Command_data), &(RTDS_msgData.Floor_Command_data), RECEIVER); \
	}
#endif /* RTDS_MSG_SEND_Floor_Command_TO_ID defined */


/* MACROS FOR SENDING MESSAGE Floor_Command TO ENVIRONMENT */

#ifndef RTDS_MSG_SEND_Floor_Command_TO_ENV
#define RTDS_MSG_SEND_Floor_Command_TO_ENV(RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Floor_Command_data.param1), &(RTDS_PARAM1), sizeof(Floor_button)); \
	RTDS_MSG_QUEUE_SEND_TO_ENV(RTDS_message_Floor_Command, sizeof(RTDS_Floor_Command_data), &(RTDS_msgData.Floor_Command_data)); \
	}
#endif /* RTDS_MSG_SEND_Floor_Command_TO_ENV defined */


#ifndef RTDS_MSG_SEND_Floor_Command_TO_ENV_W_MACRO
#define RTDS_MSG_SEND_Floor_Command_TO_ENV_W_MACRO(MACRO_NAME, RTDS_PARAM1) \
	{ \
	memcpy(&(RTDS_msgData.Floor_Command_data.param1), &(RTDS_PARAM1), sizeof(Floor_button)); \
	MACRO_NAME(RTDS_message_Floor_Command, sizeof(RTDS_Floor_Command_data), &(RTDS_msgData.Floor_Command_data)); \
	}
#endif /* RTDS_MSG_SEND_Floor_Command_TO_ENV defined */


/* MACRO FOR MESSAGE Floor_Command HEADER INITIALIZATION */

#ifndef RTDS_Floor_Command_SET_MESSAGE
#define RTDS_Floor_Command_SET_MESSAGE(MESSAGE_HEADER, RTDS_PARAM1) \
	{ \
	(MESSAGE_HEADER)->dataLength = sizeof(RTDS_Floor_Command_data); \
	(MESSAGE_HEADER)->pData = (unsigned char *)&(RTDS_msgData.Floor_Command_data); \
	memcpy(&(RTDS_msgData.Floor_Command_data.param1), &(RTDS_PARAM1), sizeof(Floor_button)); \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_Floor_Command; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_Floor_Command_SET_MESSAGE defined */


/* MACRO FOR RECEPTION OF MESSAGE door_status */

#ifndef RTDS_MSG_RECEIVE_door_status
#define RTDS_MSG_RECEIVE_door_status(RTDS_PARAM1) \
	{ \
	if ( RTDS_currentContext->currentMessage->pData != NULL ) \
		{ \
		RTDS_PARAM1 = ((RTDS_door_status_data*)(RTDS_currentContext->currentMessage->pData))->param1; \
		} \
	else \
		{ \
		RTDS_MSG_INPUT_ERROR; \
		} \
	}
#endif /* RTDS_MSG_RECEIVE_door_status defined */


/* MACRO FOR SENDING MESSAGE door_status TO A PROCESS NAME */

#ifndef RTDS_MSG_SEND_door_status_TO_NAME
#define RTDS_MSG_SEND_door_status_TO_NAME(RECEIVER, RECEIVER_NUMBER, RTDS_PARAM1) \
	{ \
	RTDS_msgData.door_status_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_NAME(RTDS_message_door_status, sizeof(RTDS_door_status_data), &(RTDS_msgData.door_status_data), RECEIVER, RECEIVER_NUMBER); \
	}
#endif /* RTDS_MSG_SEND_door_status_TO_NAME defined */


/* MACRO FOR SENDING MESSAGE door_status TO A PROCESS ID */

#ifndef RTDS_MSG_SEND_door_status_TO_ID
#define RTDS_MSG_SEND_door_status_TO_ID(RECEIVER, RTDS_PARAM1) \
	{ \
	RTDS_msgData.door_status_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_ID(RTDS_message_door_status, sizeof(RTDS_door_status_data), &(RTDS_msgData.door_status_data), RECEIVER); \
	}
#endif /* RTDS_MSG_SEND_door_status_TO_ID defined */


/* MACROS FOR SENDING MESSAGE door_status TO ENVIRONMENT */

#ifndef RTDS_MSG_SEND_door_status_TO_ENV
#define RTDS_MSG_SEND_door_status_TO_ENV(RTDS_PARAM1) \
	{ \
	RTDS_msgData.door_status_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_ENV(RTDS_message_door_status, sizeof(RTDS_door_status_data), &(RTDS_msgData.door_status_data)); \
	}
#endif /* RTDS_MSG_SEND_door_status_TO_ENV defined */


#ifndef RTDS_MSG_SEND_door_status_TO_ENV_W_MACRO
#define RTDS_MSG_SEND_door_status_TO_ENV_W_MACRO(MACRO_NAME, RTDS_PARAM1) \
	{ \
	RTDS_msgData.door_status_data.param1 = RTDS_PARAM1; \
	MACRO_NAME(RTDS_message_door_status, sizeof(RTDS_door_status_data), &(RTDS_msgData.door_status_data)); \
	}
#endif /* RTDS_MSG_SEND_door_status_TO_ENV defined */


/* MACRO FOR MESSAGE door_status HEADER INITIALIZATION */

#ifndef RTDS_door_status_SET_MESSAGE
#define RTDS_door_status_SET_MESSAGE(MESSAGE_HEADER, RTDS_PARAM1) \
	{ \
	(MESSAGE_HEADER)->dataLength = sizeof(RTDS_door_status_data); \
	(MESSAGE_HEADER)->pData = (unsigned char *)&(RTDS_msgData.door_status_data); \
	RTDS_msgData.door_status_data.param1 = RTDS_PARAM1; \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_door_status; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_door_status_SET_MESSAGE defined */


/* MACRO FOR RECEPTION OF MESSAGE position */

#ifndef RTDS_MSG_RECEIVE_position
#define RTDS_MSG_RECEIVE_position(RTDS_PARAM1) \
	{ \
	if ( RTDS_currentContext->currentMessage->pData != NULL ) \
		{ \
		RTDS_PARAM1 = ((RTDS_position_data*)(RTDS_currentContext->currentMessage->pData))->param1; \
		} \
	else \
		{ \
		RTDS_MSG_INPUT_ERROR; \
		} \
	}
#endif /* RTDS_MSG_RECEIVE_position defined */


/* MACRO FOR SENDING MESSAGE position TO A PROCESS NAME */

#ifndef RTDS_MSG_SEND_position_TO_NAME
#define RTDS_MSG_SEND_position_TO_NAME(RECEIVER, RECEIVER_NUMBER, RTDS_PARAM1) \
	{ \
	RTDS_msgData.position_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_NAME(RTDS_message_position, sizeof(RTDS_position_data), &(RTDS_msgData.position_data), RECEIVER, RECEIVER_NUMBER); \
	}
#endif /* RTDS_MSG_SEND_position_TO_NAME defined */


/* MACRO FOR SENDING MESSAGE position TO A PROCESS ID */

#ifndef RTDS_MSG_SEND_position_TO_ID
#define RTDS_MSG_SEND_position_TO_ID(RECEIVER, RTDS_PARAM1) \
	{ \
	RTDS_msgData.position_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_ID(RTDS_message_position, sizeof(RTDS_position_data), &(RTDS_msgData.position_data), RECEIVER); \
	}
#endif /* RTDS_MSG_SEND_position_TO_ID defined */


/* MACROS FOR SENDING MESSAGE position TO ENVIRONMENT */

#ifndef RTDS_MSG_SEND_position_TO_ENV
#define RTDS_MSG_SEND_position_TO_ENV(RTDS_PARAM1) \
	{ \
	RTDS_msgData.position_data.param1 = RTDS_PARAM1; \
	RTDS_MSG_QUEUE_SEND_TO_ENV(RTDS_message_position, sizeof(RTDS_position_data), &(RTDS_msgData.position_data)); \
	}
#endif /* RTDS_MSG_SEND_position_TO_ENV defined */


#ifndef RTDS_MSG_SEND_position_TO_ENV_W_MACRO
#define RTDS_MSG_SEND_position_TO_ENV_W_MACRO(MACRO_NAME, RTDS_PARAM1) \
	{ \
	RTDS_msgData.position_data.param1 = RTDS_PARAM1; \
	MACRO_NAME(RTDS_message_position, sizeof(RTDS_position_data), &(RTDS_msgData.position_data)); \
	}
#endif /* RTDS_MSG_SEND_position_TO_ENV defined */


/* MACRO FOR MESSAGE position HEADER INITIALIZATION */

#ifndef RTDS_position_SET_MESSAGE
#define RTDS_position_SET_MESSAGE(MESSAGE_HEADER, RTDS_PARAM1) \
	{ \
	(MESSAGE_HEADER)->dataLength = sizeof(RTDS_position_data); \
	(MESSAGE_HEADER)->pData = (unsigned char *)&(RTDS_msgData.position_data); \
	RTDS_msgData.position_data.param1 = RTDS_PARAM1; \
	(MESSAGE_HEADER)->messageNumber = RTDS_message_position; \
	(MESSAGE_HEADER)->timerUniqueId = 0; \
	(MESSAGE_HEADER)->sender = NULL; \
	(MESSAGE_HEADER)->receiver = NULL; \
	(MESSAGE_HEADER)->next = NULL; \
	}
#endif /* RTDS_position_SET_MESSAGE defined */


#ifdef __cplusplus
}
#endif

#endif /* defined(_RTDS_CONTROLLER_PROJECT_MESSAGES_H_) */


#include "RTDS_MACRO.h"
#include "common.h"

#include "controller_p.h"
#include "RTDS_controller_project_messages.h"
#include "RTDS_gen.h"

#define RTDS_PROCESS_NUMBER RTDS_process_controller_p
#define RTDS_PROCESS_NAME controller_p

/* LOCAL DEFINES FOR STATES */
#define RTDS_state_stopped 1
#define RTDS_state_moving 2

#include "RTDS_ADDL_MACRO.h"

#include "controller_p_decl.h"
#include "controller_p_tmpvars.h"
#undef SENDER
#define SENDER RTDS_instanceDescriptor->RTDS_senderId

/*
** INSTANCE CREATION/INITIALIZATION:
** ---------------------------------
*/

void RTDS_Proc_controller_p_createInstance(
RTDS_Proc * RTDS_instanceDescriptor,
RTDS_Scheduler * parentScheduler,
RTDS_GlobalProcessInfo * instanceContext,
RTDS_GlobalProcessInfo * parentContext
)
  {
  RTDS_instanceDescriptor->RTDS_isProcedure = 0;
  RTDS_Proc_createInstance(RTDS_instanceDescriptor, parentScheduler, instanceContext, parentContext);
  RTDS_instanceDescriptor->RTDS_currentContext->sdlProcessNumber = RTDS_PROCESS_NUMBER;
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[0] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.cabin_cmd);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[1] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.cmd);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[2] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.counter);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[3] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.currFloor);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[4] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.door);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[5] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.floor_cmd);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[6] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.prevPos);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[7] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.sensors);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals)[8] = (void*)&(RTDS_instanceDescriptor->myLocals.controller_p.target_floor);
  (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_localsStack)[0] = (RTDS_instanceDescriptor->myLocals.controller_p.RTDS_myLocals);

  };


/*
** INITIAL TRANSITION:
** -------------------
*/

static short RTDS_controller_p_start_transition(RTDS_Proc * RTDS_instanceDescriptor)
  {
  RTDS_MSG_DATA_DECL
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  (RTDS_instanceDescriptor->myLocals.controller_p.door) = door_open;
  (RTDS_instanceDescriptor->myLocals.controller_p.prevPos) = 100.0;
  (RTDS_instanceDescriptor->myLocals.controller_p.currFloor) = floor_above;
  (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x = 100.0;
  (RTDS_instanceDescriptor->myLocals.controller_p.cmd).direction = up;
  (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = off;
  (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = on;
  (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_close;
  (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.forever = FALSE; (RTDS_instanceDescriptor->myLocals.controller_p.counter).present = Start_condition_forever;
  RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_stopped);
  return 0;
  }


/*
** FUNCTION RTDS_controller_p_continuousSignals:
** ---------------------------------------------
** Executes a transition for a continuous signal in process or procedure
*/

short RTDS_controller_p_continuousSignals(RTDS_Proc * RTDS_instanceDescriptor, int * lowestPriority)
  {
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  return 0;
  }

/*
** TRANSITION FOR STATE moving - INPUT Pulse:
** ------------------------------------------
*/

static short RTDS_controller_p_transition_moving_Pulse(RTDS_Proc * RTDS_instanceDescriptor)
  {
  RTDS_MSG_DATA_DECL
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  if ( !((RTDS_BOOLEAN)(( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_forever ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.forever == TRUE ) ) || ( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_nb_of_cycle ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle > 0 ) ))) )
    {
    RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_moving);
    return 0;
    }
  else if ( (RTDS_BOOLEAN)(( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_forever ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.forever == TRUE ) ) || ( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_nb_of_cycle ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle > 0 ) )) )
    {
    syncRI_Operate_lift(&((RTDS_instanceDescriptor->myLocals.controller_p.cmd)), &((RTDS_instanceDescriptor->myLocals.controller_p.sensors)));
    if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_nb_of_cycle) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle = (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle - 1; (RTDS_instanceDescriptor->myLocals.controller_p.counter).present = Start_condition_nb_of_cycle;
      }
    if ( !((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.sensors).floor_detected && ( (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x == (RTDS_instanceDescriptor->myLocals.controller_p.target_floor) ))) )
      {
      RTDS_MSG_SEND_position(      (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x);
      return 0;
      }
    else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.sensors).floor_detected && ( (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x == (RTDS_instanceDescriptor->myLocals.controller_p.target_floor) )) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = on;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = off;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_open;
      RTDS_MSG_SEND_floor_detected(      (RTDS_instanceDescriptor->myLocals.controller_p.target_floor));
      RTDS_MSG_SEND_position(      (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x);
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_stopped);
      return 0;
      }
    }
  }


/*
** TRANSITION FOR STATE * - INPUT Manual_Control:
** ----------------------------------------------
*/

static short RTDS_controller_p_star_state_transition_Manual_Control(RTDS_Proc * RTDS_instanceDescriptor)
  {
  RTDS_MSG_DATA_DECL
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  if ( RTDS_nextLabelId == 0 )
    {
    RTDS_MSG_RECEIVE_Manual_Control(  (RTDS_instanceDescriptor->myLocals.controller_p.cmd));
    }
  return 0;
  }


/*
** TRANSITION FOR STATE * - INPUT Start:
** -------------------------------------
*/

static short RTDS_controller_p_star_state_transition_Start(RTDS_Proc * RTDS_instanceDescriptor)
  {
  RTDS_MSG_DATA_DECL
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  if ( RTDS_nextLabelId == 0 )
    {
    RTDS_MSG_RECEIVE_Start(  (RTDS_instanceDescriptor->myLocals.controller_p.counter));
    }
  return 0;
  }


/*
** TRANSITION FOR STATE stopped - INPUT Pulse:
** -------------------------------------------
*/

static short RTDS_controller_p_transition_stopped_Pulse(RTDS_Proc * RTDS_instanceDescriptor)
  {
  RTDS_MSG_DATA_DECL
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  if ( !((RTDS_BOOLEAN)(( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_forever ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.forever == TRUE ) ) || ( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_nb_of_cycle ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle > 0 ) ))) )
    {
    return 0;
    }
  else if ( (RTDS_BOOLEAN)(( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_forever ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.forever == TRUE ) ) || ( ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_nb_of_cycle ) && ( (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle > 0 ) )) )
    {
    syncRI_Operate_lift(&((RTDS_instanceDescriptor->myLocals.controller_p.cmd)), &((RTDS_instanceDescriptor->myLocals.controller_p.sensors)));
    (RTDS_instanceDescriptor->myLocals.controller_p.door) = ( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.sensors).door_open == TRUE)) ? (door_open) : (door_close) );
    RTDS_MSG_SEND_door_status(    (RTDS_instanceDescriptor->myLocals.controller_p.door));
    if ( (RTDS_instanceDescriptor->myLocals.controller_p.sensors).floor_detected )
      {
      if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.cmd).direction == down) )
        {
        (RTDS_instanceDescriptor->myLocals.controller_p.currFloor) = ( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.currFloor) == floor_above)) ? (floor_5) : (( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.currFloor) == floor_5)) ? (floor_4) : (( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.currFloor) == floor_4)) ? (floor_3) : (( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.currFloor) == floor_3)) ? (floor_2) : (floor_1) )) )) )) );
        }
      else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.cmd).direction == up) )
        {
        (RTDS_instanceDescriptor->myLocals.controller_p.currFloor) = ( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.currFloor) == floor_1)) ? (floor_2) : (( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.currFloor) == floor_2)) ? (floor_3) : (( ((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.currFloor) == floor_3)) ? (floor_4) : (floor_5) )) )) );
        }
      RTDS_MSG_SEND_floor_detected(      (RTDS_instanceDescriptor->myLocals.controller_p.currFloor));
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_open;
      }
    RTDS_MSG_SEND_position(    (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x);
    (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.prevPos) == (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x);
    if ( !((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_nb_of_cycle)) )
      {
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_stopped);
      return 0;
      }
    else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.counter).present == Start_condition_nb_of_cycle) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle = (RTDS_instanceDescriptor->myLocals.controller_p.counter).__value.nb_of_cycle - 1; (RTDS_instanceDescriptor->myLocals.controller_p.counter).present = Start_condition_nb_of_cycle;
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_stopped);
      return 0;
      }
    }
  }


/*
** TRANSITION FOR STATE stopped - INPUT Floor_Command:
** ---------------------------------------------------
*/

static short RTDS_controller_p_transition_stopped_Floor_Command(RTDS_Proc * RTDS_instanceDescriptor)
  {
  RTDS_MSG_DATA_DECL
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  if ( RTDS_nextLabelId == 0 )
    {
    RTDS_MSG_RECEIVE_Floor_Command(  (RTDS_instanceDescriptor->myLocals.controller_p.floor_cmd));
    }
  if ( !((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x == 100.0)) )
    {
    (RTDS_instanceDescriptor->myLocals.controller_p.target_floor) = (RTDS_instanceDescriptor->myLocals.controller_p.floor_cmd).floor;
    if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.floor_cmd).floor < (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).direction = down;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = on;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = off;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_close;
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_moving);
      return 0;
      }
    else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.floor_cmd).floor == (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = off;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = on;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_open;
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_stopped);
      return 0;
      }
    else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.floor_cmd).floor > (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).direction = up;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = on;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = off;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_close;
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_moving);
      return 0;
      }
    }
  else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x == 100.0) )
    {
    return 0;
    }
  }


/*
** TRANSITION FOR STATE stopped - INPUT Cabin_Command:
** ---------------------------------------------------
*/

static short RTDS_controller_p_transition_stopped_Cabin_Command(RTDS_Proc * RTDS_instanceDescriptor)
  {
  RTDS_MSG_DATA_DECL
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  unsigned int RTDS_nextLabelId = RTDS_instanceDescriptor->RTDS_nextLabelId;
  if ( RTDS_nextLabelId == 0 )
    {
    RTDS_MSG_RECEIVE_Cabin_Command(  (RTDS_instanceDescriptor->myLocals.controller_p.cabin_cmd));
    }
  if ( !((RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x == 100.0)) )
    {
    (RTDS_instanceDescriptor->myLocals.controller_p.target_floor) = (RTDS_instanceDescriptor->myLocals.controller_p.cabin_cmd).__value.floor;
    if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.target_floor) < (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).direction = down;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = on;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = off;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_close;
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_moving);
      return 0;
      }
    else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.target_floor) > (RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x) )
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).direction = up;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = on;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = off;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_close;
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_moving);
      return 0;
      }
    else
      {
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).motor = off;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).brake = on;
      (RTDS_instanceDescriptor->myLocals.controller_p.cmd).door = door_open;
      RTDS_Proc_setSdlState(RTDS_instanceDescriptor, RTDS_state_stopped);
      return 0;
      }
    }
  else if ( (RTDS_BOOLEAN)((RTDS_instanceDescriptor->myLocals.controller_p.sensors).pos_x == 100.0) )
    {
    return 0;
    }
  }


/*
** FUNCTION RTDS_controller_p_executeTransition:
** ---------------------------------------------
** Entry point for all transitions in process or procedure
*/

short RTDS_controller_p_executeTransition(RTDS_Proc * RTDS_instanceDescriptor, RTDS_MessageHeader * currentMessage)
  {
  RTDS_GlobalProcessInfo * RTDS_currentContext = RTDS_instanceDescriptor->RTDS_currentContext;
  /* Remember previous state */
  RTDS_instanceDescriptor->RTDS_sdlStatePrev = RTDS_currentContext->sdlState;
  /* Remember message as current one */
  RTDS_currentContext->currentMessage = currentMessage;
  /* No message means start transition */
  if ( currentMessage == NULL )
    {
    return RTDS_controller_p_start_transition(RTDS_instanceDescriptor);
    }
  /* Standard double-switch for all other messages */
  else
    {
    if ( currentMessage->timerUniqueId != 0 )
      {
      RTDS_TIMER_CLEAN_UP(RTDS_currentContext);
      if ( RTDS_currentContext->currentMessage == NULL ) return 0;
      }
    RTDS_instanceDescriptor->RTDS_senderId = RTDS_currentContext->currentMessage->sender;
    switch(RTDS_currentContext->sdlState)
      {
      case RTDS_state_stopped:
      switch(RTDS_currentContext->currentMessage->messageNumber)
        {
        case RTDS_message_Cabin_Command: return RTDS_controller_p_transition_stopped_Cabin_Command(RTDS_instanceDescriptor);
        case RTDS_message_Floor_Command: return RTDS_controller_p_transition_stopped_Floor_Command(RTDS_instanceDescriptor);
        case RTDS_message_Pulse: return RTDS_controller_p_transition_stopped_Pulse(RTDS_instanceDescriptor);
        }
      break;
      case RTDS_state_moving:
      switch(RTDS_currentContext->currentMessage->messageNumber)
        {
        case RTDS_message_Pulse: return RTDS_controller_p_transition_moving_Pulse(RTDS_instanceDescriptor);
        }
      break;
      }
    switch(RTDS_currentContext->currentMessage->messageNumber)
      {
      case RTDS_message_Start:
      return RTDS_controller_p_star_state_transition_Start(RTDS_instanceDescriptor);
      break;
      case RTDS_message_Manual_Control:
      return RTDS_controller_p_star_state_transition_Manual_Control(RTDS_instanceDescriptor);
      break;
      }
    }
  return 0;
  }


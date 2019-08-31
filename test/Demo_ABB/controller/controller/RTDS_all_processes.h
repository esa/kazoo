#ifndef _RTDS_ALL_PROCESSES_H_
#define _RTDS_ALL_PROCESSES_H_

struct RTDS_MessageHeader;
struct RTDS_GlobalProcessInfo;

#include "RTDS_gen.h"
#include "controller_p_locals.h"

/*
** UNION RTDS_ProcessLocals:
** -------------------------
** Union of all struct types for processes local variables
*/

typedef union _RTDS_ProcessLocals
  {
  RTDS_Proc_controller_p_Locals controller_p;
  } RTDS_ProcessLocals;

/*
** UNION RTDS_MessageData:
** -----------------------
** Union of all transport structures for messages
*/

typedef union _RTDS_MessageData
  {
  RTDS_floor_detected_data floor_detected_data;
  RTDS_Manual_Control_data Manual_Control_data;
  RTDS_Pulse_data Pulse_data;
  RTDS_Start_data Start_data;
  RTDS_Cabin_Command_data Cabin_Command_data;
  RTDS_Floor_Command_data Floor_Command_data;
  RTDS_door_status_data door_status_data;
  RTDS_position_data position_data;
  } RTDS_MessageData;

#endif

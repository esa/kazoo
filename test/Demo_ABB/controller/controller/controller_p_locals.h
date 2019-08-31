#ifndef _RTDS_CONTROLLER_P_LOCALS_H_
#define _RTDS_CONTROLLER_P_LOCALS_H_

struct _RTDS_Proc_controller_p_Locals;
typedef struct _RTDS_Proc_controller_p_Locals RTDS_Proc_controller_p_Locals;

#include "RTDS_Common.h"

#include "RTDS_controller_project_messages.h"

#include "controller_p.h"

/*
** PROCESS controller_p:
** ---------------------
*/

struct _RTDS_Proc_controller_p_Locals
  {
  Lift_control cmd;
  Start_condition counter;
  Lift_sensor sensors;
  OpenClose door;
  Floor_button floor_cmd;
  Cabin_button cabin_cmd;
  Floors target_floor;
  Position prevPos;
  Floors currFloor;
  

  void * RTDS_myLocals[9];
  void ** RTDS_localsStack[1];

  };

#endif

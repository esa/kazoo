#include <limits.h>

#include "RTDS_Common.h"
#include "RTDS_CommonTypes.h"

#include "RTDSdataView.h"


int RTDS_Lift_sensor_cmp(Lift_sensor * v1, Lift_sensor * v2)
  {
  int cmp;
  cmp = (int)((v1->door_open) - (v2->door_open));
  if ( ((v1->door_open) != (v2->door_open)) && (cmp == 0) ) { cmp = (((v1->door_open) < (v2->door_open)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  cmp = (int)((v1->door_closed) - (v2->door_closed));
  if ( ((v1->door_closed) != (v2->door_closed)) && (cmp == 0) ) { cmp = (((v1->door_closed) < (v2->door_closed)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  cmp = (int)((v1->floor_detected) - (v2->floor_detected));
  if ( ((v1->floor_detected) != (v2->floor_detected)) && (cmp == 0) ) { cmp = (((v1->floor_detected) < (v2->floor_detected)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  cmp = (int)((v1->pos_x) - (v2->pos_x));
  if ( ((v1->pos_x) != (v2->pos_x)) && (cmp == 0) ) { cmp = (((v1->pos_x) < (v2->pos_x)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  return 0;
  }


int RTDS_Lift_control_cmp(Lift_control * v1, Lift_control * v2)
  {
  int cmp;
  cmp = (int)((v1->direction) - (v2->direction));
  if ( ((v1->direction) != (v2->direction)) && (cmp == 0) ) { cmp = (((v1->direction) < (v2->direction)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  cmp = (int)((v1->motor) - (v2->motor));
  if ( ((v1->motor) != (v2->motor)) && (cmp == 0) ) { cmp = (((v1->motor) < (v2->motor)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  cmp = (int)((v1->brake) - (v2->brake));
  if ( ((v1->brake) != (v2->brake)) && (cmp == 0) ) { cmp = (((v1->brake) < (v2->brake)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  cmp = (int)((v1->door) - (v2->door));
  if ( ((v1->door) != (v2->door)) && (cmp == 0) ) { cmp = (((v1->door) < (v2->door)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  return 0;
  }


int RTDS_Floor_button_cmp(Floor_button * v1, Floor_button * v2)
  {
  int cmp;
  cmp = (int)((v1->floor) - (v2->floor));
  if ( ((v1->floor) != (v2->floor)) && (cmp == 0) ) { cmp = (((v1->floor) < (v2->floor)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  cmp = (int)((v1->direction) - (v2->direction));
  if ( ((v1->direction) != (v2->direction)) && (cmp == 0) ) { cmp = (((v1->direction) < (v2->direction)) ? -1 : 1); }
  if (cmp != 0) return cmp;
  return 0;
  }


int RTDS_Start_condition_cmp(Start_condition * v1, Start_condition * v2)
  {
  int cmp;
  if (v1->present != v2->present) return INT_MAX;
  if (v1->present == Start_condition_forever )
    {
    cmp = (int)((v1->__value.forever) - (v2->__value.forever));
    if ( ((v1->__value.forever) != (v2->__value.forever)) && (cmp == 0) ) { cmp = (((v1->__value.forever) < (v2->__value.forever)) ? -1 : 1); }
return cmp;
    }
  else if (v1->present == Start_condition_nb_of_cycle )
    {
    cmp = (int)((v1->__value.nb_of_cycle) - (v2->__value.nb_of_cycle));
    if ( ((v1->__value.nb_of_cycle) != (v2->__value.nb_of_cycle)) && (cmp == 0) ) { cmp = (((v1->__value.nb_of_cycle) < (v2->__value.nb_of_cycle)) ? -1 : 1); }
return cmp;
    }
  return 0;
  }


int RTDS_Cabin_button_cmp(Cabin_button * v1, Cabin_button * v2)
  {
  int cmp;
  if (v1->present != v2->present) return INT_MAX;
  if (v1->present == Cabin_button_emergency_stop )
    {
    cmp = (int)((v1->__value.emergency_stop) - (v2->__value.emergency_stop));
    if ( ((v1->__value.emergency_stop) != (v2->__value.emergency_stop)) && (cmp == 0) ) { cmp = (((v1->__value.emergency_stop) < (v2->__value.emergency_stop)) ? -1 : 1); }
return cmp;
    }
  else if (v1->present == Cabin_button_floor )
    {
    cmp = (int)((v1->__value.floor) - (v2->__value.floor));
    if ( ((v1->__value.floor) != (v2->__value.floor)) && (cmp == 0) ) { cmp = (((v1->__value.floor) < (v2->__value.floor)) ? -1 : 1); }
return cmp;
    }
  return 0;
  }

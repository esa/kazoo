#ifndef _RTDSDATAVIEW_
#define _RTDSDATAVIEW_

#include "RTDS_CommonTypes.h"
#include "RTDS_String.h"
#include "RTDS_Set.h"
typedef enum _UpDown
  {
  down = 0,
  up = 1
  } UpDown;

typedef enum _OpenClose
  {
  door_close = 0,
  door_open = 1
  } OpenClose;

typedef RTDS_BOOLEAN Flag;

typedef enum _Floors
  {
  floor_0 = 10,
  floor_1 = 20,
  floor_2 = 30,
  floor_3 = 40,
  floor_4 = 50,
  floor_5 = 60,
  floor_above = 70
  } Floors;

#define RTDS_POSITION_MIN 0.0
#define RTDS_POSITION_MAX 100.0 + 1
typedef double Position;

typedef long long T_Int32;
typedef long long T_Int8;
typedef long long T_UInt8;
typedef long long T_UInt32;
typedef unsigned char T_Boolean;


#define RTDS__START_CONDITION__NB_OF_CYCLE_MIN 1
#define RTDS__START_CONDITION__NB_OF_CYCLE_MAX 255 + 1
typedef int _Start_condition__nb_of_cycle;

typedef enum _t_Cabin_button
  {
  Cabin_button_emergency_stop = 1,
  Cabin_button_floor
  } t_Cabin_button;

union _Cabin_button_choice
  {
  Flag emergency_stop;
  Floors floor;
  };

typedef struct _Cabin_button
  {
  t_Cabin_button present;
  union _Cabin_button_choice __value;
  } Cabin_button;

int RTDS_Cabin_button_cmp(Cabin_button *, Cabin_button *);

typedef enum _OnOff
  {
  off = 0,
  on = 1
  } OnOff;

typedef enum _t_Start_condition
  {
  Start_condition_forever = 1,
  Start_condition_nb_of_cycle
  } t_Start_condition;

union _Start_condition_choice
  {
  RTDS_BOOLEAN forever;
  _Start_condition__nb_of_cycle nb_of_cycle;
  };

typedef struct _Start_condition
  {
  t_Start_condition present;
  union _Start_condition_choice __value;
  } Start_condition;

int RTDS_Start_condition_cmp(Start_condition *, Start_condition *);

typedef struct _Lift_sensor
  {
  Flag door_open;
  Flag door_closed;
  Flag floor_detected;
  Position pos_x;
  } Lift_sensor;

int RTDS_Lift_sensor_cmp(Lift_sensor *, Lift_sensor *);

typedef struct _Floor_button
  {
  Floors floor;
  UpDown direction;
  } Floor_button;

int RTDS_Floor_button_cmp(Floor_button *, Floor_button *);

typedef struct _Lift_control
  {
  UpDown direction;
  OnOff motor;
  OnOff brake;
  OpenClose door;
  } Lift_control;

int RTDS_Lift_control_cmp(Lift_control *, Lift_control *);



#endif

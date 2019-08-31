/*
 * File: Operate_lift_types.h
 *
 * Real-Time Workshop code generated for Simulink model Operate_lift.
 *
 * Model version                        : 1.7
 * Real-Time Workshop file version      : 7.4  (R2009b)  29-Jun-2009
 * Real-Time Workshop file generated on : Wed Jun 29 09:22:33 2011
 * TLC version                          : 7.4 (Jul 14 2009)
 * C/C++ source code generated on       : Wed Jun 29 09:22:35 2011
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_Operate_lift_types_h_
#define RTW_HEADER_Operate_lift_types_h_
#include "rtwtypes.h"
#ifndef _DEFINED_TYPEDEF_FOR_Lift_control_
#define _DEFINED_TYPEDEF_FOR_Lift_control_

typedef struct {
  int32_T direction;
  int32_T motor;
  int32_T brake;
  int32_T door;
} Lift_control;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_Lift_sensor_
#define _DEFINED_TYPEDEF_FOR_Lift_sensor_

typedef struct {
  boolean_T door_open;
  boolean_T door_closed;
  boolean_T floor_detected;
  real_T pos_x;
} Lift_sensor;

#endif

/* Parameters (auto storage) */
typedef struct Parameters_Operate_lift_ Parameters_Operate_lift;

/* Forward declaration for rtModel */
typedef struct RT_MODEL_Operate_lift RT_MODEL_Operate_lift;

#endif                                 /* RTW_HEADER_Operate_lift_types_h_ */

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

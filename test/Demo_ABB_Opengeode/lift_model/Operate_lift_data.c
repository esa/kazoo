/*
 * File: Operate_lift_data.c
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

#include "Operate_lift.h"
#include "Operate_lift_private.h"

/* Block parameters (auto storage) */
Parameters_Operate_lift Operate_lift_P = {
  70.0,                                /* Expression: 70
                                        * Referenced by: '<S7>/Integrator1'
                                        */
  60.0,                                /* Expression: 60
                                        * Referenced by: '<S14>/Floor_5'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S25>/Switch'
                                        */
  50.0,                                /* Expression: 50
                                        * Referenced by: '<S14>/Floor_4'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S24>/Switch'
                                        */
  40.0,                                /* Expression: 40
                                        * Referenced by: '<S14>/Floor_3'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S23>/Switch'
                                        */
  30.0,                                /* Expression: 30
                                        * Referenced by: '<S14>/Floor_2'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S22>/Switch'
                                        */
  20.0,                                /* Expression: 20
                                        * Referenced by: '<S14>/Floor_1'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S21>/Switch'
                                        */
  10.0,                                /* Expression: 10
                                        * Referenced by: '<S14>/Floor_0'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S20>/Switch'
                                        */
  100.0,                               /* Expression: 100
                                        * Referenced by: '<S7>/m_cabin'
                                        */
  100.0,                               /* Expression: 100
                                        * Referenced by: '<S7>/m_load'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S7>/Integrator'
                                        */
  -2.0,                                /* Expression: -2
                                        * Referenced by: '<S7>/Dead Zone1'
                                        */
  3.0,                                 /* Expression: 3
                                        * Referenced by: '<S7>/Dead Zone1'
                                        */
  9.81,                                /* Expression: 9.81
                                        * Referenced by: '<S7>/g'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S10>/Integrator'
                                        */
  1.2,                                 /* Expression: 1.2
                                        * Referenced by: '<S10>/K_t'
                                        */
  2.0,                                 /* Expression: 2
                                        * Referenced by: '<S12>/i_gear'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S12>/r_drum [m]'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S7>/no brake'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S7>/x<0'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S7>/x>0'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S7>/No end stop'
                                        */
  200.0,                               /* Expression: 200
                                        * Referenced by: '<S7>/Gain1'
                                        */
  10000.0,                             /* Expression: 1e4
                                        * Referenced by: '<S7>/Saturation1'
                                        */
  -10000.0,                            /* Expression: -1e4
                                        * Referenced by: '<S7>/Saturation1'
                                        */
  200.0,                               /* Expression: 200
                                        * Referenced by: '<S2>/U_net'
                                        */
  -1.0,                                /* Expression: -1
                                        * Referenced by: '<S8>/Sign'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S13>/Off'
                                        */
  2.0,                                 /* Expression: 2
                                        * Referenced by: '<S11>/i_gear'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S11>/r_drum [m]'
                                        */
  -1.0,                                /* Expression: -1
                                        * Referenced by: '<S11>/Sign'
                                        */
  1.2,                                 /* Expression: 1.2
                                        * Referenced by: '<S10>/K_t1'
                                        */
  1.0714285714285714E-001,             /* Expression: 13.5/126
                                        * Referenced by: '<S10>/R_m'
                                        */
  100.0,                               /* Expression: 1/0.01
                                        * Referenced by: '<S10>/1//L_m'
                                        */
  1000.0,                              /* Expression: 1000
                                        * Referenced by: '<S7>/Spring stiffness'
                                        */
  1000.0,                              /* Expression: 1000
                                        * Referenced by: '<S7>/Damping'
                                        */
  1.0E+010,                            /* Expression: 1e10
                                        * Referenced by: '<S7>/Gain'
                                        */
  10000.0,                             /* Expression: 1e4
                                        * Referenced by: '<S7>/Saturation'
                                        */
  -10000.0,                            /* Expression: -1e4
                                        * Referenced by: '<S7>/Saturation'
                                        */
  0,                                   /* Computed Parameter: Memory_X0
                                        * Referenced by: '<S18>/Memory'
                                        */

  /*  Computed Parameter: Logic_table
   * Referenced by: '<S18>/Logic'
   */
  { 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 },
  0,                                   /* Computed Parameter: Constant1_Value
                                        * Referenced by: '<S25>/Constant1'
                                        */
  1,                                   /* Computed Parameter: Constant_Value
                                        * Referenced by: '<S25>/Constant'
                                        */
  0,                                   /* Computed Parameter: Constant1_Value_d
                                        * Referenced by: '<S24>/Constant1'
                                        */
  1,                                   /* Computed Parameter: Constant_Value_e
                                        * Referenced by: '<S24>/Constant'
                                        */
  0,                                   /* Computed Parameter: Constant1_Value_o
                                        * Referenced by: '<S23>/Constant1'
                                        */
  1,                                   /* Computed Parameter: Constant_Value_p
                                        * Referenced by: '<S23>/Constant'
                                        */
  0,                                   /* Computed Parameter: Constant1_Value_h
                                        * Referenced by: '<S22>/Constant1'
                                        */
  1,                                   /* Computed Parameter: Constant_Value_h
                                        * Referenced by: '<S22>/Constant'
                                        */
  0,                                   /* Computed Parameter: Constant1_Value_a
                                        * Referenced by: '<S21>/Constant1'
                                        */
  1,                                   /* Computed Parameter: Constant_Value_j
                                        * Referenced by: '<S21>/Constant'
                                        */
  0,                                   /* Computed Parameter: Constant1_Value_g
                                        * Referenced by: '<S20>/Constant1'
                                        */
  1,                                   /* Computed Parameter: Constant_Value_c
                                        * Referenced by: '<S20>/Constant'
                                        */
  0,                                   /* Computed Parameter: Memory_X0_b
                                        * Referenced by: '<S15>/Memory'
                                        */

  /*  Computed Parameter: Logic_table_h
   * Referenced by: '<S15>/Logic'
   */
  { 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 },
  0,                                   /* Computed Parameter: Memory_X0_f
                                        * Referenced by: '<S16>/Memory'
                                        */

  /*  Computed Parameter: Logic_table_m
   * Referenced by: '<S16>/Logic'
   */
  { 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 },
  0,                                   /* Computed Parameter: Memory_X0_j
                                        * Referenced by: '<S17>/Memory'
                                        */

  /*  Computed Parameter: Logic_table_d
   * Referenced by: '<S17>/Logic'
   */
  { 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 },
  0,                                   /* Computed Parameter: Memory_X0_d
                                        * Referenced by: '<S19>/Memory'
                                        */

  /*  Computed Parameter: Logic_table_g
   * Referenced by: '<S19>/Logic'
   */
  { 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 }
};

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

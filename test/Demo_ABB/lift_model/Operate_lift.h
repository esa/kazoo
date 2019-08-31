/*
 * File: Operate_lift.h
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

#ifndef RTW_HEADER_Operate_lift_h_
#define RTW_HEADER_Operate_lift_h_
#ifndef Operate_lift_COMMON_INCLUDES_
# define Operate_lift_COMMON_INCLUDES_
#include <math.h>
#include <string.h>
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "rt_zcfcn.h"
#include "rt_SATURATE.h"
#endif                                 /* Operate_lift_COMMON_INCLUDES_ */

#include "Operate_lift_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetStopRequested
# define rtmGetStopRequested(rtm)      ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
# define rtmSetStopRequested(rtm, val) ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
# define rtmGetStopRequestedPtr(rtm)   (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
# define rtmGetT(rtm)                  (rtmGetTPtr((rtm))[0])
#endif

/* Block signals (auto storage) */
typedef struct {
  real_T x;                            /* '<S7>/Integrator1' */
  real_T m_tot;                        /* '<S7>/Add' */
  real_T x_dot;                        /* '<S7>/Integrator' */
  real_T F_g;                          /* '<S7>/Product' */
  real_T totalgearing;                 /* '<S12>/Divide' */
  real_T x_dot_dot;                    /* '<S7>/Divide' */
  real_T Sign;                         /* '<S8>/Sign' */
  real_T Sign_n;                       /* '<S11>/Sign' */
  real_T L_m;                          /* '<S10>/1//L_m' */
  boolean_T Memory;                    /* '<S18>/Memory' */
  boolean_T Logic[2];                  /* '<S18>/Logic' */
  boolean_T Memory_k;                  /* '<S15>/Memory' */
  boolean_T Logic_l[2];                /* '<S15>/Logic' */
  boolean_T x0;                        /* '<S7>/x<0' */
  boolean_T x0_d;                      /* '<S7>/x>0' */
  boolean_T Logic_e[2];                /* '<S16>/Logic' */
  boolean_T Memory_j;                  /* '<S17>/Memory' */
  boolean_T Logic_a[2];                /* '<S17>/Logic' */
  boolean_T Memory_f;                  /* '<S19>/Memory' */
  boolean_T Logic_b[2];                /* '<S19>/Logic' */
} BlockIO_Operate_lift;

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  int_T x0_MODE;                       /* '<S7>/x<0' */
  int_T x0_MODE_j;                     /* '<S7>/x>0' */
  boolean_T Memory_PreviousInput;      /* '<S18>/Memory' */
  boolean_T Memory_PreviousInput_f;    /* '<S15>/Memory' */
  boolean_T Memory_PreviousInput_g;    /* '<S16>/Memory' */
  boolean_T Memory_PreviousInput_c;    /* '<S17>/Memory' */
  boolean_T Memory_PreviousInput_e;    /* '<S19>/Memory' */
} D_Work_Operate_lift;

/* Continuous states (auto storage) */
typedef struct {
  real_T Integrator1_CSTATE;           /* '<S7>/Integrator1' */
  real_T Integrator_CSTATE;            /* '<S7>/Integrator' */
  real_T Integrator_CSTATE_p;          /* '<S10>/Integrator' */
} ContinuousStates_Operate_lift;

/* State derivatives (auto storage) */
typedef struct {
  real_T Integrator1_CSTATE;           /* '<S7>/Integrator1' */
  real_T Integrator_CSTATE;            /* '<S7>/Integrator' */
  real_T Integrator_CSTATE_p;          /* '<S10>/Integrator' */
} StateDerivatives_Operate_lift;

/* State disabled  */
typedef struct {
  boolean_T Integrator1_CSTATE;        /* '<S7>/Integrator1' */
  boolean_T Integrator_CSTATE;         /* '<S7>/Integrator' */
  boolean_T Integrator_CSTATE_p;       /* '<S10>/Integrator' */
} StateDisabled_Operate_lift;

/* Zero-crossing (trigger) state */
typedef struct {
  ZCSigState x0_Input_ZCE;             /* '<S7>/x<0' */
  ZCSigState x0_Input_ZCE_m;           /* '<S7>/x>0' */
} PrevZCSigStates_Operate_lift;

#ifndef ODE3_INTG
#define ODE3_INTG

/* ODE3 Integration Data */
typedef struct {
  real_T *y;                           /* output */
  real_T *f[3];                        /* derivatives */
} ODE3_IntgData;

#endif

/* External inputs (root inport signals with auto storage) */
typedef struct {
  Lift_control lift_command;           /* '<Root>/lift_command' */
} ExternalInputs_Operate_lift;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  Lift_sensor lift_sensors;            /* '<Root>/lift_sensors' */
} ExternalOutputs_Operate_lift;

/* Parameters (auto storage) */
struct Parameters_Operate_lift_ {
  real_T Integrator1_IC;               /* Expression: 70
                                        * Referenced by: '<S7>/Integrator1'
                                        */
  real_T Floor_5_Value;                /* Expression: 60
                                        * Referenced by: '<S14>/Floor_5'
                                        */
  real_T Switch_Threshold;             /* Expression: 1
                                        * Referenced by: '<S25>/Switch'
                                        */
  real_T Floor_4_Value;                /* Expression: 50
                                        * Referenced by: '<S14>/Floor_4'
                                        */
  real_T Switch_Threshold_f;           /* Expression: 1
                                        * Referenced by: '<S24>/Switch'
                                        */
  real_T Floor_3_Value;                /* Expression: 40
                                        * Referenced by: '<S14>/Floor_3'
                                        */
  real_T Switch_Threshold_l;           /* Expression: 1
                                        * Referenced by: '<S23>/Switch'
                                        */
  real_T Floor_2_Value;                /* Expression: 30
                                        * Referenced by: '<S14>/Floor_2'
                                        */
  real_T Switch_Threshold_a;           /* Expression: 1
                                        * Referenced by: '<S22>/Switch'
                                        */
  real_T Floor_1_Value;                /* Expression: 20
                                        * Referenced by: '<S14>/Floor_1'
                                        */
  real_T Switch_Threshold_h;           /* Expression: 1
                                        * Referenced by: '<S21>/Switch'
                                        */
  real_T Floor_0_Value;                /* Expression: 10
                                        * Referenced by: '<S14>/Floor_0'
                                        */
  real_T Switch_Threshold_n;           /* Expression: 1
                                        * Referenced by: '<S20>/Switch'
                                        */
  real_T m_cabin_Value;                /* Expression: 100
                                        * Referenced by: '<S7>/m_cabin'
                                        */
  real_T m_load_Value;                 /* Expression: 100
                                        * Referenced by: '<S7>/m_load'
                                        */
  real_T Integrator_IC;                /* Expression: 0
                                        * Referenced by: '<S7>/Integrator'
                                        */
  real_T DeadZone1_Start;              /* Expression: -2
                                        * Referenced by: '<S7>/Dead Zone1'
                                        */
  real_T DeadZone1_End;                /* Expression: 3
                                        * Referenced by: '<S7>/Dead Zone1'
                                        */
  real_T g_Value;                      /* Expression: 9.81
                                        * Referenced by: '<S7>/g'
                                        */
  real_T Integrator_IC_g;              /* Expression: 0
                                        * Referenced by: '<S10>/Integrator'
                                        */
  real_T K_t_Gain;                     /* Expression: 1.2
                                        * Referenced by: '<S10>/K_t'
                                        */
  real_T i_gear_Value;                 /* Expression: 2
                                        * Referenced by: '<S12>/i_gear'
                                        */
  real_T r_drumm_Value;                /* Expression: 1
                                        * Referenced by: '<S12>/r_drum [m]'
                                        */
  real_T nobrake_Value;                /* Expression: 0
                                        * Referenced by: '<S7>/no brake'
                                        */
  real_T x0_Offset;                    /* Expression: 0
                                        * Referenced by: '<S7>/x<0'
                                        */
  real_T x0_Offset_p;                  /* Expression: 0
                                        * Referenced by: '<S7>/x>0'
                                        */
  real_T Noendstop_Value;              /* Expression: 0
                                        * Referenced by: '<S7>/No end stop'
                                        */
  real_T Gain1_Gain;                   /* Expression: 200
                                        * Referenced by: '<S7>/Gain1'
                                        */
  real_T Saturation1_UpperSat;         /* Expression: 1e4
                                        * Referenced by: '<S7>/Saturation1'
                                        */
  real_T Saturation1_LowerSat;         /* Expression: -1e4
                                        * Referenced by: '<S7>/Saturation1'
                                        */
  real_T U_net_Value;                  /* Expression: 200
                                        * Referenced by: '<S2>/U_net'
                                        */
  real_T Sign_Gain;                    /* Expression: -1
                                        * Referenced by: '<S8>/Sign'
                                        */
  real_T Off_Value;                    /* Expression: 0
                                        * Referenced by: '<S13>/Off'
                                        */
  real_T i_gear_Value_n;               /* Expression: 2
                                        * Referenced by: '<S11>/i_gear'
                                        */
  real_T r_drumm_Value_e;              /* Expression: 1
                                        * Referenced by: '<S11>/r_drum [m]'
                                        */
  real_T Sign_Gain_g;                  /* Expression: -1
                                        * Referenced by: '<S11>/Sign'
                                        */
  real_T K_t1_Gain;                    /* Expression: 1.2
                                        * Referenced by: '<S10>/K_t1'
                                        */
  real_T R_m_Gain;                     /* Expression: 13.5/126
                                        * Referenced by: '<S10>/R_m'
                                        */
  real_T L_m_Gain;                     /* Expression: 1/0.01
                                        * Referenced by: '<S10>/1//L_m'
                                        */
  real_T Springstiffness_Gain;         /* Expression: 1000
                                        * Referenced by: '<S7>/Spring stiffness'
                                        */
  real_T Damping_Gain;                 /* Expression: 1000
                                        * Referenced by: '<S7>/Damping'
                                        */
  real_T Gain_Gain;                    /* Expression: 1e10
                                        * Referenced by: '<S7>/Gain'
                                        */
  real_T Saturation_UpperSat;          /* Expression: 1e4
                                        * Referenced by: '<S7>/Saturation'
                                        */
  real_T Saturation_LowerSat;          /* Expression: -1e4
                                        * Referenced by: '<S7>/Saturation'
                                        */
  boolean_T Memory_X0;                 /* Computed Parameter: Memory_X0
                                        * Referenced by: '<S18>/Memory'
                                        */
  boolean_T Logic_table[16];           /* Computed Parameter: Logic_table
                                        * Referenced by: '<S18>/Logic'
                                        */
  boolean_T Constant1_Value;           /* Computed Parameter: Constant1_Value
                                        * Referenced by: '<S25>/Constant1'
                                        */
  boolean_T Constant_Value;            /* Computed Parameter: Constant_Value
                                        * Referenced by: '<S25>/Constant'
                                        */
  boolean_T Constant1_Value_d;         /* Computed Parameter: Constant1_Value_d
                                        * Referenced by: '<S24>/Constant1'
                                        */
  boolean_T Constant_Value_e;          /* Computed Parameter: Constant_Value_e
                                        * Referenced by: '<S24>/Constant'
                                        */
  boolean_T Constant1_Value_o;         /* Computed Parameter: Constant1_Value_o
                                        * Referenced by: '<S23>/Constant1'
                                        */
  boolean_T Constant_Value_p;          /* Computed Parameter: Constant_Value_p
                                        * Referenced by: '<S23>/Constant'
                                        */
  boolean_T Constant1_Value_h;         /* Computed Parameter: Constant1_Value_h
                                        * Referenced by: '<S22>/Constant1'
                                        */
  boolean_T Constant_Value_h;          /* Computed Parameter: Constant_Value_h
                                        * Referenced by: '<S22>/Constant'
                                        */
  boolean_T Constant1_Value_a;         /* Computed Parameter: Constant1_Value_a
                                        * Referenced by: '<S21>/Constant1'
                                        */
  boolean_T Constant_Value_j;          /* Computed Parameter: Constant_Value_j
                                        * Referenced by: '<S21>/Constant'
                                        */
  boolean_T Constant1_Value_g;         /* Computed Parameter: Constant1_Value_g
                                        * Referenced by: '<S20>/Constant1'
                                        */
  boolean_T Constant_Value_c;          /* Computed Parameter: Constant_Value_c
                                        * Referenced by: '<S20>/Constant'
                                        */
  boolean_T Memory_X0_b;               /* Computed Parameter: Memory_X0_b
                                        * Referenced by: '<S15>/Memory'
                                        */
  boolean_T Logic_table_h[16];         /* Computed Parameter: Logic_table_h
                                        * Referenced by: '<S15>/Logic'
                                        */
  boolean_T Memory_X0_f;               /* Computed Parameter: Memory_X0_f
                                        * Referenced by: '<S16>/Memory'
                                        */
  boolean_T Logic_table_m[16];         /* Computed Parameter: Logic_table_m
                                        * Referenced by: '<S16>/Logic'
                                        */
  boolean_T Memory_X0_j;               /* Computed Parameter: Memory_X0_j
                                        * Referenced by: '<S17>/Memory'
                                        */
  boolean_T Logic_table_d[16];         /* Computed Parameter: Logic_table_d
                                        * Referenced by: '<S17>/Logic'
                                        */
  boolean_T Memory_X0_d;               /* Computed Parameter: Memory_X0_d
                                        * Referenced by: '<S19>/Memory'
                                        */
  boolean_T Logic_table_g[16];         /* Computed Parameter: Logic_table_g
                                        * Referenced by: '<S19>/Logic'
                                        */
};

/* Real-time Model Data Structure */
struct RT_MODEL_Operate_lift {
  const char_T * volatile errorStatus;
  RTWSolverInfo solverInfo;

  /*
   * ModelData:
   * The following substructure contains information regarding
   * the data used in the model.
   */
  struct {
    real_T *contStates;
    real_T *derivs;
    boolean_T *contStateDisabled;
    boolean_T zCCacheNeedsReset;
    boolean_T derivCacheNeedsReset;
    boolean_T blkStateChange;
    real_T odeY[3];
    real_T odeF[3][3];
    ODE3_IntgData intgData;
  } ModelData;

  /*
   * Sizes:
   * The following substructure contains sizes information
   * for many of the model attributes such as inputs, outputs,
   * dwork, sample times, etc.
   */
  struct {
    int_T numContStates;
    int_T numSampTimes;
  } Sizes;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    uint32_T clockTick0;
    time_T stepSize0;
    uint32_T clockTick1;
    SimTimeStep simTimeStep;
    boolean_T stopRequestedFlag;
    time_T *t;
    time_T tArray[2];
  } Timing;
};

/* Block parameters (auto storage) */
extern Parameters_Operate_lift Operate_lift_P;

/* Block signals (auto storage) */
extern BlockIO_Operate_lift Operate_lift_B;

/* Continuous states (auto storage) */
extern ContinuousStates_Operate_lift Operate_lift_X;

/* Block states (auto storage) */
extern D_Work_Operate_lift Operate_lift_DWork;

/* External inputs (root inport signals with auto storage) */
extern ExternalInputs_Operate_lift Operate_lift_U;

/* External outputs (root outports fed by signals with auto storage) */
extern ExternalOutputs_Operate_lift Operate_lift_Y;

/* External data declarations for dependent source files */
extern Lift_control Operate_lift_rtZLift_control;/* Lift_control ground */
extern Lift_sensor Operate_lift_rtZLift_sensor;/* Lift_sensor ground */

/* Model entry point functions */
extern void Operate_lift_initialize(void);
extern void Operate_lift_step(void);
extern void Operate_lift_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Operate_lift *Operate_lift_M;

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : Operate_lift
 * '<S1>'   : Operate_lift/Interface_Out
 * '<S2>'   : Operate_lift/Lift Model1
 * '<S3>'   : Operate_lift/Interface_Out/Embedded MATLAB Function
 * '<S4>'   : Operate_lift/Interface_Out/Embedded MATLAB Function1
 * '<S5>'   : Operate_lift/Interface_Out/Embedded MATLAB Function2
 * '<S6>'   : Operate_lift/Interface_Out/Embedded MATLAB Function3
 * '<S7>'   : Operate_lift/Lift Model1/Cabin
 * '<S8>'   : Operate_lift/Lift Model1/Direction switch
 * '<S9>'   : Operate_lift/Lift Model1/Door controller
 * '<S10>'  : Operate_lift/Lift Model1/ElMotor
 * '<S11>'  : Operate_lift/Lift Model1/Gear transfer cabin --> motor
 * '<S12>'  : Operate_lift/Lift Model1/Gear transfer motor --> cabin
 * '<S13>'  : Operate_lift/Lift Model1/On//off controller
 * '<S14>'  : Operate_lift/Lift Model1/Shaft sensor
 * '<S15>'  : Operate_lift/Lift Model1/Cabin/S-R Flip-Flop
 * '<S16>'  : Operate_lift/Lift Model1/Cabin/S-R Flip-Flop1
 * '<S17>'  : Operate_lift/Lift Model1/Direction switch/S-R Flip-Flop
 * '<S18>'  : Operate_lift/Lift Model1/Door controller/S-R Flip-Flop
 * '<S19>'  : Operate_lift/Lift Model1/On//off controller/S-R Flip-Flop
 * '<S20>'  : Operate_lift/Lift Model1/Shaft sensor/Sensor_0
 * '<S21>'  : Operate_lift/Lift Model1/Shaft sensor/Sensor_1
 * '<S22>'  : Operate_lift/Lift Model1/Shaft sensor/Sensor_2
 * '<S23>'  : Operate_lift/Lift Model1/Shaft sensor/Sensor_3
 * '<S24>'  : Operate_lift/Lift Model1/Shaft sensor/Sensor_4
 * '<S25>'  : Operate_lift/Lift Model1/Shaft sensor/Sensor_5
 */
#endif                                 /* RTW_HEADER_Operate_lift_h_ */

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

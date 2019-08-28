/*
 * File: Add_Two_Params.h
 *
 * Real-Time Workshop code generated for Simulink model Add_Two_Params.
 *
 * Model version                        : 1.6
 * Real-Time Workshop file version      : 7.4  (R2009b)  29-Jun-2009
 * Real-Time Workshop file generated on : Tue Aug 30 16:58:21 2011
 * TLC version                          : 7.4 (Jul 14 2009)
 * C/C++ source code generated on       : Tue Aug 30 16:58:22 2011
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_Add_Two_Params_h_
#define RTW_HEADER_Add_Two_Params_h_
#ifndef Add_Two_Params_COMMON_INCLUDES_
# define Add_Two_Params_COMMON_INCLUDES_
#include <string.h>
#include "rtwtypes.h"
#endif                                 /* Add_Two_Params_COMMON_INCLUDES_ */

#include "Add_Two_Params_types.h"

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

/* External inputs (root inport signals with auto storage) */
typedef struct {
  MyInteger first_param;               /* '<Root>/first_param' */
  MyInteger second_param;              /* '<Root>/second_param' */
} ExternalInputs_Add_Two_Params;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  MyInteger result;                    /* '<Root>/result' */
} ExternalOutputs_Add_Two_Params;

/* Parameters (auto storage) */
struct Parameters_Add_Two_Params_ {
  real_T Constant_Value;               /* Expression: 100
                                        * Referenced by: '<Root>/Constant'
                                        */
  MyInteger Constant1_Value;           /* Computed Parameter: Constant1_Value
                                        * Referenced by: '<Root>/Constant1'
                                        */
};

/* Real-time Model Data Structure */
struct RT_MODEL_Add_Two_Params {
  const char_T * volatile errorStatus;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    boolean_T stopRequestedFlag;
  } Timing;
};

/* Block parameters (auto storage) */
extern Parameters_Add_Two_Params Add_Two_Params_P;

/* External inputs (root inport signals with auto storage) */
extern ExternalInputs_Add_Two_Params Add_Two_Params_U;

/* External outputs (root outports fed by signals with auto storage) */
extern ExternalOutputs_Add_Two_Params Add_Two_Params_Y;

/* Model entry point functions */
extern void Add_Two_Params_initialize(void);
extern void Add_Two_Params_step(void);
extern void Add_Two_Params_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Add_Two_Params *Add_Two_Params_M;

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
 * '<Root>' : Add_Two_Params
 */
#endif                                 /* RTW_HEADER_Add_Two_Params_h_ */

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

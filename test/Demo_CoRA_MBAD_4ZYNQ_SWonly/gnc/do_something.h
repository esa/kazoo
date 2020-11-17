/*
 * File: do_something.h
 *
 * Code generated for Simulink model 'do_something'.
 *
 * Model version                  : 1.2
 * Simulink Coder version         : 8.12 (R2017a) 16-Feb-2017
 * C/C++ source code generated on : Thu Jan 31 17:24:34 2019
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_do_something_h_
#define RTW_HEADER_do_something_h_
#include <string.h>
#include <stddef.h>
#ifndef do_something_COMMON_INCLUDES_
# define do_something_COMMON_INCLUDES_
#include "rtwtypes.h"
#endif                                 /* do_something_COMMON_INCLUDES_ */

#include "do_something_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

/* External inputs (root inport signals with auto storage) */
typedef struct {
  Seq3 inp1;                           /* '<Root>/inp1' */
  Seq3 inp2;                           /* '<Root>/inp2' */
  Seq4 inp3;                           /* '<Root>/inp3' */
  In_Nested innested;                  /* '<Root>/innested' */
} ExtU_do_something_T;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  Seqout outpu;                        /* '<Root>/outpu' */
  Out_Nested outnested;                /* '<Root>/outnested' */
} ExtY_do_something_T;

/* Real-time Model Data Structure */
struct tag_RTM_do_something_T {
  const char_T * volatile errorStatus;
};

/* External inputs (root inport signals with auto storage) */
extern ExtU_do_something_T do_something_U;

/* External outputs (root outports fed by signals with auto storage) */
extern ExtY_do_something_T do_something_Y;

/* Model entry point functions */
extern void do_something_initialize(void);
extern void do_something_step(void);
extern void do_something_terminate(void);

/* Real-time Model object */
extern RT_MODEL_do_something_T *const do_something_M;

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
 * '<Root>' : 'do_something'
 */
#endif                                 /* RTW_HEADER_do_something_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

/*
 * File: do_something.c
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

#include "do_something.h"
#include "do_something_private.h"

/* External inputs (root inport signals with auto storage) */
ExtU_do_something_T do_something_U;

/* External outputs (root outports fed by signals with auto storage) */
ExtY_do_something_T do_something_Y;

/* Real-time model */
RT_MODEL_do_something_T do_something_M_;
RT_MODEL_do_something_T *const do_something_M = &do_something_M_;

/* Model step function */
void do_something_step(void)
{
  int32_T rtb_Sum2;
  int32_T rtb_Sum2_idx_0;
  int32_T rtb_Sum2_idx_1;
  int32_T rtb_Sum2_idx_2;

  /* Sum: '<Root>/Sum2' incorporates:
   *  Gain: '<Root>/Gain2'
   *  Inport: '<Root>/innested'
   *  Inport: '<Root>/inp3'
   */
  rtb_Sum2 = 5 * do_something_U.inp3.element_data[0] +
    do_something_U.innested.inest_a.element_data[0];

  /* Outport: '<Root>/outpu' incorporates:
   *  Inport: '<Root>/inp3'
   *  SignalConversion: '<Root>/TmpSignal ConversionAtoutpu_Seqout_BusCreInport1'
   */
  do_something_Y.outpu.element_data[0] = do_something_U.inp3.element_data[0];
  do_something_Y.outpu.element_data[4] = rtb_Sum2;

  /* Sum: '<Root>/Sum2' incorporates:
   *  Gain: '<Root>/Gain2'
   *  Inport: '<Root>/innested'
   *  Inport: '<Root>/inp3'
   */
  rtb_Sum2_idx_0 = rtb_Sum2;
  rtb_Sum2 = 5 * do_something_U.inp3.element_data[1] +
    do_something_U.innested.inest_a.element_data[1];

  /* Outport: '<Root>/outpu' incorporates:
   *  Inport: '<Root>/inp3'
   *  SignalConversion: '<Root>/TmpSignal ConversionAtoutpu_Seqout_BusCreInport1'
   */
  do_something_Y.outpu.element_data[1] = do_something_U.inp3.element_data[1];
  do_something_Y.outpu.element_data[5] = rtb_Sum2;

  /* Sum: '<Root>/Sum2' incorporates:
   *  Gain: '<Root>/Gain2'
   *  Inport: '<Root>/innested'
   *  Inport: '<Root>/inp3'
   */
  rtb_Sum2_idx_1 = rtb_Sum2;
  rtb_Sum2 = 5 * do_something_U.inp3.element_data[2] +
    do_something_U.innested.inest_a.element_data[2];

  /* Outport: '<Root>/outpu' incorporates:
   *  Inport: '<Root>/inp3'
   *  SignalConversion: '<Root>/TmpSignal ConversionAtoutpu_Seqout_BusCreInport1'
   */
  do_something_Y.outpu.element_data[2] = do_something_U.inp3.element_data[2];
  do_something_Y.outpu.element_data[6] = rtb_Sum2;

  /* Sum: '<Root>/Sum2' incorporates:
   *  Gain: '<Root>/Gain2'
   *  Inport: '<Root>/innested'
   *  Inport: '<Root>/inp3'
   */
  rtb_Sum2_idx_2 = rtb_Sum2;
  rtb_Sum2 = 5 * do_something_U.inp3.element_data[3] +
    do_something_U.innested.inest_a.element_data[3];

  /* Outport: '<Root>/outpu' incorporates:
   *  Inport: '<Root>/inp3'
   *  SignalConversion: '<Root>/TmpSignal ConversionAtoutpu_Seqout_BusCreInport1'
   */
  do_something_Y.outpu.element_data[3] = do_something_U.inp3.element_data[3];
  do_something_Y.outpu.element_data[7] = rtb_Sum2;

  /* Outport: '<Root>/outnested' incorporates:
   *  Gain: '<Root>/Gain'
   *  Gain: '<Root>/Gain1'
   *  Inport: '<Root>/innested'
   *  Inport: '<Root>/inp1'
   *  Inport: '<Root>/inp2'
   *  SignalConversion: '<Root>/TmpSignal ConversionAtoutpu_Seqout_BusCre1Inport1'
   *  Sum: '<Root>/Sum'
   *  Sum: '<Root>/Sum1'
   */
  do_something_Y.outnested.onest_a.element_data[0] = (6 *
    do_something_U.inp1.element_data[0] + do_something_U.inp2.element_data[0]) +
    3 * do_something_U.innested.inest_b.element_data[0];
  do_something_Y.outnested.onest_a.element_data[1] = (6 *
    do_something_U.inp1.element_data[1] + do_something_U.inp2.element_data[1]) +
    3 * do_something_U.innested.inest_b.element_data[1];
  do_something_Y.outnested.onest_a.element_data[2] = (6 *
    do_something_U.inp1.element_data[2] + do_something_U.inp2.element_data[2]) +
    3 * do_something_U.innested.inest_b.element_data[2];
  do_something_Y.outnested.onest_a.element_data[3] = rtb_Sum2_idx_0;
  do_something_Y.outnested.onest_a.element_data[4] = rtb_Sum2_idx_1;
  do_something_Y.outnested.onest_a.element_data[5] = rtb_Sum2_idx_2;
  do_something_Y.outnested.onest_a.element_data[6] = rtb_Sum2;
}

/* Model initialize function */
void do_something_initialize(void)
{
  /* Registration code */

  /* initialize error status */
  rtmSetErrorStatus(do_something_M, (NULL));

  /* external inputs */
  (void)memset((void *)&do_something_U, 0, sizeof(ExtU_do_something_T));

  /* external outputs */
  (void) memset((void *)&do_something_Y, 0,
                sizeof(ExtY_do_something_T));
}

/* Model terminate function */
void do_something_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

/*
 * File: Add_Two_Params.c
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

#include "Add_Two_Params.h"
#include "Add_Two_Params_private.h"

/* External inputs (root inport signals with auto storage) */
ExternalInputs_Add_Two_Params Add_Two_Params_U;

/* External outputs (root outports fed by signals with auto storage) */
ExternalOutputs_Add_Two_Params Add_Two_Params_Y;

/* Real-time model */
RT_MODEL_Add_Two_Params Add_Two_Params_M_;
RT_MODEL_Add_Two_Params *Add_Two_Params_M = &Add_Two_Params_M_;

/* Model step function */
void Add_Two_Params_step(void)
{
  /* local block i/o variables */
  boolean_T rtb_RelationalOperator;

  /* Outport: '<Root>/result' incorporates:
   *  Constant: '<Root>/Constant1'
   */
  Add_Two_Params_Y.result = Add_Two_Params_P.Constant1_Value;

  /* RelationalOperator: '<Root>/Relational Operator' incorporates:
   *  Constant: '<Root>/Constant'
   *  Inport: '<Root>/first_param'
   *  Inport: '<Root>/second_param'
   *  Sum: '<Root>/Add'
   */
  rtb_RelationalOperator = ((real_T)(uint8_T)(uint32_T)
    (Add_Two_Params_U.first_param + Add_Two_Params_U.second_param) ==
    Add_Two_Params_P.Constant_Value);

  /* Stop: '<Root>/Stop Simulation' */
  if (rtb_RelationalOperator) {
    rtmSetStopRequested(Add_Two_Params_M, 1);
  }
}

/* Model initialize function */
void Add_Two_Params_initialize(void)
{
  /* Registration code */

  /* initialize real-time model */
  (void) memset((void *)Add_Two_Params_M,0,
                sizeof(RT_MODEL_Add_Two_Params));

  /* external inputs */
  (void) memset((void *)&Add_Two_Params_U, 0,
                sizeof(ExternalInputs_Add_Two_Params));

  /* external outputs */
  Add_Two_Params_Y.result = 0;
}

/* Model terminate function */
void Add_Two_Params_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

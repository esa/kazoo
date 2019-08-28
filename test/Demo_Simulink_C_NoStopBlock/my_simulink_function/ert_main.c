/*
 * File: ert_main.c
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

#include <stdio.h>                     /* This ert_main.c example uses printf/fflush */
#include "Add_Two_Params.h"            /* Model's header file */
#include "rtwtypes.h"                  /* MathWorks types */

static boolean_T OverrunFlag = 0;

/*
 * Associating rt_OneStep with a real-time clock or interrupt service routine
 * is what makes the generated code "real-time".  The function rt_OneStep is
 * always associated with the base rate of the model.  Subrates are managed
 * by the base rate from inside the generated code.  Enabling/disabling
 * interrupts and floating point context switches are target specific.  This
 * example code indicates where these should take place relative to executing
 * the generated code step function.  Overrun behavior should be tailored to
 * your application needs.  This example simply sets an error status in the
 * real-time model and returns from rt_OneStep.
 */
void rt_OneStep(void)
{
  /* Disable interrupts here */

  /* Check for overrun */
  if (OverrunFlag++) {
    rtmSetErrorStatus(Add_Two_Params_M, "Overrun");
    return;
  }

  /* Save FPU context here (if necessary) */
  /* Re-enable timer or interrupt here */
  /* Set model inputs here */

  /* Step the model */
  Add_Two_Params_step();

  /* Get model outputs here */

  /* Indicate task complete */
  OverrunFlag--;

  /* Disable interrupts here */
  /* Restore FPU context here (if necessary) */
  /* Enable interrupts here */
}

/*
 * The example "main" function illustrates what is required by your
 * application code to initialize, execute, and terminate the generated code.
 * Attaching rt_OneStep to a real-time clock is target specific.  This example
 * illustates how you do this relative to initializing the model.
 */
int_T main(int_T argc, const char_T *argv[])
{
  /* Initialize model */
  Add_Two_Params_initialize();

  /* Simulating the model step behavior (in non real-time) to
   *  simulate model behavior at stop time.
   */
  while ((rtmGetErrorStatus(Add_Two_Params_M) == (NULL)) && !rtmGetStopRequested
         (Add_Two_Params_M)) {
    rt_OneStep();
  }

  /* Disable rt_OneStep() here */

  /* Terminate model */
  Add_Two_Params_terminate();
  return 0;
}

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

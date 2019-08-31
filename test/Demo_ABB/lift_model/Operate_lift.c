/*
 * File: Operate_lift.c
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

/* Block signals (auto storage) */
BlockIO_Operate_lift Operate_lift_B;

/* Continuous states */
ContinuousStates_Operate_lift Operate_lift_X;

/* Block states (auto storage) */
D_Work_Operate_lift Operate_lift_DWork;

/* Previous zero-crossings (trigger) states */
PrevZCSigStates_Operate_lift Operate_lift_PrevZCSigState;

/* External inputs (root inport signals with auto storage) */
ExternalInputs_Operate_lift Operate_lift_U;

/* External outputs (root outports fed by signals with auto storage) */
ExternalOutputs_Operate_lift Operate_lift_Y;

/* Real-time model */
RT_MODEL_Operate_lift Operate_lift_M_;
RT_MODEL_Operate_lift *Operate_lift_M = &Operate_lift_M_;
Lift_control Operate_lift_rtZLift_control = {
  0,                                   /* direction */
  0,                                   /* motor */
  0,                                   /* brake */
  0                                    /* door */
} ;                                    /* Lift_control ground */

Lift_sensor Operate_lift_rtZLift_sensor = {
  FALSE,                               /* door_open */
  FALSE,                               /* door_closed */
  FALSE,                               /* floor_detected */
  0.0                                  /* pos_x */
} ;                                    /* Lift_sensor ground */

/*
 * This function updates continuous states using the ODE3 fixed-step
 * solver algorithm
 */
static void rt_ertODEUpdateContinuousStates(RTWSolverInfo *si )
{
  /* Solver Matrices */
  static const real_T rt_ODE3_A[3] = {
    1.0/2.0, 3.0/4.0, 1.0
  };

  static const real_T rt_ODE3_B[3][3] = {
    { 1.0/2.0, 0.0, 0.0 },

    { 0.0, 3.0/4.0, 0.0 },

    { 2.0/9.0, 1.0/3.0, 4.0/9.0 }
  };

  time_T t = rtsiGetT(si);
  time_T tnew = rtsiGetSolverStopTime(si);
  time_T h = rtsiGetStepSize(si);
  real_T *x = rtsiGetContStates(si);
  ODE3_IntgData *id = (ODE3_IntgData *)rtsiGetSolverData(si);
  real_T *y = id->y;
  real_T *f0 = id->f[0];
  real_T *f1 = id->f[1];
  real_T *f2 = id->f[2];
  real_T hB[3];
  int_T i;
  int_T nXc = 3;
  rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

  /* Save the state values at time t in y, we'll use x as ynew. */
  (void) memcpy(y,x,
                nXc*sizeof(real_T));

  /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
  /* f0 = f(t,y) */
  rtsiSetdX(si, f0);
  Operate_lift_derivatives();

  /* f(:,2) = feval(odefile, t + hA(1), y + f*hB(:,1), args(:)(*)); */
  hB[0] = h * rt_ODE3_B[0][0];
  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0]);
  }

  rtsiSetT(si, t + h*rt_ODE3_A[0]);
  rtsiSetdX(si, f1);
  Operate_lift_step();
  Operate_lift_derivatives();

  /* f(:,3) = feval(odefile, t + hA(2), y + f*hB(:,2), args(:)(*)); */
  for (i = 0; i <= 1; i++) {
    hB[i] = h * rt_ODE3_B[1][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1]);
  }

  rtsiSetT(si, t + h*rt_ODE3_A[1]);
  rtsiSetdX(si, f2);
  Operate_lift_step();
  Operate_lift_derivatives();

  /* tnew = t + hA(3);
     ynew = y + f*hB(:,3); */
  for (i = 0; i <= 2; i++) {
    hB[i] = h * rt_ODE3_B[2][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2]);
  }

  rtsiSetT(si, tnew);
  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/* Model step function */
void Operate_lift_step(void)
{
  /* local block i/o variables */
  real_T rtb_Gain1;
  boolean_T rtb_DoorOpen;
  boolean_T rtb_DoorClose;
  boolean_T rtb_Brake_On;
  boolean_T rtb_Brake_Off;
  boolean_T rtb_Motor_On;
  boolean_T rtb_Motor_Off;
  boolean_T rtb_LiftUp;
  boolean_T rtb_LiftDown;
  boolean_T rtb_Memory;
  if (rtmIsMajorTimeStep(Operate_lift_M)) {
    /* set solver stop time */
    rtsiSetSolverStopTime(&Operate_lift_M->solverInfo,
                          ((Operate_lift_M->Timing.clockTick0+1)*
      Operate_lift_M->Timing.stepSize0));
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep(Operate_lift_M)) {
    Operate_lift_M->Timing.t[0] = rtsiGetT(&Operate_lift_M->solverInfo);
  }

  {
    boolean_T rtb_LogicalOperator;
    boolean_T rtb_Switch_l;
    boolean_T rtb_Switch_k;
    boolean_T rtb_Switch_m;
    boolean_T rtb_Switch_o;
    boolean_T rtb_LogicalOperator_k;
    real_T rtb_Integrator;
    real_T rtb_Product;
    ZCEventType zcEvent;
    real_T rtb_Switch;
    real_T rtb_Gain;

    /* Embedded MATLAB: '<S1>/Embedded MATLAB Function3' incorporates:
     *  Inport: '<Root>/lift_command'
     */
    /* Embedded MATLAB Function 'Interface_Out/Embedded MATLAB Function3': '<S6>:1' */
    if (Operate_lift_U.lift_command.door == 0) {
      /* '<S6>:1:4' */
      /* '<S6>:1:5' */
      rtb_DoorOpen = false;

      /* '<S6>:1:6' */
      rtb_DoorClose = true;
    } else {
      /* '<S6>:1:8' */
      rtb_DoorOpen = true;

      /* '<S6>:1:9' */
      rtb_DoorClose = false;
    }

    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Memory: '<S18>/Memory' */
      Operate_lift_B.Memory = Operate_lift_DWork.Memory_PreviousInput;
    }

    /* CombinatorialLogic: '<S18>/Logic' */
    {
      uint_T rowidx= 0;

      /* Compute the truth table row index corresponding to the input */
      rowidx = (rowidx << 1) + (uint_T)(rtb_DoorOpen != 0);
      rowidx = (rowidx << 1) + (uint_T)(rtb_DoorClose != 0);
      rowidx = (rowidx << 1) + (uint_T)(Operate_lift_B.Memory != 0);

      /* Copy the appropriate row of the table into the block output vector */
      Operate_lift_B.Logic[0] = Operate_lift_P.Logic_table[rowidx];
      Operate_lift_B.Logic[1] = Operate_lift_P.Logic_table[rowidx + 8];
    }

    /* Integrator: '<S7>/Integrator1' */
    Operate_lift_B.x = Operate_lift_X.Integrator1_CSTATE;

    /* Sum: '<S25>/Subtract' incorporates:
     *  Constant: '<S14>/Floor_5'
     */
    rtb_Gain1 = Operate_lift_B.x - Operate_lift_P.Floor_5_Value;

    /* Switch: '<S25>/Switch' incorporates:
     *  Abs: '<S25>/Abs'
     *  Constant: '<S25>/Constant'
     *  Constant: '<S25>/Constant1'
     */
    if (fabs(rtb_Gain1) >= Operate_lift_P.Switch_Threshold) {
      rtb_LogicalOperator = Operate_lift_P.Constant1_Value;
    } else {
      rtb_LogicalOperator = Operate_lift_P.Constant_Value;
    }

    /* Sum: '<S24>/Subtract' incorporates:
     *  Constant: '<S14>/Floor_4'
     */
    rtb_Gain1 = Operate_lift_B.x - Operate_lift_P.Floor_4_Value;

    /* Switch: '<S24>/Switch' incorporates:
     *  Abs: '<S24>/Abs'
     *  Constant: '<S24>/Constant'
     *  Constant: '<S24>/Constant1'
     */
    if (fabs(rtb_Gain1) >= Operate_lift_P.Switch_Threshold_f) {
      rtb_Switch_l = Operate_lift_P.Constant1_Value_d;
    } else {
      rtb_Switch_l = Operate_lift_P.Constant_Value_e;
    }

    /* Sum: '<S23>/Subtract' incorporates:
     *  Constant: '<S14>/Floor_3'
     */
    rtb_Gain1 = Operate_lift_B.x - Operate_lift_P.Floor_3_Value;

    /* Switch: '<S23>/Switch' incorporates:
     *  Abs: '<S23>/Abs'
     *  Constant: '<S23>/Constant'
     *  Constant: '<S23>/Constant1'
     */
    if (fabs(rtb_Gain1) >= Operate_lift_P.Switch_Threshold_l) {
      rtb_Switch_k = Operate_lift_P.Constant1_Value_o;
    } else {
      rtb_Switch_k = Operate_lift_P.Constant_Value_p;
    }

    /* Sum: '<S22>/Subtract' incorporates:
     *  Constant: '<S14>/Floor_2'
     */
    rtb_Gain1 = Operate_lift_B.x - Operate_lift_P.Floor_2_Value;

    /* Switch: '<S22>/Switch' incorporates:
     *  Abs: '<S22>/Abs'
     *  Constant: '<S22>/Constant'
     *  Constant: '<S22>/Constant1'
     */
    if (fabs(rtb_Gain1) >= Operate_lift_P.Switch_Threshold_a) {
      rtb_Switch_m = Operate_lift_P.Constant1_Value_h;
    } else {
      rtb_Switch_m = Operate_lift_P.Constant_Value_h;
    }

    /* Sum: '<S21>/Subtract' incorporates:
     *  Constant: '<S14>/Floor_1'
     */
    rtb_Gain1 = Operate_lift_B.x - Operate_lift_P.Floor_1_Value;

    /* Switch: '<S21>/Switch' incorporates:
     *  Abs: '<S21>/Abs'
     *  Constant: '<S21>/Constant'
     *  Constant: '<S21>/Constant1'
     */
    if (fabs(rtb_Gain1) >= Operate_lift_P.Switch_Threshold_h) {
      rtb_Switch_o = Operate_lift_P.Constant1_Value_a;
    } else {
      rtb_Switch_o = Operate_lift_P.Constant_Value_j;
    }

    /* Sum: '<S20>/Subtract' incorporates:
     *  Constant: '<S14>/Floor_0'
     */
    rtb_Gain1 = Operate_lift_B.x - Operate_lift_P.Floor_0_Value;

    /* Switch: '<S20>/Switch' incorporates:
     *  Abs: '<S20>/Abs'
     *  Constant: '<S20>/Constant'
     *  Constant: '<S20>/Constant1'
     */
    if (fabs(rtb_Gain1) >= Operate_lift_P.Switch_Threshold_n) {
      rtb_LogicalOperator_k = Operate_lift_P.Constant1_Value_g;
    } else {
      rtb_LogicalOperator_k = Operate_lift_P.Constant_Value_c;
    }

    /* Logic: '<S14>/Logical Operator' */
    rtb_LogicalOperator = (rtb_LogicalOperator || rtb_Switch_l || rtb_Switch_k ||
      rtb_Switch_m || rtb_Switch_o || rtb_LogicalOperator_k);

    /* Logic: '<S9>/Logical Operator' */
    rtb_LogicalOperator_k = (Operate_lift_B.Logic[0] && rtb_LogicalOperator);

    /* Outport: '<Root>/lift_sensors' incorporates:
     *  BusCreator: '<Root>/BusConversion_InsertedFor_lift_sensors_at_inport_0'
     *  Logic: '<S9>/Logical Operator1'
     */
    Operate_lift_Y.lift_sensors.door_open = rtb_LogicalOperator_k;
    Operate_lift_Y.lift_sensors.door_closed = !rtb_LogicalOperator_k;
    Operate_lift_Y.lift_sensors.floor_detected = rtb_LogicalOperator;
    Operate_lift_Y.lift_sensors.pos_x = Operate_lift_B.x;

    /* Embedded MATLAB: '<S1>/Embedded MATLAB Function' incorporates:
     *  Inport: '<Root>/lift_command'
     */
    /* Embedded MATLAB Function 'Interface_Out/Embedded MATLAB Function': '<S3>:1' */
    if (Operate_lift_U.lift_command.direction == 0) {
      /* '<S3>:1:4' */
      /* '<S3>:1:5' */
      rtb_LiftUp = false;

      /* '<S3>:1:6' */
      rtb_LiftDown = true;
    } else {
      /* '<S3>:1:8' */
      rtb_LiftUp = true;

      /* '<S3>:1:9' */
      rtb_LiftDown = false;
    }

    /* Embedded MATLAB: '<S1>/Embedded MATLAB Function1' incorporates:
     *  Inport: '<Root>/lift_command'
     */
    /* Embedded MATLAB Function 'Interface_Out/Embedded MATLAB Function1': '<S4>:1' */
    if (Operate_lift_U.lift_command.motor == 0) {
      /* '<S4>:1:4' */
      /* '<S4>:1:5' */
      rtb_Motor_On = false;

      /* '<S4>:1:6' */
      rtb_Motor_Off = true;
    } else {
      /* '<S4>:1:8' */
      rtb_Motor_On = true;

      /* '<S4>:1:9' */
      rtb_Motor_Off = false;
    }

    /* Embedded MATLAB: '<S1>/Embedded MATLAB Function2' incorporates:
     *  Inport: '<Root>/lift_command'
     */
    /* Embedded MATLAB Function 'Interface_Out/Embedded MATLAB Function2': '<S5>:1' */
    if (Operate_lift_U.lift_command.brake == 0) {
      /* '<S5>:1:4' */
      /* '<S5>:1:5' */
      rtb_Brake_On = false;

      /* '<S5>:1:6' */
      rtb_Brake_Off = true;
    } else {
      /* '<S5>:1:8' */
      rtb_Brake_On = true;

      /* '<S5>:1:9' */
      rtb_Brake_Off = false;
    }

    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Sum: '<S7>/Add' incorporates:
       *  Constant: '<S7>/m_cabin'
       *  Constant: '<S7>/m_load'
       */
      Operate_lift_B.m_tot = Operate_lift_P.m_cabin_Value +
        Operate_lift_P.m_load_Value;
    }

    /* Integrator: '<S7>/Integrator' */
    Operate_lift_B.x_dot = Operate_lift_X.Integrator_CSTATE;

    /* DeadZone: '<S7>/Dead Zone1' */
    if (Operate_lift_B.x_dot >= Operate_lift_P.DeadZone1_End) {
      rtb_Gain1 = Operate_lift_B.x_dot - Operate_lift_P.DeadZone1_End;
    } else if (Operate_lift_B.x_dot > Operate_lift_P.DeadZone1_Start) {
      rtb_Gain1 = 0.0;
    } else {
      rtb_Gain1 = Operate_lift_B.x_dot - Operate_lift_P.DeadZone1_Start;
    }

    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Product: '<S7>/Product' incorporates:
       *  Constant: '<S7>/g'
       */
      Operate_lift_B.F_g = Operate_lift_B.m_tot * Operate_lift_P.g_Value;
    }

    /* Integrator: '<S10>/Integrator' */
    rtb_Integrator = Operate_lift_X.Integrator_CSTATE_p;
    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Product: '<S12>/Divide' incorporates:
       *  Constant: '<S12>/i_gear'
       *  Constant: '<S12>/r_drum [m]'
       */
      Operate_lift_B.totalgearing = Operate_lift_P.i_gear_Value /
        Operate_lift_P.r_drumm_Value;
    }

    /* Product: '<S12>/Product' incorporates:
     *  Gain: '<S10>/K_t'
     */
    rtb_Product = Operate_lift_P.K_t_Gain * Operate_lift_X.Integrator_CSTATE_p *
      Operate_lift_B.totalgearing;
    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Memory: '<S15>/Memory' */
      Operate_lift_B.Memory_k = Operate_lift_DWork.Memory_PreviousInput_f;
    }

    /* CombinatorialLogic: '<S15>/Logic' */
    {
      uint_T rowidx= 0;

      /* Compute the truth table row index corresponding to the input */
      rowidx = (rowidx << 1) + (uint_T)(rtb_Brake_On != 0);
      rowidx = (rowidx << 1) + (uint_T)(rtb_Brake_Off != 0);
      rowidx = (rowidx << 1) + (uint_T)(Operate_lift_B.Memory_k != 0);

      /* Copy the appropriate row of the table into the block output vector */
      Operate_lift_B.Logic_l[0] = Operate_lift_P.Logic_table_h[rowidx];
      Operate_lift_B.Logic_l[1] = Operate_lift_P.Logic_table_h[rowidx + 8];
    }

    /* Switch: '<S7>/Switch' incorporates:
     *  Constant: '<S7>/no brake'
     *  Saturate: '<S7>/Saturation'
     */
    if (Operate_lift_B.Logic_l[1]) {
      rtb_Gain = Operate_lift_P.nobrake_Value;
    } else {
      /* Gain: '<S7>/Gain' */
      rtb_Gain = Operate_lift_P.Gain_Gain * Operate_lift_B.x_dot;
      rtb_Gain = rt_SATURATE(rtb_Gain, Operate_lift_P.Saturation_LowerSat,
        Operate_lift_P.Saturation_UpperSat);
    }

    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* HitCross: '<S7>/x<0' */
      zcEvent = rt_ZCFcn(FALLING_ZERO_CROSSING,
                         &Operate_lift_PrevZCSigState.x0_Input_ZCE,
                         (Operate_lift_B.x - Operate_lift_P.x0_Offset));
      if (Operate_lift_DWork.x0_MODE == 0) {
        if (zcEvent != NO_ZCEVENT) {
          Operate_lift_B.x0 = ((Operate_lift_B.x0 == 1 ? 0 : 1) != 0);
          Operate_lift_DWork.x0_MODE = 1;
        } else {
          if ((Operate_lift_B.x0 == 1) && (Operate_lift_B.x !=
               Operate_lift_P.x0_Offset)) {
            Operate_lift_B.x0 = false;
          }
        }
      } else {
        if (Operate_lift_B.x != Operate_lift_P.x0_Offset) {
          Operate_lift_B.x0 = false;
        }

        Operate_lift_DWork.x0_MODE = 0;
      }

      /* HitCross: '<S7>/x>0' */
      zcEvent = rt_ZCFcn(RISING_ZERO_CROSSING,
                         &Operate_lift_PrevZCSigState.x0_Input_ZCE_m,
                         (Operate_lift_B.x - Operate_lift_P.x0_Offset_p));
      if (Operate_lift_DWork.x0_MODE_j == 0) {
        if (zcEvent != NO_ZCEVENT) {
          Operate_lift_B.x0_d = ((Operate_lift_B.x0_d == 1 ? 0 : 1) != 0);
          Operate_lift_DWork.x0_MODE_j = 1;
        } else {
          if ((Operate_lift_B.x0_d == 1) && (Operate_lift_B.x !=
               Operate_lift_P.x0_Offset_p)) {
            Operate_lift_B.x0_d = false;
          }
        }
      } else {
        if (Operate_lift_B.x != Operate_lift_P.x0_Offset_p) {
          Operate_lift_B.x0_d = false;
        }

        Operate_lift_DWork.x0_MODE_j = 0;
      }

      /* Memory: '<S16>/Memory' */
      rtb_Memory = Operate_lift_DWork.Memory_PreviousInput_g;

      /* CombinatorialLogic: '<S16>/Logic' */
      {
        uint_T rowidx= 0;

        /* Compute the truth table row index corresponding to the input */
        rowidx = (rowidx << 1) + (uint_T)(Operate_lift_B.x0 != 0);
        rowidx = (rowidx << 1) + (uint_T)(Operate_lift_B.x0_d != 0);
        rowidx = (rowidx << 1) + (uint_T)(rtb_Memory != 0);

        /* Copy the appropriate row of the table into the block output vector */
        Operate_lift_B.Logic_e[0] = Operate_lift_P.Logic_table_m[rowidx];
        Operate_lift_B.Logic_e[1] = Operate_lift_P.Logic_table_m[rowidx + 8];
      }
    }

    /* Switch: '<S7>/Switch1' incorporates:
     *  Constant: '<S7>/No end stop'
     *  Gain: '<S7>/Damping'
     *  Gain: '<S7>/Spring stiffness'
     *  Sum: '<S7>/F_endstop'
     */
    if (Operate_lift_B.Logic_e[0]) {
      rtb_Switch = Operate_lift_P.Damping_Gain * Operate_lift_B.x_dot +
        Operate_lift_P.Springstiffness_Gain * Operate_lift_B.x;
    } else {
      rtb_Switch = Operate_lift_P.Noendstop_Value;
    }

    /* Gain: '<S7>/Gain1' */
    rtb_Gain1 *= Operate_lift_P.Gain1_Gain;

    /* Product: '<S7>/Divide' incorporates:
     *  Saturate: '<S7>/Saturation1'
     *  Sum: '<S7>/F_sum'
     */
    Operate_lift_B.x_dot_dot = ((((rtb_Product - Operate_lift_B.F_g) - rtb_Gain)
      - rtb_Switch) - rt_SATURATE(rtb_Gain1, Operate_lift_P.Saturation1_LowerSat,
      Operate_lift_P.Saturation1_UpperSat)) * (1.0 / Operate_lift_B.m_tot);
    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Memory: '<S17>/Memory' */
      Operate_lift_B.Memory_j = Operate_lift_DWork.Memory_PreviousInput_c;
    }

    /* CombinatorialLogic: '<S17>/Logic' */
    {
      uint_T rowidx= 0;

      /* Compute the truth table row index corresponding to the input */
      rowidx = (rowidx << 1) + (uint_T)(rtb_LiftUp != 0);
      rowidx = (rowidx << 1) + (uint_T)(rtb_LiftDown != 0);
      rowidx = (rowidx << 1) + (uint_T)(Operate_lift_B.Memory_j != 0);

      /* Copy the appropriate row of the table into the block output vector */
      Operate_lift_B.Logic_a[0] = Operate_lift_P.Logic_table_d[rowidx];
      Operate_lift_B.Logic_a[1] = Operate_lift_P.Logic_table_d[rowidx + 8];
    }

    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Gain: '<S8>/Sign' incorporates:
       *  Constant: '<S2>/U_net'
       */
      Operate_lift_B.Sign = Operate_lift_P.Sign_Gain *
        Operate_lift_P.U_net_Value;

      /* Memory: '<S19>/Memory' */
      Operate_lift_B.Memory_f = Operate_lift_DWork.Memory_PreviousInput_e;
    }

    /* CombinatorialLogic: '<S19>/Logic' */
    {
      uint_T rowidx= 0;

      /* Compute the truth table row index corresponding to the input */
      rowidx = (rowidx << 1) + (uint_T)(rtb_Motor_On != 0);
      rowidx = (rowidx << 1) + (uint_T)(rtb_Motor_Off != 0);
      rowidx = (rowidx << 1) + (uint_T)(Operate_lift_B.Memory_f != 0);

      /* Copy the appropriate row of the table into the block output vector */
      Operate_lift_B.Logic_b[0] = Operate_lift_P.Logic_table_g[rowidx];
      Operate_lift_B.Logic_b[1] = Operate_lift_P.Logic_table_g[rowidx + 8];
    }

    /* Switch: '<S13>/Switch' incorporates:
     *  Constant: '<S13>/Off'
     */
    if (Operate_lift_B.Logic_b[0]) {
      /* Switch: '<S8>/Switch' incorporates:
       *  Constant: '<S2>/U_net'
       */
      if (Operate_lift_B.Logic_a[0]) {
        rtb_Switch = Operate_lift_P.U_net_Value;
      } else {
        rtb_Switch = Operate_lift_B.Sign;
      }
    } else {
      rtb_Switch = Operate_lift_P.Off_Value;
    }

    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Gain: '<S11>/Sign' incorporates:
       *  Constant: '<S11>/i_gear'
       *  Constant: '<S11>/r_drum [m]'
       *  Product: '<S11>/Divide'
       */
      Operate_lift_B.Sign_n = Operate_lift_P.i_gear_Value_n /
        Operate_lift_P.r_drumm_Value_e * Operate_lift_P.Sign_Gain_g;
    }

    /* Gain: '<S10>/1//L_m' incorporates:
     *  Gain: '<S10>/K_t1'
     *  Gain: '<S10>/R_m'
     *  Product: '<S11>/Product'
     *  Sum: '<S10>/Subtract'
     */
    Operate_lift_B.L_m = ((rtb_Switch - Operate_lift_B.x_dot *
      Operate_lift_B.Sign_n * Operate_lift_P.K_t1_Gain) -
                          Operate_lift_P.R_m_Gain * rtb_Integrator) *
      Operate_lift_P.L_m_Gain;
  }

  if (rtmIsMajorTimeStep(Operate_lift_M)) {
    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Update for Memory: '<S18>/Memory' */
      Operate_lift_DWork.Memory_PreviousInput = Operate_lift_B.Logic[0];

      /* Update for Memory: '<S15>/Memory' */
      Operate_lift_DWork.Memory_PreviousInput_f = Operate_lift_B.Logic_l[0];

      /* Update for Memory: '<S16>/Memory' */
      Operate_lift_DWork.Memory_PreviousInput_g = Operate_lift_B.Logic_e[0];

      /* Update for Memory: '<S17>/Memory' */
      Operate_lift_DWork.Memory_PreviousInput_c = Operate_lift_B.Logic_a[0];

      /* Update for Memory: '<S19>/Memory' */
      Operate_lift_DWork.Memory_PreviousInput_e = Operate_lift_B.Logic_b[0];
    }
  }                                    /* end MajorTimeStep */

  if (rtmIsMajorTimeStep(Operate_lift_M)) {
    rt_ertODEUpdateContinuousStates(&Operate_lift_M->solverInfo);

    /* Update absolute time for base rate */
    /* The "clockTick0" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick0"
     * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
     * overflow during the application lifespan selected.
     */
    ++Operate_lift_M->Timing.clockTick0;
    Operate_lift_M->Timing.t[0] = rtsiGetSolverStopTime
      (&Operate_lift_M->solverInfo);
    if (rtmIsMajorTimeStep(Operate_lift_M)) {
      /* Update absolute timer for sample time: [0.01s, 0.0s] */
      /* The "clockTick1" counts the number of times the code of this task has
       * been executed. The resolution of this integer timer is 0.01, which is the step size
       * of the task. Size of "clockTick1" ensures timer will not overflow during the
       * application lifespan selected.
       */
      Operate_lift_M->Timing.clockTick1++;
    }
  }                                    /* end MajorTimeStep */

  /* tid is required for a uniform function interface.
   * Argument tid is not used in the function. */
}

/* Derivatives for root system: '<Root>' */
void Operate_lift_derivatives(void)
{
  /* Derivatives for Integrator: '<S7>/Integrator1' */
  ((StateDerivatives_Operate_lift *) Operate_lift_M->ModelData.derivs)
    ->Integrator1_CSTATE = Operate_lift_B.x_dot;

  /* Derivatives for Integrator: '<S7>/Integrator' */
  ((StateDerivatives_Operate_lift *) Operate_lift_M->ModelData.derivs)
    ->Integrator_CSTATE = Operate_lift_B.x_dot_dot;

  /* Derivatives for Integrator: '<S10>/Integrator' */
  ((StateDerivatives_Operate_lift *) Operate_lift_M->ModelData.derivs)
    ->Integrator_CSTATE_p = Operate_lift_B.L_m;
}

/* Model initialize function */
void Operate_lift_initialize(void)
{
  /* Registration code */

  /* initialize real-time model */
  (void) memset((void *)Operate_lift_M,0,
                sizeof(RT_MODEL_Operate_lift));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&Operate_lift_M->solverInfo,
                          &Operate_lift_M->Timing.simTimeStep);
    rtsiSetTPtr(&Operate_lift_M->solverInfo, &rtmGetTPtr(Operate_lift_M));
    rtsiSetStepSizePtr(&Operate_lift_M->solverInfo,
                       &Operate_lift_M->Timing.stepSize0);
    rtsiSetdXPtr(&Operate_lift_M->solverInfo, &Operate_lift_M->ModelData.derivs);
    rtsiSetContStatesPtr(&Operate_lift_M->solverInfo,
                         &Operate_lift_M->ModelData.contStates);
    rtsiSetNumContStatesPtr(&Operate_lift_M->solverInfo,
      &Operate_lift_M->Sizes.numContStates);
    rtsiSetErrorStatusPtr(&Operate_lift_M->solverInfo, ((const char_T **)
      (&rtmGetErrorStatus(Operate_lift_M))));
    rtsiSetRTModelPtr(&Operate_lift_M->solverInfo, Operate_lift_M);
  }

  rtsiSetSimTimeStep(&Operate_lift_M->solverInfo, MAJOR_TIME_STEP);
  Operate_lift_M->ModelData.intgData.y = Operate_lift_M->ModelData.odeY;
  Operate_lift_M->ModelData.intgData.f[0] = Operate_lift_M->ModelData.odeF[0];
  Operate_lift_M->ModelData.intgData.f[1] = Operate_lift_M->ModelData.odeF[1];
  Operate_lift_M->ModelData.intgData.f[2] = Operate_lift_M->ModelData.odeF[2];
  Operate_lift_M->ModelData.contStates = ((real_T *) &Operate_lift_X);
  rtsiSetSolverData(&Operate_lift_M->solverInfo, (void *)
                    &Operate_lift_M->ModelData.intgData);
  rtsiSetSolverName(&Operate_lift_M->solverInfo,"ode3");
  rtmSetTPtr(Operate_lift_M, &Operate_lift_M->Timing.tArray[0]);
  Operate_lift_M->Timing.stepSize0 = 0.01;

  /* block I/O */
  (void) memset(((void *) &Operate_lift_B),0,
                sizeof(BlockIO_Operate_lift));

  /* states (continuous) */
  {
    (void) memset((void *)&Operate_lift_X,0,
                  sizeof(ContinuousStates_Operate_lift));
  }

  /* states (dwork) */
  (void) memset((void *)&Operate_lift_DWork, 0,
                sizeof(D_Work_Operate_lift));

  /* external inputs */
  Operate_lift_U.lift_command = Operate_lift_rtZLift_control;

  /* external outputs */
  Operate_lift_Y.lift_sensors = Operate_lift_rtZLift_sensor;
  Operate_lift_PrevZCSigState.x0_Input_ZCE = UNINITIALIZED_ZCSIG;
  Operate_lift_PrevZCSigState.x0_Input_ZCE_m = UNINITIALIZED_ZCSIG;

  /* InitializeConditions for Memory: '<S18>/Memory' */
  Operate_lift_DWork.Memory_PreviousInput = Operate_lift_P.Memory_X0;

  /* InitializeConditions for Integrator: '<S7>/Integrator1' */
  Operate_lift_X.Integrator1_CSTATE = Operate_lift_P.Integrator1_IC;

  /* InitializeConditions for Integrator: '<S7>/Integrator' */
  Operate_lift_X.Integrator_CSTATE = Operate_lift_P.Integrator_IC;

  /* InitializeConditions for Integrator: '<S10>/Integrator' */
  Operate_lift_X.Integrator_CSTATE_p = Operate_lift_P.Integrator_IC_g;

  /* InitializeConditions for Memory: '<S15>/Memory' */
  Operate_lift_DWork.Memory_PreviousInput_f = Operate_lift_P.Memory_X0_b;

  /* InitializeConditions for Memory: '<S16>/Memory' */
  Operate_lift_DWork.Memory_PreviousInput_g = Operate_lift_P.Memory_X0_f;

  /* InitializeConditions for Memory: '<S17>/Memory' */
  Operate_lift_DWork.Memory_PreviousInput_c = Operate_lift_P.Memory_X0_j;

  /* InitializeConditions for Memory: '<S19>/Memory' */
  Operate_lift_DWork.Memory_PreviousInput_e = Operate_lift_P.Memory_X0_d;
}

/* Model terminate function */
void Operate_lift_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

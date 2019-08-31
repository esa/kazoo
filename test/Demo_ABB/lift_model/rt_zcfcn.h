/*
 * File: rt_zcfcn.h
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

#ifndef RTW_HEADER_rt_zcfcn_h_
#define RTW_HEADER_rt_zcfcn_h_
#include "rtwtypes.h"
#include "solver_zc.h"
#ifndef slZcHadEvent
#define slZcHadEvent(ev, zcsDir)       (((ev) & (zcsDir)) != 0x00 )
#endif

#ifndef slZcUnAliasEvents
#define slZcUnAliasEvents(evL, evR)    ((((slZcHadEvent((evL), (SL_ZCS_EVENT_N2Z)) && slZcHadEvent((evR), (SL_ZCS_EVENT_Z2P))) || (slZcHadEvent((evL), (SL_ZCS_EVENT_P2Z)) && slZcHadEvent((evR), (SL_ZCS_EVENT_Z2N)))) ? (SL_ZCS_EVENT_NUL) : (evR)))
#endif

extern ZCEventType rt_ZCFcn(ZCDirection zcDir, ZCSigState *prevZc, real_T
  currValue);

#endif                                 /* RTW_HEADER_rt_zcfcn_h_ */

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

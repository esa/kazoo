#ifndef _CONTROLLER_H_
#define _CONTROLLER_H_

#include "RTDS_Common.h"
#include "RTDS_CommonTypes.h"
#include "RTDS_String.h"
#include "RTDS_Set.h"
#include "RTDSdataView.h"


#ifdef __cplusplus
extern "C" {
#endif
extern void syncRI_Operate_lift(Lift_control * lift_command, Lift_sensor * lift_sensors);
#ifdef __cplusplus
}
#endif


#endif

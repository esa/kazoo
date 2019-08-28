/*
 * Copyright 1994-2004 The MathWorks, Inc.
 *
 * File: ertformat.h     $Revision: 1.17.4.2 $
 *
 * Abstract:
 *   Obsolete Real-Time Workshop Embedded Coder header file.
 *
 * Note:
 *   The file ertformat.h will be obsoleted in a future release.  To
 *   break your dependence on this file, include the file rtwtypes.h
 *   in your C-code, and change all occurrences of 
 *   ssGet(Set)ErrorStatus to rtmGet(Set)ErrorStatus.
 */

#ifndef __ERTFORMAT__
#define __ERTFORMAT__

#include "rtwtypes.h"

#define ssGetErrorStatus rtmGetErrorStatus
#define ssSetErrorStatus rtmSetErrorStatus

#endif /* __ERTFORMAT__ */

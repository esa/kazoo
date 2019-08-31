#if defined(_MSC_VER) || __GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ > 3)
#pragma once
#endif

#ifndef mwmathutil_h
#define mwmathutil_h

/* Copyright 2003-2008 The MathWorks, Inc. */

/* Only define EXTERN_C if it hasn't been defined already. This allows
 * individual modules to have more control over managing their exports.
 */
#ifndef EXTERN_C

#ifdef __cplusplus
  #define EXTERN_C extern "C"
#else
  #define EXTERN_C extern
#endif

#endif

#include "tmwtypes.h"


/* abs(a) */
EXTERN_C double muDoubleScalarAbs(double a);


/* ceil(a) */
EXTERN_C double muDoubleScalarCeil(double a);


/* floor(a) */
EXTERN_C double muDoubleScalarFloor(double a);


/* round(a) */
EXTERN_C double muDoubleScalarRound(double a);


/* acos(a) */
EXTERN_C double muDoubleScalarAcos(double a);


/* acosh(a) */
EXTERN_C double muDoubleScalarAcosh(double a);


/* asin(a) */
EXTERN_C double muDoubleScalarAsin(double a);


/* asinh(a) */
EXTERN_C double muDoubleScalarAsinh(double a);


/* atan(a) */
EXTERN_C double muDoubleScalarAtan(double a);


/* atanh(a) */
EXTERN_C double muDoubleScalarAtanh(double a);


/* cos(a) */
EXTERN_C double muDoubleScalarCos(double a);


/* cosh(a) */
EXTERN_C double muDoubleScalarCosh(double a);


/* exp(a) */	
EXTERN_C double muDoubleScalarExp(double a);


/* log */
/*A warning 'Log of zero' should be issued by users for a = 0 */
EXTERN_C double muDoubleScalarLog(double a);


/* log10 */
/*A warning 'Log of zero' should be issued by users for a = 0 */
EXTERN_C double muDoubleScalarLog10(double a);


/* atan2(a,b) */
EXTERN_C double muDoubleScalarAtan2(double a, double b);


/* max(a,b) */
EXTERN_C double muDoubleScalarMax(double a, double b);


/* min(a,b) */
EXTERN_C double muDoubleScalarMin(double a, double b);


/* power(a,b) */
EXTERN_C double muDoubleScalarPower(double a, double b);


/* sin(a) */
EXTERN_C double muDoubleScalarSin(double a);


/* [s,c] = sincos(a) */
EXTERN_C void muDoubleScalarSinCos(double a, double* s, double* c);


/* sign(a) */
EXTERN_C double muDoubleScalarSign(double a);


/* sinh(a) */
EXTERN_C double muDoubleScalarSinh(double a);


/* sqrt(a) */
EXTERN_C double muDoubleScalarSqrt(double a);


/* tan(a) */
EXTERN_C double muDoubleScalarTan(double a);


/* tanh(a) */
EXTERN_C double muDoubleScalarTanh(double a);


/* mod(a,b) */
EXTERN_C double muDoubleScalarMod(double a, double b);


/* rem(a,b) */
EXTERN_C double muDoubleScalarRem(double a, double b);


/* hypot(a,b) */
EXTERN_C double muDoubleScalarHypot(double a,double b);

#ifdef __WATCOMC__
#pragma aux muDoubleScalarAbs value [8087];
#pragma aux muDoubleScalarCeil value [8087];
#pragma aux muDoubleScalarFloor value [8087];
#pragma aux muDoubleScalarRound value [8087];
#pragma aux muDoubleScalarAcos value [8087];
#pragma aux muDoubleScalarAcosh value [8087];
#pragma aux muDoubleScalarAsin value [8087];
#pragma aux muDoubleScalarAsinh value [8087];
#pragma aux muDoubleScalarAtan value [8087];
#pragma aux muDoubleScalarAtanh value [8087];
#pragma aux muDoubleScalarCos value [8087];
#pragma aux muDoubleScalarCosh value [8087];
#pragma aux muDoubleScalarExp value [8087];
#pragma aux muDoubleScalarLog value [8087];
#pragma aux muDoubleScalarLog10 value [8087];
#pragma aux muDoubleScalarAtan2 value [8087]
#pragma aux muDoubleScalarMax value [8087]
#pragma aux muDoubleScalarMin value [8087]
#pragma aux muDoubleScalarPower value [8087]
#pragma aux muDoubleScalarSin value [8087];
#pragma aux muDoubleScalarSinCos value [8087];
#pragma aux muDoubleScalarSign value [8087];
#pragma aux muDoubleScalarSinh value [8087];
#pragma aux muDoubleScalarSqrt value [8087];
#pragma aux muDoubleScalarTan value [8087];
#pragma aux muDoubleScalarTanh value [8087];
#pragma aux muDoubleScalarMod value [8087]
#pragma aux muDoubleScalarRem value [8087]
#pragma aux muDoubleScalarHypot value [8087];
#endif

/* Integer Scalar functions. */
/* Integer Abs Family. */
EXTERN_C uint8_T muIntScalarAbs_uint8(uint8_T a);

EXTERN_C int8_T muIntScalarAbs_sint8(int8_T a);

EXTERN_C uint16_T muIntScalarAbs_uint16(uint16_T a);

EXTERN_C int16_T muIntScalarAbs_sint16(int16_T a);

EXTERN_C uint32_T muIntScalarAbs_uint32(uint32_T a);

EXTERN_C int32_T muIntScalarAbs_sint32(int32_T a);

/* Integer Max Family. */
EXTERN_C uint8_T muIntScalarMax_uint8(uint8_T a, uint8_T b);

EXTERN_C int8_T muIntScalarMax_sint8(int8_T a, int8_T b);

EXTERN_C uint16_T muIntScalarMax_uint16(uint16_T a, uint16_T b);

EXTERN_C int16_T muIntScalarMax_sint16(int16_T a, int16_T b);

EXTERN_C uint32_T muIntScalarMax_uint32(uint32_T a, uint32_T b);

EXTERN_C int32_T muIntScalarMax_sint32(int32_T a, int32_T b);

/* Integer Min Family. */
EXTERN_C uint8_T muIntScalarMin_uint8(uint8_T a, uint8_T b);

EXTERN_C int8_T muIntScalarMin_sint8(int8_T a, int8_T b);

EXTERN_C uint16_T muIntScalarMin_uint16(uint16_T a, uint16_T b);

EXTERN_C int16_T muIntScalarMin_sint16(int16_T a, int16_T b);

EXTERN_C uint32_T muIntScalarMin_uint32(uint32_T a, uint32_T b);

EXTERN_C int32_T muIntScalarMin_sint32(int32_T a, int32_T b);

/* Integer Mod Family. */
EXTERN_C uint8_T muIntScalarMod_uint8(uint8_T a, uint8_T b);

EXTERN_C int8_T muIntScalarMod_sint8(int8_T a, int8_T b);

EXTERN_C uint16_T muIntScalarMod_uint16(uint16_T a, uint16_T b);

EXTERN_C int16_T muIntScalarMod_sint16(int16_T a, int16_T b);

EXTERN_C uint32_T muIntScalarMod_uint32(uint32_T a, uint32_T b);

EXTERN_C int32_T muIntScalarMod_sint32(int32_T a, int32_T b);

/* Integer Rem Family. */
EXTERN_C uint8_T muIntScalarRem_uint8(uint8_T a, uint8_T b);

EXTERN_C int8_T muIntScalarRem_sint8(int8_T a, int8_T b);

EXTERN_C uint16_T muIntScalarRem_uint16(uint16_T a, uint16_T b);

EXTERN_C int16_T muIntScalarRem_sint16(int16_T a, int16_T b);

EXTERN_C uint32_T muIntScalarRem_uint32(uint32_T a, uint32_T b);

EXTERN_C int32_T muIntScalarRem_sint32(int32_T a, int32_T b);

/* Integer Sign Family. */
EXTERN_C uint8_T muIntScalarSign_uint8(uint8_T a);

EXTERN_C int8_T muIntScalarSign_sint8(int8_T a);

EXTERN_C uint16_T muIntScalarSign_uint16(uint16_T a);

EXTERN_C int16_T muIntScalarSign_sint16(int16_T a);

EXTERN_C uint32_T muIntScalarSign_uint32(uint32_T a);

EXTERN_C int32_T muIntScalarSign_sint32(int32_T a);

#endif /* mwmathutil_h */

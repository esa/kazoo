/*
 * File: do_something_types.h
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

#ifndef RTW_HEADER_do_something_types_h_
#define RTW_HEADER_do_something_types_h_
#include "rtwtypes.h"
#ifndef DEFINED_TYPEDEF_FOR_Seq3_
#define DEFINED_TYPEDEF_FOR_Seq3_

typedef struct {
  int32_T element_data[3];
} Seq3;

#endif

#ifndef DEFINED_TYPEDEF_FOR_Seq4_
#define DEFINED_TYPEDEF_FOR_Seq4_

typedef struct {
  int32_T element_data[4];
} Seq4;

#endif

#ifndef DEFINED_TYPEDEF_FOR_In_Nested_inest_a_
#define DEFINED_TYPEDEF_FOR_In_Nested_inest_a_

typedef struct {
  int32_T element_data[4];
} In_Nested_inest_a;

#endif

#ifndef DEFINED_TYPEDEF_FOR_In_Nested_inest_b_
#define DEFINED_TYPEDEF_FOR_In_Nested_inest_b_

typedef struct {
  int32_T element_data[3];
} In_Nested_inest_b;

#endif

#ifndef DEFINED_TYPEDEF_FOR_In_Nested_
#define DEFINED_TYPEDEF_FOR_In_Nested_

typedef struct {
  In_Nested_inest_a inest_a;
  In_Nested_inest_b inest_b;
} In_Nested;

#endif

#ifndef DEFINED_TYPEDEF_FOR_Out_Nested_onest_a_
#define DEFINED_TYPEDEF_FOR_Out_Nested_onest_a_

typedef struct {
  int32_T element_data[7];
} Out_Nested_onest_a;

#endif

#ifndef DEFINED_TYPEDEF_FOR_Out_Nested_
#define DEFINED_TYPEDEF_FOR_Out_Nested_

typedef struct {
  Out_Nested_onest_a onest_a;
} Out_Nested;

#endif

#ifndef DEFINED_TYPEDEF_FOR_Seqout_
#define DEFINED_TYPEDEF_FOR_Seqout_

typedef struct {
  int32_T element_data[8];
} Seqout;

#endif

/* Forward declaration for rtModel */
typedef struct tag_RTM_do_something_T RT_MODEL_do_something_T;

#endif                                 /* RTW_HEADER_do_something_types_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */

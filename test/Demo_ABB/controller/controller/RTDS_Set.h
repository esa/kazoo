#ifndef _RTDS_SET_H_
#define _RTDS_SET_H_

#include <stdlib.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
** MACRO RTDS_SET_OF_INIT:
** -----------------------
** Generic initialzation for set variables. Works on all set types.
** Parameter:
**  - SET_OF_VAR: address for the set varaible to initialize.
*/
#define RTDS_SET_OF_INIT(SET_OF_VAR) \
  { (SET_OF_VAR)->head = NULL; (SET_OF_VAR)->last = NULL; (SET_OF_VAR)->length = 0; memset(&((SET_OF_VAR)->used[0]), 0, sizeof((SET_OF_VAR)->used)); }

/*
** MACRO RTDS_SET_OF_LENGTH:
** -------------------------
** Generic macro returning the length of a set. Works on all set types
** Parameter:
**  - SET_OF_VAR: set variable whose length must be returned.
** Returns: the set length as an unsigned int.
*/
#define RTDS_SET_OF_LENGTH(SET_OF_VAR) (SET_OF_VAR)->length

/*
** TYPE RTDS_setOfCompareOperator:
** -------------------------------
** Operators for set comparisons.
*/
enum RTDS_setOfCompareOperator
  {
  RTDS_SET_OF_CMP_EQ,
  RTDS_SET_OF_CMP_NE,
  RTDS_SET_OF_CMP_LT,
  RTDS_SET_OF_CMP_LE,
  RTDS_SET_OF_CMP_GT,
  RTDS_SET_OF_CMP_GE,
  RTDS_SET_OF_CMP_CMP
  };

#ifdef __cplusplus
}
#endif
  
#endif



/* Header file for function Function2 in C language
 * Generated by TASTE on 2020-02-10 09:40:10
 * Context Parameters present : NO
 * Provided interfaces : doSth, shoot
 * Required interfaces : done
 * User-defined properties for this function:
  *  |_ Taste::Active_Interfaces = any
  *  |_ Taste::coordinates = 151964 60943 179207 82517
 * DO NOT EDIT THIS FILE, IT WILL BE OVERWRITTEN DURING THE BUILD
 */

#pragma once

#include "dataview-uniq.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __unix__
   #include <stdlib.h>
   #include <stdio.h>
#else
   typedef unsigned size_t;
#endif

void function2_startup(void);

/* Provided interfaces */
void function2_PI_doSth( void );

void function2_PI_shoot( void );


/* Required interfaces */
extern void function2_RI_done( void );



#ifdef __cplusplus
}
#endif

/* Body file for function Function1
 * Generated by TASTE on 2020-04-28 13:58:47
 * You can edit this file, it will not be overwritten
 * Provided interfaces : pulse
 * Required interfaces : adder
 * User-defined properties for this function:
 *   |_ Taste::Active_Interfaces = any
 *   |_ Taste::coordinates = 94328 59998 121572 90549
 * Timers              : 
 */

#include "function1.h"
#include <stdio.h>

char p_szGlobalState[10] = "AllModes";
char globalFpgaStatus_function2[20] = "ready";


void function1_startup(void)
{
   // Write your initialisation code, but DO NOT CALL REQUIRED INTERFACES
    printf ("[Function1] Startup");
}

void function1_PI_pulse(void)
{
   // Write your code here
   static asn1SccT_Int32 inp;
   asn1SccT_Int32 outp;
   function1_RI_adder(&inp, &outp);
   printf("function1_PI_pulse sent %lld, got %lld%s\n", inp, outp,
           inp == outp ? " (PRIME)": "");
   inp++;
}


/* Body file for function Function2
 * Generated by TASTE on 2020-02-10 09:21:12
 * You can edit this file, it will not be overwritten
 * Provided interfaces : doSth
 * Required interfaces : done
 * User-defined properties for this function:
 *   |_ Taste::Active_Interfaces = any
 *   |_ Taste::coordinates = 151964 60943 179207 82517
 * Timers              : 
 */

#include "function2.h"
#include <stdio.h>


void function2_startup(void)
{
   // Write your initialisation code, but DO NOT CALL REQUIRED INTERFACES
   // puts ("[Function2] Startup");
    puts("function2 starting up!");
    //function2_RI_done();
}

void function2_PI_doSth(void)
{
   puts("function2 doing something and calling back done");
   function2_RI_done();
}

void function2_PI_shoot(void)
{
    puts("function2 shoots!");
}




/* Body file for function Worker
 * Generated by TASTE on 2019-11-18 13:56:29
 * You can edit this file, it will not be overwritten
 * Provided interfaces : DoSomething
 * Required interfaces : 
 * User-defined properties for this function:
 *   |_ Taste::Active_Interfaces = any
 *   |_ Taste::coordinates = 154169 92281 191963 118422
 * Timers              : 
 */

#include "worker.h"
//#include <stdio.h>


void worker_startup(void)
{
   // Write your initialisation code, but DO NOT CALL REQUIRED INTERFACES
   // puts ("[Worker] Startup");
}

void worker_PI_DoSomething
      (const asn1SccT_Int32 *IN_a,
       asn1SccT_Int32 *OUT_b)

{
    //static asn1SccT_Int32 prev = 0;
    *OUT_b = *IN_a + 1; //prev;
    //prev = *IN_a;
}


void worker_PI_pong(void)
{
    static asn1SccT_Boolean val = true;
    if (val) {
       worker_RI_ping_daughter(&val);
       val = false;
    }
    else {
        worker_RI_ping_twin(&val);
        val = true;
    }
}


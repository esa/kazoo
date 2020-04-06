/* User code: This file will not be overwritten by TASTE. */

#include "function1.h"

void function1_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
}

void function1_PI_cycl()
{
    static asn1SccT_Boolean someBool = true;
    /* Write your code here! */
    printf("[function1] PI_cycl\n");
    if(someBool){
        printf("[function1] Calling RI_t %s\n", someBool?"TRUE":"FALSE");
        function1_RI_t(&someBool);
    }
    someBool = someBool?false:true;
}

void function1_PI_z
      (const asn1SccTASTE_Boolean *IN_param1)

{
       // Write your code here
        printf("[function1] PI_z got %s\n", *IN_param1?"TRUE":"FALSE");
        if(*IN_param1){
            printf("[function1] Calling RI_t %s\n", *IN_param1?"TRUE":"FALSE");
            function1_RI_t(IN_param1);
        }

} 


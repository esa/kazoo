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
      (const asn1SccT_Int32 *IN_param1)

{
       // Write your code here
       static asn1SccT_Boolean someBool = true;
        printf("[function1] PI_z got %d\n", *IN_param1);
        if(*IN_param1 == 100){
            printf("[function1] Calling RI_t %s\n", someBool?"TRUE":"FALSE");
            function1_RI_t(&someBool);
        }

} 


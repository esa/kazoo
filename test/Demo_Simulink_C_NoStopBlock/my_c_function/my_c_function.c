/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "my_c_function.h"
#include <stdio.h>

void my_c_function_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
}

void my_c_function_PI_pulse()
{
    /* Write your code here! */
    
    static asn1SccMyInteger a = 0, 
			    b = 0;
    asn1SccMyInteger res = 0;
    
    my_c_function_RI_Add_Two_Params (&a, &b, &res);

    printf ("Result: %"PRId64" + %"PRId64" = %"PRId64"\n", a, b, res);

    a++;
    b++;
}


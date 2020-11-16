/* User code: This file will not be overwritten by TASTE. */

/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "passive_function.h"
#include "Context-passive-function.h"
#include <stdio.h>

void passive_function_startup() 
{
    printf ("[passive_function] startup done: ");
    printf ("%"PRId64" %"PRId64" \n", passive_function_ctxt.test1, passive_function_ctxt.test2);
}

void passive_function_PI_compute_data(const asn1SccT_SEQUENCE *IN_my_in, asn1SccT_INTEGER *OUT_result)
{
	*OUT_result = IN_my_in->x + IN_my_in->y;

    // passive_function_ctxt.test1 = *OUT_result;

       /* test1 is a context parameter */
       // printf("test1 = %"PRId64"\n", passive_function_ctxt.test1);
       printf("test1 = %"PRId64"\n", *OUT_result);

       if (*OUT_result > 255) *OUT_result = 255;
	
}



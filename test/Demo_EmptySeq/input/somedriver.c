/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "somedriver.h"
#include <stdio.h>
#include <stdbool.h>

void somedriver_startup(void)
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
    static bool init = false;
    if (false == init) {
        printf("[Driver] Init!\n");
        init = true;
    }
    
}

void somedriver_printf(const char *IN_nothing, size_t size_IN_nothing)
{
}


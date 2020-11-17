/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "simple_c_function.h"
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

void myhandler ();

void simple_c_function_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
	printf ("[Startup] Expected output: \"Hello, world...\" every 2 seconds\n");
	(void) signal (SIGINT, myhandler);
}

void myhandler ()
{
    printf ("Ctrl-C hit!\n");
    exit (0);
}

void simple_c_function_PI_cyclic_operation()
{
	printf ("Hello, world...\n");
}


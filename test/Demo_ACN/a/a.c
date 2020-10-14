/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "a.h"

#include <stdio.h>

void a_startup()
{
	/* Write your initialization code here,
	   but do not make any call to a required interface!! */
        printf("[A] startup\n");
}

void a_PI_Cyclic_Run()
{
    static asn1SccT_POS p = { .kind = first_choice_PRESENT, .u={.first_choice = 1}};

//    p.kind = first_choice_PRESENT;

//    p.u.first_choice = 1;

	/* Write your code here! */
    printf ("[A] Cyclic_Run (value = %"PRId64")\n", p.u.first_choice);
    a_RI_Hi (&p);
    p.u.first_choice ++;
    if (p.u.first_choice > 10)
        p.u.first_choice = 1;
}

void a_PI_from_gui(const asn1SccT_POS *toto)
{
    (void)toto;
}

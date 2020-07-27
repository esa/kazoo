/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "f2.h"
#include <stdio.h>

void f2_startup()
{
    printf ("[f2] startup\n");
}

static int seq_received = 0;
static asn1SccMyInteger previousA = -1;
static asn1SccMyInteger previousB = -1;

void f2_PI_A(const asn1SccMyInteger *counter)
{
    if (31415 == *counter) seq_received = 1;
    
    if (0 != seq_received) {
	printf ("[A] INVERSION ERROR (%lld - previousA was %lld)\n", *counter, previousA);
	fflush (stdout);
	exit (1);
    }
    if (*counter != previousA + 1) {
	printf ("[A] MESSAGE LOSS ERROR (%lld - previousA was %lld)\n", *counter, previousA);
	fflush (stdout);
	exit (1);
    }
	printf ("[A] OK");
	fflush (stdout);

    seq_received = 1;
    previousA = *counter;
}

void f2_PI_B(const asn1SccMyInteger *counter)
{
    if (1 != seq_received) {
	printf ("[B] INVERSION ERROR (%lld, previousB was %lld)\n", *counter, previousB);
        fflush (stdout);
        exit (1);
    }
    if (*counter != previousB + 1) {
        printf ("[B] MESSAGE LOSS ERROR (%lld - previousB was %lld)\n", *counter, previousB);
        fflush (stdout);
        exit (1);
    }

	printf ("[B] OK");
	fflush (stdout);

    seq_received=0;
    previousB = *counter;
}


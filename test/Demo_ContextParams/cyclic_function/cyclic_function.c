/* User code: This file will not be overwritten by TASTE. */

#include "cyclic_function.h"

#include <stdio.h>

#ifdef REPORT_MALLOC
#include <malloc.h>
#endif

#include "cyclic_function.h"
#include <stdio.h>

void cyclic_function_startup() 
{
    printf ("[cyclic function] startup done\n");
}

void cyclic_function_PI_cyclic_activation()
{
	static asn1SccT_INTEGER i=0, j=0;
	asn1SccT_INTEGER result=0;
  	asn1SccT_SEQUENCE seq;

	seq.x=i;
	seq.y=j;	
	
#if WORD_SIZE==8
	printf("cycle: input i=%"PRId64", j=%"PRId64"\n", i, j);
#else
	printf("cycle: input i=%ld, j=%ld\n", i, j);
#endif
	cyclic_function_RI_compute_data(&seq, &result);

#if WORD_SIZE==8
	printf("   result of computation: %"PRId64"\n", result);
#else
	printf("   result of computation: %ld\n", result);
#endif

	i++;
	j++;
#ifdef REPORT_MALLOC
	printf("Heap used so far:\n");
	printf("total space allocated from system: %d\n", mallinfo().arena);
	printf("total allocated space: %d\n", mallinfo().uordblks);
	printf("total non-inuse space: %d\n", mallinfo().fordblks);
#endif

#ifdef COVERAGE
	__gcov_flush();
#endif
}



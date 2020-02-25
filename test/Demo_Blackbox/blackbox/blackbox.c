/* Functions to be filled by the user (never overwritten by buildsupport tool) */

#include "blackbox.h"
#include <stdio.h>
#include <string.h>


void blackbox_startup()
{   
    printf ("[blackbox] startup\n");
}

void blackbox_RunDriver
      (const char *IN_inp1_uper, size_t IN_inp1_uper_len,
       const char *IN_inp2_native, size_t IN_inp2_native_len,
       char *OUT_outp1_native, size_t *OUT_outp1_native_len,
       char *OUT_outp2_uper, size_t *OUT_outp2_uper_len)
{
    memcpy(OUT_outp1_native, IN_inp2_native, IN_inp2_native_len);
    memcpy(OUT_outp2_uper, IN_inp1_uper, IN_inp1_uper_len);
    *OUT_outp1_native_len = IN_inp2_native_len;
    *OUT_outp2_uper_len   = IN_inp1_uper_len;
}


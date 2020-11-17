/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_calling__
#define __USER_CODE_H_calling__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void calling_startup();

void calling_PI_pulse();

void calling_PI_changeMode();

extern void calling_RI_do_something(const asn1SccSeq3 *,
                                    const asn1SccSeq3 *,
                                    const asn1SccSeq4 *,
                                    const asn1SccIn_Nested *,
                                    asn1SccSeqout *,
                                    asn1SccOut_Nested *);

#ifdef __cplusplus
}
#endif


#endif

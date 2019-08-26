/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_pus_protocol_handling__
#define __USER_CODE_H_pus_protocol_handling__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void pus_protocol_handling_startup();

void pus_protocol_handling_PI_pus_packetIndication(const asn1SccT_PUS_tc_sp *);

void pus_protocol_handling_PI_pus_response(const asn1SccT_apid *, const asn1SccT_PUS_tm_userDataField *);

extern void pus_protocol_handling_RI_pus_packetRequest(const asn1SccT_PUS_tm_sp *);

extern void pus_protocol_handling_RI_pus_request(const asn1SccT_apid *, const asn1SccT_PUS_tc_userDataField *, asn1SccT_PUS_tc_failure_code *);

#ifdef __cplusplus
}
#endif


#endif

/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_mal_space_packet_binding__
#define __USER_CODE_H_mal_space_packet_binding__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void mal_space_packet_binding_startup();

void mal_space_packet_binding_PI_mo_packetIndication(const asn1SccT_MO_tc_sp *, const asn1SccT_MO_userDataField *);

void mal_space_packet_binding_PI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_space_packet_binding_RI_mo_packetRequest(const asn1SccT_MO_tm_sp *, const asn1SccT_MO_userDataField *);

extern void mal_space_packet_binding_RI_receiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

#ifdef __cplusplus
}
#endif


#endif

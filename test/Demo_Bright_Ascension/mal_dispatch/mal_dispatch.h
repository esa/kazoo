/* This file was generated automatically: DO NOT MODIFY IT ! */

/* Declaration of the functions that have to be provided by the user */

#ifndef __USER_CODE_H_mal_dispatch__
#define __USER_CODE_H_mal_dispatch__

#include "C_ASN1_Types.h"

#ifdef __cplusplus
extern "C" {
#endif

void mal_dispatch_startup();

void mal_dispatch_PI_receiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

void mal_dispatch_PI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_dispatch_RI_transmitRequest(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_dispatch_RI_paramServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_dispatch_RI_modeControlServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_dispatch_RI_aggrServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_dispatch_RI_alertServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_dispatch_RI_checkServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

extern void mal_dispatch_RI_actionServiceReceiveIndication(const asn1SccT_MAL_msg_header *, const asn1SccT_MO_userDataField *);

#ifdef __cplusplus
}
#endif


#endif

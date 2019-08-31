#ifndef _RTDS_COMMON_TYPES_H_
#define _RTDS_COMMON_TYPES_H_

/* Boolean type */
#ifndef _RTDS_BOOLEAN_
#define _RTDS_BOOLEAN_
#undef FALSE
#undef TRUE
typedef enum _RTDS_BOOLEAN { FALSE=0, TRUE=1 } RTDS_BOOLEAN;
#endif

#endif

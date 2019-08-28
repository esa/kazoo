/*
 * Copyright 1994-2005 The MathWorks, Inc.
 *
 * File: rtw_modelmap_logging.h     $Revision: 1.1.6.1 $
 *
 * Abstract:
 *   Meta information used in conjunction with the ModelMappingInfo to
 *   facilitate logging.
 *
 */

#ifndef __RTW_MODELMAP_LOGGING__
#define __RTW_MODELMAP_LOGGING__

#include "sysran_types.h"

typedef struct rtwCAPI_ModelMapLoggingStaticInfo_tag rtwCAPI_ModelMapLoggingStaticInfo;
typedef struct rtwCAPI_ModelMapLoggingInstanceInfo_tag rtwCAPI_ModelMapLoggingInstanceInfo;

typedef struct rtwCAPI_LoggingMetaInfo_tag {
    uint_T sigIdx;   /* same index as the rtwCAPI_Signals */
    uint_T startIdx; /* starting index in the block I/O */
    const char *blockPath;
    uint_T portIdx;
    int_T  parentSysNum;   /* system number of the parent signal that requested
                              the logging */
} rtwCAPI_LoggingMetaInfo;

typedef enum {
    rtwCAPI_bus,
    rtwCAPI_signal
} rtwCAPI_LoggingBusElementType;

typedef struct rtwCAPI_LoggingBusElement_tag {
    uint_T                        index;
    rtwCAPI_LoggingBusElementType type;
} rtwCAPI_LoggingBusElement;

typedef struct rtwCAPI_LoggingBusSignals_tag {
    const char   *signalName;   /* logname should be in the sigProp */
    const char   *blockPath;
    uint_T  portIdx;
    uint_T  numElements;

    const rtwCAPI_LoggingBusElement *elements;
} rtwCAPI_LoggingBusSignals;

/* ModelMapLoggingStaticInfo */
struct rtwCAPI_ModelMapLoggingStaticInfo_tag {
    /* Total number of non-virtual systems */
    uint_T numSystems;

    /* Effective context systems array */
    int_T const * contextSystems;

    rtwCAPI_LoggingMetaInfo const *logInfo;

    /* Bus signals info */
    uint_T numBusSignals;
    rtwCAPI_LoggingBusSignals const *busSignals;
};

/* Macros for accessing static fields */
/* Note: These are all relative to the base MMI */
#define rtwCAPI_GetNumSystems(MMI) \
    ((MMI)->staticMap->staticLogInfo->numSystems)

#define rtwCAPI_GetContextSystems(MMI) \
    ((MMI)->staticMap->staticLogInfo->contextSystems)

#define rtwCAPI_GetLoggingInfoSigIdx(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->logInfo[i].sigIdx)

#define rtwCAPI_GetLoggingInfoStartIdx(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->logInfo[i].startIdx)

#define rtwCAPI_GetLoggingInfoBlockPath(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->logInfo[i].blockPath)

#define rtwCAPI_GetLoggingInfoPortNumber(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->logInfo[i].portIdx)

#define rtwCAPI_GetLoggingInfoParentSysNum(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->logInfo[i].parentSysNum)

#define rtwCAPI_GetLoggingInfoNumBusSignals(MMI) \
    ((MMI)->staticMap->staticLogInfo->numBusSignals)

#define rtwCAPI_GetLoggingInfoBusSignalName(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->busSignals[i].signalName)

#define rtwCAPI_GetLoggingInfoBusBlockPath(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->busSignals[i].blockPath)

#define rtwCAPI_GetLoggingInfoBusPortIdx(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->busSignals[i].portIdx)

#define rtwCAPI_GetLoggingInfoBusNumElements(MMI, i) \
    ((MMI)->staticMap->staticLogInfo->busSignals[i].numElements)

#define rtwCAPI_GetLoggingInfoBusElementIndex(MMI, i, j) \
    ((MMI)->staticMap->staticLogInfo->busSignals[i].elements[j].index)

#define rtwCAPI_GetLoggingInfoBusElementType(MMI, i, j) \
    ((MMI)->staticMap->staticLogInfo->busSignals[i].elements[j].type)

/* ModelMapLoggingInstanceInfo */
struct rtwCAPI_ModelMapLoggingInstanceInfo_tag {
    /* Pointer to the sysRan dwork pointers */
    sysRanDType **systemRan;

    /* Effective non-triggered tid of each system */
    int_T *systemTid;

    /* Points to the global tid map */
    int_T *globalTIDMap;
};

/* Note: These are all relative to the base MMI */

/* Get methods */
#define rtwCAPI_GetSystemRan(MMI) \
   ((MMI)->InstanceMap.instanceLogInfo->systemRan)

#define rtwCAPI_GetSystemTid(MMI) \
   ((MMI)->InstanceMap.instanceLogInfo->systemTid)

#define rtwCAPI_GetGlobalTIDMap(MMI) \
   ((MMI)->InstanceMap.instanceLogInfo->globalTIDMap)

/* Set methods */
#define rtwCAPI_SetSystemRan(MMI,s) \
   ((MMI).InstanceMap.instanceLogInfo->systemRan) = (s)

#define rtwCAPI_SetSystemTid(MMI,s) \
   ((MMI).InstanceMap.instanceLogInfo->systemTid) = (s)

#define rtwCAPI_SetGlobalTIDMap(MMI,s) \
   ((MMI).InstanceMap.instanceLogInfo->globalTIDMap) = (s)

#endif  /* __RTW_MODELMAP_LOGGING__ */

/* EOF - rtw_modelmap_logging.h */

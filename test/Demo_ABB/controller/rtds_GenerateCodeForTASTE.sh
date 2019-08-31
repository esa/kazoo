#!/bin/bash

curdir=$(pwd)
cd $(dirname "$0")

echo Preparing RTDS profile
mkdir -p profile && mkdir -p profile/bricks

echo '[general]
rtos=-
socketAvailable=1
scheduling=required
malloc=forbidden

[common]
includes=.;${RTDS_TEMPLATES_DIR}

[debug]
debug=1
defines=RTDS_SIMULATOR

[tracer]
defines=RTDS_MSC_TRACER
'>profile/DefaultOptions.ini

echo '#define RTDS_SETUP_CURRENT_CONTEXT
#define RTDS_FORGET_INSTANCE_INFO
' >profile/RTDS_ADDL_MACRO.h

echo 'typedef int RTDS_RtosQueueId;
typedef int RTDS_RtosTaskId;
typedef int RTDS_TimerState;

#define RTDS_GLOBAL_PROCESS_INFO_ADDITIONNAL_FIELDS
#define RTDS_MESSAGE_HEADER_ADDITIONNAL_FIELDS
' >profile/RTDS_BasicTypes.h

echo '#define RTDS_MSG_INPUT_ERROR 1
#define RTDS_TIMER_CLEAN_UP
#define RTDS_START_SYNCHRO_WAIT
' >profile/RTDS_MACRO.h

echo '#include "RTDS_MACRO.h"
#include "common.h"
' >profile/bricks/RTDS_Include.c

echo Invoking RTDS code generator
rtdsGenerateCode -f controller_project.rdp scheduled partial-linux || exit -1

echo Generating zipfile for TASTE
mv controller/RTDS-RTOS-adaptation/* controller/ && zip controller controller/*
echo 'All done.
Copy the controller.zip file into your TASTE working directory'
cd "$curdir"

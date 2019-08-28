#!/bin/bash

# This script will build your TASTE system.

# You must check it before running it: it may need to be adapted to your context:
# 1) You may need to fix some paths and filenames (path to interface/deployment views)
# 2) You may need to specify additional paths for the compiler to find .h file
#    (e.g. "export C_INCLUDE_PATH=/usr/include/xenomai/analogy/:$C_INCLUDE_PATH")
# 3) You may need to link with pre-built libraries, using the -l option
#    (e.g. -l /usr/lib/libanalogy.a,/usr/lib/librtdm.a)
# 4) You may need to change the runtime (add -p flag to select PolyORB-HI-C)
# etc.

# Note: TASTE will not overwrite your changes - if you need to update some  parts
#       you will have to merge the changes with the newly-created "build-script.new.sh" file.

mkdir -p .cache
export PROJECT_CACHE=$HOME/.taste_AST_cache

rm -f my_c_function.zip
zip my_c_function my_c_function/*
rm -f my_simulink_function.zip
zip my_simulink_function my_simulink_function/*
[ ! -z "$CLEANUP" ] && rm -rf binary

echo Building the system with the Ada runtime 
assert-builder-ocarina.py \
	-f  -p\
	--aadlv2 \
	--keep-case \
	--interfaceView InterfaceView.aadl \
	--deploymentView DeploymentView.aadl \
	-o binary \
	--subC my_c_function:my_c_function.zip \
	--subSIMULINK my_simulink_function:my_simulink_function.zip

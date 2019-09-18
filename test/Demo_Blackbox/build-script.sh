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

if [ -z "$DEPLOYMENTVIEW" ]
then
    DEPLOYMENTVIEW=DeploymentView.aadl
fi

SKELS="./"

cd "$SKELS"
rm -f caller_in_ada.zip
zip caller_in_ada caller_in_ada/*
rm -f blackbox.zip
zip blackbox blackbox/*
rm -f caller_in_c.zip
zip caller_in_c caller_in_c/*
cd "$OLDPWD"

[ ! -z "$CLEANUP" ] && rm -rf binary*

echo 'Building the system with the Ada runtime (add -p in the build script to replace with C)'
assert-builder-ocarina.py \
	-f \
	-g \
	--aadlv2 \
	--keep-case \
	--interfaceView InterfaceView.aadl \
	--deploymentView "$DEPLOYMENTVIEW" \
	-o binary.ada \
	--subAda caller_in_ada:"$SKELS"/caller_in_ada.zip \
	--subC blackbox:"$SKELS"/blackbox.zip \
	--subC caller_in_c:"$SKELS"/caller_in_c.zip

echo 'Building the system with the C runtime'
assert-builder-ocarina.py \
	-f \
	-g -p \
	--aadlv2 \
	--keep-case \
	--interfaceView InterfaceView.aadl \
	--deploymentView "$DEPLOYMENTVIEW" \
	-o binary.pohic \
	--subAda caller_in_ada:"$SKELS"/caller_in_ada.zip \
	--subC blackbox:"$SKELS"/blackbox.zip \
	--subC caller_in_c:"$SKELS"/caller_in_c.zip

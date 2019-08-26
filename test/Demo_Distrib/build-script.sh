#!/bin/bash

mkdir -p .cache
export PROJECT_CACHE=$HOME/.taste_AST_cache

cd skels
rm -f a.zip
zip a a/*
rm -f b.zip
zip b b/*
cd ..

[ ! -z "$CLEANUP" ] && rm -rf binary.linux.pohic/

assert-builder-ocarina.py \
	-f \
        -p \
	--aadlv2 \
	--keep-case \
	--interfaceView InterfaceView.aadl \
	--deploymentView DeploymentView.aadl \
	-o binary.linux.pohic \
	--subC a:skels/a.zip \
	--subC b:skels/b.zip

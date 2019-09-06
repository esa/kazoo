#!/bin/bash

mkdir -p .cache
export PROJECT_CACHE=$HOME/.taste_AST_cache

rm -f a.zip
zip a a/*
rm -f b.zip
zip b b/*
rm -f c.zip
zip c c/*

[ ! -z "$CLEANUP" ] && rm -rf binary.linux.*

# C runtime
assert-builder-ocarina.py \
	-f \
	-p \
	--aadlv2 \
	--interfaceView InterfaceView.aadl \
	--deploymentView DeploymentView.aadl \
	-o binary.linux.pohic \
	--subC a:a.zip \
	--subC b:b.zip \
	--subC c:c.zip

# Ada runtime
assert-builder-ocarina.py \
	-f \
	--aadlv2 \
	--interfaceView InterfaceView.aadl \
	--deploymentView DeploymentView.aadl \
	-o binary.linux.ada \
	--subC a:a.zip \
	--subC b:b.zip \
	--subC c:c.zip

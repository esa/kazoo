#!/bin/bash

mkdir -p .cache
export PROJECT_CACHE=$HOME/.taste_AST_cache

rm -f simple_c_function.zip
zip simple_c_function simple_c_function/*

[ ! -z "$CLEANUP" ] && rm -rf binary.*

# C runtime
assert-builder-ocarina.py \
        -f \
        -p \
        --aadlv2 \
        --keep-case \
        --interfaceView InterfaceView.aadl \
        --deploymentView DeploymentView.aadl \
        -o binary.linux.pohic \
        --subC simple_c_function:simple_c_function.zip

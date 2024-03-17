#!/bin/bash
set -ex

cd src/

## This doesn't seem to work reliably
# the makefile directly calls g++, and doesn't use env variables
# use an alias to redirect to the correct compiler without changing the makefile
#alias "g++"=$CXX
#make # builds the package

## instead just build with a manual call to the compiler
$CXX  -O3 -ffast-math -lm -o mTM-align main.cpp TMM.cpp UPGMA.cpp

mkdir -p $PREFIX/bin
mv mTM-align $PREFIX/bin/mtm-align

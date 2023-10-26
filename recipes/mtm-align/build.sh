#!/bin/bash
set -ex

cd src/
# the makefile directly calls g++, and doesn't use env variables
# use an alias to redirect to the correct compiler without changing the makefile
alias "g++"=$CXX
make # builds the package

mkdir -p $PREFIX/bin
mv mTM-align $PREFIX/bin/mtm-align

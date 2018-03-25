#!/bin/bash


##strictly use anaconda build environment
#CXX=${PREFIX}/bin/g++

#to fix problems with zlib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

git clone --recursive https://github.com/mcveanlab/mccortex
cd mccortex

git checkout v0.2

make all MAXK=31
make all MAXK=63
make all MAXK=127

mkdir -p ${PREFIX}/bin
cp bin/mccortex31 ${PREFIX}/bin
cp bin/mccortex63 ${PREFIX}/bin
cp bin/mccortex127 ${PREFIX}/bin


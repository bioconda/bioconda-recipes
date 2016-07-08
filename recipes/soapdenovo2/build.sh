#!/bin/sh
set -x -e

export GCC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $PREFIX/bin
cp -rf SOAP* $PREFIX/bin

#https://sourceforge.net/projects/soapdenovo2/files/SOAPdenovo2/bin/r240/SOAPdenovo2-bin-r240-mac.tgz/download
# This is the MACOSX version

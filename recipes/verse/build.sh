#!/bin/bash

mkdir -p ${PREFIX}/bin

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd src

if [ `uname` == Darwin ]; then
make -f Makefile.MacOS
else
make -f Makefile.Linux
fi

cp ../verse ${PREFIX}/bin

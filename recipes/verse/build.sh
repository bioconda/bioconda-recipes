#!/bin/bash

mkdir -p ${PREFIX}/bin

export CPATH=${PREFIX}/include

cd src

if [ `uname` == Darwin ]; then
make -f Makefile.MacOS
else
make -f Makefile.Linux
fi

cp ../verse ${PREFIX}/bin

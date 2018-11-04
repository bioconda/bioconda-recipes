#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

mkdir -p $PREFIX/bin

curl -L https://github.com/attractivechaos/k8/releases/download/0.2.5/k8-0.2.5.tar.bz2 | tar jxf - k8-0.2.5/k8-`uname -s`
cp k8-0.2.5/k8-* $PREFIX/bin/k8

make
cp minimap2 misc/paftools.js $PREFIX/bin

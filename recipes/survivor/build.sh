#!/bin/bash

export CXX_INCLUDE_PATH=$PREFIX/include
export CPP_INCLUDE_PATH=$PREFIX/include
export CPPLUS_INCLUDE_PATH=$PREFIX/include

mkdir -p $PREFIX/bin
sed -i.bak "s#g++#$CXX#g" Debug/makefile
for f in Debug/src/*/subdir.mk; do
    sed -i.bak "s#g++#$CXX#g" $f
done
cd Debug
make
cp SURVIVOR $PREFIX/bin

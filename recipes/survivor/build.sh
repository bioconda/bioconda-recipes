#!/bin/bash

mkdir -p $PREFIX/bin
sed -i.bak "s#g++#$CXX -I$PREFIX/include -L$PREFIX/lib#g" Debug/makefile
for f in Debug/src/*/subdir.mk; do
    sed -i.bak "s#g++#$CXX -I$PREFIX/include -L$PREFIX/lib#g" $f
done
sed -i.bak "s#g++#$CXX -I$PREFIX/include -L$PREFIX/lib#g" Debug/src/subdir.mk

cd Debug
make
cp SURVIVOR $PREFIX/bin

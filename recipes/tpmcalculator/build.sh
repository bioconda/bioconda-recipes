#!/usr/bin/env bash

export CPPFLAGS="-I$PREFIX/include/bamtools"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" nbproject/Makefile-Release.mk

make
cp bin/TPMCalculator $PREFIX/bin/

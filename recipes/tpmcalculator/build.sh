#!/usr/bin/env bash

set -xe

export CPPFLAGS="-I$PREFIX/include/bamtools"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" nbproject/Makefile-Release.mk

make -j ${CPU_COUNT}
cp bin/TPMCalculator $PREFIX/bin/

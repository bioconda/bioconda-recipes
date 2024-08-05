#!/bin/bash

set -xe

cd src/

# without -fpermissive, this fails with GCC7 due to bad style
make -j ${CPU_COUNT} CXX="${CXX}" CXXFLAGS+='-fpermissive' LDFLAGS+='-lpthread -lm -lexpat'

mkdir -p "${PREFIX}/bin"
cp ../bin/tandem.exe "${PREFIX}/bin/xtandem"

#!/bin/bash

mkdir -p ${PREFIX}/bin
cd src/
# without -fpermissive, this fails with GCC7 due to bad style
make CXXFLAGS+='-fpermissive'
cp ../bin/tandem.exe ${PREFIX}/bin/xtandem

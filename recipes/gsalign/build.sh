#!/bin/bash
make Compiler=$CXX CXX=$CXX CC=$CC LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS} -msse4.2 -mpopcnt -fPIC" CXXFLAGS="${CXXFLAGS} -msse4.2 -mpopcnt -fPIC"
cp bin/GSAlign bin/bwt_index $PREFIX/bin

#!/bin/bash
make Compiler=$CXX CXX=$CXX CC=$CC LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS} -msse4.1 -mpopcnt" CXXFLAGS="${CXXFLAGS}"
cp bin/MapCaller $PREFIX/bin

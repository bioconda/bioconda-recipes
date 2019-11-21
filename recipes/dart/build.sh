#!/bin/bash
make Compiler=$CXX CXX=$CXX CC=$CC LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
cp bin/dart bin/bwt_index $PREFIX/bin

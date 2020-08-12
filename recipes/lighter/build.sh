#!/bin/sh

mkdir -p $PREFIX/bin
make CXX=${CXX} CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
cp lighter $PREFIX/bin

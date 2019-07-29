#!/bin/sh

make all CXX=$CXX
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin

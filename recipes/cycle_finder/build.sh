#!/bin/sh

mkdir -p $PREFIX/bin
make CC=$CXX
cp cycle_finder $PREFIX/bin/

#!/bin/sh

mkdir -p $PREFIX/bin
make CXX=$CXX
cp cycle_finder $PREFIX/bin/

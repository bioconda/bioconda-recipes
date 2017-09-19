#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin

CXXFLAGS="-stdlib=libc++ -I ${PREFIX}/include" make

cp squeakr-count  $PREFIX/bin
cp squeakr-inner-prod $PREFIX/bin
cp squeakr-query $PREFIX/bin

#!/bin/bash

mkdir -p $PREFIX/bin

CXXFLAGS="-stdlib=libc++ -I ${PRFIX}/include" make

cp squeakr-count  $PREFIX/bin
cp squeakr-inner-prod $PREFIX/bin
cp squeakr-query $PREFIX/bin

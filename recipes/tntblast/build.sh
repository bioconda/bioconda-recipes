#!/bin/bash

sed -i.bak '/BLAST_DIR =/d' Makefile

export INCLUDE_PATH="${BUILD_PREFIX}/include"
export LIBRARY_PATH="${BUILD_PREFIX}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BUILD_PREFIX}/lib"

export LDFLAGS="-lm -lz -L${BUILD_PREFIX}/lib"
export CPPFLAGS="-I${BUILD_PREFIX}/include"

export CXX="${BUILD_PREFIX}/bin/mpicxx"

make CC="${CXX}" INC="${CPPFLAGS}" LIBS="${LDFLAGS}" all

mkdir -p $PREFIX/bin
cp tntblast $PREFIX/bin

#!/bin/bash

LIBS="${LDFLAGS}" make -j4 CC="${CC}" CXX="${CXX}" multi

mkdir -p $PREFIX/bin
cp bwa-meme* $PREFIX/bin



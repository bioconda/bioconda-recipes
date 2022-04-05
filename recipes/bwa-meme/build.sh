#!/bin/bash

LIBS="${LDFLAGS}" make CC="${CC}" CXX="${CXX}" multi

mkdir -p $PREFIX/bin
cp bwa-meme* $PREFIX/bin

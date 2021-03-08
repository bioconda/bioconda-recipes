#!/bin/bash

cd bwa-mem2-2.2

LIBS="${LDFLAGS}" make CC="${CC}" CXX="${CXX}" multi

mkdir -p $PREFIX/bin
cp bwa-mem2* $PREFIX/bin

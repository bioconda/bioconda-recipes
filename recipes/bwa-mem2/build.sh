#!/bin/bash

LIBS="${LDFLAGS}" make CC="${CC}" CXX="${CXX}" multi

mkdir -p $PREFIX/bin
cp bwa-mem2* $PREFIX/bin

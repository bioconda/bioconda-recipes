#!/bin/bash

cd src

sed -i'.bak' 's/${CC}/${CXX}/g' Makefile
sed -i'.bak' 's/ifeq (${CXX},g++)/ifneq (,$(firstword $(findstring gnu-c++,$(CXX)) $(findstring clang,$(CXX))))/g' Makefile
sed -i'.bak' 's/${LFLAGS}/${LFLAGS} ${LDFLAGS} -lopenblas/g' Makefile

sed -i'.bak' 's/asm (".symver memcpy, memcpy@GLIBC_2.2.5");//g' memcpy.cpp

make CC=$CC

mkdir -p ${PREFIX}/bin

install -m775 bolt ${PREFIX}/bin/

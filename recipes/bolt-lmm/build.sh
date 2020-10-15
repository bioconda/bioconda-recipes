#!/bin/bash

cd src

sed -i'.bak' 's/${CC}/${CXX}/g' Makefile
sed -i'.bak' 's/ifeq (${CXX},g++)/ifneq (,$(firstword $(findstring gnu-c++,$(CXX)) $(findstring clang,$(CXX))))/g' Makefile
sed -i'.bak' 's/${LFLAGS}/${LFLAGS} ${LDFLAGS} -lopenblas/g' Makefile

make CC=$CC

mkdir -p ${PREFIX}/bin

install -m775 bolt ${PREFIX}/bin/

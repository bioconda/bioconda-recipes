#!/bin/bash

cd src

sed -i'.bak' 's/${CC}/${CXX}/g' Makefile
sed -i'.bak' 's/ifeq (${CXX},g++)/ifneq (,$(findstring gnu-c++,$(CXX)))/g' Makefile
sed -i'.bak' 's/${LFLAGS}/${LFLAGS} ${LDFLAGS} -lblas/g' Makefile

make CC=$CC

mkdir -p ${PREFIX}/bin

install -m775 bolt ${PREFIX}/bin/

#!/bin/bash

cd src

sed -i'.bak' 's/ifeq (${CC},g++)/ifneq (,$(findstring gnu-cc,$(CC)))/g' Makefile
sed -i'.bak' 's/${LFLAGS}/${LFLAGS} ${LDFLAGS}/g' Makefile

make CC=$CC

mkdir -p ${PREFIX}/bin

install -m775 bolt ${PREFIX}/bin/

#!/bin/bash

make CC="${CC}" LD="${CXX}" CXX="${CXX}" \
   LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lpthread -lboost_system -lboost_thread -lm -lbz2 -lz -lrt" \
   CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -I. -I${SRC_DIR}/include" \
   CFLAGS="${CFLAGS} -I${PREFIX}/include -I. -I${SRC_DIR}/include" \
   ARCH="${ARCH}"

install -d $PREFIX/bin
install squeakr $PREFIX/bin

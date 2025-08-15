#!/bin/sh
make -C htslib CC=${CC} CFLAGS="${CFLAGS} -g -Wall -O2 -fvisibility=hidden" LDFLAGS="${LDFLAGS} -fvisibility=hidden" lib-static

mkdir -p build
make CXX=${CXX} CXXFLAGS="${CXXFLAGS} -O3 -DPRINT" LDLIBS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp cas ${PREFIX}/bin

#!/bin/sh
make -C htslib CC=${CC} CFLAGS="${CFLAGS} -g -Wall -O2 -fvisibility=hidden" LDFLAGS="${LDFLAGS} -fvisibility=hidden"

mkdir -p build
make print CXX=${CXX} CXXFLAGS="${CXXFLAGS} -I." LDLIBS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp cas ${PREFIX}/bin

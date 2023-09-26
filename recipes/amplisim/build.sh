#!/bin/sh
make -C lib/htslib CC=${CC} CFLAGS="${CFLAGS} -g -Wall -O2 -fvisibility=hidden" LDFLAGS="${LDFLAGS} -fvisibility=hidden" lib-static

mkdir -p build
make CXX=${CXX} CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -Wno-missing-field-initializers -Wno-unused-function" LDLIBS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp amplisim ${PREFIX}/bin

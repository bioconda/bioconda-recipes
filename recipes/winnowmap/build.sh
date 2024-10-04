#! /bin/sh

set -xe

make -j ${CPU_COUNT} \
  CPPFLAGS="${CXXFLAGS} ${CPPFLAGS} -g -Wall -O2 -DHAVE_KALLOC -fopenmp -std=c++11 -Wno-sign-compare -Wno-write-strings -Wno-unused-but-set-variable ${LDFLAGS}"

install -d "${PREFIX}/bin"
install bin/winnowmap "${PREFIX}/bin/"

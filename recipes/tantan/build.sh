#!/bin/bash -euo

ARCH=$(uname -m)
case ${ARCH} in
    x86_64) ARCH_FLAGS="-msse4" ;;
    *) ARCH_FLAGS="" ;;
esac

make install CXXFLAGS="${CXXFLAGS} -O3 ${ARCH_FLAGS} -pthread -I${PREFIX}/include" prefix=${PREFIX}

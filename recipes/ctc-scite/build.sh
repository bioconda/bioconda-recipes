#!/bin/bash

set -xe

export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include:/usr/include/c++/$(gcc -dumpversion)"
export CXXFLAGS="${CXXFLAGS} -std=c++11 -Wall -Wextra -Wno-missing-field-initializers -g -O2"

mkdir -p $PREFIX/bin

case $(uname -m) in
    aarch64)
       CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ARCH_OPTS="SSE_FLAG= POPCNT_CAPABILITY=0"
        ;;
    *)
        ARCH_OPTS=""
        ;;
esac

make -j ${CPU_COUNT} CXX=$CXX RELEASE_FLAGS="$CXXFLAGS" ${ARCH_OPTS} -C ${SRC_DIR}/CTC_SCITE
make install prefix=$PREFIX -C ${SRC_DIR}/CTC_SCITE

#!/bin/bash

set -xe

export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

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

make -j ${CPU_COUNT} CXX=$CXX RELEASE_FLAGS="$CXXFLAGS" ${ARCH_OPTS}
make install prefix=$PREFIX

cp evaluation/{centrifuge_evaluate.py,centrifuge_simulate_reads.py} $PREFIX/bin

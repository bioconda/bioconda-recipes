#!/bin/bash

set -xe
case $(uname -m) in
    x86_64)
        # -msse4.1 needed for _mm_min_epi32
        ARCH_OPTS="-msse4.1"
        ;;
    *)
        ;;
esac

make -j ${CPU_COUNT} CXX=$CXX CXXFLAGS="-O3 -Wall -I$PREFIX/include -std=c++11 ${ARCH_OPTS} -fopenmp" LDFLAGS="-L$PREFIX/lib -lm -lz"
mkdir -p $PREFIX/bin
mv chromap $PREFIX/bin

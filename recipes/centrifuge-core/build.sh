#!/bin/bash

set -xe

export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

case $(uname -m) in
    aarch64 | arm64)
        ARCH_FLAGS=(POPCNT_CAPABILITY=0 "RELEASE_FLAGS=${CXXFLAGS} -fsigned-char")
        ;;
    *)
        ARCH_FLAGS=("RELEASE_FLAGS=${CXXFLAGS}")
        ;;
esac

sed "/^GCC/d;/^CC =/d;/^CPP =/d;/^CXX =/d" < Makefile > Makefile.new
mv Makefile.new Makefile
cat Makefile
make -j"${CPU_COUNT}" CC=$CC CXX=$CXX "${ARCH_FLAGS[@]}"
make install prefix=$PREFIX


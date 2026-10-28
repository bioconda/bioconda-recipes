#!/bin/bash

set -xe

export CPATH=${PREFIX}/include

if [ $(uname -m) == "x86_64" ]; then
    CXXFLAGS="${CXXFLAGS} -msse4.2"
fi

mkdir -p $PREFIX/bin

make -j ${CPU_COUNT} CXX="$CXX" CXXFLAGS="$CXXFLAGS" LINKPATH="-L${PREFIX}/lib"

install -m 0755 {centrifuger,centrifuger-build,centrifuger-download,centrifuger-kreport,centrifuger-inspect,centrifuger-quant} $PREFIX/bin

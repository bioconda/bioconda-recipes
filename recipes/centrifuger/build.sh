#!/bin/bash

set -xe

export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

make -j ${CPU_COUNT} CXX="$CXX" CXXFLAGS="$CXXFLAGS"
chmod +x centrifuger-download
chmod +x centrifuger-kreport
chmod +x centrifuger-inspect

cp {centrifuger,centrifuger-build,centrifuger-download,centrifuger-kreport,centrifuger-inspect} $PREFIX/bin

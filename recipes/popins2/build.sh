#!/usr/bin/env bash

set -xe

# no need to build SeqAn's documentation/demos
rm -rf external/seqan-library-2.2.0/share/doc/seqan/

mkdir build

CXX="${CXX} -std=c++14" make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/bin
install -m 755 popins2 ${PREFIX}/bin

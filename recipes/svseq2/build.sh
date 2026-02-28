#!/usr/bin/env bash

set -xe

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/bam"

make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/bin
install -m 755 SVseq2_2 ${PREFIX}/bin

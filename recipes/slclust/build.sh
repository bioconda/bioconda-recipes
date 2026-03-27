#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

make install CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 bin/slclust "${PREFIX}/bin"

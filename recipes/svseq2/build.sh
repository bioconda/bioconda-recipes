#!/usr/bin/env bash

set -xe

CXX=${CXX} make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/bin
install -m 755 SVseq2_2 ${PREFIX}/bin

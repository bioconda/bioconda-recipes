#!/usr/bin/env bash

set -xe

CXX="${CXX} -std=c++14" make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/bin
install -m 755 SoftSV ${PREFIX}/bin

#!/usr/bin/env bash

set -xe

CXX="${CXX} -std=c++14" make -j"${CPU_COUNT}"

ls -la

mkdir -p ${PREFIX}/bin
install -m 755 softsv ${PREFIX}/bin

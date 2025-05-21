#!/usr/bin/env bash

set -xe

CXX="${CXX}" make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/bin
install -m 755 MCScanX ${PREFIX}/bin
install -m 755 MCScanX_h ${PREFIX}/bin
install -m 755 duplicate_gene_classifier ${PREFIX}/bin

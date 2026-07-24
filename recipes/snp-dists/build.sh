#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

LIBS="${LDFLAGS}" make -j"${CPU_COUNT}" CC="${CC}" PREFIX="${PREFIX}"

install -v -m 0755 snp-dists "${PREFIX}/bin"

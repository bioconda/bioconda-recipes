#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"
LIBS="${LDFLAGS}" make -j ${CPU_COUNT} CC="${CC}" PREFIX="${PREFIX}"
cp -f snp-dists ${PREFIX}/bin/
chmod 0755 ${PREFIX}/bin/snp-dists
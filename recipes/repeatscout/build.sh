#!/bin/bash
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 RepeatScout ${PREFIX}/bin
install -v -m 0755 build_lmer_table ${PREFIX}/bin
cp -rf compare-out-to-gff.prl filter-stage-1.prl filter-stage-2.prl merge-lmer-tables.prl ${PREFIX}/bin

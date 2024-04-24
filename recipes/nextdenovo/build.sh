#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
OUTDIR="${SP_DIR}/nextdenovo"

mkdir -p ${PREFIX}/bin ${OUTDIR}

make CC="${CC}" CFLAGS="-O3" LDFLAGS="${LDFLAGS}" TOP_DIR="${PREFIX}" -j "${CPU_COUNT}"

cp -rf "${SRC_DIR}/nextDenovo" ${PREFIX}/bin
chmod a+x ${PREFIX}/bin/nextDenovo

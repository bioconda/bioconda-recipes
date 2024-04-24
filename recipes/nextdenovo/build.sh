#!/bin/bash
set -x

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
OUTDIR="${SP_DIR}/nextdenovo"

mkdir -p ${PREFIX}/bin ${OUTDIR}

make CC="${CC}" CFLAGS="-O3" LDFLAGS="${LDFLAGS}" prefix="${PREFIX}" -j "${CPU_COUNT}"

cp -rf "${SRC_DIR}/*" ${OUTDIR}
chmod a+x ${OUTDIR}/nextDenovo
ln -sf ${OUTDIR}/nextDenovo ${PREFIX}/bin/nextDenovo

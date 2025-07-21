#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

OUTDIR="${SP_DIR}/nextdenovo"

mkdir -p ${PREFIX}/bin ${OUTDIR}

cd lib/htslib

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
autoreconf -if

cd ../../

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 755 bin/* "${OUTDIR}"
cp -rf ${SRC_DIR}/* "${OUTDIR}"
chmod 755 ${OUTDIR}/nextDenovo
ln -sf ${OUTDIR}/nextDenovo "${PREFIX}/bin/nextDenovo"

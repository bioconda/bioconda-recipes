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

case $(uname -m) in
	aarch64|arm64) export arm_neon=1 && make arm_neon=1 CC="${CC}" -j"${CPU_COUNT}" ;;
  *) make CC="${CC}" -j"${CPU_COUNT}" ;;
esac

install -v -m 755 bin/* "${OUTDIR}"
cp -rf ${SRC_DIR}/* "${OUTDIR}"
chmod 755 ${OUTDIR}/nextDenovo
ln -sf ${OUTDIR}/nextDenovo "${PREFIX}/bin/nextDenovo"

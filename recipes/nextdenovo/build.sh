#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

OUTDIR="${SP_DIR}/nextdenovo-${PKG_VERSION}"

mkdir -p "${PREFIX}/bin" "${OUTDIR}"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* lib/htslib/

case $(uname -m) in
	aarch64|arm64) export arm_neon=1; export aarch64=1; make arm_neon=1 aarch64=1 CC="${CC}" -j"${CPU_COUNT}" ;;
	*) make CC="${CC}" -j"${CPU_COUNT}" ;;
esac

cp -rf ${SRC_DIR}/* "${OUTDIR}"

chmod 755 ${OUTDIR}/nextDenovo
ln -sf ${OUTDIR}/nextDenovo "${PREFIX}/bin/nextDenovo"

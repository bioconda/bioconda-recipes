#!/bin/bash
set -ex

OUTDIR="${SP_DIR}/nextdenovo"

mkdir -p ${PREFIX}/bin ${OUTDIR}

cp -rf ${SRC_DIR}/* ${OUTDIR}
chmod 755 ${OUTDIR}/nextDenovo
ln -sf ${OUTDIR}/nextDenovo ${PREFIX}/bin/nextDenovo

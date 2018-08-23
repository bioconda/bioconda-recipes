#!/bin/bash
set -eu -o pipefail

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p $outdir
mkdir -p ${PREFIX}/bin
cp ${SRC_DIR}/* $outdir/
cp ${RECIPE_DIR}/clove.py $outdir/clove
ln -s $outdir/clove ${PREFIX}/bin
chmod 0755 "${PREFIX}/bin/clove"

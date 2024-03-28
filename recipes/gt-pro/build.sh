#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

make

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${outdir}
mkdir -p ${PREFIX}/bin

cp -r bin ${outdir}/
cp -r scripts ${outdir}/
cp GT_Pro ${outdir}/

chmod -R 755 ${outdir}/bin/
chmod -R 755 ${outdir}/scripts/
chmod -R 755 ${outdir}/GT_Pro

ln -s ${outdir}/GT_Pro ${PREFIX}/bin/GT_Pro

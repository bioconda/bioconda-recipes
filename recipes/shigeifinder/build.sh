#!/bin/bash

outdir="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${outdir}"
mkdir -p "${PREFIX}/bin"

cp target/abra2-${PKG_VERSION}-jar-with-dependencies.jar "${outdir}/abra2.jar"
cp "${RECIPE_DIR}/*" "${outdir}/"
chmod +x "${outdir}/shigeifinder.py"
ln -s "${outdir}/shigeifinder.py" "${PREFIX}/bin/shigeifinder.py"
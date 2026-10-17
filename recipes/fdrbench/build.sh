#!/bin/bash
set -eu

OUTDIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${OUTDIR}" "${PREFIX}/bin"

# The jar is thin: its manifest Class-Path lists lib/*.jar as relative paths,
# so the jar and lib/ have to stay side by side.
cp "fdrbench-${PKG_VERSION}.jar" "${OUTDIR}/fdrbench.jar"
cp -r lib "${OUTDIR}/"

cp "${RECIPE_DIR}/fdrbench.sh" "${OUTDIR}/fdrbench"
chmod +x "${OUTDIR}/fdrbench"
ln -s "${OUTDIR}/fdrbench" "${PREFIX}/bin/fdrbench"

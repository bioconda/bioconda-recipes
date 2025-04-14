#!/bin/bash
set -eu -o pipefail

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p "$outdir"
cp -R dist/* "$outdir/"
mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/rdp_classifier.sh" "${outdir}/rdp_classifier"
chmod +x "${outdir}/rdp_classifier"
ln -s "${outdir}/rdp_classifier" "${PREFIX}/bin/"

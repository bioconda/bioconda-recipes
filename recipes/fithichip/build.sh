#!/bin/bash
set -euxo pipefail

# FitHiChIP is a set of bash, R and Python scripts that run from their own directory.
# Install the code (no test data, docs or container files) and a wrapper on PATH.
share="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${share}" "${PREFIX}/bin"

cd "${SRC_DIR}/fithichip"
cp -R FitHiChIP_HiCPro.sh src Analysis Imp_Scripts configfile* LICENSE README.md Release_Notes.txt "${share}/"
cp "${SRC_DIR}/ucsc/interact.as" "${share}/"
chmod -R a+rX "${share}"

sed "s|@FITHICHIP_SHARE@|${PKG_NAME}-${PKG_VERSION}|" "${RECIPE_DIR}/fithichip.sh" > "${PREFIX}/bin/FitHiChIP_HiCPro.sh"
chmod 755 "${PREFIX}/bin/FitHiChIP_HiCPro.sh"

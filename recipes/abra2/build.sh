#!/bin/bash

set -eu -o pipefail

sed -i.bak "s#g++#${CXX}#" Makefile
make
outdir="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${outdir}"
mkdir -p "${PREFIX}/bin"
cp target/abra2-2.20-jar-with-dependencies.jar "${outdir}/abra2.jar"
cp "${RECIPE_DIR}/abra2-wrapper.sh" "${outdir}/abra2"
chmod +x "${outdir}/abra2"
ln -s "${outdir}/abra2" "${PREFIX}/bin/abra2"

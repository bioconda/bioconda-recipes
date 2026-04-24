#!/usr/bin/env bash
set -euo pipefail

PIPELINE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PIPELINE_DIR}"

cp bin/somatem "${PREFIX}/bin/${PKG_NAME}"
chmod +x "${PREFIX}/bin/${PKG_NAME}"

sed -i "s|@@PIPELINE_DIR@@|${PIPELINE_DIR}|g" "${PREFIX}/bin/${PKG_NAME}"

cp -r assets "${PIPELINE_DIR}/"
cp -r bin "${PIPELINE_DIR}/"
cp -r conf "${PIPELINE_DIR}/"
cp -r docs "${PIPELINE_DIR}/"
cp -r modules "${PIPELINE_DIR}/"
cp -r subworkflows "${PIPELINE_DIR}/"
cp -r workflows "${PIPELINE_DIR}/"
cp -r tests "${PIPELINE_DIR}/"

cp CITATIONS.md "${PIPELINE_DIR}/"
cp LICENSE "${PIPELINE_DIR}/"
cp README.md "${PIPELINE_DIR}/"
cp main.nf "${PIPELINE_DIR}/"
cp modules.json "${PIPELINE_DIR}/"
cp nextflow.config "${PIPELINE_DIR}/"
cp nf-test.config "${PIPELINE_DIR}/"
#!/usr/bin/env bash
set -euo pipefail

PIPELINE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

pipeline_dirs=(
    assets
    bin
    conf
    docs
    modules
    subworkflows
    tests
    workflows
)

pipeline_files=(
    CITATIONS.md
    LICENSE
    README.md
    main.nf
    modules.json
    nextflow.config
    nf-test.config
)

mkdir -p "${PREFIX}/bin" "${PIPELINE_DIR}"

cp bin/somatem "${PREFIX}/bin/${PKG_NAME}"
chmod +x "${PREFIX}/bin/${PKG_NAME}"

sed -i "s|@@PIPELINE_DIR@@|${PIPELINE_DIR}|g" "${PREFIX}/bin/${PKG_NAME}"

for dir in "${pipeline_dirs[@]}"; do
    cp -r "${dir}" "${PIPELINE_DIR}/"
done

for file in "${pipeline_files[@]}"; do
    cp "${file}" "${PIPELINE_DIR}/"
done

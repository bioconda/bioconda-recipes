#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/share/rnaframework/lib"
mkdir -p "${PREFIX}/bin"

cp -r lib/. "${PREFIX}/share/rnaframework/lib/"

SCRIPTS=(
    rf-combine
    rf-compare
    rf-correlate
    rf-count
    rf-count-genome
    rf-duplex
    rf-eval
    rf-fold
    rf-index
    rf-jackknife
    rf-json2rc
    rf-map
    rf-mmtools
    rf-modcall
    rf-motifdiscovery
    rf-mutate
    rf-norm
    rf-normfactor
    rf-peakcall
    rf-rctools
    rf-structextract
    rf-wiggle
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "${script}" ]; then
        cp "${script}" "${PREFIX}/share/rnaframework/${script}"
        chmod 755 "${PREFIX}/share/rnaframework/${script}"
        ln -sf "../share/rnaframework/${script}" "${PREFIX}/bin/${script}"
    else
        echo "WARNING: expected script '${script}' not found in source tree" >&2
    fi
done

echo "RNAFramework ${PKG_VERSION} installed successfully."

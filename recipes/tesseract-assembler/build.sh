#!/usr/bin/env bash
set -euo pipefail
# conda-build entry point. Kept separate from the inline script in meta.yaml so
# the same steps work when building from a local checkout.

mkdir -p "${PREFIX}/bin"

make -j"${CPU_COUNT:-4}" CXX="${CXX:-g++}"
make -j"${CPU_COUNT:-4}" CXX="${CXX:-g++}" tesseract-model

install -v -m 0755 tesseract tesseract-asm tesseract-model "${PREFIX}/bin"
install -v -m 0755 scripts/tesseract-get-models scripts/models.sha256 models/om2detect.sketch "${PREFIX}/bin"

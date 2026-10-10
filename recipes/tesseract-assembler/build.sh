#!/usr/bin/env bash
set -euo pipefail
# conda-build entry point. Kept separate from the inline script in meta.yaml so
# the same steps work when building from a local checkout.

mkdir -p "${PREFIX}/bin"

make -j"${CPU_COUNT:-4}" CXX="${CXX:-g++}"

install -v -m 0755 tesseract-asm "${PREFIX}/bin"
install -v -m 0755 tesseract-get-models "${PREFIX}/bin"
install -v -m 0755 tesseract-klebsiella "${PREFIX}/bin"
install -v -m 0755 tesseract-eskape "${PREFIX}/bin"
install -v -m 0755 models.sha256 "${PREFIX}/bin"

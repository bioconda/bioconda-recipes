#!/usr/bin/env bash
# conda-build entry point. Kept separate from the inline script in meta.yaml so
# the same steps work when building from a local checkout.
set -euo pipefail

make -j"${CPU_COUNT:-4}" CXX="${CXX:-g++}"

mkdir -p "${PREFIX}/bin"
install -m 0755 tessera "${PREFIX}/bin/tessera"
install -m 0755 tessera-model "${PREFIX}/bin/tessera-model"

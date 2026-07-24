#!/usr/bin/env bash

set -euo pipefail

export JULIA_CPU_TARGET=generic

julia --project="${SRC_DIR}/build" "${SRC_DIR}/build/build_app.jl"

install -d "${PREFIX}/libexec" "${PREFIX}/bin"
cp -R "${SRC_DIR}/build/compiled" "${PREFIX}/libexec/patchwork"
ln -s "../libexec/patchwork/bin/patchwork" "${PREFIX}/bin/patchwork"

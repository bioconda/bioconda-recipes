#!/bin/bash
set -euo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"
export HDF5_DIR="${PREFIX}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

cargo install --no-track --locked --root "${PREFIX}" --path . --bin rastqc \
  --features nanopore

# Rename so this variant can coexist with the core `rastqc` package in the same env.
mv "${PREFIX}/bin/rastqc" "${PREFIX}/bin/rastqc-nanopore"

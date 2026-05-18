#!/usr/bin/env bash
set -euxo pipefail

# Collect Rust dependency licenses for Bioconda license compliance checks.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build/install using the conda-provided maturin + Rust toolchain.
"${PYTHON}" -m pip install . \
  --no-deps \
  --no-build-isolation \
  --no-cache-dir \
  -vvv

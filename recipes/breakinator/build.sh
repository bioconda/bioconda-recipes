#!/usr/bin/env bash

set -eux -o pipefail

# --- 1. Environment Setup ---
export HTSLIB_SYSTEM=1
export OPENSSL_NO_VENDOR=1
export OPENSSL_DIR=$PREFIX
export LIBZ_SYS_STATIC=0
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# --- 2. Build & Install ---
cargo install --path breakinator --root "${PREFIX}" --no-track --verbose


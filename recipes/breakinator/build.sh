#!/usr/bin/env bash

set -ex

# --- 1. Environment Setup ---
# These ensure Rust links against the Conda-provided libraries
# rather than compiling them from scratch.
export HTSLIB_SYSTEM=1
export OPENSSL_NO_VENDOR=1
export OPENSSL_DIR=$PREFIX
export LIBZ_SYS_STATIC=0
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# --- 2. Build & Install ---
# Cargo install handles building --release and moving the binary to $PREFIX/bin automatically.
# We use --path . because usually the tarball unpacks exactly where Cargo.toml is.
cargo install --path breakinator --root "${PREFIX}" --no-track --verbose


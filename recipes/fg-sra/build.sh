#!/usr/bin/env bash
set -euo pipefail

# Point fg-sra-vdb-sys at the conda-installed ncbi-vdb.
export VDB_INCDIR="${PREFIX}/include"
export VDB_LIBDIR="${PREFIX}/lib"

# Build the fg-sra binary with default features disabled so the
# `vendored` code path (which would try to build ncbi-vdb from a
# bundled submodule via cmake) is skipped. fg-sra-vdb-sys will
# bindgen against $VDB_INCDIR and static-link $VDB_LIBDIR/libncbi-vdb.a.
cargo install \
    --locked \
    --no-track \
    --no-default-features \
    --root "${PREFIX}" \
    --path crates/fg-sra

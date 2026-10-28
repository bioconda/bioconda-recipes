#!/bin/bash
set -ex

# sassy's SIMD needs AVX2 on x86-64 (x86-64-v3). aarch64/arm64 use NEON, which
# the conda toolchain enables by default, so they need no override. The previous
# aarch64/arm64 values were target *triples*, not CPU names; rustc rejected them
# and dropped NEON, which tripped ensure_simd's AVX2/NEON compile_error.
case $(uname -m) in
    x86_64)
        export RUSTFLAGS="-C target-cpu=x86-64-v3"
        ;;
esac

# Bundle third-party licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build with cargo
RUST_BACKTRACE=1 cargo install --no-track --locked --root "${PREFIX}" --path .

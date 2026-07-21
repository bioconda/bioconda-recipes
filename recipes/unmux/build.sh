#!/bin/bash -e

# zlib-ng (via flate2's zlib-ng feature), libdeflate, and mimalloc are vendored C compiled by
# cc/cmake. Modern clang errors on implicit function declarations; relax that so those C builds
# succeed under the conda compilers.
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
export RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# x86_64 ships an AVX-512-aware multi-versioned binary. cargo-multivers (configured by
# [package.metadata.multivers.x86_64] in Cargo.toml: x86-64-v3 + v4) builds one codegen slice per
# CPU tier and packs them behind a CPUID dispatcher chosen at startup, so a single binary runs
# natively on both AVX2-only and AVX-512 hosts and an AVX2-only host never executes AVX-512 code.
# The >=0.12.0 floor carries the fexecve/memfd fix (ronnychevalier/cargo-multivers#30) the launcher
# needs to run under Docker amd64 emulation.
#
# aarch64 has NEON as a baseline (sassy's SIMD requirement is always met, no target-cpu flag), and
# cargo-multivers on a non-x86_64 target expands to every rustc-known CPU rather than microarch
# tiers, so there we build a single portable binary with the dist profile instead. The dist profile
# (fat LTO, one codegen unit, stripped) is the fast path on both architectures.
case "${target_platform}" in
  linux-64 | osx-64)
    cargo install --locked --version '>=0.12.0' cargo-multivers
    cargo multivers --profile dist --out-dir "${PREFIX}/bin"
    ;;
  *)
    cargo install --no-track --locked --verbose --profile dist --root "${PREFIX}" --path .
    ;;
esac

#!/bin/bash
set -euxo pipefail

# conda-build does not pass HOME through, so the default ~/.cargo is unusable.
export CARGO_HOME="${BUILD_PREFIX}/.cargo"

# The repo's .cargo/config.toml sets `-C target-feature=+avx2,+fma` for
# x86_64-unknown-linux-gnu, which would make the linux-64 binary SIGILL on
# x86-64 CPUs without AVX2/FMA. RUSTFLAGS outranks [target.<triple>].rustflags,
# so setting it restores the portable baseline; faer's matmul kernels select
# SIMD at runtime. The pin exists only for that triple, so scope to linux-64.
if [[ "${target_platform}" == "linux-64" ]]; then
  export RUSTFLAGS="${RUSTFLAGS:-}"
fi

# ethnum 1.5.2 (pulled in by polars) transmutes `()` into core's TryFromIntError,
# which is no longer zero-sized on current rustc (E0512 on rust 1.98.1). ethnum
# 1.5.3 constructs the error safely; bump only that crate. Drop this once
# upstream's Cargo.lock carries ethnum >= 1.5.3.
cargo update -p ethnum --precise 1.5.3

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Default features only (the optional `gpu` feature needs CUDA).
RUST_BACKTRACE=1 cargo install --verbose --locked --no-track --root "${PREFIX}" --path .

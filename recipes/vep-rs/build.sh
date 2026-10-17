#!/usr/bin/env bash
set -euo pipefail

# Any RUSTFLAGS replaces the target-cpu the source's .cargo/config.toml pins,
# so the package builds for the target's baseline CPU. It also replaces the
# rpath flags conda's Rust activation sets in CARGO_BUILD_RUSTFLAGS, which are
# carried over here.
export RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS:-}"
export OPENSSL_DIR="${PREFIX}"
export CARGO_HOME="${SRC_DIR}/.cargo-home"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release --locked --bin vep --bin vep-cache-builder --bin vep-cache-converter

out="target/${CARGO_BUILD_TARGET:+${CARGO_BUILD_TARGET}/}release"
mkdir -p "${PREFIX}/bin"
for bin in vep vep-cache-builder vep-cache-converter; do
    install -m 0755 "${out}/${bin}" "${PREFIX}/bin/${bin}"
done

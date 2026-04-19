#!/bin/bash
set -ex

case $(uname -m) in
    aarch64)
        export RUSTFLAGS="-C target-cpu=aarch64-unknown-linux-gnu"
        ;;
    arm64)
        export RUSTFLAGS="-C target-cpu=aarch64-apple-darwin"
        ;;
    x86_64)
        export RUSTFLAGS="-C target-cpu=x86-64-v3"
        ;;
esac

# Bundle third-party licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build with cargo
RUST_BACKTRACE=1
RUSTFLAGS="${RUSTFLAGS}" cargo install --no-track --locked --root "${PREFIX}" --path .

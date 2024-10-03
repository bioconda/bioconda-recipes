#!/bin/bash 

set -xeuo

case $(uname -m) in
    aarch64 | arm64)
        FEATURES="--no-default-features --features neon"
        ;;
    *)
        FEATURES=""
        ;;
esac

# build statically linked binary with Rust
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 cargo install --verbose --locked --no-track --root $PREFIX --path . ${FEATURES}
cp scripts/* $PREFIX/bin

#!/bin/bash

set -xeuo

# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_HOME="$(pwd)/.cargo"

# build statically linked binary with Rust
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

case $(uname -m) in
    aarch64 | arm64)
        FEATURES="--features neon --no-default-features"
        ;;
    *)
        FEATURES=""
        ;;
esac

RUST_BACKTRACE=1 cargo install --verbose --locked --no-track --root $PREFIX --path . ${FEATURES}
cp scripts/* $PREFIX/bin

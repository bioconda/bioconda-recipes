#!/bin/bash -euo

set -xe

if [[ -n "$OSX_ARCH" ]]; then
    # Set this so that it doesn't fail with open ssl errors
    export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --path . --root ${PREFIX}

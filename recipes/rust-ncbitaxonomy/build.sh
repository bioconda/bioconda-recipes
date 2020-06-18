#!/bin/bash -euo

if [ "$(uname)" == "Darwin" ]; then
    # Apparently the Home variable isn't set correctly
    export HOME="/Users/distiller"

    # According to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 remove circle ci default configuration solve cargo trouble
    git config --global --unset url.ssh://git@github.com.insteadOf 
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1 C_INCLUDE_PATH=$PREFIX/include RUSTFLAGS="-L $PREFIX/lib" cargo install --verbose --root $PREFIX --path .

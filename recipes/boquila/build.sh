#!/bin/bash -euo

# build statically linked binary with Rust
RUST_BACKTRACE=1 C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --path $SRC_DIR --verbose --root $PREFIX
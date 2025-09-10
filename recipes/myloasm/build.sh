#!/bin/bash -euo

export CFLAGS="${CFLAGS} -O3 -Wno-cpp -Wno-unused-function -Wno-implicit-function-declaration -Wno-int-conversion"
git submodule update --init --recursive
# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX

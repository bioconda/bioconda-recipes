#!/bin/bash -euo

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --root ${PREFIX} --path .

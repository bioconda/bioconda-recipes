#!/bin/bash

set -xe

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Use conda-provided AR and RANLIB if set, to avoid broken llvm-ranlib on macOS
if [ -n "$AR" ]; then
  export CMAKE_AR="$AR"
fi
if [ -n "$RANLIB" ]; then
  export CMAKE_RANLIB="$RANLIB"
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1 C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --verbose --root $PREFIX --path . --no-track

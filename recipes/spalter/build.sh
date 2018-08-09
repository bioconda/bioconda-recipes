#!/bin/bash -e

# build statically linked binary with Rust
LIBRARY_PATH="${PREFIX}/lib" \
  C_INCLUDE_PATH="${PREFIX}/include" \
  CPLUS_INCLUDE_PATH="${PREFIX}/include" \
  cargo install --root "${PREFIX}"

#!/bin/bash -euo

# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --root $PREFIX

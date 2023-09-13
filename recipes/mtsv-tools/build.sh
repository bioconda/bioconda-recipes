#!/bin/bash -e
# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --path $SRC_DIR/ --root $PREFIX

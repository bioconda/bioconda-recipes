#!/bin/bash

set -xe

# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include OPENSSL_DIR=$PREFIX LIBRARY_PATH=$PREFIX/lib cargo install --verbose --path . --root "${PREFIX}" --no-track

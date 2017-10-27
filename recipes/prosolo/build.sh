#!/bin/bash -euo

# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib:/usr/lib64 cargo install --root $PREFIX --verbose --debug

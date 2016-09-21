#!/bin/bash -e

# build statically linked binary with Rust
LIBRARY_PATH=$PREFIX/lib cargo install --root $PREFIX

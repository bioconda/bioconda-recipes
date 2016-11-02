#!/bin/bash -euo

# build statically linked binary with Rust
LIBRARY_PATH=$PREFIX/lib cargo build --release

cp target/release/prosic $PREFIX/bin

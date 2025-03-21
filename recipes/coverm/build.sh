#!/bin/bash -e



C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
cargo build --release

cargo install --root $PREFIX

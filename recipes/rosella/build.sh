#!/bin/bash -e

# PREFIX=$CONDA_PREFIX
echo $PREFIX
echo $CONDA_PREFIX

# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
LD_LIBRARY_PATH=$PREFIX/lib \
LIBCLANG_PATH=$PREFIX/lib/libclang.so \
cargo build --release

# Install the binaries
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
LD_LIBRARY_PATH=$PREFIX/lib \
LIBCLANG_PATH=$PREFIX/lib/libclang.so \
cargo install --path ./ --force --root $PREFIX
# cp target/release/rosella $PREFIX/bin
# cp target/release/remove_minimap2_duplicated_headers $PREFIX/bin

# Install flight
# cd flight/ && pip install . && cd ../
pip install git+https://github.com/rhysnewell/flight

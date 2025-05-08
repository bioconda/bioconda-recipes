#!/bin/bash -e

# build statically linked binary with Rust
RUST_BACKTRACE=1 \
 C_INCLUDE_PATH=$PREFIX/include \
 LIBRARY_PATH=$PREFIX/lib \
 cargo build --release

mkdir $PREFIX/bin
cp $SRC_DIR/target/*/release/transanno $PREFIX/bin/transanno
chmod a+x $PREFIX/bin/transanno

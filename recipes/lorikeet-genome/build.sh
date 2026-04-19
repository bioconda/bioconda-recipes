#!/bin/bash -e

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang.so \
OPENSSL_DIR=$PREFIX \
cargo build --release

# Install the binaries
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang.so \
OPENSSL_DIR=$PREFIX \
cargo install --path ./ --force --root $PREFIX

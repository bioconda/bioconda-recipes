#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
C_INCLUDE_PATH="$PREFIX/include" OPENSSL_DIR="$PREFIX" LIBRARY_PATH="$PREFIX/lib" cargo install --verbose --path . --root "${PREFIX}" --no-track

"${STRIP}" "$PREFIX/bin/tidk"

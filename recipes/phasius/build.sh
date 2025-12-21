#!/bin/bash
set -xeuo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -fcommon -O3"
export CXXFLAGS="${CFLAGS} -fcommon -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
export LD="${CC}"
C_INCLUDE_PATH="$PREFIX/include" LIBRARY_PATH="$PREFIX/lib" RUST_BACKTRACE=1 cargo install --verbose --root "${PREFIX}" --path . --no-track

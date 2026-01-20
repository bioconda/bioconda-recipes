#!/bin/bash -euo
set -xe

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

# build statically linked binary with Rust
export LD="$CC"
RUST_BACKTRACE=1
C_INCLUDE_PATH="$PREFIX/include" LIBRARY_PATH="$PREFIX/lib" cargo install -v --root "$PREFIX" --path . --no-track --locked

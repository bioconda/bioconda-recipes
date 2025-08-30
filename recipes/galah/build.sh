#!/bin/bash -e

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

# Build statically linked binary with Rust
C_INCLUDE_PATH="$PREFIX/include" \
  LIBRARY_PATH="$PREFIX/lib" \
  cargo build --release

# Install the binary
install -v -m 0755 target/release/galah "$PREFIX/bin"

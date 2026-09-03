#!/bin/bash -e

export C_INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --root "$PREFIX" --path . --no-track

# Strip the binary
"${STRIP}" "$PREFIX/bin/mfqe"

#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"

export OS=$(uname -s)
export ARCH=$(uname -m)

# build binary with Rust
export RUSTC_BOOTSTRAP=1
# build binary with Rust
RUSTFLAGS="-C target-cpu=native" cargo install --features visual --locked --no-track -v --path . --root "$PREFIX"

"${STRIP}" "$PREFIX/bin/turboani"
"${STRIP}" "$PREFIX/bin/fastani"

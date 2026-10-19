#!/bin/bash -e
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}" --locked

"${STRIP}" "${PREFIX}/bin/galah"

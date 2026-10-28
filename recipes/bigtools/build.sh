#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export RUST_BACKTRACE=full
cargo install --verbose --path ./bigtools --root "$PREFIX" --locked --no-track

"${STRIP}" "$PREFIX/bin/bigtools"

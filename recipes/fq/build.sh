#!/usr/bin/env bash
set -eu

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install --verbose --locked --no-track --root "$PREFIX" --path .

"${STRIP}" "$PREFIX/bin/fq"

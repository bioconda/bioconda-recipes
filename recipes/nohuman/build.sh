#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=full
cargo install -v --locked --no-track --root "${PREFIX}" --path .

"$STRIP" "$PREFIX/bin/nohuman"

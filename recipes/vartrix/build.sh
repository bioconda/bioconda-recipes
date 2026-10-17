#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -std=gnu11"

mkdir -p "${PREFIX}/bin"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo update -p rust-htslib --precise 0.48.0
cargo update -p rustc-serialize --precise 0.3.25
cargo update -p num-complex@0.1.43 --precise 0.1.44

RUST_BACKTRACE=1
cargo install --verbose --locked --no-track --root "$PREFIX" --path .

"${STRIP}" "$PREFIX/bin/vartrix"

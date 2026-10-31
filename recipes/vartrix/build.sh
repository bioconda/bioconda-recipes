#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -std=gnu11"
export LIBCLANG_PATH="$BUILD_PREFIX/lib"

mkdir -p "${PREFIX}/bin"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install --verbose --locked --no-track --profile=release --root "$PREFIX" --path .

"${STRIP}" "$PREFIX/bin/vartrix"

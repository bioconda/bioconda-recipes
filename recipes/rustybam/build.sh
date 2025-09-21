#!/bin/bash -e

export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

sed -i.bak 's|"0.44"|"0.47.1"|' Cargo.toml
rm -f *.bak

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install -v --no-track --root "${PREFIX}" --path .

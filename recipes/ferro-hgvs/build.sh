#!/bin/bash -e

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
CARGO_PROFILE_RELEASE_LTO=thin \
  cargo install --no-track --locked -v --root "${PREFIX}" --path . --features "benchmark,hgvs-rs"

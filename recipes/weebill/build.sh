#!/bin/bash -e
set -ex

export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}" --locked

"${STRIP}" "${PREFIX}/bin/weebill"

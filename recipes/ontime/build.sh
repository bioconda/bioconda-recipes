#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CFLAGS} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=full
cargo install -v --no-track --root "${PREFIX}" --path .

"${STRIP}" "${PREFIX}/bin/ontime"

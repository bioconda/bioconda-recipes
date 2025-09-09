#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install -v --no-track --root "${PREFIX}" --path .

# Copy R scripts
mkdir -p $PREFIX/share/rastair/scripts
cp -R scripts/* $PREFIX/share/rastair/scripts/

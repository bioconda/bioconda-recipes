#!/bin/bash -exuo

export INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CFLAGS} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

sed -i.bak 's|0.39.5|0.47.1|' Cargo.toml
rm -rf *.bak

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --no-track --path . --root "${PREFIX}"

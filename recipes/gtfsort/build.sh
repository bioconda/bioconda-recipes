#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cd gtfsort

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo build --package gtfsort --release -j "${CPU_COUNT}"

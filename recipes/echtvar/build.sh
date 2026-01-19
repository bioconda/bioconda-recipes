#!/bin/bash
set -o xtrace -o nounset -o pipefail -o errexit

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

sed -i.bak 's|"0.38.2"|"0.47.1"|' Cargo.toml
rm -rf *.bak

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --locked --root "${PREFIX}" --path .

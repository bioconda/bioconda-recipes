#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

mkdir -p "${PREFIX}/include"
mkdir -p "${PREFIX}/lib"

cp -f ${RECIPE_DIR}/build_htslib.sh d4-hts/build_htslib.sh

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

cd d4binding

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo build --release --package=d4binding --lib

ls
ls ../

install -v -m 644 include/d4.h "${PREFIX}/include"
install -v -m 644 ../target/release/libd4binding.* "${PREFIX}/lib"

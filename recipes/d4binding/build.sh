#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

mkdir -p "${PREFIX}/include"
mkdir -p "${PREFIX}/lib"

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
  export TARGET="aarch64-apple-darwin"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
  export TARGET="aarch64-unknown-linux-gnu"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
  export TARGET="x86_64-apple-darwin"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "x86_64" ]]; then
  export TARGET="x86_64-unknown-linux-gnu"
fi

cp -f ${RECIPE_DIR}/build_htslib.sh d4-hts/build_htslib.sh

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cd d4binding

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo build --release --package d4binding --lib -j "${CPU_COUNT}"

install -v -m 644 include/d4.h "${PREFIX}/include"
install -v -m 644 ../target/${TARGET}/release/libd4binding.* "${PREFIX}/lib"

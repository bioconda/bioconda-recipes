#!/bin/bash
set -xe

mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/lib

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cp -f ${RECIPE_DIR}/build_htslib.sh d4-hts/build_htslib.sh

cd d4binding

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo build --release --package=d4binding

install -m 644 include/d4.h ${PREFIX}/include
install -m 644 target/release/libd4binding.* ${PREFIX}/lib

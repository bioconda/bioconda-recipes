#!/bin/bash -euo

export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak 's|2024|2021|' Cargo.toml
rm -f *.bak

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --root "${PREFIX}" --no-track --locked --path .

"${STRIP}" "${PREFIX}/bin/inquiSTR"

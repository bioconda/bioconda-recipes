#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -ldeflate"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -fcommon"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

sed -i.bak 's|"0.16.2"|"0.18.0"|' Cargo.toml
sed -i.bak 's|"0.39.5"|"0.47.1"|' Cargo.toml
rm -f *.bak

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --root "${PREFIX}" --path .

"${STRIP}" "${PREFIX}/bin/mudskipper"

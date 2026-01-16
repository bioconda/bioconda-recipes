#!/bin/bash -eu

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -ldeflate"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PYO3_PYTHON="${PYTHON}"

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

sed -i.bak 's|"0.3.3"|{ version = "0.3.7", features = ["ab_glyph", "fontconfig-dlopen"] }|' Cargo.toml
rm -f *.bak

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
RUSTFLAGS="-L ${PREFIX}/include" cargo install -v --no-track --locked --root "${PREFIX}" --path .

"${STRIP}" "${PREFIX}/bin/orthanq"

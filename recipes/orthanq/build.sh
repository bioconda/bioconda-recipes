#!/bin/bash -eu

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PYO3_PYTHON="${PYTHON}"

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
export RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib -L ${PREFIX}/lib"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install -v --no-track --locked --root "${PREFIX}" --path .

"${STRIP}" "${PREFIX}/bin/orthanq"

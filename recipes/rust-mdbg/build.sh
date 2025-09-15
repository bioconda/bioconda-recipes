#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"
export RUSTFLAGS="-C linker=${CC}"
export CARGO_BUILD_TARGET="${CC}"

if [[ "${target_platform}"  == "linux-aarch64" ]]; then
        export CFLAGS="${CFLAGS} -fno-dse"
fi

RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

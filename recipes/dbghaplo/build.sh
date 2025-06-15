#!/bin/bash
set -xeuo

export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

case $(uname -m) in
    aarch64 | arm64)
        FEATURES="--no-default-features --features neon"
        ;;
    *)
        FEATURES=""
        ;;
esac

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --locked --no-track --root "${PREFIX}" --path . "${FEATURES}"
cp -f scripts/* "${PREFIX}/bin"

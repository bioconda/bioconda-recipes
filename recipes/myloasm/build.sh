#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-cpp -Wno-unused-function -Wno-implicit-function-declaration -Wno-int-conversion"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1

case $(uname -m) in
    aarch64|arm64) cargo install -v --no-track --path . --root "$PREFIX" --features=neon --no-default-features ;;
    *) cargo install -v --no-track --path . --root "$PREFIX" ;;
esac

"${STRIP}" "$PREFIX/bin/myloasm"

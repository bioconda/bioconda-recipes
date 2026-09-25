#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-cpp -Wno-unused-function -Wno-implicit-function-declaration -Wno-int-conversion"

cd src && rm -rf rust-spoa
git clone https://github.com/bluenote-1577/rust-spoa.git && cd rust-spoa
git checkout 8a6e44bd802a256e8e369afd697543bf9cf7f23d
git submodule update --init --recursive
cd ../../

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1

case $(uname -m) in
    aarch64|arm64) cargo install -v --no-track --path . --root "$PREFIX" --features=neon --no-default-features ;;
    *) cargo install -v --no-track --path . --root "$PREFIX" ;;
esac

"${STRIP}" "$PREFIX/bin/myloasm"

#!/bin/bash -euo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

rustc - --crate-name probe --crate-type bin --print=cfg < /dev/null

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --no-track --path . --root "${PREFIX}"

"${STRIP}" "$PREFIX/bin/autocycler"

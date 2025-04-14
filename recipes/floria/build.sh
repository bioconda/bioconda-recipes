#!/bin/bash -euo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
  export CFLAGS="${CFLAGS} -O3 -Wno-int-conversion -Wno-implicit-function-declaration"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --no-track --path . --root "${PREFIX}"

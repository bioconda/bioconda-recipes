#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --no-track --path . --root "$PREFIX" --locked

"${STRIP}" "$PREFIX/bin/myloasm-kmc-v1"

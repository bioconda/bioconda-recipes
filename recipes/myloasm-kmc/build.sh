#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cargo install -v --no-track --path . --root "$PREFIX"

"${STRIP}" "$PREFIX/bin/myloasm-kmc-v1"

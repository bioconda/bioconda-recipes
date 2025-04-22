#!/bin/bash

set -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

# build statically linked binary with Rust
RUST_BACKTRACE=1
maturin build -b cffi --interpreter "${PYTHON}" --release --strip --frozen -f

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

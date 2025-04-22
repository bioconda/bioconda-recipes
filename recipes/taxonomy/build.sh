#!/bin/bash

set -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
maturin build --find-interpreter --release --strip --frozen -b cffi
# --interpreter "${PYTHON}"

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

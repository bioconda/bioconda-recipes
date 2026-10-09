#!/bin/bash
set -euo pipefail

export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export CARGO_BUILD_JOBS="${CPU_COUNT}"
export CARGO_INCREMENTAL=0

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release --locked --bin pqsio --lib

install -Dm755 target/release/pqsio "${PREFIX}/bin/pqsio"
install -Dm755 target/release/libpqsio.so "${PREFIX}/lib/libpqsio.so"
install -Dm644 include/pqsio.h "${PREFIX}/include/pqsio.h"
install -Dm644 include/pqsio.hpp "${PREFIX}/include/pqsio.hpp"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv

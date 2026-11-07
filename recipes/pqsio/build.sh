#!/bin/bash
set -euo pipefail

export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export CARGO_BUILD_JOBS=2
export CARGO_INCREMENTAL=0

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
pqsio_target="${CARGO_BUILD_TARGET:-$(rustc -vV | sed -n 's/^host: //p')}"
cargo build --release --locked --bin pqsio --lib \
    --target "${pqsio_target}" --target-dir target
pqsio_artifacts="target/${pqsio_target}/release"

install -Dm755 "${pqsio_artifacts}/pqsio" "${PREFIX}/bin/pqsio"
install -Dm755 "${pqsio_artifacts}/libpqsio.so" "${PREFIX}/lib/libpqsio.so"
install -Dm644 include/pqsio.h "${PREFIX}/include/pqsio.h"
install -Dm644 include/pqsio.hpp "${PREFIX}/include/pqsio.hpp"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv

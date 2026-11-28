#!/bin/bash
set -euo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS:-} ${CFLAGS:-}"
export OPENSSL_DIR="${PREFIX}"
export OPENSSL_NO_VENDOR=1

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

cargo install --locked --no-track --path . --root "${PREFIX}"

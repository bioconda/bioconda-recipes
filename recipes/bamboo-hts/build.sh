#!/bin/bash
set -exuo pipefail

if [ "$(uname)" == "Darwin" ]; then
    SHLIB_EXT="dylib"
    CLANG_ROOT="${PREFIX}"
    export DYLD_FALLBACK_LIBRARY_PATH="${CLANG_ROOT}/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"
else
    SHLIB_EXT="so"
    CLANG_ROOT="${BUILD_PREFIX}"
    export LD_LIBRARY_PATH="${CLANG_ROOT}/lib:${LD_LIBRARY_PATH:-}"
fi

export LIBCLANG_PATH="${CLANG_ROOT}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="-I${PREFIX}/include"
TARGET_LIB="${LIBCLANG_PATH}/libclang.${SHLIB_EXT}"

if [ ! -f "${TARGET_LIB}" ]; then
    FOUND_LIB="$(find "${LIBCLANG_PATH}" -name "libclang*.${SHLIB_EXT}*" ! -name "*cpp*" | head -n 1 || true)"
    if [ -n "${FOUND_LIB}" ]; then
        ln -sf "${FOUND_LIB}" "${TARGET_LIB}"
    fi
fi

"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vvv
#!/bin/bash
set -euo pipefail

export RUST_BACKTRACE=1

# bindgen (rust-htslib's htslib bindings) loads libclang from the build env. It
# parses the C headers with the compiler flags and, on Linux, the GCC sysroot.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS:-} ${CPPFLAGS:-}"
if [[ "$(uname)" == "Linux" ]]; then
  sysroot="${CONDA_BUILD_SYSROOT:-${BUILD_PREFIX}/${HOST}/sysroot}"
  if [[ -d "${sysroot}" ]]; then
    export BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS} --sysroot=${sysroot}"
  fi
fi

# The OpenMP runtime for XGBoost on macOS: llvm-openmp in the host env.
if [[ "$(uname)" == "Darwin" ]]; then
  export WINNOWR_LIBOMP_PREFIX="${PREFIX}"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

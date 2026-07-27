#!/bin/bash -e

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

# Fix: conda's llvm-ranlib doesn't support macOS-specific ranlib flags
sed -i.bak '/-no_warning_for_no_symbols/d' vendor/ncbi-vdb/build/env.cmake

# Parallelize the vendored ncbi-vdb cmake build
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"
export RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/fg-sra

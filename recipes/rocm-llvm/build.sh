#!/bin/bash

set -ex

mkdir -p build

cd build

cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DBUILD_SHARED_LIBS=ON \
      -DLLVM_BUILD_LLVM_DYLIB=ON \
      -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
      -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86" \
      -DLLVM_ENABLE_ASSERTIONS=OFF \
      ../llvm

ninja -j"${CPU_COUNT}"

ninja install

#!/bin/bash
set -euo pipefail

mkdir -p build
cd build

cmake \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DDORADO_3RD_PARTY_DOWNLOAD="${SRC_DIR}/download" \
    -DOPENSSL_ROOT_DIR="${PREFIX}" \
    -DDORADO_DISABLE_TESTS=ON \
    -DDORADO_DISABLE_PACKAGING=ON \
    -DDORADO_DISABLE_CCACHE=ON \
    ..

cmake --build . --parallel "${CPU_COUNT}"
cmake --install .

# Replace Debian cuDNN links with relative links.
for lib in "${PREFIX}"/lib/libcudnn*.so.9; do
    ln -sfn "$(basename "$lib")" "${lib%.so.9}.so"
done

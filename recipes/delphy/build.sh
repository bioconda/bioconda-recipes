#!/bin/bash
set -euo pipefail

# GCC 14 flags a CHECK(false) fall-through in abseil's log macros as -Werror=return-type.
sed -i.bak '/^  -Werror /d' CMakeLists.txt && rm CMakeLists.txt.bak

mkdir -p build
cd build

# Values from upstream CMakeLists.txt (BUILD_PREV_GIT_HASH) and the 1.4.1 tag commit.
cmake ${CMAKE_ARGS} .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_GOOGLETEST="${SRC_DIR}/googletest" \
  -DDELPHY_GIT_HASH=1e8d4a9 \
  -DDELPHY_PREV_GIT_HASH=1bfff2f

cmake --build . --target delphy delphy_mcc --parallel "${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -m 0755 delphy delphy_mcc "${PREFIX}/bin/"

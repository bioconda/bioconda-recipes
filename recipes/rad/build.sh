#!/usr/bin/env bash
set -euo pipefail

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

# configure CMake: install into $PREFIX
cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
   "${CONFIG_ARGS}"

# build and install
cmake --build build --clean-first -j "${CPU_COUNT}"
cmake --install build --prefix "${PREFIX}"
#super lazy local fix
install -v -m 0755 ./build/rad "${PREFIX}/bin/rad"

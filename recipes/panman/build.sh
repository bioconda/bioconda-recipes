#!/bin/bash

# ---- Build and install ----
mkdir -p "${PREFIX}/bin"
cp -rf ${RECIPE_DIR}/CMakeLists.txt $SRC_DIR/CMakeLists.txt

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname -s` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DTBB_DIR="${PREFIX}/lib/cmake/tbb" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli \
    "${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}"
install -v -m 0755 build/panmanUtils "${PREFIX}/bin"

#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"


cp -rf ${RECIPE_DIR}/CMakeLists.txt $SRC_DIR/CMakeLists.txt

# Detect if we're building CPU-only version (dipper-cpu)
if [[ "${PKG_NAME}" == "dipper-cpu" ]]; then
  BUILD_CPU_ONLY=true
else
  BUILD_CPU_ONLY=false
fi

if [[ `uname -m` == "aarch64" ]]; then
  # On aarch64, always build CPU-only
  BUILD_CPU_ONLY=true
fi

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
  # macOS doesn't support CUDA, so always build CPU-only
  BUILD_CPU_ONLY=true
fi

EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DTBB_DIR="${PREFIX}/lib/cmake/TBB" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli"

if [ "$BUILD_CPU_ONLY" = true ]; then
  # Build CPU-only version (dipper-cpu)
  cmake -S . -B build ${EXTRA_FLAGS} ${CONFIG_ARGS} -DUSE_CPU=ON -DUSE_CUDA=OFF -DUSE_HIP=OFF
  cmake --build build -j "${CPU_COUNT}"
  install -m 0755 bin/dipper_cpu "${PREFIX}/bin/"
else
  # Build full version with CUDA support (dipper)
  cmake -S . -B build ${EXTRA_FLAGS} ${CONFIG_ARGS} -DUSE_CUDA=ON -DUSE_HIP=OFF -DUSE_CPU=OFF
  cmake --build build -j "${CPU_COUNT}"
  install -m 0755 bin/dipper "${PREFIX}/bin/"
fi
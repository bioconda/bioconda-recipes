#!/bin/bash

# ---- Build and install ----
mkdir -p "${PREFIX}/bin"
cp -rf ${RECIPE_DIR}/CMakeLists.txt $SRC_DIR/CMakeLists.txt

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
	-DBOOST_ROOT="${PREFIX}" -Wno-dev -Wno-deprecated \
	--no-warn-unused-cli \
    -DTBB_DIR="${PREFIX}/lib/cmake/tbb" \
    "${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/wepp ${PREFIX}/bin

# Copy WEPP files to $PREFIX/WEPP
mkdir -p $PREFIX/WEPP
cp -rf "${SRC_DIR}"/* "${PREFIX}/WEPP"

# Copy the build directory
cp -rf build "${PREFIX}/WEPP/"

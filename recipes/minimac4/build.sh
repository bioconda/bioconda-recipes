#!/bin/bash
set -euo pipefail

echo "Building Minimac4 version ${PKG_VERSION}"

# Set CXXFLAGS to include the correct path to lzma.h and LDFLAGS to include the path to liblzma
export CXXFLAGS="-I${PREFIX}/include -I${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib -llzma"
CMAKE_MAKE_PROGRAM="$(which make)"
CMAKE_C_COMPILER="${CC}"
CMAKE_CXX_COMPILER="${CXX}"

export CMAKE_MAKE_PROGRAM
export CMAKE_C_COMPILER
export CMAKE_CXX_COMPILER

# Set up dependencies and directories
if [ ! -f ./requirements.txt ]; then
    echo "Error: requirements.txt not found"
    exit 1
fi
cget ignore xz || exit 1
cget install -f ./requirements.txt || exit 1

cmake --version
mkdir -p build || exit 1
cd build || exit 1

cmake \
    -DBUILD_TESTS=1 \
    -DCMAKE_TOOLCHAIN_FILE=../cget/cget/cget.cmake \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM} \
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} \
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCPACK_GENERATOR="STGZ" \
    -DCPACK_PACKAGE_CONTACT="csg-devel@umich.edu" \
    ..

make || exit 1
make install || exit 1
make CTEST_OUTPUT_ON_FAILURE=1 test || exit 1
echo "Minimac4 installation completed successfully"

cd .. || exit 1

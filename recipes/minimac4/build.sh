#!/bin/bash
#set -euo pipefail

echo "Building Minimac4 version ${PKG_VERSION}"

# Set up dependencies and directories
cget ignore xz
cget install -f ./requirements.txt
cmake --version
mkdir -p build
cd build

# Set CXXFLAGS to include the correct path to lzma.h and LDFLAGS to include the path to liblzma
export CXXFLAGS="-I${PREFIX}/include -I${PREFIX}/bin -I${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib -llzma"
export CMAKE_MAKE_PROGRAM=$(which make)
export CMAKE_C_COMPILER=${CC}
export CMAKE_CXX_COMPILER=${CXX}

cmake \
    -DBUILD_TESTS=1 \
    -DCMAKE_TOOLCHAIN_FILE=../cget/cget/cget.cmake \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_MAKE_PROGRAM=$(which make) \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    -DCPACK_GENERATOR="STGZ" \
    -DCPACK_PACKAGE_CONTACT="csg-devel@umich.edu" \
    ..

make
make install
make CTEST_OUTPUT_ON_FAILURE=1 test
echo "Minimac4 installation completed successfully"

cd .. || exit 1

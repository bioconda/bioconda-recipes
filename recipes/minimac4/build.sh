#!/bin/bash
set -euo pipefail

echo "Building Minimac4 version ${PKG_VERSION}"

# Set CXXFLAGS to include the correct path to lzma.h and LDFLAGS to include the path to liblzma
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -I${PREFIX}/include -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -llzma"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

sed -i.bak 's|VERSION 3.2|VERSION 3.5|' src/CMakeLists.txt
rm -f src/*.bak

# Set up dependencies and directories
if [[ ! -f ./requirements.txt ]]; then
    echo "Error: requirements.txt not found"
    exit 1
fi
cget ignore xz || exit 1
cget install -f ./requirements.txt || exit 1

cmake -S . -B build -DBUILD_TESTS=1 \
	-DCMAKE_TOOLCHAIN_FILE=cget/cget/cget.cmake \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	-DCPACK_GENERATOR="STGZ" \
	-DCPACK_PACKAGE_CONTACT="csg-devel@umich.edu" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cd build

make -j"${CPU_COUNT}" || exit 1
make install || exit 1
make CTEST_OUTPUT_ON_FAILURE=1 test || exit 1
echo "Minimac4 installation completed successfully"

cd .. || exit 1

#!/bin/bash
set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"

sed -i.bak 's|if (NOT TARGET dssp)|find_package(dssp QUIET)\nif(NOT TARGET dssp::dssp AND NOT TARGET dssp)|g' CMakeLists.txt
sed -i.bak 's|${CIFPP_SHARE_DIR}|$ENV{PREFIX}/share/libcifpp|g' CMakeLists.txt
rm -rf *.bak

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja \
	${CMAKE_ARGS} \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_STANDARD=20 \
	-DBUILD_TESTING=ON \
	-DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --config Release -j "${CPU_COUNT}"
ctest -V -C Release --test-dir build
cmake --install build

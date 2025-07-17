#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -ldl"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

rm -rf cmake-build-release
mkdir -p cmake-build-release

echo "Step 1"
echo $PWD
echo "...SRCDIR= $SRC_DIR"
export VERBOSE=1

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
 	-DCMAKE_MAKE_PROGRAM=make \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-G "CodeBlocks - Unix Makefiles" \
	-S . \
	-B cmake-build-release \
	-DCMAKE_VERBOSE_MAKEFILE=ON

echo "Step 2"
echo $PWD
echo "cmake --build cmake-build-release --target protal -- -j ${CPU_COUNT}"

cmake --build cmake-build-release --clean-first --target protal -- -j ${CPU_COUNT}
cmake --build cmake-build-release --clean-first --target protal_avx2 -- -j ${CPU_COUNT}

cp -f cmake-build-release/protal ${PREFIX}/bin/protal_plain
cp -f cmake-build-release/protal_avx2 ${PREFIX}/bin/protal_avx2
cp -f protal_launcher ${PREFIX}/bin/protal

#!/bin/bash
set -ex

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="$CXXFLAGS -std=c++14"

if [ "$(uname)" == Darwin ]; then
	export CMAKE_C_COMPILER="clang"
	export CMAKE_CXX_COMPILER="clang++"
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release \
	-DUSE_LSD2=ON -DIQTREE_FLAGS=omp -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"

case $(uname -m) in
	aarch64) 
		JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values 
		;;
	*)
		JOBS=${CPU_COUNT}
		;;
esac

cmake --build build --target install -j 1

cp -f "${PREFIX}"/bin/iqtree2 "${PREFIX}"/bin/iqtree

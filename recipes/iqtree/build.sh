#!/bin/bash

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

mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX:PATH="${PREFIX}" -DUSE_LSD2=ON -DIQTREE_FLAGS=omp ..

case $(uname -m) in
	aarch64) 
		JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values 
		;;
	*)
		JOBS=${CPU_COUNT}
		;;
esac

make --jobs=${JOBS}
make install
cp "${PREFIX}"/bin/iqtree2 "${PREFIX}"/bin/iqtree

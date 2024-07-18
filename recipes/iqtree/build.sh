#!/bin/bash
set -ex

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -w"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -w"
export CXXFLAGS="${CXXFLAGS} -std=c++14 -w"

if [ "$(uname)" == Darwin ]; then
	export CMAKE_C_COMPILER="clang"
	export CMAKE_CXX_COMPILER="clang++"
	export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=11"
	CC=$(which "$CC")
	CXX=$(which "$CXX")
	AR=$(which "$AR")
	RANLIB=$(which "$RANLIB")
	DCMAKE_ARGS=(-DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}"
		-DCMAKE_CXX_COMPILER_AR="${AR}" -DCMAKE_CXX_COMPILER_RANLIB="${RANLIB}")
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release \
	-DUSE_LSD2=ON -DIQTREE_FLAGS=omp -DUSE_CMAPLE=ON \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" "${DCMAKE_ARGS[@]}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli

case $(uname -m) in
	aarch64) 
		JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values 
		;;
	*)
		JOBS=${CPU_COUNT}
		;;
esac

VERBOSE=1 cmake --build build --target install -j "${JOBS}"

chmod 755 "${PREFIX}/bin/iqtree2"
cp -f "${PREFIX}"/bin/iqtree2 "${PREFIX}"/bin/iqtree

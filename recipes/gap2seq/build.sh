#!/bin/bash
set -xe -o pipefail

export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="$CPPFLAGS -I${PREFIX}/include -Wno-deprecated-declarations"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export BOOST_ROOT="${PREFIX}"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

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

if [[ "$(uname -s)" == "Darwin" ]]; then
	# c++11 compatibility
	LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";

	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
	export CXX_FLAGS="${CXX_FLAGS} -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
	export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
	export LDFLAGS="${LDFLAGS} -stdlib=libc++"
	export LD_FLAGS="${LD_FLAGS} -stdlib=libc++"
	export CMAKE_LDFLAGS="${CMAKE_LDFLAGS} -stdlib=libc++"

	export CXX=clang++
	export CC=clang
fi

rm -rf thirdparty/gatb-core
git clone https://github.com/GATB/gatb-core.git thirdparty/gatb-core

cd thirdparty/gatb-core
git checkout e80aa72fc91bac58de11341b536c3a94ecb54719
cd ../..

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_C_COMPILER="$CC" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	-DSYSTEM_HTSLIB=1 \
	-DCMAKE_INSTALL_PREFIX="$PREFIX" \
	"${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/Gap2Seq-core build/GapCutter build/GapMerger build/ReadFilter build/Gap2Seq "${PREFIX}/bin"

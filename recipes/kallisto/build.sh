#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

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

cd ext/htslib || exit 1
autoreconf -if
./configure
cd ../.. || exit 1

case $(uname -m) in
    x86_64)
	ARCH_OPTS="-DENABLE_AVX2=OFF -DCOMPILATION_ARCH=OFF"
	;;
    aarch64)
	ARCH_OPTS="-DCOMPILATION_ARCH=OFF"
	;;
    arm64)
	ARCH_OPTS="-DCOMPILATION_ARCH=ON"
	;;
    *)
	;;
esac

if [[ "$(uname -s)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS="-DZLIBNG=ON"
fi

if [[ "$(uname -m)" == "arm64" ]]; then
	sed -i.bak 's|-mno-avx2||' ext/bifrost/CMakeLists.txt
	rm -rf ext/bifrost/*.bak
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DUSE_HDF5=ON -DUSE_BAM=ON -DBUILD_FUNCTESTING=ON -DMAX_KMER_SIZE=64 \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${ARCH_OPTS}" \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install

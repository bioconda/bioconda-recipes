#!/bin/bash -ex

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64"

ARCH=$(uname -m)

case "${ARCH}" in
	x86_64) ARCH_FLAGS="-DCOMPILATION_ARCH=OFF" ;;
	aarch64) ARCH_FLAGS="-DCOMPILATION_ARCH=OFF" ;;
	*) ARCH_FLAGS="-DCOMPILATION_ARCH=ON" ;;
esac

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

if [[ `uname -s` == Darwin ]]; then
	export CONFIG_ARGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
else
	export CONFIG_ARGS="-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake"
fi

cmake -S . -B build -G Ninja \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${ARCH_FLAGS}" \
	"${CONFIG_ARGS}"

ninja -C build install -j "${CPU_COUNT}"

#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-ignored-optimization-argument"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -fopenmp"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CPATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export LDFLAGS="${LDFLAGS} -Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs -Wl,-rpath,${PREFIX}/lib"
else
	export CONFIG_ARGS=""
fi

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

rm -rf build

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

ninja -C build -j "${CPU_COUNT}" install

#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export EXTRA_FLAGS="-Ofast -pipe -funroll-all-loops"

case $(uname -m) in
    aarch64)
	export EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8-a";;
    arm64)
	export EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8.4-a";;
    x86_64)
	export EXTRA_FLAGS="${EXTRA_FLAGS} -march=x86-64-v3";;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DBUILD_STATIC=0 -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS="-DBUILD_STATIC=1"
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Generic \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
 	-DCMAKE_C_FLAGS="${CFLAGS}" -DEXTRA_FLAGS="${EXTRA_FLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"

PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
mkdir -p "${SP_DIR}"

cp -rf lib/*cpython* "${SP_DIR}"
cp -rf lib/* "${PREFIX}/lib"

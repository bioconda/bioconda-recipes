#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
EXTRA_FLAGS="-Ofast"

case $(uname -m) in
    aarch64)
	EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8-a"
	;;
    arm64)
	EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8.4-a"
	;;
    x86_64)
	EXTRA_FLAGS="${EXTRA_FLAGS} -march=x86-64-v3"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DBUILD_STATIC=0 -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS="-DBUILD_STATIC=1"
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Generic \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DEXTRA_FLAGS="${EXTRA_FLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"

PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
mkdir -p "${PREFIX}/lib/python${PYVER}/site-packages"

cp -rf lib/*cpython* "${PREFIX}/lib/python${PYVER}/site-packages"
cp -rf lib/* "${PREFIX}/lib"

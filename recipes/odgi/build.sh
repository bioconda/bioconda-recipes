#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"

export INCLUDES="-I${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export EXTRA_FLAGS="-Ofast -pipe -funroll-all-loops"

case $(uname -m) in
    aarch64)
	export EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8-a"
 	sed -i.bak 's|arch=x86-64|arch=armv8-a|' src/main.cpp
 	;;
    arm64)
	export EXTRA_FLAGS="${EXTRA_FLAGS} -march=armv8.4-a"
 	sed -i.bak 's|arch=x86-64|arch=armv8.4-a|' src/main.cpp
 	;;
    x86_64)
	export EXTRA_FLAGS="${EXTRA_FLAGS} -march=x86-64-v3"
	sed -i.bak 's|arch=x86-64|arch=x86-64-v3|' src/main.cpp
	;;
esac
rm -rf src/*.bak

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
mkdir -p "${PREFIX}/lib/python${PYVER}/site-packages"

cp -rf lib/*cpython* "${PREFIX}/lib/python${PYVER}/site-packages"
cp -rf lib/* "${PREFIX}/lib"

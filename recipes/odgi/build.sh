#!/bin/bash

mkdir -p $PREFIX/bin

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

sed -i.bak -e 's|VERSION 3.16|VERSION 3.5|' CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6 FATAL_ERROR|VERSION 3.5|' deps/libbf/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.1|VERSION 3.5|' deps/mmmulti/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.1|VERSION 3.5|' deps/atomicbitvector/CMakeLists.txt
sed -i.bak -e 's|VERSION 3.2|VERSION 3.5|' deps/args/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.8.11|VERSION 3.5|' deps/sdsl-lite/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.4.4|VERSION 3.5|' deps/sdsl-lite/external/libdivsufsort/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/sdsl-lite/external/googletest/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/sdsl-lite/external/googletest/googletest/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' deps/sdsl-lite/external/googletest/googlemock/CMakeLists.txt

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Generic \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DEXTRA_FLAGS='-march=sandybridge -Ofast' \
	-Wno-dev "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}"

PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
mkdir -p "${PREFIX}/lib/python${PYVER}/site-packages"
cp -rf lib/*cpython* "${PREFIX}/lib/python${PYVER}/site-packages"
cp -rf lib/* "${PREFIX}/lib"

#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

sed -i.bak 's|VERSION 3.1.0|VERSION 3.5|' subprojects/cpptoml/CMakeLists.txt
sed -i.bak 's|VERSION 2.8.11|VERSION 3.5|' subprojects/sdsl-lite/CMakeLists.txt
rm -rf subprojects/cpptoml/*.bak
rm -rf subprojects/sdsl-lite/*.bak

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" meson setup --buildtype release \
	--prefix "${PREFIX}" --strip -Db_coverage=false \
	-Dcmake_args="${CONFIG_ARGS}" build/

cd build

ninja install -v -j"${CPU_COUNT}"

# python wrappers:
${PYTHON} -m pip install "${PREFIX}/lib/btllib/python" --no-deps --no-build-isolation --no-cache-dir -vvv

#!/bin/bash

export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"

# we can't build bcalm with avaible gatb, link trouble
rm -rf gatb-core
git clone https://github.com/GATB/gatb-core.git
cd gatb-core
git checkout e80aa72fc91bac58de11341b536c3a94ecb54719
cd ..

sed -i.bak 's|VERSION 2.6|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

# avoid gatb example install
if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak "s/.*INSTALL.*examples.*/#&/" gatb-core/gatb-core/CMakeLists.txt
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	sed -i.bak "s/.*INSTALL.*examples.*/#&/" gatb-core/gatb-core/CMakeLists.txt
	export CONFIG_ARGS=""
fi

# build
cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DKSIZE_LIST="32 64 96 128 160 192" -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" -Wno-dev \
	-Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"

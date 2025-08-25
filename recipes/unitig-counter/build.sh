#!/bin/bash

install -d $PREFIX/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
if [[ `uname -s` == "Darwin" ]]; then
    export CFLAGS="${CFLAGS} -Wno-error=int-conversion -Wno-error=implicit-function-declaration"
    export CXXFLAGS="${CXXFLAGS} -Wno-error=int-conversion"
fi

sed -i.bak 's|Boost_USE_STATIC_LIBS   ON|Boost_USE_STATIC_LIBS   OFF|' CMakeLists.txt
sed -i.bak 's|-Wnested-externs -Winline|-Wnested-externs -Winline -Wno-int-conversion -Wno-implicit-function-declaration|' gatb-core/gatb-core/thirdparty/hdf5/config/cmake/HDFCompilerFlags.cmake
rm -rf *.bak

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DBOOST_ROOT="${PREFIX}" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build -j "${CPU_COUNT}"

cd build
install -v -m 0755 unitig-counter cdbg-ops ext/gatb-core/bin/Release/gatb-h5dump $PREFIX/bin

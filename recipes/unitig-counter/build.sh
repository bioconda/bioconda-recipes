#!/bin/bash

install -d $PREFIX/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

sed -i.bak 's|Boost_USE_STATIC_LIBS   ON|Boost_USE_STATIC_LIBS   OFF|' CMakeLists.txt
sed -i.bak 's|FIND_PACKAGE|find_package|' CMakeLists.txt
sed -i.bak 's|-Wnested-externs -Winline|-Wnested-externs -Winline -Wno-int-conversion -Wno-implicit-function-declaration|' gatb-core/gatb-core/thirdparty/hdf5/config/cmake/HDFCompilerFlags.cmake
rm -rf *.bak

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DBOOST_ROOT="${PREFIX}" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_C_FLAGS="${CFLAGS}"
cmake --build build -j 1

cd build
install -v -m 0755 unitig-counter cdbg-ops ext/gatb-core/bin/Release/gatb-h5dump $PREFIX/bin
